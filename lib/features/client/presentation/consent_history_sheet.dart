import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiveto_mobile/features/client/domain/consent.dart';
import 'package:kiveto_mobile/features/client/presentation/account_messages.dart';
import 'package:kiveto_mobile/features/client/presentation/account_providers.dart';
import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';
import 'package:kiveto_mobile/shared/presentation/async/async_views.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/kit/feedback.dart';
import 'package:kiveto_mobile/shared/presentation/kit/navigation.dart';
import 'package:kiveto_mobile/shared/presentation/kit/surfaces.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_layout.dart';
import 'package:material_ui/material_ui.dart';

/// The consent history of a clinic, newest first, in a sheet: one row per
/// change (« Factures · SMS », « Accordé le 13 oct. 2026 · La clinique »),
/// « Afficher plus » while the server has more.
Future<void> showConsentHistorySheet(
  BuildContext context, {
  required ClinicId clinicId,
  String? clinicName,
}) => showKivetoSheet<void>(
  context: context,
  builder: (context) =>
      ConsentHistorySheet(clinicId: clinicId, clinicName: clinicName),
);

/// The content of the history sheet (see [showConsentHistorySheet]).
class ConsentHistorySheet extends ConsumerWidget {
  const new({required this.clinicId, super.key, this.clinicName});

  final ClinicId clinicId;
  final String? clinicName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final provider = consentHistoryProvider(clinicId);
    return KivetoSheet(
      title: l10n.accountHistoryTitle,
      subtitle: clinicName,
      children: [
        AsyncValueView(
          value: ref.watch(provider),
          onRetry: () => ref.invalidate(provider),
          data: (history) {
            final shown = [
              for (final entry in history.items)
                if (entry.kind != ConsentKind.unknown) entry,
            ];
            final moreError = history.moreError;
            void more() => unawaited(ref.read(provider.notifier).loadMore());
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // The card only with rows to show (the pages read so far may
                // hold only kinds this app does not know), the footnote only
                // without a next page either.
                if (shown.isNotEmpty)
                  KivetoCard.list(
                    children: [
                      for (final entry in shown)
                        KivetoListRow(
                          title: l10n.accountHistoryRow(
                            consentKindTitle(l10n, entry.kind),
                            consentChannelLabel(l10n, entry.channel),
                          ),
                          meta: consentHistoryMeta(l10n, entry),
                        ),
                    ],
                  )
                else if (history.nextCursor == null)
                  KivetoFootnote(l10n.accountHistoryEmpty),
                if (moreError != null) ...[
                  const SizedBox(height: KivetoSpace.m),
                  KivetoCallout.danger(
                    body: failureMessage(l10n, moreError).$2,
                    actionLabel: l10n.commonRetry,
                    onAction: more,
                  ),
                ] else if (history.nextCursor != null) ...[
                  const SizedBox(height: KivetoSpace.m),
                  KivetoButton.outline(
                    label: l10n.accountHistoryMore,
                    loading: history.loadingMore,
                    expand: true,
                    onPressed: more,
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}
