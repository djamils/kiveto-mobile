import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiveto_mobile/features/identity_access/application/sign_in_with_code.dart';
import 'package:kiveto_mobile/features/identity_access/di.dart';
import 'package:kiveto_mobile/features/identity_access/domain/otp_channel.dart';
import 'package:kiveto_mobile/features/identity_access/presentation/flows.dart';
import 'package:kiveto_mobile/features/identity_access/presentation/identity_messages.dart';
import 'package:kiveto_mobile/features/identity_access/presentation/resend_countdown.dart';
import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/presentation/formatters/kiveto_format.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/kit/feedback.dart';
import 'package:kiveto_mobile/shared/presentation/kit/forms.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_colors.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_layout.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_text.dart';
import 'package:material_ui/material_ui.dart';

/// Screen 8, the code received by SMS: verified on the 6th digit
/// (`SignInWithCode`), resent by SMS or email once the countdown of
/// `resendAvailableAt` is over.
///
/// Exits, by the branch of the verification: [onSignedIn] (the session is
/// open), [onInvitations] (pending invitations, signed in or not),
/// [onRegister] (no account); [onRestart] back to the welcome page (the
/// back button, "Modifier", a request no longer valid, a page opened
/// without its flow).
class CodePage extends ConsumerStatefulWidget {
  const new({
    required this.onSignedIn,
    required this.onInvitations,
    required this.onRegister,
    required this.onRestart,
    super.key,
  });

  final void Function(BuildContext context) onSignedIn;
  final void Function(BuildContext context) onInvitations;
  final void Function(BuildContext context) onRegister;
  final void Function(BuildContext context) onRestart;

  @override
  ConsumerState<CodePage> createState() => _CodePageState();
}

class _CodePageState extends ConsumerState<CodePage> {
  final _code = TextEditingController();
  final _edit = TapGestureRecognizer();
  bool _verifying = false;
  bool _resending = false;
  String? _codeError;
  String? _resendError;
  bool _restartable = false;
  String? _notice;
  SignInFlowState? _shown;

  @override
  void initState() {
    super.initState();
    _edit.onTap = _back;
    if (ref.read(signInFlowProvider) == null) {
      leaveWhenShown(context, () => widget.onRestart(context));
    }
  }

  @override
  void dispose() {
    _code.dispose();
    _edit.dispose();
    super.dispose();
  }

  /// Back to the welcome page; not while a verification runs (its answer
  /// decides where the user goes).
  void _back() {
    if (!_verifying) widget.onRestart(context);
  }

  Future<void> _verify(String code) async {
    final flow = ref.read(signInFlowProvider);
    // Not while a resend replaces the challenge.
    if (flow == null || _verifying || _resending || code.length != 6) {
      return;
    }
    final l10n = AppLocalizations.of(context);
    setState(() {
      _verifying = true;
      _codeError = null;
    });
    try {
      final outcome = await ref.read(signInWithCodeProvider)(
        challengeId: flow.challenge.id,
        code: code,
      );
      if (!mounted) return;
      final signIn = ref.read(signInFlowProvider.notifier);
      switch (outcome) {
        case SignedIn(:final pendingInvitations, :final onboarding?)
            when pendingInvitations.isNotEmpty:
          ref
              .read(onboardingProvider.notifier)
              .start(
                grant: onboarding,
                invitations: pendingInvitations,
                signedIn: true,
              );
          widget.onInvitations(context);
        case SignedIn():
          widget.onSignedIn(context);
        case InvitationPending(:final onboarding, :final invitations):
          ref
              .read(onboardingProvider.notifier)
              .start(
                grant: onboarding,
                invitations: invitations,
                signedIn: false,
              );
          widget.onInvitations(context);
        case RegistrationRequired(:final registration):
          ref
              .read(registrationFlowProvider.notifier)
              .start(registration, flow.phone);
          widget.onRegister(context);
      }
      signIn.clear();
    } on Object catch (error) {
      if (!mounted) return;
      _code.clear();
      setState(() {
        _verifying = false;
        _codeError = identityErrorText(l10n, error);
        _restartable = isRestartFailure(error);
      });
    }
  }

  Future<void> _resend(OtpChannel channel) async {
    final flow = ref.read(signInFlowProvider);
    if (flow == null || _resending) return;
    final l10n = AppLocalizations.of(context);
    setState(() {
      _resending = true;
      _resendError = null;
      _notice = null;
    });
    try {
      final challenge = await ref
          .read(authRepositoryProvider)
          .resendCode(challengeId: flow.challenge.id, channel: channel);
      if (!mounted) return;
      ref.read(signInFlowProvider.notifier).replaceChallenge(challenge);
      setState(() {
        _resending = false;
        _notice = switch (channel) {
          OtpChannel.sms => l10n.identityCodeResentSms,
          OtpChannel.email => l10n.identityCodeResentEmail,
        };
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _resending = false;
        _resendError = identityErrorText(l10n, error);
        _restartable = isRestartFailure(error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // A flow cleared on the way out stays shown while the page leaves.
    final flow = _shown = ref.watch(signInFlowProvider) ?? _shown;
    if (flow == null) {
      return const Scaffold(backgroundColor: KivetoColors.surface);
    }
    final l10n = AppLocalizations.of(context);
    final phone = KivetoFormat.phone(flow.phone.e164);
    final sentence = l10n.identityCodeSentTo(phone);
    final at = sentence.indexOf(phone);
    final notice = _notice;
    final resendError = _resendError;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        backgroundColor: KivetoColors.surface,
        body: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                // iOS number pads have no return key: a drag closes them
                // (the submit stays pinned under the list, above the keyboard).
                child: ListView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(
                    KivetoSpace.authGutter,
                    KivetoSpace.xl,
                    KivetoSpace.authGutter,
                    KivetoSpace.xl,
                  ),
                  children: [
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: KivetoIconButton.back(onPressed: _back),
                    ),
                    const SizedBox(height: KivetoSpace.xl5),
                    Semantics(
                      header: true,
                      child: Text(
                        l10n.screenSignInCodeTitle,
                        style: KivetoText.pageTitle.copyWith(height: 1.15),
                      ),
                    ),
                    const SizedBox(height: KivetoSpace.sm),
                    Text.rich(
                      TextSpan(
                        style: KivetoText.bodyLarge,
                        children: [
                          if (at < 0)
                            TextSpan(text: sentence)
                          else ...[
                            TextSpan(text: sentence.substring(0, at)),
                            TextSpan(
                              text: phone,
                              style: const TextStyle(
                                color: KivetoColors.ink,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextSpan(
                              text: sentence.substring(at + phone.length),
                            ),
                          ],
                          const TextSpan(text: ' '),
                          TextSpan(
                            text: l10n.identityCodeEdit,
                            style: const TextStyle(
                              color: KivetoColors.brand,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                              decorationColor: KivetoColors.brand,
                            ),
                            recognizer: _edit,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: KivetoSpace.xl5),
                    KivetoOtpField(
                      legend: l10n.identityCodeLegend,
                      helpText: l10n.identityCodeHelp,
                      errorText: _codeError,
                      controller: _code,
                      autofocus: true,
                      onChanged: (_) => setState(() => _codeError = null),
                      onCompleted: (code) => unawaited(_verify(code)),
                    ),
                    const SizedBox(height: KivetoSpace.xl5),
                    ResendCountdown(
                      availableAt: flow.challenge.resendAvailableAt,
                      builder: (context, remaining) {
                        final waiting = remaining > Duration.zero;
                        final enabled = !waiting && !_resending && !_verifying;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            KivetoTextButton(
                              label: waiting
                                  ? l10n.identityCodeResendSmsIn(
                                      ResendCountdown.format(remaining),
                                    )
                                  : l10n.identityCodeResendSms,
                              onPressed: enabled
                                  ? () => unawaited(_resend(OtpChannel.sms))
                                  : null,
                            ),
                            const SizedBox(height: KivetoSpace.xs),
                            KivetoTextButton(
                              label: l10n.identityCodeResendEmail,
                              onPressed: enabled
                                  ? () => unawaited(_resend(OtpChannel.email))
                                  : null,
                            ),
                            if (notice != null) ...[
                              const SizedBox(height: KivetoSpace.xs),
                              Semantics(
                                liveRegion: true,
                                child: Text(
                                  notice,
                                  style: KivetoText.bodySmall,
                                ),
                              ),
                            ],
                            if (resendError != null) ...[
                              const SizedBox(height: KivetoSpace.xs),
                              Semantics(
                                liveRegion: true,
                                child: Text(
                                  resendError,
                                  style: KivetoText.bodySmall.copyWith(
                                    color: KivetoColors.danger,
                                  ),
                                ),
                              ),
                            ],
                            if (_restartable)
                              KivetoTextButton(
                                label: l10n.identityRestart,
                                onPressed: _back,
                              ),
                            if (!waiting) ...[
                              const SizedBox(height: KivetoSpace.sm),
                              KivetoFootnote(l10n.identityCodeNotReceived),
                            ],
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  KivetoSpace.authGutter,
                  KivetoSpace.l,
                  KivetoSpace.authGutter,
                  kivetoBottomPadding(context, 28),
                ),
                child: KivetoButton.primary(
                  label: l10n.identityCodeSubmit,
                  loading: _verifying,
                  onPressed: _code.text.length == 6 && !_resending
                      ? () => unawaited(_verify(_code.text))
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
