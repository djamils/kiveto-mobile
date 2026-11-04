import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiveto_mobile/features/client/domain/consent.dart';
import 'package:kiveto_mobile/features/client/presentation/account_messages.dart';
import 'package:kiveto_mobile/features/client/presentation/account_providers.dart';
import 'package:kiveto_mobile/features/client/presentation/consent_history_sheet.dart';
import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';
import 'package:kiveto_mobile/shared/presentation/async/async_views.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/kit/forms.dart';
import 'package:kiveto_mobile/shared/presentation/kit/surfaces.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_colors.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_layout.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_text.dart';
import 'package:material_ui/material_ui.dart';

/// « Consentements » of the account screen (6) for the active clinic
/// ([clinicName]): one block per kind (C-11h's layout) with its SMS and
/// Email tiles (C-22b), then « Historique de mes consentements ». A tap
/// sends the change at once; the server decides (a kind sent anyway keeps
/// one channel: its refusal puts the tile back and says so).
class ConsentsSection extends ConsumerWidget {
  const new({required this.clinicName, super.key});

  /// The active clinic's name; null while unknown.
  final String? clinicName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final consents = ref.watch(consentsProvider);
    final clinicName = this.clinicName;
    final body = switch (consents) {
      AsyncValue(isLoading: true, hasError: true) => const _SkeletonCard(),
      // A refresh (pull-to-refresh, the reload after a 409) keeps the
      // tiles shown, all disabled: a change is not sent meanwhile.
      AsyncData(value: final state?, :final isLoading) => _ConsentsCard(
        state: state,
        loading: isLoading,
      ),
      AsyncError(:final error) => KivetoCard(
        child: ErrorView(
          error: error,
          title: _isNotFound(error)
              ? l10n.accountConsentsUnavailableTitle
              : null,
          message: _isNotFound(error)
              ? l10n.accountConsentsUnavailableBody
              : null,
          onRetry: () => ref.invalidate(consentsProvider),
        ),
      ),
      _ => const _SkeletonCard(),
    };
    final clinicId = switch (consents) {
      AsyncData(value: final state?) => state.clinicId,
      _ => null,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KivetoSectionHeader(
          l10n.accountConsentsTitle,
          description: clinicName == null
              ? null
              : l10n.accountConsentsDescription(clinicName),
        ),
        const SizedBox(height: KivetoSpace.m),
        body,
        if (clinicId != null) ...[
          const SizedBox(height: KivetoSpace.m),
          // Mockup 06: a plain 13/600 link, left-aligned.
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: KivetoInlineLinks([
              InlinePart.link(
                l10n.accountConsentsHistoryLink,
                underline: false,
                onTap: () => unawaited(
                  showConsentHistorySheet(
                    context,
                    clinicId: clinicId,
                    clinicName: clinicName,
                  ),
                ),
              ),
            ]),
          ),
        ],
      ],
    );
  }

  static bool _isNotFound(Object error) => switch (error) {
    NotFoundFailure() => true,
    _ => false,
  };
}

/// The consents of one clinic: the known kinds, in the page's order.
class _ConsentsCard extends ConsumerWidget {
  const new({required this.state, required this.loading});

  final ConsentsState state;

  /// The consents reload: every tile is disabled.
  final bool loading;

  Future<void> _toggle(
    BuildContext context,
    WidgetRef ref,
    Consent consent,
    ConsentChannel channel, {
    required bool enabled,
  }) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(consentsProvider.notifier)
          .setChannel(consent.kind, channel, enabled: enabled);
    } on Object catch (error) {
      final message = switch (error) {
        ConflictFailure() => l10n.accountConsentConflict,
        ValidationFailure()
            when consent.effect == ConsentEffect.channelPreference =>
          l10n.accountConsentKeepOneChannel,
        _ => failureMessage(l10n, error).$2,
      };
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return KivetoCard.list(
      children: [
        for (final kind in ConsentKind.known)
          if (state.consents.of(kind) case final consent?)
            _ConsentBlock(
              key: ValueKey(kind),
              title: consentKindTitle(l10n, kind),
              description: consentDescription(l10n, consent),
              consent: consent,
              saving: loading || state.saving.contains(kind),
              onChanged: (channel, {required enabled}) => unawaited(
                _toggle(context, ref, consent, channel, enabled: enabled),
              ),
            ),
      ],
    );
  }
}

/// One kind: its title and description (gap 3), then its SMS and Email
/// tiles, 12 below, 10 apart; disabled while the kind is being saved.
class _ConsentBlock extends StatelessWidget {
  const new({
    required this.title,
    required this.description,
    required this.consent,
    required this.saving,
    required this.onChanged,
    super.key,
  });

  final String title;
  final String description;
  final Consent consent;
  final bool saving;
  final void Function(ConsentChannel channel, {required bool enabled})
  onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      container: true,
      label: title,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ExcludeSemantics(child: Text(title, style: KivetoText.labelStrong)),
            const SizedBox(height: KivetoSpace.tight),
            Text(description, style: KivetoText.caption.copyWith(height: 1.4)),
            const SizedBox(height: KivetoSpace.ml),
            Row(
              children: [
                for (final channel in ConsentChannel.values) ...[
                  if (channel != ConsentChannel.values.first)
                    const SizedBox(width: KivetoSpace.m),
                  Expanded(
                    child: KivetoCheckboxTile(
                      label: consentChannelLabel(l10n, channel),
                      value: consent.channels.contains(channel),
                      onChanged: saving
                          ? null
                          : (enabled) => onChanged(channel, enabled: enabled),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// The consents loading: a 160 px card.
class _SkeletonCard extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) => Semantics(
    label: AppLocalizations.of(context).commonLoading,
    child: Container(
      height: 160,
      decoration: BoxDecoration(
        color: KivetoColors.surface,
        border: Border.all(color: KivetoColors.border),
        borderRadius: BorderRadius.circular(KivetoRadius.l),
      ),
    ),
  );
}
