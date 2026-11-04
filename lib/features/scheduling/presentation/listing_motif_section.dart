import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/listing_booking.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/scheduling_messages.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/scheduling_providers.dart';
import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';
import 'package:kiveto_mobile/shared/domain/listing_id.dart';
import 'package:kiveto_mobile/shared/presentation/async/async_views.dart';
import 'package:kiveto_mobile/shared/presentation/formatters/kiveto_format.dart';
import 'package:kiveto_mobile/shared/presentation/icons/lucide_glyph.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/kit/surfaces.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_colors.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_layout.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_text.dart';
import 'package:material_ui/material_ui.dart';

/// Places a call to [phone] (E.164) through the dialer seam; a SnackBar
/// says when no app took it.
Future<void> callClinic(
  BuildContext context,
  WidgetRef ref,
  String phone,
) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  final failed = AppLocalizations.of(context).bookingCallError;
  var opened = false;
  try {
    opened = await ref.read(phoneDialerProvider)(
      Uri(scheme: 'tel', path: phone),
    );
  } on Object catch (error) {
    debugPrint('Call not placed (${error.runtimeType})');
  }
  if (!opened) messenger?.showSnackBar(SnackBar(content: Text(failed)));
}

/// The « Motif » block of a clinic's sheet (11) for a new client: the
/// motifs the clinic opens online to new clients (C-11b rows: the label,
/// its length and description), the emergency hint with the clinic's
/// phone; tapping a motif starts the clinic's new-client booking with it
/// ([listingBookingProvider], kept alive by this block while the steps are
/// stacked over the sheet) and calls [onChooseMotif]. A clinic closed to
/// online requests ([onlineBooking] false, or `booking_not_open`) says so,
/// with « Appeler la clinique » when it has a [phone].
class ListingMotifSection extends ConsumerWidget {
  const new({
    required this.listingId,
    required this.clinicName,
    required this.onlineBooking,
    required this.acceptsNewClients,
    required this.onChooseMotif,
    super.key,
    this.phone,
  });

  final ListingId listingId;
  final String clinicName;
  final bool onlineBooking;
  final bool acceptsNewClients;

  /// E.164; null when the clinic gave none.
  final String? phone;
  final void Function(BuildContext context) onChooseMotif;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    // The draft lives while the sheet is shown under the booking's steps
    // (listened, not watched: its changes do not rebuild the sheet).
    ref.listen(listingBookingProvider(listingId), (_, _) {});
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KivetoSectionHeader(l10n.bookingMotifLabel),
        const SizedBox(height: KivetoSpace.m),
        if (!onlineBooking)
          _closed(
            context,
            ref,
            acceptsNewClients
                ? l10n.listingMotifNotOpen
                : l10n.listingMotifNoNewClients,
          )
        else
          _motifs(context, ref, l10n),
      ],
    );
  }

  /// A white card on the sheet's canvas (an info box, C-33a, would not
  /// stand out from it): why, then « Appeler la clinique » (C-4b with the
  /// phone glyph, as the unlisted card of 10).
  Widget _closed(BuildContext context, WidgetRef ref, String message) {
    final phone = this.phone;
    return KivetoCard(
      padding: const EdgeInsets.all(KivetoSpace.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(message, style: KivetoText.bodySmall.copyWith(height: 1.45)),
          if (phone != null) ...[
            const SizedBox(height: KivetoSpace.m),
            KivetoButton.outline(
              label: AppLocalizations.of(context).listingMotifCall,
              icon: LucideGlyph.phone,
              expand: true,
              onPressed: () => unawaited(callClinic(context, ref, phone)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _motifs(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final provider = listingMotifsProvider(listingId);
    switch (ref.watch(provider)) {
      case AsyncValue(isLoading: true, hasError: true):
        return const _Loading();
      case AsyncData(:final value) when value.isEmpty:
        return Text(l10n.listingMotifEmpty, style: KivetoText.bodySmall);
      case AsyncData(:final value):
        final phone = this.phone;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            KivetoCard.list(
              children: [
                for (final motif in value)
                  KivetoListRow.navigation(
                    title: motif.label,
                    meta: motifMeta(l10n, motif),
                    onTap: () {
                      ref
                          .read(listingBookingProvider(listingId).notifier)
                          .start(motif, clinicName: clinicName);
                      onChooseMotif(context);
                    },
                  ),
              ],
            ),
            if (phone != null) ...[
              const SizedBox(height: KivetoSpace.m),
              _UrgencyHint(
                phone: phone,
                onCall: () => unawaited(callClinic(context, ref, phone)),
              ),
            ],
          ],
        );
      case AsyncError(:final error) when _notOpen(error):
        return _closed(context, ref, l10n.listingMotifNotOpen);
      case AsyncError(:final error):
        return ErrorView(error: error, onRetry: () => ref.invalidate(provider));
      default:
        return const _Loading();
    }
  }
}

/// The clinic closed online booking to new clients.
bool _notOpen(Object error) => switch (failureCause(error)) {
  ApiFailure(code: 'booking_not_open') => true,
  _ => false,
};

/// « Urgence ? Appelez directement la clinique au 04 78 92 01 45. » (C-33f,
/// 12/1.4 grey), the number a link that calls it.
class _UrgencyHint extends StatelessWidget {
  const new({required this.phone, required this.onCall});

  final String phone;
  final VoidCallback onCall;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // The number kept on one line.
    final number = KivetoFormat.phone(phone).replaceAll(' ', ' ');
    const marker = '\u0001';
    final parts = l10n.listingMotifUrgency(marker).split(marker);
    final style = KivetoText.caption.copyWith(
      height: 1.4,
      color: KivetoColors.inkMuted,
    );
    return KivetoInlineLinks([
      InlinePart.text(parts.first),
      InlinePart.link(number, onTap: onCall, underline: false),
      if (parts.length > 1) InlinePart.text(parts.last),
    ], style: style);
  }
}

class _Loading extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) =>
      const SizedBox(height: 120, child: LoadingView());
}
