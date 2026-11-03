import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiveto_mobile/core/di/core_providers.dart';
import 'package:kiveto_mobile/features/identity_access/domain/invitation_preview.dart';
import 'package:kiveto_mobile/features/identity_access/domain/terms.dart';
import 'package:kiveto_mobile/features/identity_access/presentation/flows.dart';
import 'package:kiveto_mobile/features/identity_access/presentation/identity_messages.dart';
import 'package:kiveto_mobile/features/identity_access/presentation/invitation_controller.dart';
import 'package:kiveto_mobile/features/identity_access/presentation/resend_countdown.dart';
import 'package:kiveto_mobile/features/identity_access/presentation/terms_consent.dart';
import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';
import 'package:kiveto_mobile/shared/presentation/async/async_views.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/kit/feedback.dart';
import 'package:kiveto_mobile/shared/presentation/kit/forms.dart';
import 'package:kiveto_mobile/shared/presentation/kit/pills.dart';
import 'package:kiveto_mobile/shared/presentation/kit/surfaces.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_colors.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_layout.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_text.dart';
import 'package:material_ui/material_ui.dart';

/// Screen 0, the invitation link (`/invitation#t=<token>`): the inviting
/// clinic, the code sent at once to the invited mobile, the terms, then
/// the acceptance (`AcceptInvitationByLink`). An expired, unknown or used
/// link gets its own explanation.
///
/// Exits: [onDone] to the home once the session is open (or from an
/// unusable link, signed in); [onSignIn] to the welcome page ("Rattacher
/// cette clinique", "Se connecter avec mon numéro").
class InvitationPage extends ConsumerStatefulWidget {
  const new({
    required this.token,
    required this.onDone,
    required this.onSignIn,
    super.key,
  });

  /// The token of the link's fragment; null when the link had none.
  final String? token;
  final void Function(BuildContext context) onDone;
  final void Function(BuildContext context) onSignIn;

  @override
  ConsumerState<InvitationPage> createState() => _InvitationPageState();
}

class _InvitationPageState extends ConsumerState<InvitationPage> {
  final _code = TextEditingController();
  bool _accepted = false;

  @override
  void initState() {
    super.initState();
    _open();
  }

  @override
  void didUpdateWidget(InvitationPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.token != widget.token) {
      _code.clear();
      _accepted = false;
      _open();
    }
  }

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  /// Reads the link after the frame (a provider is not changed while the
  /// tree builds).
  void _open() {
    final token = widget.token;
    if (token == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(ref.read(invitationControllerProvider.notifier).open(token));
      }
    });
  }

  void _retry() {
    final token = widget.token;
    if (token != null) {
      unawaited(ref.read(invitationControllerProvider.notifier).open(token));
    }
  }

  Future<void> _accept() async {
    final terms = ref.read(currentTermsProvider);
    // Not while the terms reload (after a terms_outdated): their version
    // would be the stale one.
    if (terms is! AsyncData<Terms> || terms.isLoading) return;
    final accepted = await ref
        .read(invitationControllerProvider.notifier)
        .accept(code: _code.text, termsVersion: terms.value.version);
    if (!mounted) return;
    if (accepted) {
      widget.onDone(context);
      return;
    }
    final state = ref.read(invitationControllerProvider);
    if (state case InvitationReady(
      acceptError: ApiFailure(code: 'terms_outdated'),
    )) {
      ref.invalidate(currentTermsProvider);
      setState(() => _accepted = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final signedIn = ref.watch(sessionStatusProvider) == SessionStatus.signedIn;
    if (widget.token == null) {
      return _ClosedView(
        reason: InvitationClosedReason.invalid,
        signedIn: signedIn,
        onDone: widget.onDone,
        onSignIn: widget.onSignIn,
      );
    }
    return switch (ref.watch(invitationControllerProvider)) {
      InvitationLoading() => _WaitingView(
        signedIn: signedIn,
        onDone: widget.onDone,
        onSignIn: widget.onSignIn,
        child: const LoadingView(),
      ),
      InvitationClosed(:final reason) => _ClosedView(
        reason: reason,
        signedIn: signedIn,
        onDone: widget.onDone,
        onSignIn: widget.onSignIn,
      ),
      InvitationLoadFailed(:final error) => _WaitingView(
        signedIn: signedIn,
        onDone: widget.onDone,
        onSignIn: widget.onSignIn,
        child: ErrorView(error: error, onRetry: _retry),
      ),
      final InvitationReady ready => _form(context, ready, signedIn),
    };
  }

  Widget _form(BuildContext context, InvitationReady ready, bool signedIn) {
    final l10n = AppLocalizations.of(context);
    final preview = ready.preview;
    final terms = ref.watch(currentTermsProvider);
    final controller = ref.read(invitationControllerProvider.notifier);
    final email = preview.email;
    final challenge = ready.challenge;
    final acceptError = ready.acceptError;
    final codeError = ready.codeError;
    // A code refusal under the code field; any other refusal above the
    // button.
    final codeFieldError = switch (acceptError) {
      ApiFailure(:final String code) when code.startsWith('otp_') =>
        identityErrorText(l10n, acceptError),
      RateLimitedFailure() => identityErrorText(l10n, acceptError),
      _ => null,
    };
    final otherError = acceptError == null || codeFieldError != null
        ? null
        : identityErrorText(l10n, acceptError);
    final canAccept =
        _code.text.length == 6 &&
        _accepted &&
        terms is AsyncData &&
        !terms.isLoading &&
        challenge != null &&
        !ready.accepting &&
        !ready.sendingCode;
    // No new code while an acceptance is in flight.
    final canResend = !ready.sendingCode && !ready.accepting;
    return Scaffold(
      backgroundColor: KivetoColors.surface,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  KivetoSpace.authGutter,
                  KivetoSpace.xl7,
                  KivetoSpace.authGutter,
                  kivetoBottomPadding(context, 28),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: KivetoBrandLockup(),
                        ),
                        const SizedBox(height: KivetoSpace.xl6),
                        KivetoTag.brand(
                          l10n.identityInvitationTag(preview.clinicName),
                        ),
                        const SizedBox(height: KivetoSpace.m),
                        Semantics(
                          header: true,
                          child: Text(
                            _title(l10n, preview),
                            style: KivetoText.displaySmall,
                          ),
                        ),
                        const SizedBox(height: KivetoSpace.m),
                        Text(
                          l10n.identityInvitationIntro,
                          style: KivetoText.bodyLarge,
                        ),
                        const SizedBox(height: KivetoSpace.xl6),
                        if (email != null) ...[
                          _ReadOnlyField(
                            label: l10n.identityEmailLabel,
                            value: email,
                            helpText: l10n.identityInvitationEmailHelp,
                          ),
                          const SizedBox(height: KivetoSpace.xl),
                        ],
                        KivetoCodeField(
                          label: l10n.identityInvitationCodeLabel(
                            preview.maskedPhone,
                          ),
                          hintText: l10n.identityInvitationCodeHint,
                          controller: _code,
                          errorText: codeFieldError,
                          onChanged: (_) {
                            controller.clearAcceptError();
                            setState(() {});
                          },
                        ),
                        if (challenge == null)
                          KivetoTextButton(
                            label: l10n.identityInvitationResend,
                            onPressed: canResend
                                ? () => unawaited(controller.resend())
                                : null,
                          )
                        else
                          ResendCountdown(
                            availableAt: challenge.resendAvailableAt,
                            builder: (context, remaining) => KivetoTextButton(
                              label: remaining > Duration.zero
                                  ? l10n.identityInvitationResendIn(
                                      ResendCountdown.format(remaining),
                                    )
                                  : l10n.identityInvitationResend,
                              onPressed: remaining > Duration.zero || !canResend
                                  ? null
                                  : () => unawaited(controller.resend()),
                            ),
                          ),
                        if (codeError != null)
                          Semantics(
                            liveRegion: true,
                            child: Text(
                              identityErrorText(l10n, codeError),
                              style: KivetoText.bodySmall.copyWith(
                                color: KivetoColors.danger,
                              ),
                            ),
                          )
                        else if (ready.resent)
                          Semantics(
                            liveRegion: true,
                            child: Text(
                              l10n.identityCodeResentSms,
                              style: KivetoText.bodySmall,
                            ),
                          ),
                        const SizedBox(height: KivetoSpace.xl),
                        TermsConsent(
                          value: _accepted,
                          onChanged: (value) =>
                              setState(() => _accepted = value),
                        ),
                        if (otherError != null) ...[
                          const SizedBox(height: KivetoSpace.xl),
                          Semantics(
                            liveRegion: true,
                            child: KivetoCallout.danger(body: otherError),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: KivetoSpace.xl5),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        KivetoButton.primary(
                          label: l10n.identityInvitationSubmit,
                          loading: ready.accepting,
                          onPressed: canAccept
                              ? () => unawaited(_accept())
                              : null,
                        ),
                        if (!signedIn) ...[
                          const SizedBox(height: KivetoSpace.l),
                          KivetoInlineLinks(
                            linkParts(
                              l10n.identityInvitationExistingAccount(
                                l10n.identityInvitationAttach,
                              ),
                              [
                                (
                                  l10n.identityInvitationAttach,
                                  () => widget.onSignIn(context),
                                ),
                              ],
                              underline: false,
                            ),
                            textAlign: TextAlign.center,
                            style: KivetoText.bodySmall,
                          ),
                        ],
                        if (signedIn) ...[
                          // Signed in, reached by a link: the way back.
                          const SizedBox(height: KivetoSpace.s),
                          KivetoLinkButton(
                            label: l10n.identityBackHome,
                            onPressed: () => widget.onDone(context),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _title(AppLocalizations l10n, InvitationPreview preview) =>
      preview.petNames.isEmpty
      ? l10n.identityInvitationTitleNoPet
      : l10n.identityInvitationTitle(joinNames(l10n, preview.petNames));
}

/// C-18b: a read-only field holding [value].
class _ReadOnlyField extends StatefulWidget {
  const new({required this.label, required this.value, this.helpText});

  final String label;
  final String value;
  final String? helpText;

  @override
  State<_ReadOnlyField> createState() => _ReadOnlyFieldState();
}

class _ReadOnlyFieldState extends State<_ReadOnlyField> {
  late final _controller = TextEditingController(text: widget.value);

  @override
  void didUpdateWidget(_ReadOnlyField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) _controller.text = widget.value;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => KivetoTextField(
    label: widget.label,
    controller: _controller,
    helpText: widget.helpText,
    readOnly: true,
  );
}

/// An invitation link that cannot be used: why, and the way out (the
/// sign-in by number, or the home when signed in).
class _ClosedView extends StatelessWidget {
  const new({
    required this.reason,
    required this.signedIn,
    required this.onDone,
    required this.onSignIn,
  });

  final InvitationClosedReason reason;
  final bool signedIn;
  final void Function(BuildContext context) onDone;
  final void Function(BuildContext context) onSignIn;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (title, body) = switch (reason) {
      InvitationClosedReason.expired => (
        l10n.identityInvitationExpiredTitle,
        l10n.identityInvitationExpiredBody,
      ),
      InvitationClosedReason.invalid => (
        l10n.identityInvitationInvalidTitle,
        l10n.identityInvitationInvalidBody,
      ),
      InvitationClosedReason.used => (
        l10n.identityInvitationUsedTitle,
        l10n.identityInvitationUsedBody,
      ),
    };
    return Scaffold(
      backgroundColor: KivetoColors.surface,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  KivetoSpace.authGutter,
                  KivetoSpace.xl7,
                  KivetoSpace.authGutter,
                  kivetoBottomPadding(context, 28),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: KivetoBrandLockup(),
                        ),
                        const SizedBox(height: KivetoSpace.xl6),
                        Semantics(
                          header: true,
                          child: Text(title, style: KivetoText.displaySmall),
                        ),
                        const SizedBox(height: KivetoSpace.m),
                        Text(body, style: KivetoText.bodyLarge),
                      ],
                    ),
                    const SizedBox(height: KivetoSpace.xl5),
                    KivetoButton.primary(
                      label: signedIn
                          ? l10n.identityBackHome
                          : l10n.identityInvitationSignIn,
                      onPressed: () =>
                          signedIn ? onDone(context) : onSignIn(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The link being read, or that could not be read: [child], and under it
/// the way out of the closed links (the page is reached by a link: no
/// back).
class _WaitingView extends StatelessWidget {
  const new({
    required this.child,
    required this.signedIn,
    required this.onDone,
    required this.onSignIn,
  });

  final Widget child;
  final bool signedIn;
  final void Function(BuildContext context) onDone;
  final void Function(BuildContext context) onSignIn;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: KivetoColors.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: child),
            Padding(
              padding: EdgeInsets.fromLTRB(
                KivetoSpace.authGutter,
                0,
                KivetoSpace.authGutter,
                kivetoBottomPadding(context, 28),
              ),
              child: KivetoLinkButton(
                label: signedIn
                    ? l10n.identityBackHome
                    : l10n.identityInvitationSignIn,
                onPressed: () => signedIn ? onDone(context) : onSignIn(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
