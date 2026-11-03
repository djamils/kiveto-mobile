// The domain imports no package (rule 1), so package:meta's @immutable is
// out of reach: the value objects below have only final fields.
// ignore_for_file: avoid_equals_and_hash_code_on_mutable_classes

/// Why a call to the Portal API failed, as the app sees it.
///
/// Repositories **throw** these (no generic `Result`, architecture §3);
/// Riverpod's `AsyncValue.error` carries them to the presentation, which
/// pattern-matches on the subtype and, when it needs to, on [code] (the
/// problem+json `type`, e.g. `slot_taken`). Feature domains may add their
/// own sealed failures on top. The mapping from HTTP lives in `core/`.
sealed class ApiFailure implements Exception {
  const new({this.code, this.detail});

  /// The problem+json `type` (`token_expired`, `slot_taken`…), when the
  /// answer carried one.
  final String? code;

  /// The problem+json `detail`, for diagnostics; never shown as is.
  final String? detail;

  String get _name;

  String get _fields => 'code: $code';

  @override
  String toString() => '$_name($_fields)';
}

/// No usable answer: offline, timeouts, TLS, cancelled.
final class NetworkFailure extends ApiFailure {
  const new({super.code, super.detail});

  @override
  String get _name => 'NetworkFailure';
}

/// 401: the session is missing, expired after a failed refresh, or refused.
final class UnauthorizedFailure extends ApiFailure {
  const new({super.code, super.detail});

  @override
  String get _name => 'UnauthorizedFailure';
}

/// 422 `validation_failed`: the server refused some fields.
final class ValidationFailure extends ApiFailure {
  const new({super.code, super.detail, this.violations = const []});

  final List<Violation> violations;

  @override
  String get _name => 'ValidationFailure';

  @override
  String get _fields => '${super._fields}, violations: $violations';
}

/// 429: a quota is exhausted; [retryAfter] comes from `Retry-After`.
final class RateLimitedFailure extends ApiFailure {
  const new({super.code, super.detail, this.retryAfter});

  final Duration? retryAfter;

  @override
  String get _name => 'RateLimitedFailure';

  @override
  String get _fields => '${super._fields}, retryAfter: $retryAfter';
}

/// 404.
final class NotFoundFailure extends ApiFailure {
  const new({super.code, super.detail});

  @override
  String get _name => 'NotFoundFailure';
}

/// 409: the action conflicts with the current state (`slot_taken`…).
final class ConflictFailure extends ApiFailure {
  const new({super.code, super.detail});

  @override
  String get _name => 'ConflictFailure';
}

/// 5xx, or an answer the app could not use (undecodable, unexpected
/// status).
final class ServerFailure extends ApiFailure {
  const new({super.code, super.detail, this.statusCode, this.retryAfter});

  final int? statusCode;

  /// From `Retry-After` (`503 service_unavailable`).
  final Duration? retryAfter;

  @override
  String get _name => 'ServerFailure';

  @override
  String get _fields =>
      '${super._fields}, statusCode: $statusCode, retryAfter: $retryAfter';
}

/// Any other 4xx: a business refusal named by [code] (`otp_invalid`,
/// `invitation_expired`…).
final class BusinessFailure extends ApiFailure {
  const new({
    required String super.code,
    required this.statusCode,
    super.detail,
  });

  final int statusCode;

  @override
  String get code => super.code!;

  @override
  String get _name => 'BusinessFailure';

  @override
  String get _fields => '${super._fields}, statusCode: $statusCode';
}

/// One refused field of a [ValidationFailure].
final class Violation {
  const new({required this.propertyPath, required this.message, this.code});

  /// The field, as the API names it (`firstName`).
  final String propertyPath;

  /// The server's message, in French.
  final String message;

  final String? code;

  @override
  bool operator ==(Object other) =>
      other is Violation &&
      other.propertyPath == propertyPath &&
      other.message == message &&
      other.code == code;

  @override
  int get hashCode => Object.hash(propertyPath, message, code);

  @override
  String toString() => 'Violation($propertyPath: $message)';
}
