// The vocabulary of the sign-in flows: the phone number in E.164, and value
// objects whose tokens never reach a toString.

import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/features/identity_access/domain/invitation_preview.dart';
import 'package:kiveto_mobile/features/identity_access/domain/otp_challenge.dart';
import 'package:kiveto_mobile/features/identity_access/domain/otp_verification.dart';
import 'package:kiveto_mobile/features/identity_access/domain/phone_number.dart';
import 'package:kiveto_mobile/features/identity_access/domain/registration_request.dart';
import 'package:kiveto_mobile/features/identity_access/domain/session_tokens.dart';
import 'package:kiveto_mobile/features/identity_access/domain/terms.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';

final _at = DateTime.utc(2026, 11, 3, 10, 30);

void main() {
  group('PhoneNumber', () {
    test('digits only, one trunk 0 dropped, E.164', () {
      final typed = PhoneNumber.fromNational(
        countryCode: '+33',
        national: '06 12 34 56 78',
      );
      final withoutTrunk = PhoneNumber.fromNational(
        countryCode: '33',
        national: '6 12 34 56 78',
      );

      expect(typed?.e164, '+33612345678');
      expect(typed?.countryCode, '+33');
      expect(typed?.national, '612345678');
      expect(withoutTrunk, typed);
      expect(withoutTrunk.hashCode, typed.hashCode);
      expect('$typed', 'PhoneNumber(+33612345678)');
    });

    test("only one leading 0 is dropped; the rest is the server's", () {
      expect(
        PhoneNumber.fromNational(countryCode: '+687', national: '0075')?.e164,
        '+687075',
      );
      expect(
        PhoneNumber.fromNational(countryCode: '+262', national: '692 1')?.e164,
        '+2626921',
      );
    });

    test('no digit: null', () {
      expect(
        PhoneNumber.fromNational(countryCode: '+33', national: ''),
        isNull,
      );
      expect(
        PhoneNumber.fromNational(countryCode: '+33', national: ' 0 '),
        isNull,
      );
      expect(
        PhoneNumber.fromNational(countryCode: '+33', national: 'abc'),
        isNull,
      );
    });

    test('equality compares the prefix and the digits', () {
      final paris = PhoneNumber.fromNational(
        countryCode: '+33',
        national: '612345678',
      );
      final reunion = PhoneNumber.fromNational(
        countryCode: '+262',
        national: '612345678',
      );

      expect(paris == reunion, isFalse);
    });
  });

  group('the tokens are redacted', () {
    test('SessionTokens', () {
      final tokens = SessionTokens(
        accessToken: 'access-secret',
        refreshToken: 'refresh-secret',
        accessTokenExpiresAt: _at,
        refreshTokenExpiresAt: _at,
      );

      expect('$tokens', 'SessionTokens(<redacted>)');
      expect(
        tokens,
        SessionTokens(
          accessToken: 'access-secret',
          refreshToken: 'refresh-secret',
          accessTokenExpiresAt: _at,
          refreshTokenExpiresAt: _at,
        ),
      );
      expect(
        tokens.hashCode,
        SessionTokens(
          accessToken: 'access-secret',
          refreshToken: 'refresh-secret',
          accessTokenExpiresAt: _at,
          refreshTokenExpiresAt: _at,
        ).hashCode,
      );
      expect(
        tokens == const SessionTokens(accessToken: 'x', refreshToken: 'y'),
        isFalse,
      );
    });

    test('the grants and the registration request', () {
      final onboarding = OnboardingGrant(token: 'onb-secret', expiresAt: _at);
      final registration = RegistrationGrant(
        token: 'reg-secret',
        expiresAt: _at,
      );
      final request = RegistrationRequest(
        grant: registration,
        firstName: 'Sarah',
        lastName: 'Bernard',
        email: 'sarah@example.com',
        termsVersion: '2026-10-29',
      );

      expect('$onboarding', 'OnboardingGrant(<redacted>)');
      expect('$registration', 'RegistrationGrant(<redacted>)');
      expect('$request', 'RegistrationRequest(<redacted>)');
      expect(onboarding, OnboardingGrant(token: 'onb-secret', expiresAt: _at));
      expect(
        onboarding.hashCode,
        OnboardingGrant(token: 'onb-secret', expiresAt: _at).hashCode,
      );
      expect(
        registration,
        RegistrationGrant(token: 'reg-secret', expiresAt: _at),
      );
      expect(
        registration.hashCode,
        RegistrationGrant(token: 'reg-secret', expiresAt: _at).hashCode,
      );
      expect(request.grant, registration);
      expect(request.email, 'sarah@example.com');
    });
  });

  test('OtpChallenge: value equality, readable', () {
    final challenge = OtpChallenge(
      id: 'c1',
      expiresAt: _at,
      resendAvailableAt: _at,
    );

    expect(
      challenge,
      OtpChallenge(id: 'c1', expiresAt: _at, resendAvailableAt: _at),
    );
    expect(
      challenge.hashCode,
      OtpChallenge(id: 'c1', expiresAt: _at, resendAvailableAt: _at).hashCode,
    );
    expect('$challenge', contains('c1'));
  });

  test('the verification branches and the pending invitations', () {
    const invitation = PendingInvitation(
      id: 'i1',
      clinicName: 'Clinique Vétérinaire de Paris',
      clinicCity: 'Paris',
    );
    final authenticated = AuthenticatedVerification(
      tokens: const SessionTokens(accessToken: 'a', refreshToken: 'r'),
      pendingInvitations: const [invitation],
      onboarding: OnboardingGrant(token: 'o', expiresAt: _at),
    );
    final pending = InvitationPendingVerification(
      onboarding: OnboardingGrant(token: 'o', expiresAt: _at),
      invitations: const [invitation],
    );
    final registration = RegistrationRequiredVerification(
      registration: RegistrationGrant(token: 'r', expiresAt: _at),
    );

    expect(authenticated.pendingInvitations, [invitation]);
    expect(
      const AuthenticatedVerification(
        tokens: SessionTokens(accessToken: 'a', refreshToken: 'r'),
      ).pendingInvitations,
      isEmpty,
    );
    expect(pending.invitations.single, invitation);
    expect(registration.registration.token, 'r');
    expect(
      invitation,
      const PendingInvitation(
        id: 'i1',
        clinicName: 'Clinique Vétérinaire de Paris',
        clinicCity: 'Paris',
      ),
    );
    expect(
      invitation.hashCode,
      const PendingInvitation(
        id: 'i1',
        clinicName: 'Clinique Vétérinaire de Paris',
        clinicCity: 'Paris',
      ).hashCode,
    );
    expect(
      '$invitation',
      'PendingInvitation(i1, Clinique Vétérinaire de Paris)',
    );
  });

  test('InvitationPreview and Terms', () {
    final preview = InvitationPreview(
      invitationId: 'i1',
      clinicId: const ClinicId('c1'),
      clinicName: 'Clinique Vétérinaire de Paris',
      maskedPhone: '+33 6 •• •• •• 55',
      expiresAt: _at,
    );
    const terms = Terms(version: '2026-10-29', url: 'https://x/cgu');

    expect(preview.petNames, isEmpty);
    expect(preview.email, isNull);
    expect('$preview', 'InvitationPreview(i1, Clinique Vétérinaire de Paris)');
    expect(terms, const Terms(version: '2026-10-29', url: 'https://x/cgu'));
    expect(
      terms.hashCode,
      const Terms(version: '2026-10-29', url: 'https://x/cgu').hashCode,
    );
    expect('$terms', 'Terms(2026-10-29)');
  });
}
