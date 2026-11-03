import 'package:kiveto_mobile/features/identity_access/domain/auth_repository.dart';
import 'package:kiveto_mobile/features/identity_access/domain/otp_verification.dart';
import 'package:kiveto_mobile/features/identity_access/domain/session_store.dart';

/// Where a right code leads (the session tokens never leave the use case).
sealed class SignInOutcome {
  const new();
}

/// Signed in (the session is open); [pendingInvitations] may still be
/// accepted with [onboarding].
final class SignedIn extends SignInOutcome {
  const new({this.pendingInvitations = const [], this.onboarding});

  final List<PendingInvitation> pendingInvitations;
  final OnboardingGrant? onboarding;
}

/// Not signed in: clinics invited the number; accepting one creates the
/// account.
final class InvitationPending extends SignInOutcome {
  const new({required this.onboarding, required this.invitations});

  final OnboardingGrant onboarding;
  final List<PendingInvitation> invitations;
}

/// Not signed in: the number has no account; [registration] creates it.
final class RegistrationRequired extends SignInOutcome {
  const new({required this.registration});

  final RegistrationGrant registration;
}

/// Verifies a sign-in code, then branches on the server's answer: an
/// account opens the session; an invited or unknown number gets the grant
/// of its next step, without a session.
final class SignInWithCode {
  const new(this._auth, this._session);

  final AuthRepository _auth;
  final SessionStore _session;

  /// Throws the `ApiFailure` of a wrong, expired or refused code.
  Future<SignInOutcome> call({
    required String challengeId,
    required String code,
  }) async {
    switch (await _auth.verifyCode(challengeId: challengeId, code: code)) {
      case AuthenticatedVerification(
        :final tokens,
        :final pendingInvitations,
        :final onboarding,
      ):
        await _session.open(tokens);
        return SignedIn(
          pendingInvitations: pendingInvitations,
          onboarding: onboarding,
        );
      case InvitationPendingVerification(:final onboarding, :final invitations):
        return InvitationPending(
          onboarding: onboarding,
          invitations: invitations,
        );
      case RegistrationRequiredVerification(:final registration):
        return RegistrationRequired(registration: registration);
    }
  }
}
