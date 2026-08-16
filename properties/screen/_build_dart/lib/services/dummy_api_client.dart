import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/api_response.dart';
import 'api_client.dart' show ApiTransport;

/// A failure the dummy client should return instead of the fixture, so every
/// error path in the UI can be exercised without a server.
class DummyFailure {
  const DummyFailure({
    required this.code,
    required this.message,
    this.errors,
    this.errorCode,
  });

  const DummyFailure.network()
    : code = 0,
      message =
          'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      errors = null,
      errorCode = ApiErrorCode.network;

  const DummyFailure.validation(
    this.errors, {
    this.message = 'Data yang dikirim tidak valid.',
  }) : code = 422,
       errorCode = ApiErrorCode.validation;

  const DummyFailure.unauthenticated()
    : code = 401,
      message = 'Sesi Anda telah berakhir. Silakan masuk kembali.',
      errors = null,
      errorCode = ApiErrorCode.unauthenticated;

  const DummyFailure.server()
    : code = 500,
      message = 'Terjadi kesalahan pada server. Silakan coba lagi.',
      errors = null,
      errorCode = ApiErrorCode.server;

  final int code;
  final String message;
  final Map<String, dynamic>? errors;
  final String? errorCode;

  ApiException toException() => ApiException(code, message, errors, errorCode);
}

/// Serves the response envelope from local JSON assets.
///
/// Routes are matched against an explicit table rather than guessed from the
/// path, so a call the fixtures do not cover fails as a 404 envelope instead of
/// silently resolving to an empty map — the old behaviour, which turned a
/// missing fixture into a confusing parse error further up the stack.
class DummyApiClient implements ApiTransport {
  DummyApiClient({this.latency = const Duration(milliseconds: 300)});

  final Duration latency;

  /// Fails the next matching request. Key is `'METHOD path'` with the literal
  /// path (e.g. `'POST bookings'`); `'*'` matches every request.
  static final Map<String, DummyFailure> failures = <String, DummyFailure>{};

  /// When set, every request fails with this. Useful for offline-banner work.
  static DummyFailure? globalFailure;

  /// Route table: `'METHOD template'` -> fixture basename. `{id}` matches any
  /// single segment. Order matters — the first match wins, so literal routes
  /// are listed before their `{id}` siblings.
  static const Map<String, String> routes = <String, String>{
    'POST auth/register': 'POST_auth_register',
    'POST auth/login': 'POST_auth_login',
    'POST auth/logout': 'POST_auth_logout',
    'GET auth/me': 'GET_auth_me',

    'GET remote-config': 'GET_remote_config',
    'GET remote-config/{id}': 'GET_remote_config_key',

    'GET home': 'GET_home',
    'GET faqs': 'GET_faqs',
    'GET cms/{id}': 'GET_cms_slug',

    'GET cities': 'GET_cities',
    'GET cities/{id}': 'GET_cities_id',

    'GET properties': 'GET_properties',
    'GET properties/{id}': 'GET_properties_id',
    'GET properties/{id}/detail': 'GET_properties_id_detail',
    'GET properties/{id}/pricing': 'GET_properties_id_pricing',
    'GET properties/{id}/reviews': 'GET_properties_id_reviews',
    'GET properties/{id}/availability': 'GET_properties_id_availability',
    'GET properties/{id}/host': 'GET_properties_id_host',

    // Hotel OTA
    'GET hotels': 'GET_hotels',
    'GET hotels/{id}': 'GET_hotels_id',

    'GET profile': 'GET_profile',
    'PUT profile': 'PUT_profile',
    'POST profile/become-host': 'POST_profile_become_host',
    'GET user/validation': 'GET_user_validation',
    'POST user/validation': 'POST_user_validation',

    'GET wishlists': 'GET_wishlists',
    'POST wishlists/{id}': 'POST_wishlists_id',
    'DELETE wishlists/{id}': 'DELETE_wishlists_id',

    'GET vouchers': 'GET_vouchers',
    'POST vouchers/apply': 'POST_vouchers_apply',

    'GET insurance/plans': 'GET_insurance_plans',

    'GET conversations': 'GET_conversations',
    'POST conversations': 'POST_conversations',
    'GET conversations/{id}/messages': 'GET_conversations_id_messages',
    'POST conversations/{id}/messages': 'POST_conversations_id_messages',

    'GET host/dashboard': 'GET_host_dashboard',
    'GET host/properties': 'GET_host_properties',
    'POST host/properties': 'POST_host_properties',
    'PUT host/properties/{id}': 'PUT_host_properties_id',
    'POST host/properties/gallery/upload':
        'POST_host_properties_gallery_upload',
    'DELETE host/properties/gallery': 'DELETE_host_properties_gallery',
    'DELETE host/properties/{id}/gallery': 'DELETE_host_properties_id_gallery',
  };

  /// Required fields per route, mirroring the Laravel validation rules. The
  /// fixtures would otherwise happily accept a request the real API rejects,
  /// which is how the `amount`/`subtotal` and `token`/`fcm_token` mismatches
  /// went unnoticed.
  static const Map<String, List<String>>
  requiredFields = <String, List<String>>{
    'POST auth/register': ['name', 'email', 'password'],
    'POST auth/login': ['email', 'password'],
    // `duration_type` is nullable server-side (hotel bookings are always daily) and
    // the property is identified by either `property_id` or `hotel_id` — see
    // [eitherOrFields].
    'POST bookings': ['check_in', 'check_out'],
    'POST vouchers/apply': ['code', 'subtotal'],
    'POST orders/{id}/pay': ['method'],
    'POST bookings/{id}/review': ['rating'],
    'POST devices/fcm-token': ['fcm_token'],
    'POST conversations': ['recipient_id'],
    'POST host/withdrawals': [
      'amount',
      'bank_name',
      'bank_account_number',
      'bank_account_name',
    ],
  };

  /// Groups where the API accepts any one member. `POST bookings` resolves the
  /// property from `property_id` (unit booking) **or** `hotel_id` (hotel booking),
  /// so requiring either one alone would reject a legitimate request.
  static const Map<String, List<List<String>>> eitherOrFields =
      <String, List<List<String>>>{
        'POST bookings': [
          ['property_id', 'hotel_id'],
        ],
      };

  @override
  Future<ApiResponse> get(
    String path, {
    Map<String, dynamic>? query,
    bool auth = true,
  }) => _handle('GET', path, null);

  @override
  Future<ApiResponse> post(String path, {Object? body, bool auth = true}) =>
      _handle('POST', path, _asMap(body));

  @override
  Future<ApiResponse> put(String path, {Object? body, bool auth = true}) =>
      _handle('PUT', path, _asMap(body));

  @override
  Future<ApiResponse> delete(
    String path, {
    Map<String, dynamic>? query,
    bool auth = true,
  }) => _handle('DELETE', path, null);

  @override
  Future<ApiResponse> postMultipart(
    String path,
    Map<String, String> fields,
    Map<String, String> files, {
    bool auth = true,
  }) => _handle('POST', path, {...fields, ...files});

  Future<ApiResponse> _handle(
    String method,
    String path,
    Map<String, dynamic>? body,
  ) async {
    if (latency > Duration.zero) await Future<void>.delayed(latency);

    final cleaned = path.replaceAll(RegExp(r'^/+|/+$'), '');

    final failure =
        globalFailure ?? failures.remove('$method $cleaned') ?? failures['*'];
    if (failure != null) throw failure.toException();

    final template = _matchRoute(method, cleaned);
    if (template == null) {
      throw ApiException(
        404,
        'Endpoint dummy tidak tersedia: $method /$cleaned',
        null,
        ApiErrorCode.notFound,
      );
    }

    final missing = _missingFields(template, body);
    if (missing.isNotEmpty) {
      throw ApiException(
        422,
        'Data yang dikirim tidak valid.',
        missing,
        ApiErrorCode.validation,
      );
    }

    return _loadEnvelope(routes[template]!, method);
  }

  Map<String, dynamic>? _asMap(Object? body) =>
      body is Map ? Map<String, dynamic>.from(body) : null;

  Map<String, dynamic> _missingFields(
    String template,
    Map<String, dynamic>? body,
  ) {
    final required = requiredFields[template];
    final groups = eitherOrFields[template];
    if (required == null && groups == null) return const <String, dynamic>{};

    bool blank(String field) {
      final value = body?[field];
      return value == null || (value is String && value.trim().isEmpty);
    }

    final errors = <String, dynamic>{};
    for (final field in required ?? const <String>[]) {
      if (blank(field)) {
        errors[field] = <String>['Kolom $field wajib diisi.'];
      }
    }

    for (final group in groups ?? const <List<String>>[]) {
      if (group.every(blank)) {
        errors[group.first] = <String>[
          'Salah satu dari ${group.join(' / ')} wajib diisi.',
        ];
      }
    }

    return errors;
  }

  /// Matches `method` + `path` against [routes]. Literal segments win over
  /// `{id}` so `payments/methods` never resolves to `payments/{id}`.
  String? _matchRoute(String method, String path) {
    final segments = path.split('/').where((s) => s.isNotEmpty).toList();

    String? wildcardMatch;

    for (final template in routes.keys) {
      final parts = template.split(' ');
      if (parts.first != method) continue;

      final pattern = parts.last.split('/').where((s) => s.isNotEmpty).toList();
      if (pattern.length != segments.length) continue;

      var exact = true;
      var matches = true;

      for (var i = 0; i < pattern.length; i++) {
        if (pattern[i] == '{id}') {
          exact = false;
          continue;
        }
        if (pattern[i] != segments[i]) {
          matches = false;
          break;
        }
      }

      if (!matches) continue;
      if (exact) return template;
      wildcardMatch ??= template;
    }

    return wildcardMatch;
  }

  Future<ApiResponse> _loadEnvelope(String basename, String method) async {
    final assetPath = 'assets/json/$basename.json';

    String raw;
    try {
      raw = await rootBundle.loadString(assetPath);
    } catch (_) {
      throw ApiException(
        404,
        'Fixture tidak ditemukan: $assetPath',
        null,
        ApiErrorCode.notFound,
      );
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException catch (e) {
      throw ApiException(
        500,
        'Fixture $assetPath bukan JSON yang valid: ${e.message}',
        null,
        ApiErrorCode.malformed,
      );
    }

    if (decoded is! Map<String, dynamic>) {
      // A fixture that is a bare list is still usable as the payload.
      return ApiResponse(
        status: true,
        code: 200,
        message: 'Berhasil.',
        data: decoded,
      );
    }

    final parsed = ApiResponse.fromJson(
      decoded,
      httpCode: method == 'POST' ? 201 : 200,
    );

    // Fixtures can encode failures too, so the UI's error branches can be
    // demoed by editing the asset alone.
    if (!parsed.status) throw ApiException.fromResponse(parsed);

    return parsed;
  }
}
