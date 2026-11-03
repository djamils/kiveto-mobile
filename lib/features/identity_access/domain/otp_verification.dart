// The domain imports no package (rule 1), so package:meta's @immutable is
// out of reach: the value objects below have only final fields.
// ignore_for_file: avoid_equals_and_hash_code_on_mutable_classes

import 'package:kiveto_mobile/features/identity_access/domain/session_tokens.dart';

/// What `POST /auth/otp/verify` answered for a right code: the branch the
/// server chose for this number.
sealed class OtpVerification {
  const new();
}

/// The number has an account: its session, and the clinic invitations
/// still waiting for it ([onboarding] accepts them).
final class AuthenticatedVerification extends OtpVerification {
  const new({
    required this.tokens,
    this.pendingInvitations = const [],
    this.onboarding,
  });

  final SessionTokens tokens;
  final List<PendingInvitation> pendingInvitations;
  final OnboardingGrant? onboarding;
}

/// No account, but clinics invited this number: accept one with
/// [onboarding] to create the account.
final class InvitationPendingVerification extends OtpVerification {
  const new({required this.onboarding, required this.invitations});

  final OnboardingGrant onboarding;
  final List<PendingInvitation> invitations;
}

/// No account and no invitation: [registration] creates the account.
final class RegistrationRequiredVerification extends OtpVerification {
  const new({required this.registration});

  final RegistrationGrant registration;
}

/// A clinic invitation waiting for the verified number.
final class PendingInvitation {
  const new({required this.id, required this.clinicName, this.clinicCity});

  final String id;
  final String clinicName;
  final String? clinicCity;

  @override
  bool operator ==(Object other) =>
      other is PendingInvitation &&
      other.id == id &&
      other.clinicName == clinicName &&
      other.clinicCity == clinicCity;

  @override
  int get hashCode => Object.hash(id, clinicName, clinicCity);

  @override
  String toString() => 'PendingInvitation($id, $clinicName)';
}

/// The onboarding token of a verified number: it accepts its pending
/// invitations until [expiresAt] (UTC). Never logged.
final class OnboardingGrant {
  const new({required this.token, required this.expiresAt});

  final String token;
  final DateTime expiresAt;

  @override
  bool operator ==(Object other) =>
      other is OnboardingGrant &&
      other.token == token &&
      other.expiresAt == expiresAt;

  @override
  int get hashCode => Object.hash(token, expiresAt);

  @override
  String toString() => 'OnboardingGrant(<redacted>)';
}

/// The registration token of a verified number without account: it
/// creates the account until [expiresAt] (UTC). Never logged.
final class RegistrationGrant {
  const new({required this.token, required this.expiresAt});

  final String token;
  final DateTime expiresAt;

  @override
  bool operator ==(Object other) =>
      other is RegistrationGrant &&
      other.token == token &&
      other.expiresAt == expiresAt;

  @override
  int get hashCode => Object.hash(token, expiresAt);

  @override
  String toString() => 'RegistrationGrant(<redacted>)';
}
