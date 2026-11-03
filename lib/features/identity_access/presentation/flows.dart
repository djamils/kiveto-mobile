import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiveto_mobile/features/identity_access/di.dart';
import 'package:kiveto_mobile/features/identity_access/domain/otp_challenge.dart';
import 'package:kiveto_mobile/features/identity_access/domain/otp_verification.dart';
import 'package:kiveto_mobile/features/identity_access/domain/phone_number.dart';
import 'package:kiveto_mobile/features/identity_access/domain/terms.dart';
import 'package:material_ui/material_ui.dart';

// The state the sign-in screens hand to each other. In memory only: a page
// opened without its flow (a restart, a stale route) goes back to its
// start. The grants they hold are never logged (their toString redacts).

/// Calls [leave] once the page of [context] is shown: after the first
/// frame and the end of its route's entrance. Leaving during the entrance
/// would bring back the page it covers (the shell) while that one is still
/// on its way out (one widget, two places).
void leaveWhenShown(BuildContext context, void Function() leave) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!context.mounted) return;
    final animation = ModalRoute.of(context)?.animation;
    if (animation == null || animation.isCompleted) {
      leave();
      return;
    }
    void shown(AnimationStatus status) {
      if (!status.isCompleted) return;
      animation.removeStatusListener(shown);
      if (context.mounted) leave();
    }

    animation.addStatusListener(shown);
  });
}

/// The number being signed in (7 → 8) and its code challenge.
final class SignInFlowState {
  const new({required this.phone, required this.challenge});

  final PhoneNumber phone;
  final OtpChallenge challenge;
}

final signInFlowProvider = NotifierProvider<SignInFlow, SignInFlowState?>(
  SignInFlow.new,
);

final class SignInFlow extends Notifier<SignInFlowState?> {
  @override
  SignInFlowState? build() => null;

  /// A code was sent to [phone].
  void start(PhoneNumber phone, OtpChallenge challenge) =>
      state = SignInFlowState(phone: phone, challenge: challenge);

  /// A new code was sent (a resend).
  void replaceChallenge(OtpChallenge challenge) {
    final current = state;
    if (current == null) return;
    state = SignInFlowState(phone: current.phone, challenge: challenge);
  }

  void clear() => state = null;
}

/// The pending invitations of a verified number (8 → onboarding): signed in
/// already (an account with invitations, or after a first acceptance), or
/// not (the first acceptance creates the account).
final class OnboardingState {
  const new({
    required this.grant,
    required this.invitations,
    required this.signedIn,
    this.acceptedClinicName,
  });

  final OnboardingGrant grant;
  final List<PendingInvitation> invitations;
  final bool signedIn;

  /// The clinic of the last acceptance, while others are left.
  final String? acceptedClinicName;
}

final onboardingProvider = NotifierProvider<Onboarding, OnboardingState?>(
  Onboarding.new,
);

final class Onboarding extends Notifier<OnboardingState?> {
  @override
  OnboardingState? build() => null;

  void start({
    required OnboardingGrant grant,
    required List<PendingInvitation> invitations,
    required bool signedIn,
  }) => state = OnboardingState(
    grant: grant,
    invitations: invitations,
    signedIn: signedIn,
  );

  /// [invitation] was accepted: the session is open, it leaves the list.
  void accepted(PendingInvitation invitation) {
    final current = state;
    if (current == null) return;
    state = OnboardingState(
      grant: current.grant,
      invitations: [
        for (final other in current.invitations)
          if (other.id != invitation.id) other,
      ],
      signedIn: true,
      acceptedClinicName: invitation.clinicName,
    );
  }

  /// The invitation [id] is no longer available.
  void remove(String id) {
    final current = state;
    if (current == null) return;
    state = OnboardingState(
      grant: current.grant,
      invitations: [
        for (final other in current.invitations)
          if (other.id != id) other,
      ],
      signedIn: current.signedIn,
    );
  }

  void clear() => state = null;
}

/// The verified number without account (8 → 9) and its registration grant.
final class RegistrationFlowState {
  const new({required this.grant, required this.phone});

  final RegistrationGrant grant;
  final PhoneNumber phone;
}

final registrationFlowProvider =
    NotifierProvider<RegistrationFlow, RegistrationFlowState?>(
      RegistrationFlow.new,
    );

final class RegistrationFlow extends Notifier<RegistrationFlowState?> {
  @override
  RegistrationFlowState? build() => null;

  void start(RegistrationGrant grant, PhoneNumber phone) =>
      state = RegistrationFlowState(grant: grant, phone: phone);

  void clear() => state = null;
}

/// The current terms of use, loaded while a page that accepts them is
/// shown; invalidated after a `422 terms_outdated`.
final FutureProvider<Terms> currentTermsProvider =
    FutureProvider.autoDispose<Terms>(
      (ref) => ref.watch(termsRepositoryProvider).current(),
    );
