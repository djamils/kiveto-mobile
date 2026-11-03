// PortalAccountSecurityRepository on the real chain and the captures: the
// e-mail change (the SMS code, the code sent to the address, the
// verification) and the deletion (its code, its 202 without body); the
// refusals by their problem type.

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/features/identity_access/domain/otp_challenge.dart';
import 'package:kiveto_mobile/features/identity_access/infrastructure/portal_account_security_repository.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';

import '../../../../support/fakes.dart';
import '../../../../support/portal_api/fake_portal_backend.dart';
import '../../../../support/portal_api/portal_http_harness.dart';

const _emailOtp = '$api/me/email-change/otp';
const _emailChange = '$api/me/email-change';
const _emailVerify = '$api/me/email-change/verify';
const _deletionOtp = '$api/me/deletion-request/otp';
const _deletion = '$api/me/deletion-request';

Map<String, Object?> _body(PortalRequest request) =>
    jsonDecode(utf8.decode(request.body)) as Map<String, Object?>;

Matcher _business(String code) => isA<BusinessFailure>()
    .having((failure) => failure.code, 'code', code)
    .having((failure) => failure.statusCode, 'statusCode', 422);

void main() {
  late PortalHarness harness;
  late PortalAccountSecurityRepository repository;

  setUp(() async {
    harness = await PortalHarness.create(tokens: pair('A'));
    repository = PortalAccountSecurityRepository(
      harness.http.server,
      harness.failures,
    );
  });

  group('the e-mail change', () {
    test('the SMS code (capture): its challenge in UTC', () async {
      harness.backend.on(
        'POST',
        _emailOtp,
        PortalReply.fixture('me.email-change.otp.post.202.json', status: 202),
      );

      final challenge = await repository.requestEmailChangeCode();

      expect(
        challenge,
        OtpChallenge(
          id: '01a1a363-dc7d-7157-9dfb-7ad4ffa5945e',
          expiresAt: DateTime.utc(2026, 11, 3, 21, 59, 53),
          resendAvailableAt: DateTime.utc(2026, 11, 3, 21, 50, 23),
        ),
      );
      expect(challenge.expiresAt.isUtc, isTrue);
      expect(bearerOf(harness.backend.requests.single), 'Bearer A');
    });

    test('the SMS code: 429 otp_rate_limited', () async {
      harness.backend.on('POST', _emailOtp, problem('otp_rate_limited', 429));

      await expectLater(
        repository.requestEmailChangeCode(),
        throwsA(isA<RateLimitedFailure>()),
      );
    });

    test('the address (capture): the SMS code and the address sent, the '
        'e-mail challenge answered', () async {
      harness.backend.on(
        'POST',
        _emailChange,
        PortalReply.fixture('me.email-change.post.202.json', status: 202),
      );

      final id = await repository.startEmailChange(
        challengeId: 'sms-challenge',
        code: '123456',
        email: 'zoe.essai@example.com',
      );

      expect(id, '01a1a364-15fd-71ad-9a43-0146dbcad996');
      expect(_body(harness.backend.requests.single), {
        'challengeId': 'sms-challenge',
        'code': '123456',
        'email': 'zoe.essai@example.com',
      });
    });

    test('the address: a wrong SMS code (capture), a refused address '
        '(capture)', () async {
      harness.backend.on(
        'POST',
        _emailChange,
        PortalReply.fixture(
          'me.email-change.otp-invalid.post.422.json',
          status: 422,
        ),
      );
      await expectLater(
        repository.startEmailChange(
          challengeId: 'c',
          code: '000000',
          email: 'a@b.fr',
        ),
        throwsA(_business('otp_invalid')),
      );

      harness.backend.on(
        'POST',
        _emailChange,
        PortalReply.fixture(
          'me.email-change.validation.post.422.json',
          status: 422,
        ),
      );
      await expectLater(
        repository.startEmailChange(
          challengeId: 'c',
          code: '123456',
          email: 'a@',
        ),
        throwsA(
          isA<ValidationFailure>().having(
            (failure) => failure.violations.single.propertyPath,
            'propertyPath',
            'email',
          ),
        ),
      );
    });

    test(
      'the verification (capture): the e-mail challenge and its code',
      () async {
        harness.backend.on(
          'POST',
          _emailVerify,
          PortalReply.fixture('me.email-change.verify.post.200.json'),
        );

        await repository.verifyEmail(
          challengeId: 'email-challenge',
          code: '654321',
        );

        expect(_body(harness.backend.requests.single), {
          'challengeId': 'email-challenge',
          'code': '654321',
        });
      },
    );

    test('the verification: a wrong code (capture), email_taken', () async {
      harness.backend.on(
        'POST',
        _emailVerify,
        PortalReply.fixture(
          'me.email-change.verify.otp-invalid.post.422.json',
          status: 422,
        ),
      );
      await expectLater(
        repository.verifyEmail(challengeId: 'c', code: '000000'),
        throwsA(_business('otp_invalid')),
      );

      harness.backend.on('POST', _emailVerify, problem('email_taken', 422));
      await expectLater(
        repository.verifyEmail(challengeId: 'c', code: '123456'),
        throwsA(_business('email_taken')),
      );
    });
  });

  group('the deletion', () {
    test('the SMS code (capture): its challenge in UTC', () async {
      harness.backend.on(
        'POST',
        _deletionOtp,
        PortalReply.fixture(
          'me.deletion-request.otp.post.202.json',
          status: 202,
        ),
      );

      final challenge = await repository.requestDeletionCode();

      expect(challenge.id, '01a1a364-f91f-7dd0-8637-861f9ac73106');
      expect(challenge.expiresAt, DateTime.utc(2026, 11, 3, 22, 1, 6));
      expect(
        challenge.resendAvailableAt,
        DateTime.utc(2026, 11, 3, 21, 51, 36),
      );
    });

    test('the SMS code: 429 otp_rate_limited', () async {
      harness.backend.on(
        'POST',
        _deletionOtp,
        problem('otp_rate_limited', 429),
      );

      await expectLater(
        repository.requestDeletionCode(),
        throwsA(isA<RateLimitedFailure>()),
      );
    });

    test('the confirmation: 202 without body, the challenge and code '
        'sent', () async {
      harness.backend.on('POST', _deletion, PortalReply.empty(202));

      await repository.confirmDeletion(challengeId: 'del', code: '123456');

      expect(_body(harness.backend.requests.single), {
        'challengeId': 'del',
        'code': '123456',
      });
    });

    test('the confirmation: a wrong code (capture)', () async {
      harness.backend.on(
        'POST',
        _deletion,
        PortalReply.fixture(
          'me.deletion-request.otp-invalid.post.422.json',
          status: 422,
        ),
      );

      await expectLater(
        repository.confirmDeletion(challengeId: 'del', code: '000000'),
        throwsA(_business('otp_invalid')),
      );
    });
  });
}
