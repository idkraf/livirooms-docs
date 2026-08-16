/// Error identifiers emitted by the Laravel `ApiResponse` helper. Branch on
/// these instead of on message strings, which are localized and may change.
class ApiErrorCode {
  ApiErrorCode._();

  static const String validation = 'validation_error';
  static const String unauthenticated = 'unauthenticated';
  static const String forbidden = 'forbidden';
  static const String notFound = 'not_found';
  static const String methodNotAllowed = 'method_not_allowed';
  static const String conflict = 'conflict';
  static const String unprocessable = 'unprocessable';
  static const String rateLimited = 'rate_limited';
  static const String server = 'server_error';
  static const String gateway = 'gateway_error';

  /// Client-side only: the request never reached the server.
  static const String network = 'network_error';

  /// Client-side only: the server answered with something that is not the
  /// envelope (an HTML error page, a proxy notice, a truncated body).
  static const String malformed = 'malformed_response';
}

/// The single response shape every endpoint returns.
///
///     { status, code, message, data, meta, errors, error_code }
///
/// `status` is the only branch point the app needs: it is `true` for success
/// and `false` for every failure, whether the failure came from validation,
/// from an exception, or from the dummy client.
class ApiResponse {
  const ApiResponse({
    required this.status,
    required this.code,
    required this.message,
    this.data,
    this.meta,
    this.errors,
    this.errorCode,
  });

  final bool status;
  final int code;
  final String message;
  final dynamic data;
  final Map<String, dynamic>? meta;
  final Map<String, dynamic>? errors;
  final String? errorCode;

  /// Parses the envelope. A body that is missing `status` is still accepted so
  /// a partially-migrated endpoint degrades instead of throwing: the HTTP code
  /// decides, and `data` falls back to the whole body.
  factory ApiResponse.fromJson(Map<String, dynamic> json, {int? httpCode}) {
    final hasEnvelope = json.containsKey('status') && json['status'] is bool;
    final code = _int(json['code']) ?? httpCode ?? 200;

    return ApiResponse(
      status: hasEnvelope ? json['status'] as bool : (code >= 200 && code < 300),
      code: code,
      message: json['message'] is String ? json['message'] as String : '',
      data: hasEnvelope || json.containsKey('data') ? json['data'] : json,
      meta: json['meta'] is Map ? Map<String, dynamic>.from(json['meta'] as Map) : null,
      errors: json['errors'] is Map ? Map<String, dynamic>.from(json['errors'] as Map) : null,
      errorCode: json['error_code'] as String?,
    );
  }

  /// `data` as an object. Empty map when the payload is a list or null, so
  /// callers can index it without a null check.
  Map<String, dynamic> get dataMap =>
      data is Map ? Map<String, dynamic>.from(data as Map) : const <String, dynamic>{};

  /// `data` as a list. Also unwraps `data.data`, which is what a Laravel
  /// resource collection produces when it is nested inside the envelope.
  List<dynamic> get dataList {
    if (data is List) return data as List<dynamic>;
    if (data is Map && (data as Map)['data'] is List) {
      return (data as Map)['data'] as List<dynamic>;
    }
    return const <dynamic>[];
  }

  /// Objects out of [dataList], skipping any entry that is not a map.
  List<Map<String, dynamic>> get dataObjects => dataList
      .whereType<Map>()
      .map((e) => Map<String, dynamic>.from(e))
      .toList(growable: false);

  T? metaValue<T>(String key) {
    final value = meta?[key];
    return value is T ? value : null;
  }

  int metaInt(String key, [int fallback = 0]) => _int(meta?[key]) ?? fallback;

  static int? _int(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }
}

/// Thrown for every failed call — HTTP error, `status: false`, transport
/// failure, or unparseable body — so callers have exactly one thing to catch.
class ApiException implements Exception {
  ApiException(
    this.statusCode,
    this.message, [
    this.errors,
    this.errorCode,
  ]);

  /// The request never reached the server (no connection, DNS, TLS, timeout).
  factory ApiException.network([String? message]) => ApiException(
        0,
        message ?? 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
        null,
        ApiErrorCode.network,
      );

  factory ApiException.malformed(int statusCode) => ApiException(
        statusCode,
        'Respons server tidak dapat dibaca. Silakan coba lagi.',
        null,
        ApiErrorCode.malformed,
      );

  factory ApiException.fromResponse(ApiResponse res) => ApiException(
        res.code,
        res.message.isNotEmpty ? res.message : 'Permintaan gagal diproses.',
        res.errors,
        res.errorCode,
      );

  final int statusCode;
  final String message;
  final Map<String, dynamic>? errors;
  final String? errorCode;

  bool get isNetwork => errorCode == ApiErrorCode.network;
  bool get isValidation => statusCode == 422 || errorCode == ApiErrorCode.validation;
  bool get isUnauthenticated => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isConflict => statusCode == 409;
  bool get isRateLimited => statusCode == 429;
  bool get isServer => statusCode >= 500;

  /// True when retrying the same request could plausibly succeed.
  bool get isRetryable => isNetwork || isServer || isRateLimited;

  /// First validation message for [field], for inline form errors.
  String? fieldError(String field) {
    final value = errors?[field];
    if (value is List && value.isNotEmpty) return '${value.first}';
    if (value is String) return value;
    return null;
  }

  /// Every validation message flattened, for a summary banner.
  List<String> get allErrors {
    final out = <String>[];
    errors?.forEach((_, value) {
      if (value is List) {
        out.addAll(value.map((e) => '$e'));
      } else if (value is String) {
        out.add(value);
      }
    });
    return out;
  }

  /// Screens interpolate the exception straight into snackbars, so this is the
  /// user-facing message only. Use [debugString] for diagnostics.
  @override
  String toString() => message;

  String get debugString => 'ApiException($statusCode, $errorCode): $message';
}
