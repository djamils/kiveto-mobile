import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiveto_mobile/core/di/core_providers.dart';
import 'package:kiveto_mobile/features/identity_access/di.dart';
import 'package:kiveto_mobile/features/identity_access/domain/otp_verification.dart';
import 'package:kiveto_mobile/features/identity_access/presentation/flows.dart';
import 'package:kiveto_mobile/features/identity_access/presentation/identity_messages.dart';
import 'package:kiveto_mobile/features/identity_access/presentation/terms_consent.dart';
import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';
import 'package:kiveto_mobile/shared/presentation/icons/kiveto_icon.dart';
import 'package:kiveto_mobile/shared/presentation/icons/lucide_glyph.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/kit/feedback.dart';
import 'package:kiveto_mobile/shared/presentation/kit/forms.dart';
import 'package:kiveto_mobile/shared/presentation/kit/pills.dart';
import 'package:kiveto_mobile/shared/presentation/kit/surfaces.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_colors.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_layout.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_text.dart';
import 'package:material_ui/material_ui.dart';

/// The pending invitations of a verified number (screen 0's language):
/// one invitation as a card, several as a choice; each accepted with the
/// onboarding grant and the terms (`AcceptPendingInvitation`).
///
/// Exits: [onDone] to the home (no invitation left, "Plus tard", or a page
/// opened signed in without its flow); [onRestart] to the welcome page
/// (signed out: "Revenir à l'accueil", "Se reconnecter", a page opened
/// without its flow).
class OnboardingInvitationsPage extends ConsumerStatefulWidget {
  const new({required this.onDone, required this.onRestart, super.key});

  final void Function(BuildContext context) onDone;
  final void Function(BuildContext context) onRestart;

  @override
  ConsumerState<OnboardingInvitationsPage> createState() =>
      _OnboardingInvitationsPageState();
}

class _OnboardingInvitationsPageState
    extends ConsumerState<OnboardingInvitationsPage> {
  String? _selectedId;
  bool _accepted = false;
  bool _sending = false;
  String? _error;
  bool _restartable = false;
  OnboardingState? _shown;

  @override
  void initState() {
    super.initState();
    if (ref.read(onboardingProvider) == null) {
      leaveWhenShown(context, () {
        if (ref.read(sessionStatusProvider) == SessionStatus.signedIn) {
          widget.onDone(context);
        } else {
          widget.onRestart(context);
        }
      });
    }
  }

  void _restart() {
    ref.read(onboardingProvider.notifier).clear();
    widget.onRestart(context);
  }

  void _later() {
    final onboarding = ref.read(onboardingProvider.notifier);
    widget.onDone(context);
    onboarding.clear();
  }

  PendingInvitation? _selected(List<PendingInvitation> invitations) {
    for (final invitation in invitations) {
      if (invitation.id == _selectedId) return invitation;
    }
    return invitations.firstOrNull;
  }

  Future<void> _accept(OnboardingState flow) async {
    final invitation = _selected(flow.invitations);
    final terms = ref.read(currentTermsProvider);
    // Not while the terms reload (after a terms_outdated): their version
    // would be the stale one.
    if (invitation == null ||
        terms is! AsyncData ||
        terms.isLoading ||
        _sending) {
      return;
    }
    final l10n = AppLocalizations.of(context);
    final onboarding = ref.read(onboardingProvider.notifier);
    setState(() {
      _sending = true;
      _error = null;
      _restartable = false;
    });
    try {
      await ref.read(acceptPendingInvitationProvider)(
        invitationId: invitation.id,
        onboarding: flow.grant,
        termsVersion: terms.requireValue.version,
      );
      if (!mounted) return;
      onboarding.accepted(invitation);
      if (ref.read(onboardingProvider)?.invitations.isEmpty ?? true) {
        widget.onDone(context);
        onboarding.clear();
        return;
      }
      setState(() {
        _sending = false;
        _selectedId = null;
      });
    } on Object catch (error) {
      if (!mounted) return;
      switch (error) {
        case ApiFailure(code: 'invitation_invalid'):
          onboarding.remove(invitation.id);
        case ApiFailure(code: 'terms_outdated'):
          ref.invalidate(currentTermsProvider);
      }
      setState(() {
        _sending = false;
        _error = identityErrorText(l10n, error);
        _restartable =
            error is ApiFailure && error.code == 'onboarding_invalid';
        if (error case ApiFailure(code: 'terms_outdated')) _accepted = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // A flow cleared on the way out stays shown while the page leaves.
    final flow = _shown = ref.watch(onboardingProvider) ?? _shown;
    if (flow == null) {
      return const Scaffold(backgroundColor: KivetoColors.surface);
    }
    final l10n = AppLocalizations.of(context);
    final terms = ref.watch(currentTermsProvider);
    final invitations = flow.invitations;
    final selected = _selected(invitations);
    final acceptedClinic = flow.acceptedClinicName;
    final error = _error;
    final ready =
        selected != null &&
        _accepted &&
        terms is AsyncData &&
        !terms.isLoading &&
        !_sending;
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
                        if (invitations.isNotEmpty) ...[
                          KivetoTag.brand(
                            invitations.length == 1
                                ? l10n.identityInvitationTag(
                                    invitations.single.clinicName,
                                  )
                                : l10n.identityOnboardingCount(
                                    invitations.length,
                                  ),
                          ),
                          const SizedBox(height: KivetoSpace.m),
                        ],
                        Semantics(
                          header: true,
                          child: Text(
                            l10n.identityInvitationTitleNoPet,
                            style: KivetoText.displaySmall,
                          ),
                        ),
                        const SizedBox(height: KivetoSpace.m),
                        Text(
                          l10n.identityOnboardingBody,
                          style: KivetoText.bodyLarge,
                        ),
                        const SizedBox(height: KivetoSpace.xl6),
                        if (acceptedClinic != null) ...[
                          _AcceptedLine(
                            l10n.identityOnboardingAccepted(acceptedClinic),
                          ),
                          const SizedBox(height: KivetoSpace.xl),
                        ],
                        if (invitations.isEmpty)
                          Text(
                            l10n.identityOnboardingNone,
                            style: KivetoText.body,
                          )
                        else if (invitations.length == 1)
                          KivetoCard(
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 16,
                            ),
                            child: _ClinicLines(invitations.single),
                          )
                        else
                          for (final invitation in invitations) ...[
                            if (invitation != invitations.first)
                              const SizedBox(height: KivetoSpace.sm),
                            KivetoRadioCard(
                              title: invitation.clinicName,
                              subtitle: invitation.clinicCity,
                              selected: invitation == selected,
                              onTap: () =>
                                  setState(() => _selectedId = invitation.id),
                            ),
                          ],
                        if (invitations.isNotEmpty) ...[
                          const SizedBox(height: KivetoSpace.xl),
                          TermsConsent(
                            value: _accepted,
                            onChanged: (value) =>
                                setState(() => _accepted = value),
                          ),
                        ],
                        if (error != null) ...[
                          const SizedBox(height: KivetoSpace.xl),
                          Semantics(
                            liveRegion: true,
                            child: KivetoCallout.danger(
                              body: error,
                              actionLabel: _restartable
                                  ? l10n.identityReconnect
                                  : null,
                              onAction: _restartable ? _restart : null,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: KivetoSpace.xl5),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (invitations.isNotEmpty)
                          KivetoButton.primary(
                            // "Activer mon espace" creates the space; once
                            // signed in, the space exists: accept.
                            label: invitations.length == 1 && !flow.signedIn
                                ? l10n.identityInvitationSubmit
                                : l10n.identityOnboardingAcceptSelected,
                            loading: _sending,
                            onPressed: ready
                                ? () => unawaited(_accept(flow))
                                : null,
                          ),
                        if (flow.signedIn) ...[
                          const SizedBox(height: KivetoSpace.l),
                          Center(
                            child: KivetoTextButton(
                              label: l10n.identityOnboardingLater,
                              onPressed: _later,
                            ),
                          ),
                        ] else ...[
                          const SizedBox(height: KivetoSpace.l),
                          KivetoInlineLinks(
                            linkParts(
                              l10n.identityOnboardingNotNow(
                                l10n.identityBackHome,
                              ),
                              [(l10n.identityBackHome, _restart)],
                              underline: false,
                            ),
                            textAlign: TextAlign.center,
                            style: KivetoText.bodySmall,
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
}

/// The clinic of a single invitation: its name (16/700) and city (13).
class _ClinicLines extends StatelessWidget {
  const new(this.invitation);

  final PendingInvitation invitation;

  @override
  Widget build(BuildContext context) {
    final city = invitation.clinicCity;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(invitation.clinicName, style: KivetoText.sectionTitle),
        if (city != null) ...[
          const SizedBox(height: KivetoSpace.xxs),
          Text(city, style: KivetoText.bodySmall),
        ],
      ],
    );
  }
}

/// A C-33a-style line: an accepted invitation.
class _AcceptedLine extends StatelessWidget {
  const new(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: Container(
      padding: const EdgeInsets.all(KivetoSpace.l),
      decoration: BoxDecoration(
        color: KivetoColors.canvas,
        borderRadius: BorderRadius.circular(KivetoRadius.l),
      ),
      child: Row(
        children: [
          const KivetoIcon(
            LucideGlyph.check,
            size: 16,
            strokeWidth: 2.4,
            color: KivetoColors.success,
          ),
          const SizedBox(width: KivetoSpace.m),
          Expanded(
            child: Text(
              text,
              style: KivetoText.labelSmall.copyWith(color: KivetoColors.ink),
            ),
          ),
        ],
      ),
    ),
  );
}
