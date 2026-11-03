// PortalAuthRepository on the real chain (PortalHttp, strict status) and
// the real generated client, fed with the backend's captured answers: the
// code request, the three verification branches, the resend, the
// registration, the logout (one refresh with an expired access token,
// the replay carrying the same body).

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/features/identity_access/domain/otp_challenge.dart';
import 'package:kiveto_mobile/features/identity_access/domain/otp_channel.dart';
import 'package:kiveto_mobile/features/identity_access/domain/otp_verification.dart';
import 'package:kiveto_mobile/features/identity_access/domain/phone_number.dart';
import 'package:kiveto_mobile/features/identity_access/domain/registration_request.dart';
import 'package:kiveto_mobile/features/identity_access/infrastructure/portal_auth_repository.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';

import '../../../../support/fakes.dart';
import '../../../../support/portal_api/fake_portal_backend.dart';
import '../../../../support/portal_api/portal_http_harness.dart';

const _request = '$api/auth/otp/request';
const _verify = '$api/auth/otp/verify';
const _challenge = '01a1a0ee-b560-7aca-b883-0473f9c33042';
const _resend = '$api/auth/otp/$_challenge/resend';
const _register = '$api/auth/register';
const _logout = '$api/auth/logout';

Map<String, Object?> _body(PortalRequest request) =>
    jsonDecode(utf8.decode(request.body)) as Map<String, Object?>;

/// A verification answer: the `authenticated` capture with [changes].
PortalReply _verified(Map<String, Object?> changes) => PortalReply.json(
  jsonEncode({
    'status': 'authenticated',
    'accessToken': 'A',
    'accessTokenExpiresAt': '2026-11-03T10:37:51+00:00',
    'refreshToken': 'refresh-A',
    'refreshTokenExpiresAt': '2027-02-01T10:22:51+00:00',
    'pendingInvitations': <Object?>[],
    'onboardingToken': null,
    'onboardingTokenExpiresAt': null,
    'registrationToken': null,
    'invitations': <Object?>[],
    'registrationTokenExpiresAt': null,
    ...changes,
  }),
);

void main() {
  late PortalHarness harness;
  late PortalAuthRepository repository;

  Future<void> start({String? tokens}) async {
    harness = await PortalHarness.create(
      tokens: tokens == null ? null : pair(tokens),
    );
    repository = PortalAuthRepository(harness.http.server, harness.failures);
  }

  Future<OtpVerification> verify(PortalReply reply) {
    harness.backend.on('POST', _verify, reply);
    return repository.verifyCode(challengeId: _challenge, code: '123456');
  }

  final phone = PhoneNumber.fromNational(
    countryCode: '+33',
    national: '06 12 34 56 78',
  )!;

  setUp(start);

  group('requestCode', () {
    test('sends the number in E.164 (and the device id); the challenge, '
        'in UTC', () async {
      harness.backend.on(
        'POST',
        _request,
        PortalReply.fixture('auth.otp.request.post.202.json', status: 202),
      );

      final challenge = await repository.requestCode(phone);

      expect(
        challenge,
        OtpChallenge(
          id: _challenge,
          expiresAt: DateTime.utc(2026, 11, 3, 10, 32, 40),
          resendAvailableAt: DateTime.utc(2026, 11, 3, 10, 23, 10),
        ),
      );
      expect(challenge.expiresAt.isUtc, isTrue);
      final request = harness.backend.requestsTo(_request).single;
      expect(_body(request), {'phone': '+33612345678'});
      expect(request.headers['X-Device-Id'], 'device-1');
    });

    test('the refusals: phone_not_supported, validation_failed, '
        'otp_rate_limited with its Retry-After', () async {
      Future<Object?> refusal(PortalReply reply) async {
        harness.backend.on('POST', _request, reply);
        try {
          await repository.requestCode(phone);
        } on ApiFailure catch (failure) {
          return failure;
        }
        return null;
      }

      expect(
        await refusal(
          PortalReply.fixture(
            'auth.otp.request.phone-not-supported.post.422.json',
            status: 422,
          ),
        ),
        isA<BusinessFailure>().having(
          (f) => f.code,
          'code',
          'phone_not_supported',
        ),
      );
      expect(
        await refusal(
          PortalReply.fixture('auth.otp.request.post.422.json', status: 422),
        ),
        isA<ValidationFailure>().having(
          (f) => f.violations.single.propertyPath,
          'field',
          'phone',
        ),
      );
      expect(
        await refusal(
          PortalReply.fixture(
            'auth.otp.request.post.429.json',
            status: 429,
            headers: {
              'Retry-After': ['3599'],
            },
          ),
        ),
        isA<RateLimitedFailure>()
            .having((f) => f.code, 'code', 'otp_rate_limited')
            .having(
              (f) => f.retryAfter,
              'retryAfter',
              const Duration(seconds: 3599),
            ),
      );
    });
  });

  group('verifyCode', () {
    test('authenticated (capture): the tokens, in UTC', () async {
      final verification = await verify(
        PortalReply.fixture('auth.otp.verify.authenticated.post.200.json'),
      );

      final authenticated = verification as AuthenticatedVerification;
      expect(authenticated.tokens.refreshToken, startsWith('0tlWl3NB'));
      expect(
        authenticated.tokens.accessTokenExpiresAt,
        DateTime.utc(2026, 11, 3, 10, 37, 51),
      );
      expect(
        authenticated.tokens.refreshTokenExpiresAt,
        DateTime.utc(2027, 2, 1, 10, 22, 51),
      );
      expect(authenticated.pendingInvitations, isEmpty);
      expect(authenticated.onboarding, isNull);
      expect(_body(harness.backend.requestsTo(_verify).single), {
        'challengeId': _challenge,
        'code': '123456',
      });
    });

    test(
      'authenticated with pending invitations: the onboarding grant',
      () async {
        final verification = await verify(
          _verified({
            'pendingInvitations': [
              {
                'invitationId': 'i1',
                'clinic': {
                  'name': 'Clinique Vétérinaire de Lyon',
                  'city': null,
                },
              },
            ],
            'onboardingToken': 'onb',
            'onboardingTokenExpiresAt': '2026-11-03T11:38:35+01:00',
          }),
        );

        final authenticated = verification as AuthenticatedVerification;
        expect(authenticated.pendingInvitations, [
          const PendingInvitation(
            id: 'i1',
            clinicName: 'Clinique Vétérinaire de Lyon',
          ),
        ]);
        expect(
          authenticated.onboarding,
          OnboardingGrant(
            token: 'onb',
            expiresAt: DateTime.utc(2026, 11, 3, 10, 38, 35),
          ),
        );
      },
    );

    test('authenticated with pending invitations (capture): the session '
        'and the grant of the invitations left', () async {
      final verification = await verify(
        PortalReply.fixture(
          'auth.otp.verify.authenticated-pending.post.200.json',
        ),
      );

      final authenticated = verification as AuthenticatedVerification;
      expect(
        authenticated.tokens.accessTokenExpiresAt,
        DateTime.utc(2026, 11, 3, 12, 3, 55),
      );
      expect(authenticated.pendingInvitations, [
        const PendingInvitation(
          id: '01a1a13d-1dc9-7544-aaa3-0594b1eac03a',
          clinicName: 'Clinique Vétérinaire de Lyon',
          clinicCity: 'Lyon',
        ),
      ]);
      expect(
        authenticated.onboarding?.expiresAt,
        DateTime.utc(2026, 11, 3, 12, 3, 55),
      );
      expect(authenticated.onboarding?.expiresAt.isUtc, isTrue);
    });

    test(
      'invitation_pending (capture): the grant and the invitations',
      () async {
        final verification = await verify(
          PortalReply.fixture(
            'auth.otp.verify.invitation-pending.post.200.json',
          ),
        );

        final pending = verification as InvitationPendingVerification;
        expect(
          pending.onboarding.token,
          'f7KIjOjhC5A-HcVbOnhZ0BgnOgNeJ5tQOjOftbAMVP8',
        );
        expect(
          pending.onboarding.expiresAt,
          DateTime.utc(2026, 11, 3, 10, 38, 35),
        );
        expect(pending.invitations, [
          const PendingInvitation(
            id: '01a19a10-d14e-7ed1-8251-a40291ac5ce9',
            clinicName: 'Clinique Vétérinaire de Paris',
            clinicCity: 'Paris',
          ),
        ]);
      },
    );

    test('registration_required (capture): the registration grant', () async {
      final verification = await verify(
        PortalReply.fixture(
          'auth.otp.verify.registration-required.post.200.json',
        ),
      );

      expect(
        (verification as RegistrationRequiredVerification).registration,
        RegistrationGrant(
          token: 't7OYpg5LsCy88SrpM_qqvW3DEiOgYeFmKWvQSInRp4w',
          expiresAt: DateTime.utc(2026, 11, 3, 10, 38, 36),
        ),
      );
    });

    test('an unknown status, or a branch without its tokens: an answer the '
        'app cannot use', () async {
      for (final reply in [
        _verified({'status': 'mfa_required'}),
        _verified({'accessToken': null}),
        _verified({'refreshToken': null}),
        _verified({'status': 'invitation_pending'}),
        _verified({
          'status': 'registration_required',
          'registrationToken': 'reg',
        }),
        _verified({
          'status': 'registration_required',
          'registrationTokenExpiresAt': '2026-11-03T10:38:36+00:00',
        }),
      ]) {
        await expectLater(verify(reply), throwsA(isA<ServerFailure>()));
      }
    });

    test('a wrong code (capture): otp_invalid', () async {
      await expectLater(
        verify(
          PortalReply.fixture(
            'auth.otp.verify.otp-invalid.post.422.json',
            status: 422,
          ),
        ),
        throwsA(
          isA<BusinessFailure>().having((f) => f.code, 'code', 'otp_invalid'),
        ),
      );
    });
  });

  group('resendCode', () {
    test('by SMS or email: the new challenge', () async {
      harness.backend.on(
        'POST',
        _resend,
        PortalReply.json(
          jsonEncode({
            'challengeId': _challenge,
            'expiresAt': '2026-11-03T10:42:40+00:00',
            'resendAvailableAt': '2026-11-03T10:33:10+00:00',
          }),
          status: 202,
        ),
      );

      final sms = await repository.resendCode(
        challengeId: _challenge,
        channel: OtpChannel.sms,
      );
      await repository.resendCode(
        challengeId: _challenge,
        channel: OtpChannel.email,
      );

      expect(sms.resendAvailableAt, DateTime.utc(2026, 11, 3, 10, 33, 10));
      expect(harness.backend.requestsTo(_resend).map(_body), [
        {'channel': 'sms'},
        {'channel': 'email'},
      ]);
    });

    test('a verified challenge (capture): otp_challenge_not_found', () async {
      harness.backend.on(
        'POST',
        _resend,
        PortalReply.fixture('auth.otp.resend.post.404.json', status: 404),
      );

      await expectLater(
        repository.resendCode(challengeId: _challenge, channel: OtpChannel.sms),
        throwsA(
          isA<NotFoundFailure>().having(
            (f) => f.code,
            'code',
            'otp_challenge_not_found',
          ),
        ),
      );
    });
  });

  group('register', () {
    final request = RegistrationRequest(
      grant: RegistrationGrant(
        token: 'reg',
        expiresAt: DateTime.utc(2026, 11, 3, 10, 38),
      ),
      firstName: 'Test',
      lastName: 'Capture',
      termsVersion: '2026-10-29',
    );

    test('sends the grant, the names, a null email and the terms version; '
        'the tokens (capture)', () async {
      harness.backend.on(
        'POST',
        _register,
        PortalReply.fixture('auth.register.post.201.json', status: 201),
      );

      final tokens = await repository.register(request);

      expect(
        tokens.refreshToken,
        'dCuSyfWyzqWw8I_9nmv8QWZFXNgpFxQvKEVpjjBUSug',
      );
      expect(
        tokens.accessTokenExpiresAt,
        DateTime.utc(2026, 11, 3, 10, 38, 48),
      );
      expect(
        tokens.refreshTokenExpiresAt,
        DateTime.utc(2027, 2, 1, 10, 23, 48),
      );
      final body = _body(harness.backend.requestsTo(_register).single);
      expect(body['registrationToken'], 'reg');
      expect(body['firstName'], 'Test');
      expect(body['lastName'], 'Capture');
      expect(body['email'], isNull);
      expect(body['termsVersion'], '2026-10-29');
    });

    test('terms_outdated (capture)', () async {
      harness.backend.on(
        'POST',
        _register,
        PortalReply.fixture(
          'auth.register.terms-outdated.post.422.json',
          status: 422,
        ),
      );

      await expectLater(
        repository.register(request),
        throwsA(
          isA<BusinessFailure>().having(
            (f) => f.code,
            'code',
            'terms_outdated',
          ),
        ),
      );
    });
  });

  group('logout', () {
    test('signed in: the refresh token in the body, 204', () async {
      await start(tokens: 'A');
      harness.backend.on('POST', _logout, PortalReply.empty(204));

      await repository.logout('refresh-A');

      final request = harness.backend.requestsTo(_logout).single;
      expect(_body(request), {'refreshToken': 'refresh-A'});
      expect(bearerOf(request), 'Bearer A');
    });

    test(
      'an expired access token: one refresh, then the same body is '
      'replayed (the backend revokes the family from a spent member)',
      () async {
        await start(tokens: 'A');
        harness.backend
          ..onRequest(
            'POST',
            _logout,
            (request) => bearerOf(request) == 'Bearer B'
                ? PortalReply.empty(204)
                : problem('token_expired', 401),
          )
          ..on('POST', '$api/auth/refresh', refreshed('B'));

        await repository.logout('refresh-A');

        expect(harness.refreshes, hasLength(1));
        expect(refreshTokenOf(harness.refreshes.single), 'refresh-A');
        final logouts = harness.backend.requestsTo(_logout);
        expect(logouts.map(bearerOf), ['Bearer A', 'Bearer B']);
        expect(logouts.map(_body), [
          {'refreshToken': 'refresh-A'},
          {'refreshToken': 'refresh-A'},
        ]);
        expect(harness.session.tokens?.refreshToken, 'refresh-B');
      },
    );

    test('a refusal is a failure (the use case signs out anyway)', () async {
      harness.backend.on('POST', _logout, problem('unauthorized', 401));

      await expectLater(
        repository.logout('refresh-A'),
        throwsA(isA<UnauthorizedFailure>()),
      );
    });
  });

  test('the tokens of a registration are never in a toString', () async {
    harness.backend.on(
      'POST',
      _register,
      PortalReply.fixture('auth.register.post.201.json', status: 201),
    );

    final tokens = await repository.register(
      RegistrationRequest(
        grant: RegistrationGrant(
          token: 'reg',
          expiresAt: DateTime.utc(2026, 11, 3),
        ),
        firstName: 'Test',
        lastName: 'Capture',
        termsVersion: '2026-10-29',
      ),
    );

    expect('$tokens', isNot(contains(tokens.refreshToken)));
  });
}
