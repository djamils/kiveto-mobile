import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiveto_mobile/features/client/client.dart';
import 'package:kiveto_mobile/features/scheduling/domain/appointment.dart';
import 'package:kiveto_mobile/features/scheduling/domain/booking.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/booking_layout.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/booking_wizard.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/scheduling_messages.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/scheduling_providers.dart';
import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';
import 'package:kiveto_mobile/shared/presentation/async/async_views.dart';
import 'package:kiveto_mobile/shared/presentation/icons/lucide_glyph.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/kit/feedback.dart';
import 'package:kiveto_mobile/shared/presentation/kit/forms.dart';
import 'package:kiveto_mobile/shared/presentation/kit/navigation.dart';
import 'package:kiveto_mobile/shared/presentation/kit/pills.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_layout.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_text.dart';
import 'package:material_ui/material_ui.dart';

/// Screen 13, step 2 of the booking (mockup 13): « Quel est le motif ? »,
/// the motifs the clinic opens online in its order, those the server
/// suggests for the pet first (« Rappel à faire »; the first one chosen),
/// and the emergency callout with the clinic's phone.
///
/// Exits: [onContinue] once a motif is chosen, [onBack], [onClose].
class BookingMotifPage extends ConsumerStatefulWidget {
  const new({
    required this.onContinue,
    required this.onBack,
    required this.onClose,
    super.key,
  });

  final void Function(BuildContext context) onContinue;
  final void Function(BuildContext context) onBack;
  final void Function(BuildContext context) onClose;

  @override
  ConsumerState<BookingMotifPage> createState() => _BookingMotifPageState();
}

class _BookingMotifPageState extends ConsumerState<BookingMotifPage> {
  /// The motif tapped (null: the draft's, else the first suggested).
  MotifId? _motifId;

  Future<void> _call(String phone) async {
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final draft = ref.watch(bookingWizardProvider).draft;
    final clinicId = draft.clinicId;
    final pet = draft.pet;
    final clinic = switch (ref.watch(activeClinicProvider)) {
      AsyncData(:final value?) when value.clinicId == clinicId => value,
      _ => null,
    };
    final motifs = clinicId == null
        ? null
        : ref.watch(
            bookingMotifsProvider((
              clinicId,
              switch (pet) {
                ExistingPet(:final petId) => petId,
                _ => null,
              },
            )),
          );
    // The suggested motifs first, each group in the clinic's order.
    final ordered = switch (motifs) {
      AsyncData(:final value) => [
        for (final motif in value)
          if (motif.suggested) motif,
        for (final motif in value)
          if (!motif.suggested) motif,
      ],
      _ => const <BookingMotif>[],
    };
    BookingMotif? find(MotifId? id) =>
        ordered.where((motif) => motif.id == id).firstOrNull;
    final chosen =
        find(_motifId) ??
        find(draft.motif?.id) ??
        ordered.where((motif) => motif.suggested).firstOrNull;
    final subtitle = [?pet?.name, ?clinic?.name].join(' · ');
    final phone = clinic?.phone;
    return FlowScaffold(
      bar: StickySummaryBar(
        label: l10n.bookingMotifLabel,
        value: chosen?.label ?? l10n.bookingMotifEmpty,
        action: KivetoButton.primary(
          label: l10n.commonContinue,
          size: KivetoButtonSize.medium,
          onPressed: chosen == null
              ? null
              : () {
                  ref.read(bookingWizardProvider.notifier).chooseMotif(chosen);
                  widget.onContinue(context);
                },
        ),
      ),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            WizardHeader(
              step: 2,
              stepLabel: l10n.bookingStepLabel(2),
              title: l10n.screenBookingMotifTitle,
              onBack: () => widget.onBack(context),
              onClose: () => widget.onClose(context),
            ),
            if (subtitle.isNotEmpty) ...[
              const SizedBox(height: KivetoSpace.xs),
              Text(
                pet != null && clinic != null
                    ? l10n.bookingMotifSubtitle(pet.name, clinic.name)
                    : subtitle,
                style: KivetoText.body,
              ),
            ],
          ],
        ),
        switch (motifs) {
          null => const BookingClinicPending(),
          AsyncValue(isLoading: true, hasError: true) => const _Loading(),
          AsyncData() when ordered.isEmpty => EmptyState(
            glyph: LucideGlyph.calendar,
            title: l10n.bookingMotifsEmptyTitle,
            body: l10n.bookingMotifsEmptyBody,
          ),
          AsyncData() => Semantics(
            container: true,
            label: l10n.bookingMotifLabel,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < ordered.length; i++) ...[
                  if (i > 0) const SizedBox(height: KivetoSpace.sm),
                  KivetoRadioCard(
                    title: ordered[i].label,
                    subtitle: motifMeta(l10n, ordered[i]),
                    pill: ordered[i].suggested
                        ? StatusPill(
                            l10n.bookingMotifSuggested,
                            tone: StatusTone.warning,
                            compact: true,
                          )
                        : null,
                    selected: ordered[i].id == chosen?.id,
                    onTap: () => setState(() => _motifId = ordered[i].id),
                  ),
                ],
              ],
            ),
          ),
          AsyncError(:final error) when _notOpen(error) => ErrorView(
            error: error,
            title: l10n.bookingNotOpenTitle,
            message: l10n.bookingNotOpenBody,
          ),
          AsyncError(:final error) => ErrorView(
            error: error,
            onRetry: () => ref.invalidate(bookingMotifsProvider),
          ),
          _ => const _Loading(),
        },
        if (phone == null)
          KivetoCallout.danger(body: l10n.bookingEmergencyNoPhone)
        else
          KivetoCallout.danger(
            body: l10n.bookingEmergency,
            actionLabel: l10n.bookingCall,
            onAction: () => unawaited(_call(phone)),
          ),
      ],
    );
  }
}

/// The clinic closed online booking.
bool _notOpen(Object error) => switch (failureCause(error)) {
  ApiFailure(code: 'booking_not_open') => true,
  _ => false,
};

class _Loading extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) =>
      const SizedBox(height: 160, child: LoadingView());
}
