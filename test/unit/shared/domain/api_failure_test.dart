import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';

void main() {
  test('each failure describes itself for diagnostics', () {
    const violation = Violation(
      propertyPath: 'firstName',
      message: 'Le prénom ne peut pas être vide.',
      code: 'c1',
    );
    final failures = <ApiFailure>[
      const NetworkFailure(),
      const UnauthorizedFailure(code: 'token_expired', detail: 'expired'),
      const ValidationFailure(
        code: 'validation_failed',
        violations: [violation],
      ),
      const RateLimitedFailure(
        code: 'otp_rate_limited',
        retryAfter: Duration(seconds: 120),
      ),
      const NotFoundFailure(code: 'not_found'),
      const ConflictFailure(code: 'slot_taken'),
      const ServerFailure(statusCode: 503, retryAfter: Duration(seconds: 30)),
      const BusinessFailure(code: 'otp_invalid', statusCode: 422),
    ];

    const validation =
        'ValidationFailure(code: validation_failed, violations: '
        '[Violation(firstName: Le prénom ne peut pas être vide.)])';
    expect(failures.map((failure) => '$failure'), [
      'NetworkFailure(code: null)',
      'UnauthorizedFailure(code: token_expired)',
      validation,
      'RateLimitedFailure(code: otp_rate_limited, retryAfter: 0:02:00.000000)',
      'NotFoundFailure(code: not_found)',
      'ConflictFailure(code: slot_taken)',
      'ServerFailure(code: null, statusCode: 503, retryAfter: 0:00:30.000000)',
      'BusinessFailure(code: otp_invalid, statusCode: 422)',
    ]);
    expect(failures[1].detail, 'expired');
    expect(failures, everyElement(isA<Exception>()));
  });

  test('a business failure always has a code', () {
    const failure = BusinessFailure(
      code: 'invitation_expired',
      statusCode: 410,
    );

    expect(failure.code, 'invitation_expired');
    expect(failure.statusCode, 410);
  });

  test('violations compare by value', () {
    const a = Violation(propertyPath: 'email', message: 'Invalide.');

    expect(a, const Violation(propertyPath: 'email', message: 'Invalide.'));
    expect(
      a.hashCode,
      const Violation(propertyPath: 'email', message: 'Invalide.').hashCode,
    );
    expect(a, isNot(const Violation(propertyPath: 'phone', message: 'X')));
    expect(a == Object(), isFalse);
    expect(a.code, isNull);
  });
}
