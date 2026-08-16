import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/api_response.dart';
import 'auth_storage.dart';
import 'dummy_api_client.dart';

export '../models/api_response.dart' show ApiResponse, ApiException, ApiErrorCode;

/// Contract shared by the real and the dummy client so [ApiClient] can hold
/// either without the call sites knowing which one is active.
abstract class ApiTransport {
  Future<ApiResponse> get(String path, {Map<String, dynamic>? query, bool auth = true});
  Future<ApiResponse> post(String path, {Object? body, bool auth = true});
  Future<ApiResponse> put(String path, {Object? body, bool auth = true});
  Future<ApiResponse> delete(String path, {Map<String, dynamic>? query, bool auth = true});
  Future<ApiResponse> postMultipart(
    String path,
    Map<String, String> fields,
    Map<String, String> files, {
    bool auth = true,
  });
}

class _RealApiClient implements ApiTransport {
  _RealApiClient(this._client, this._storage);

  final http.Client _client;
  final AuthStorage _storage;

  static const _timeout = Duration(seconds: 20);

  Future<Map<String, String>> _headers({bool auth = true, bool json = true}) async {
    final headers = <String, String>{'Accept': 'application/json'};
    if (json) headers['Content-Type'] = 'application/json';
    if (auth) {
      final token = await _storage.readToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final cleaned = path.startsWith('/') ? path.substring(1) : path;
    final uri = Uri.parse('${AppConfig.baseUrl}/$cleaned');
    print(uri.toString());
    if (query == null || query.isEmpty) return uri;

    final qp = <String, String>{};
    query.forEach((k, v) {
      if (v != null) qp[k] = '$v';
    });
    if (qp.isEmpty) return uri;

    return uri.replace(queryParameters: {...uri.queryParameters, ...qp});
  }

  @override
  Future<ApiResponse> get(String path, {Map<String, dynamic>? query, bool auth = true}) {
    return _send(() async => _client
        .get(_uri(path, query), headers: await _headers(auth: auth))
        .timeout(_timeout));
  }

  @override
  Future<ApiResponse> post(String path, {Object? body, bool auth = true}) {
    return _send(() async => _client
        .post(_uri(path), headers: await _headers(auth: auth), body: jsonEncode(body ?? {}))
        .timeout(_timeout));
  }

  @override
  Future<ApiResponse> put(String path, {Object? body, bool auth = true}) {
    return _send(() async => _client
        .put(_uri(path), headers: await _headers(auth: auth), body: jsonEncode(body ?? {}))
        .timeout(_timeout));
  }

  @override
  Future<ApiResponse> delete(String path, {Map<String, dynamic>? query, bool auth = true}) {
    // The headers were previously omitted here, which made every authenticated
    // DELETE come back as a 401.
    return _send(() async => _client
        .delete(_uri(path, query), headers: await _headers(auth: auth))
        .timeout(_timeout));
  }

  @override
  Future<ApiResponse> postMultipart(
    String path,
    Map<String, String> fields,
    Map<String, String> files, {
    bool auth = true,
  }) {
    return _send(() async {
      final request = http.MultipartRequest('POST', _uri(path))
        ..headers.addAll(await _headers(auth: auth, json: false))
        ..fields.addAll(fields);

      for (final entry in files.entries) {
        request.files.add(await http.MultipartFile.fromPath(entry.key, entry.value));
      }

      final streamed = await request.send().timeout(_timeout);
      return http.Response.fromStream(streamed).timeout(_timeout);
    });
  }

  /// Runs a request and normalizes every possible outcome into the envelope.
  /// Nothing else in the app has to know about sockets, timeouts, or HTML
  /// error pages: it either gets an [ApiResponse] or an [ApiException].
  Future<ApiResponse> _send(Future<http.Response> Function() request) async {
    http.Response res;

    try {
      res = await request();
    } on TimeoutException {
      throw ApiException.network('Server tidak merespons. Silakan coba lagi.');
    } on SocketException {
      throw ApiException.network();
    } on http.ClientException catch (e) {
      throw ApiException.network(e.message.isNotEmpty ? null : e.message);
    } on HandshakeException {
      throw ApiException.network('Koneksi aman ke server gagal dibuat.');
    } on FormatException {
      throw ApiException.network('Alamat server tidak valid.');
    }

    return _decode(res);
  }

  ApiResponse _decode(http.Response res) {
    // 204 and empty bodies are still successes — synthesize the envelope.
    if (res.body.trim().isEmpty) {
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return ApiResponse(status: true, code: res.statusCode, message: 'Berhasil.');
      }
      throw ApiException(res.statusCode, _messageForStatus(res.statusCode));
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(res.body);
    } on FormatException {
      // An HTML error page or a proxy notice — never surface it to the user.
      throw ApiException.malformed(res.statusCode);
    }

    if (decoded is! Map<String, dynamic>) {
      // A bare list is not our envelope, but it is still usable data.
      if (decoded is List && res.statusCode >= 200 && res.statusCode < 300) {
        return ApiResponse(
          status: true,
          code: res.statusCode,
          message: 'Berhasil.',
          data: decoded,
        );
      }
      throw ApiException.malformed(res.statusCode);
    }

    final parsed = ApiResponse.fromJson(decoded, httpCode: res.statusCode);

    // Both signals must agree before the call counts as a success, so a body
    // that says `status: false` with a 200 is still treated as a failure.
    final httpOk = res.statusCode >= 200 && res.statusCode < 300;
    if (!parsed.status || !httpOk) {
      throw ApiException.fromResponse(parsed);
    }

    return parsed;
  }

  String _messageForStatus(int status) {
    if (status == 401) return 'Sesi Anda telah berakhir. Silakan masuk kembali.';
    if (status == 403) return 'Anda tidak memiliki akses ke data ini.';
    if (status == 404) return 'Data yang diminta tidak ditemukan.';
    if (status == 429) return 'Terlalu banyak permintaan. Coba lagi sebentar lagi.';
    if (status >= 500) return 'Terjadi kesalahan pada server. Silakan coba lagi.';
    return 'Permintaan gagal diproses ($status).';
  }
}

/// HTTP wrapper around the Laravel API. Attaches the Sanctum bearer token,
/// parses the response envelope, and turns every failure — HTTP, transport, or
/// `status: false` — into an [ApiException].
///
/// Swaps to [DummyApiClient] when `AppConfig.dummy` is set, which serves the
/// same envelope from local JSON assets.
class ApiClient implements ApiTransport {
  ApiClient({http.Client? client, AuthStorage? storage, ApiTransport? transport})
      : _impl = transport ??
            (AppConfig.dummy
                ? DummyApiClient()
                : _RealApiClient(client ?? http.Client(), storage ?? AuthStorage()));

  final ApiTransport _impl;

  @override
  Future<ApiResponse> get(String path, {Map<String, dynamic>? query, bool auth = true}) =>
      _impl.get(path, query: query, auth: auth);

  @override
  Future<ApiResponse> post(String path, {Object? body, bool auth = true}) =>
      _impl.post(path, body: body, auth: auth);

  @override
  Future<ApiResponse> put(String path, {Object? body, bool auth = true}) =>
      _impl.put(path, body: body, auth: auth);

  @override
  Future<ApiResponse> delete(String path, {Map<String, dynamic>? query, bool auth = true}) =>
      _impl.delete(path, query: query, auth: auth);

  @override
  Future<ApiResponse> postMultipart(
    String path,
    Map<String, String> fields,
    Map<String, String> files, {
    bool auth = true,
  }) =>
      _impl.postMultipart(path, fields, files, auth: auth);
}
