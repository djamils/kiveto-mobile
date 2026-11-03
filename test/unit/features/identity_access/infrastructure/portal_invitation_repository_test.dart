// PortalInvitationRepository on the real chain and the generated client:
// the lookup (Roussel's capture, the expired and invalid ones), the code,
// the two acceptances; the link token only in request bodies.

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/features/identity_access/domain/otp_verification.dart';
import 'package:kiveto_mobile/features/identity_access/infrastructure/portal_invitation_repository.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';

import '../../../../support/portal_api/fake_portal_backend.dart';
import '../../../../support/portal_api/portal_http_harness.dart';

const _lookup = '$api/invitations/lookup';
const _otp = '$api/invitations/otp';
const _accept = '$api/invitations/accept';
const _invitation = '01a19a10-d14e-7ed1-8251-a40291ac5ce9';
const _acceptById = '$api/invitations/$_invitation/accept';
const _token = 'ROUSSEL_TOKEN';

Map<String, Object?> _body(PortalRequest request) =>
    jsonDecode(utf8.decode(request.body)) as Map<String, Object?>;

/// A 200 acceptance shaped like `auth.register.post.201.json` (the live
/// acceptance captures consume an invitation).
PortalReply _accepted() => PortalReply.json(
  jsonEncode({
    'accessToken': 'A',
    'accessTokenExpiresAt': '2026-11-03T11:38:48+01:00',
    'refreshToken': 'refresh-A',
    'refreshTokenExpiresAt': '2027-02-01T10:23:48+00:00',
    'account': {
      'id': '01a19a10-d011-70c8-8daf-26e4db824374',
      'firstName': 'Antoine',
      'lastName': 'Roussel',
      'email': 'antoine.roussel@gmail.com',
      'emailVerified': false,
      'maskedPhone': '+33 6 •• •• •• 55',
      'address': null,
    },
  }),
);

void main() {
  late PortalHarness harness;
  late PortalInvitationRepository repository;

  setUp(() async {
    harness = await PortalHarness.create();
    repository = PortalInvitationRepository(
      harness.http.server,
      harness.failures,
    );
  });

  group('lookup', () {
    test('Roussel (capture): the clinic, the email, the masked phone, the '
        'pets; the token in the body only', () async {
      harness.backend.on(
        'POST',
        _lookup,
        PortalReply.fixture('invitations.lookup.post.200.json'),
      );

      final preview = await repository.lookup(_token);

      expect(preview.invitationId, _invitation);
      expect(
        preview.clinicId,
        const ClinicId('01960000-0000-7000-8000-000000000001'),
      );
      expect(preview.clinicName, 'Clinique Vétérinaire de Paris');
      expect(preview.clinicCity, 'Paris');
      expect(preview.email, 'antoine.roussel@gmail.com');
      expect(preview.maskedPhone, '+33 6 •• •• •• 55');
      expect(preview.petNames, ['Ulysse']);
      expect(preview.expiresAt, DateTime.utc(2026, 11, 8, 2, 22, 35));
      final request = harness.backend.requestsTo(_lookup).single;
      expect(_body(request), {'token': _token});
      expect(request.uri.toString(), isNot(contains(_token)));
    });

    test('expired (PERRIN, capture) and invalid (capture)', () async {
      harness.backend.on(
        'POST',
        _lookup,
        PortalReply.fixture(
          'invitations.lookup.expired.post.410.json',
          status: 410,
        ),
      );
      await expectLater(
        repository.lookup('PERRIN_TOKEN'),
        throwsA(
          isA<BusinessFailure>()
              .having((f) => f.code, 'code', 'invitation_expired')
              .having((f) => f.statusCode, 'status', 410),
        ),
      );

      harness.backend.on(
        'POST',
        _lookup,
        PortalReply.fixture(
          'invitations.lookup.invalid.post.404.json',
          status: 404,
        ),
      );
      await expectLater(
        repository.lookup('nope'),
        throwsA(
          isA<NotFoundFailure>().having(
            (f) => f.code,
            'code',
            'invitation_invalid',
          ),
        ),
      );
    });

    test('already accepted (capture): invitation_already_used', () async {
      harness.backend.on(
        'POST',
        _lookup,
        PortalReply.fixture(
          'invitations.lookup.used.post.410.json',
          status: 410,
        ),
      );

      await expectLater(
        repository.lookup(_token),
        throwsA(
          isA<BusinessFailure>()
              .having((f) => f.code, 'code', 'invitation_already_used')
              .having((f) => f.statusCode, 'status', 410),
        ),
      );
    });
  });

  group('requestCode', () {
    test('the challenge (capture), in UTC', () async {
      harness.backend.on(
        'POST',
        _otp,
        PortalReply.fixture('invitations.otp.post.202.json', status: 202),
      );

      final challenge = await repository.requestCode(_token);

      expect(challenge.id, '01a1a0ef-e80b-7435-83d5-132dfd62759a');
      expect(challenge.expiresAt, DateTime.utc(2026, 11, 3, 10, 33, 59));
      expect(
        challenge.resendAvailableAt,
        DateTime.utc(2026, 11, 3, 10, 24, 29),
      );
      expect(_body(harness.backend.requestsTo(_otp).single), {'token': _token});
    });

    test('a quota: rate limited', () async {
      harness.backend.on(
        'POST',
        _otp,
        PortalReply.fixture('auth.otp.request.post.429.json', status: 429),
      );

      await expectLater(
        repository.requestCode(_token),
        throwsA(isA<RateLimitedFailure>()),
      );
    });
  });

  group('acceptByLink', () {
    test('sends the token, the challenge, the code and the terms; the '
        'tokens in UTC', () async {
      harness.backend.on('POST', _accept, _accepted());

      final tokens = await repository.acceptByLink(
        token: _token,
        challengeId: 'c1',
        code: '123456',
        termsVersion: '2026-10-29',
      );

      expect(tokens.accessToken, 'A');
      expect(tokens.refreshToken, 'refresh-A');
      expect(
        tokens.accessTokenExpiresAt,
        DateTime.utc(2026, 11, 3, 10, 38, 48),
      );
      expect(tokens.accessTokenExpiresAt!.isUtc, isTrue);
      expect(_body(harness.backend.requestsTo(_accept).single), {
        'token': _token,
        'challengeId': 'c1',
        'code': '123456',
        'termsVersion': '2026-10-29',
      });
    });

    test('a live acceptance (capture): the pair, in UTC', () async {
      harness.backend.on(
        'POST',
        _accept,
        PortalReply.fixture('invitations.accept.post.200.json'),
      );

      final tokens = await repository.acceptByLink(
        token: _token,
        challengeId: 'c1',
        code: '123456',
        termsVersion: '2026-10-29',
      );

      expect(tokens.refreshToken, isNotEmpty);
      expect(tokens.accessTokenExpiresAt, DateTime.utc(2026, 11, 3, 12, 3, 42));
      expect(
        tokens.refreshTokenExpiresAt,
        DateTime.utc(2027, 2, 1, 11, 48, 42),
      );
    });

    test('a refused code', () async {
      harness.backend.on(
        'POST',
        _accept,
        PortalReply.fixture(
          'auth.otp.verify.otp-invalid.post.422.json',
          status: 422,
        ),
      );

      await expectLater(
        repository.acceptByLink(
          token: _token,
          challengeId: 'c1',
          code: '000000',
          termsVersion: '2026-10-29',
        ),
        throwsA(
          isA<BusinessFailure>().having((f) => f.code, 'code', 'otp_invalid'),
        ),
      );
    });
  });

  group('acceptPending', () {
    final grant = OnboardingGrant(
      token: 'onb',
      expiresAt: DateTime.utc(2026, 11, 3, 10, 38),
    );

    test('by id, with the onboarding token and the terms', () async {
      harness.backend.on('POST', _acceptById, _accepted());

      final tokens = await repository.acceptPending(
        invitationId: _invitation,
        onboarding: grant,
        termsVersion: '2026-10-29',
      );

      expect(tokens.refreshToken, 'refresh-A');
      expect(
        tokens.refreshTokenExpiresAt,
        DateTime.utc(2027, 2, 1, 10, 23, 48),
      );
      expect(_body(harness.backend.requestsTo(_acceptById).single), {
        'onboardingToken': 'onb',
        'termsVersion': '2026-10-29',
      });
    });

    test('a live acceptance by id (capture): the pair, in UTC', () async {
      harness.backend.on(
        'POST',
        _acceptById,
        PortalReply.fixture('invitations.accept-by-id.post.200.json'),
      );

      final tokens = await repository.acceptPending(
        invitationId: _invitation,
        onboarding: grant,
        termsVersion: '2026-10-29',
      );

      expect(tokens.accessTokenExpiresAt, DateTime.utc(2026, 11, 3, 12, 3, 56));
      expect(tokens.accessTokenExpiresAt!.isUtc, isTrue);
    });

    test('an expired grant: onboarding_invalid', () async {
      harness.backend.on(
        'POST',
        _acceptById,
        PortalReply.fixture(
          'invitations.accept-by-id.onboarding-invalid.post.401.json',
          status: 401,
        ),
      );

      await expectLater(
        repository.acceptPending(
          invitationId: _invitation,
          onboarding: grant,
          termsVersion: '2026-10-29',
        ),
        throwsA(
          isA<UnauthorizedFailure>().having(
            (f) => f.code,
            'code',
            'onboarding_invalid',
          ),
        ),
      );
      expect(harness.refreshes, isEmpty);
    });
  });
}
