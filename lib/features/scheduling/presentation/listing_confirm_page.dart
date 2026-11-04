import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiveto_mobile/features/client/client.dart';
import 'package:kiveto_mobile/features/scheduling/domain/appointment_request.dart';
import 'package:kiveto_mobile/features/scheduling/domain/booking.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/booking_layout.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/listing_booking.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/new_pet_form.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/scheduling_messages.dart';
import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';
import 'package:kiveto_mobile/shared/domain/listing_id.dart';
import 'package:kiveto_mobile/shared/domain/species.dart';
import 'package:kiveto_mobile/shared/presentation/async/async_views.dart';
import 'package:kiveto_mobile/shared/presentation/formatters/kiveto_format.dart';
import 'package:kiveto_mobile/shared/presentation/icons/lucide_glyph.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/kit/feedback.dart';
import 'package:kiveto_mobile/shared/presentation/kit/navigation.dart';
import 'package:kiveto_mobile/shared/presentation/kit/surfaces.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_colors.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_layout.dart';
import 'package:material_ui/material_ui.dart';

/// The `newPet.name` property path of a refused request.
const _newPetName = 'newPet.name';

/// Step 2 of 2 of the new-client booking of a clinic of the directory (the
/// layout of 14): « Votre animal » (the new pet's name and species), the
/// recap (clinic, motif, date, practitioner), « Envoyer la demande »; then
/// « Demande envoyée ». A refusal stays on the step with the server's word
/// in the bar above the button (under the name field for the name); a
/// retry of the same content sends the same key.
///
/// Exits: [onSeeAppointments] (the success, the request limit),
/// [onBackToDirectory] (the success, back on it), [onSlotTaken] (another
/// booking took the slot), [onBookAsClient] (already a client of the
/// clinic: its confirmed clinic of the same name made active first),
/// [onBack], [onClose].
class ListingConfirmPage extends ConsumerStatefulWidget {
  const new({
    required this.listingId,
    required this.onSeeAppointments,
    required this.onBackToDirectory,
    required this.onSlotTaken,
    required this.onBookAsClient,
    required this.onBack,
    required this.onClose,
    super.key,
  });

  final String listingId;
  final void Function(BuildContext context) onSeeAppointments;
  final void Function(BuildContext context) onBackToDirectory;
  final void Function(BuildContext context) onSlotTaken;
  final void Function(BuildContext context) onBookAsClient;
  final void Function(BuildContext context) onBack;
  final void Function(BuildContext context) onClose;

  @override
  ConsumerState<ListingConfirmPage> createState() => _ListingConfirmPageState();
}

class _ListingConfirmPageState extends ConsumerState<ListingConfirmPage> {
  final _name = TextEditingController();
  Species? _species;

  ListingId get _id => ListingId(widget.listingId);

  @override
  void initState() {
    super.initState();
    // Back on the step: the pet as it was sent or typed.
    if (ref.read(listingBookingProvider(_id)).draft.pet case NewPet(
      :final name,
      :final species,
    )) {
      _name.text = name;
      _species = species;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final pet = newPetOf(_name.text, _species);
    if (pet == null) return;
    final notifier = ref.read(listingBookingProvider(_id).notifier)
      ..setPet(pet.$1, pet.$2);
    final outcome = await notifier.confirm();
    if (outcome == ListingOutcome.slotTaken && mounted) {
      widget.onSlotTaken(context);
    }
  }

  /// The pet as typed, into the draft once complete (the same content keeps
  /// the key; a refused request goes back to idle): it is there when the
  /// step is shown again.
  void _typed() {
    setState(() {});
    if (newPetOf(_name.text, _species) case (final name, final species)) {
      ref.read(listingBookingProvider(_id).notifier).setPet(name, species);
    }
  }

  /// Already a client: `/me` read again (the clinic may have confirmed the
  /// link since), the confirmed clinic of the same name becomes the active
  /// one (else the active one stays, its chip switches), then the booking
  /// of a known client.
  Future<void> _bookAsClient(String clinicName) async {
    final container = ProviderScope.containerOf(context, listen: false)
      ..invalidate(meProvider);
    try {
      await container.read(meProvider.future);
    } on Object {
      // No account read: no clinic matches, the active one stays.
    }
    await selectConfirmedClinicNamed(container, clinicName);
    if (mounted) widget.onBookAsClient(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final booking = ref.watch(listingBookingProvider(_id));
    final submission = booking.submission;
    if (submission case ListingSent(:final request)) {
      return _Sent(
        request: request,
        onSeeAppointments: widget.onSeeAppointments,
        onBackToDirectory: widget.onBackToDirectory,
      );
    }
    final draft = booking.draft;
    final motif = draft.motif;
    final slot = draft.slot;
    if (motif == null || slot == null) {
      return FlowScaffold(
        children: [
          WizardHeader(
            step: 2,
            total: 2,
            stepLabel: l10n.listingBookingStepLabel(2),
            title: l10n.listingBookingPetTitle,
            onBack: () => widget.onBack(context),
            onClose: () => widget.onClose(context),
          ),
          EmptyState(
            glyph: LucideGlyph.calendar,
            title: l10n.listingBookingNoMotif,
            action: KivetoButton.outline(
              label: l10n.commonBack,
              onPressed: () => widget.onBack(context),
            ),
          ),
        ],
      );
    }
    final clinicName = booking.clinicName ?? '';
    final sending = submission is ListingSending;
    final error = switch (submission) {
      ListingFailed(:final error) => error,
      _ => null,
    };
    final message = error == null
        ? null
        : listingFailureMessage(l10n, error, shown: const {_newPetName});
    final (actionLabel, onAction) = switch (error == null
        ? null
        : failureCause(error)) {
      ApiFailure(code: 'already_linked') => (
        l10n.appointmentsBook,
        () => unawaited(_bookAsClient(clinicName)),
      ),
      ApiFailure(code: 'booking_request_limit') => (
        l10n.listingBookingSeeAppointments,
        () => widget.onSeeAppointments(context),
      ),
      NetworkFailure() ||
      ServerFailure() => (l10n.commonRetry, () => unawaited(_send())),
      _ => (null, null),
    };
    final ready = newPetOf(_name.text, _species) != null;
    void unlessSending(void Function(BuildContext context) exit) {
      if (!sending) exit(context);
    }

    return PopScope(
      canPop: !sending,
      child: FlowScaffold(
        // The server's answer sits above the button: the body may be
        // scrolled anywhere when it comes.
        bar: StickyCtaBar(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (message != null) ...[
                KivetoCallout.danger(
                  body: message,
                  actionLabel: actionLabel,
                  onAction: onAction,
                ),
                const SizedBox(height: KivetoSpace.m),
              ],
              KivetoButton.primary(
                label: l10n.renewalSend,
                loading: sending,
                onPressed: !ready || sending ? null : () => unawaited(_send()),
              ),
            ],
          ),
        ),
        children: [
          WizardHeader(
            step: 2,
            total: 2,
            stepLabel: l10n.listingBookingStepLabel(2),
            title: l10n.listingBookingPetTitle,
            onBack: () => unlessSending(widget.onBack),
            onClose: () => unlessSending(widget.onClose),
          ),
          NewPetForm(
            framed: false,
            name: _name,
            species: _species,
            nameError: error == null ? null : violationOf(error, _newPetName),
            onNameChanged: _typed,
            onSpecies: (species) {
              _species = species;
              _typed();
            },
          ),
          KivetoCard.list(
            radius: KivetoRadius.xl,
            children: [
              KivetoKeyValueRow(
                label: l10n.bookingRecapClinic,
                value: clinicName,
              ),
              KivetoKeyValueRow(
                label: l10n.bookingMotifLabel,
                value: motifWithDuration(l10n, motif.label, motif.durationMin),
              ),
              KivetoKeyValueRow(
                label: l10n.bookingRecapDate,
                value: slotLong(l10n, slot),
              ),
              KivetoKeyValueRow(
                label: l10n.bookingVetLabel,
                value: practitionerLabel(l10n, draft.practitioner?.displayName),
              ),
            ],
          ),
          KivetoFootnote(l10n.listingBookingFootnote),
        ],
      ),
    );
  }
}

/// « Demande envoyée » (C-34a): the slot the clinic must confirm, where to
/// follow the request; back returns to the directory.
class _Sent extends StatelessWidget {
  const new({
    required this.request,
    required this.onSeeAppointments,
    required this.onBackToDirectory,
  });

  final AppointmentRequest request;
  final void Function(BuildContext context) onSeeAppointments;
  final void Function(BuildContext context) onBackToDirectory;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) onBackToDirectory(context);
      },
      child: Scaffold(
        backgroundColor: KivetoColors.surface,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: SuccessView(
                      title: l10n.bookingPendingTitle,
                      message: l10n.listingBookingSentMessage(
                        slotDayInSentence(request.startAt),
                        KivetoFormat.time(request.startAt),
                      ),
                      note: l10n.listingBookingSentNote,
                    ),
                  ),
                ),
              ),
              BottomCtaArea(
                success: true,
                children: [
                  KivetoButton.primary(
                    label: l10n.listingBookingSeeAppointments,
                    onPressed: () => onSeeAppointments(context),
                  ),
                  KivetoLinkButton(
                    label: l10n.listingBookingBackToDirectory,
                    onPressed: () => onBackToDirectory(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
