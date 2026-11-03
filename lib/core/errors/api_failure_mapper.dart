import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';
import 'package:kiveto_mobile/shared/domain/clock.dart';

/// Turns what Dio reports into an [ApiFailure] (the pure model lives in
/// `shared/domain/`; the tonik-level mapping in
/// `core/network/portal_results.dart`, rule 7 keeping tonik_util out of
/// here).
///
/// The problem+json body gives the `type` (the failure's `code`), the
/// `detail` and the `violations`; the status picks the subtype.
final class ApiFailureMapper {
  const new({required this._clock});

  final Clock _clock;

  /// A [DioException]: a response (strict status, see
  /// `StrictStatusInterceptor`) is mapped by [fromResponse]; no response is
  /// a [NetworkFailure].
  ApiFailure fromDio(DioException exception) {
    final response = exception.response;
    switch (exception.type) {
      case DioExceptionType.badResponse || DioExceptionType.unknown
          when response != null:
        return fromResponse(
          statusCode: response.statusCode,
          body: response.data,
          headers: response.headers.map,
        );
      case DioExceptionType.connectionTimeout ||
          DioExceptionType.sendTimeout ||
          DioExceptionType.receiveTimeout ||
          DioExceptionType.transformTimeout ||
          DioExceptionType.connectionError ||
          DioExceptionType.badCertificate ||
          DioExceptionType.cancel ||
          DioExceptionType.badResponse ||
          DioExceptionType.unknown:
        return const NetworkFailure();
    }
  }

  /// An answer with [statusCode], its raw [body] (bytes, a string or a
  /// decoded map) and its [headers].
  ApiFailure fromResponse({
    required int? statusCode,
    required Object? body,
    required Map<String, List<String>> headers,
  }) {
    final problem = problemOf(body);
    final code = problem?['type'] is String
        ? problem!['type']! as String
        : null;
    final detail = problem?['detail'] is String
        ? problem!['detail']! as String
        : null;
    final status = statusCode;
    if (status == null || status < 400) {
      return ServerFailure(code: code, detail: detail, statusCode: status);
    }
    if (status >= 500) {
      return ServerFailure(
        code: code,
        detail: detail,
        statusCode: status,
        retryAfter: _retryAfter(headers),
      );
    }
    return switch (status) {
      401 => UnauthorizedFailure(code: code, detail: detail),
      404 => NotFoundFailure(code: code, detail: detail),
      409 => ConflictFailure(code: code, detail: detail),
      422 when code == 'validation_failed' => ValidationFailure(
        code: code,
        detail: detail,
        violations: _violationsOf(problem),
      ),
      429 => RateLimitedFailure(
        code: code,
        detail: detail,
        retryAfter: _retryAfter(headers),
      ),
      _ => BusinessFailure(
        code: code ?? 'http_$status',
        statusCode: status,
        detail: detail,
      ),
    };
  }

  /// The decoded problem+json object of a raw [body] (bytes, a string or a
  /// decoded map), or null when it is not a JSON object.
  static Map<String, Object?>? problemOf(Object? body) {
    try {
      final decoded = switch (body) {
        final Map<String, Object?> map => map,
        final String text => jsonDecode(text),
        final List<int> bytes => jsonDecode(utf8.decode(bytes)),
        _ => null,
      };
      return decoded is Map<String, Object?> ? decoded : null;
    } on FormatException {
      return null;
    }
  }

  static List<Violation> _violationsOf(Map<String, Object?>? problem) => [
    if (problem?['violations'] case final List<Object?> violations)
      for (final violation in violations)
        if (violation case {
          'propertyPath': final String propertyPath,
          'message': final String message,
        })
          Violation(
            propertyPath: propertyPath,
            message: message,
            code: violation['code'] is String
                ? violation['code']! as String
                : null,
          ),
  ];

  /// `Retry-After` (any case): whole seconds, else an HTTP-date minus now
  /// (never negative), else null.
  Duration? _retryAfter(Map<String, List<String>> headers) {
    final value = [
      for (final MapEntry(:key, :value) in headers.entries)
        if (key.toLowerCase() == 'retry-after') ...value,
    ].firstOrNull?.trim();
    if (value == null) return null;
    final seconds = int.tryParse(value);
    if (seconds != null) {
      return seconds < 0 ? null : Duration(seconds: seconds);
    }
    try {
      final wait = HttpDate.parse(value).difference(_clock.now());
      return wait.isNegative ? Duration.zero : wait;
    } on HttpException {
      return null;
    }
  }
}
