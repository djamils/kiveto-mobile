// The orchestrations of identity_access: the verification opens a session
// only for an account; the acceptances and the registration open the
// session they get; the logout signs out whatever the server says.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/features/identity_access/application/accept_invitation_by_link.dart';
import 'package:kiveto_mobile/features/identity_access/application/accept_pending_invitation.dart';
import 'package:kiveto_mobile/features/identity_access/application/register_account.dart';
import 'package:kiveto_mobile/features/identity_access/application/sign_in_with_code.dart';
import 'package:kiveto_mobile/features/identity_access/application/sign_out.dart';
import 'package:kiveto_mobile/features/identity_access/domain/auth_repository.dart';
import 'package:kiveto_mobile/features/identity_access/domain/invitation_preview.dart';
import 'package:kiveto_mobile/features/identity_access/domain/invitation_repository.dart';
import 'package:kiveto_mobile/features/identity_access/domain/otp_challenge.dart';
import 'package:kiveto_mobile/features/identity_access/domain/otp_channel.dart';
import 'package:kiveto_mobile/features/identity_access/domain/otp_verification.dart';
import 'package:kiveto_mobile/features/identity_access/domain/phone_number.dart';
import 'package:kiveto_mobile/features/identity_access/domain/registration_request.dart';
import 'package:kiveto_mobile/features/identity_access/domain/session_store.dart';
import 'package:kiveto_mobile/features/identity_access/domain/session_tokens.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';

final _at = DateTime.utc(2026, 11, 3, 10, 30);
const _tokens = SessionTokens(accessToken: 'A', refreshToken: 'refresh-A');
final _onboarding = OnboardingGrant(token: 'onb', expiresAt: _at);
const _invitation = PendingInvitation(id: 'i1', clinicName: 'Paris');

final class _Session implements SessionStore {
  new([this.refreshToken]);

  @override
  String? refreshToken;
  final opened = <SessionTokens>[];
  int closes = 0;

  @override
  Future<void> open(SessionTokens tokens) async {
    opened.add(tokens);
    refreshToken = tokens.refreshToken;
  }

  @override
  Future<void> close() async {
    closes++;
    refreshToken = null;
  }
}

final class _Auth implements AuthRepository {
  new({this.verification, this.failure, this.stall});

  final OtpVerification? verification;
  final Object? failure;

  /// Holds the logout until it completes (a stalled network).
  final Completer<void>? stall;
  final calls = <String>[];

  void _failIfAsked() {
    final failure = this.failure;
    if (failure != null) Error.throwWithStackTrace(failure, StackTrace.current);
  }

  @override
  Future<OtpChallenge> requestCode(PhoneNumber phone) =>
      throw UnimplementedError();

  @override
  Future<OtpChallenge> resendCode({
    required String challengeId,
    required OtpChannel channel,
  }) => throw UnimplementedError();

  @override
  Future<OtpVerification> verifyCode({
    required String challengeId,
    required String code,
  }) async {
    calls.add('verify $challengeId $code');
    _failIfAsked();
    return verification!;
  }

  @override
  Future<SessionTokens> register(RegistrationRequest request) async {
    calls.add('register ${request.firstName}');
    _failIfAsked();
    return _tokens;
  }

  @override
  Future<void> logout(String refreshToken) async {
    calls.add('logout $refreshToken');
    await stall?.future;
    _failIfAsked();
  }
}

final class _Invitations implements InvitationRepository {
  new({this.failure});

  final Object? failure;
  final calls = <String>[];

  @override
  Future<InvitationPreview> lookup(String token) => throw UnimplementedError();

  @override
  Future<OtpChallenge> requestCode(String token) => throw UnimplementedError();

  @override
  Future<SessionTokens> acceptByLink({
    required String token,
    required String challengeId,
    required String code,
    required String termsVersion,
  }) async {
    calls.add('link $token $challengeId $code $termsVersion');
    if (failure case final Object failure) {
      Error.throwWithStackTrace(failure, StackTrace.current);
    }
    return _tokens;
  }

  @override
  Future<SessionTokens> acceptPending({
    required String invitationId,
    required OnboardingGrant onboarding,
    required String termsVersion,
  }) async {
    calls.add('pending $invitationId ${onboarding.token} $termsVersion');
    if (failure case final Object failure) {
      Error.throwWithStackTrace(failure, StackTrace.current);
    }
    return _tokens;
  }
}

void main() {
  group('SignInWithCode', () {
    test('an account: the session opens, the pending invitations come '
        'back without the tokens', () async {
      final session = _Session();
      final auth = _Auth(
        verification: AuthenticatedVerification(
          tokens: _tokens,
          pendingInvitations: const [_invitation],
          onboarding: _onboarding,
        ),
      );

      final outcome = await SignInWithCode(auth, session)(
        challengeId: 'c1',
        code: '123456',
      );

      expect(auth.calls, ['verify c1 123456']);
      expect(session.opened, [_tokens]);
      expect(
        outcome,
        isA<SignedIn>()
            .having((o) => o.pendingInvitations, 'invitations', [_invitation])
            .having((o) => o.onboarding, 'onboarding', _onboarding),
      );
    });

    test('invited: no session, the onboarding grant', () async {
      final session = _Session();
      final outcome = await SignInWithCode(
        _Auth(
          verification: InvitationPendingVerification(
            onboarding: _onboarding,
            invitations: const [_invitation],
          ),
        ),
        session,
      )(challengeId: 'c1', code: '123456');

      expect(session.opened, isEmpty);
      expect(
        outcome,
        isA<InvitationPending>()
            .having((o) => o.onboarding, 'onboarding', _onboarding)
            .having((o) => o.invitations, 'invitations', [_invitation]),
      );
    });

    test('unknown number: no session, the registration grant', () async {
      final session = _Session();
      final grant = RegistrationGrant(token: 'reg', expiresAt: _at);
      final outcome = await SignInWithCode(
        _Auth(
          verification: RegistrationRequiredVerification(registration: grant),
        ),
        session,
      )(challengeId: 'c1', code: '123456');

      expect(session.opened, isEmpty);
      expect(
        outcome,
        isA<RegistrationRequired>().having(
          (o) => o.registration,
          'grant',
          grant,
        ),
      );
    });

    test('a refused code: the failure, no session', () async {
      final session = _Session();
      const failure = BusinessFailure(code: 'otp_invalid', statusCode: 422);

      await expectLater(
        SignInWithCode(_Auth(failure: failure), session)(
          challengeId: 'c1',
          code: '000000',
        ),
        throwsA(failure),
      );
      expect(session.opened, isEmpty);
    });
  });

  group('the acceptances and the registration open their session', () {
    test('AcceptInvitationByLink', () async {
      final session = _Session();
      final invitations = _Invitations();

      await AcceptInvitationByLink(invitations, session)(
        token: 'tok',
        challengeId: 'c1',
        code: '123456',
        termsVersion: '2026-10-29',
      );

      expect(invitations.calls, ['link tok c1 123456 2026-10-29']);
      expect(session.opened, [_tokens]);
    });

    test('AcceptPendingInvitation', () async {
      final session = _Session();
      final invitations = _Invitations();

      await AcceptPendingInvitation(invitations, session)(
        invitationId: 'i1',
        onboarding: _onboarding,
        termsVersion: '2026-10-29',
      );

      expect(invitations.calls, ['pending i1 onb 2026-10-29']);
      expect(session.opened, [_tokens]);
    });

    test('RegisterAccount', () async {
      final session = _Session();
      final auth = _Auth();

      await RegisterAccount(auth, session)(
        RegistrationRequest(
          grant: RegistrationGrant(token: 'reg', expiresAt: _at),
          firstName: 'Sarah',
          lastName: 'Bernard',
          termsVersion: '2026-10-29',
        ),
      );

      expect(auth.calls, ['register Sarah']);
      expect(session.opened, [_tokens]);
    });

    test('a refusal leaves the session unchanged', () async {
      final session = _Session();
      const failure = BusinessFailure(code: 'terms_outdated', statusCode: 422);

      await expectLater(
        AcceptPendingInvitation(_Invitations(failure: failure), session)(
          invitationId: 'i1',
          onboarding: _onboarding,
          termsVersion: 'old',
        ),
        throwsA(failure),
      );
      await expectLater(
        AcceptInvitationByLink(_Invitations(failure: failure), session)(
          token: 'tok',
          challengeId: 'c1',
          code: '123456',
          termsVersion: 'old',
        ),
        throwsA(failure),
      );
      await expectLater(
        RegisterAccount(_Auth(failure: failure), session)(
          RegistrationRequest(
            grant: RegistrationGrant(token: 'reg', expiresAt: _at),
            firstName: 'Sarah',
            lastName: 'Bernard',
            termsVersion: 'old',
          ),
        ),
        throwsA(failure),
      );
      expect(session.opened, isEmpty);
    });
  });

  group('SignOut', () {
    test('revokes the session on the server, then signs out', () async {
      final session = _Session('refresh-A');
      final auth = _Auth();

      await SignOut(auth, session)();

      expect(auth.calls, ['logout refresh-A']);
      expect(session.closes, 1);
    });

    test('any API failure still signs out', () async {
      for (final failure in const <ApiFailure>[
        NetworkFailure(),
        UnauthorizedFailure(code: 'refresh_revoked'),
        ServerFailure(statusCode: 503),
      ]) {
        final session = _Session('refresh-A');

        await SignOut(_Auth(failure: failure), session)();

        expect(session.closes, 1, reason: '$failure');
        expect(session.refreshToken, isNull);
      }
    });

    test('signed out already: no call, signed out', () async {
      final session = _Session();
      final auth = _Auth();

      await SignOut(auth, session)();

      expect(auth.calls, isEmpty);
      expect(session.closes, 1);
    });

    // testWidgets for its fake clock: the 5 s pass without waiting.
    testWidgets('a stalled server: signed out after 5 s, not after the HTTP '
        'timeouts', (tester) async {
      final session = _Session('refresh-A');
      final auth = _Auth(stall: Completer<void>());
      var done = false;

      unawaited(SignOut(auth, session)().then((_) => done = true));
      await tester.pump(const Duration(seconds: 4));
      expect(auth.calls, ['logout refresh-A']);
      expect(session.closes, 0);

      await tester.pump(const Duration(seconds: 1));
      expect(done, isTrue);
      expect(session.closes, 1);
      expect(session.refreshToken, isNull);
    });

    test('an unexpected error still signs out, then surfaces', () async {
      final session = _Session('refresh-A');

      await expectLater(
        SignOut(_Auth(failure: StateError('bug')), session)(),
        throwsStateError,
      );
      expect(session.closes, 1);
    });
  });
}
