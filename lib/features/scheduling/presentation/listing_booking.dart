import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show NotifierProviderFamily;
import 'package:kiveto_mobile/core/di/core_providers.dart';
import 'package:kiveto_mobile/features/scheduling/di.dart';
import 'package:kiveto_mobile/features/scheduling/domain/appointment_request.dart';
import 'package:kiveto_mobile/features/scheduling/domain/booking.dart';
import 'package:kiveto_mobile/features/scheduling/domain/booking_draft.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/booking_wizard.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/scheduling_providers.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';
import 'package:kiveto_mobile/shared/domain/clinic_instant.dart';
import 'package:kiveto_mobile/shared/domain/listing_id.dart';
import 'package:kiveto_mobile/shared/domain/species.dart';

/// The new-client booking of a clinic of the directory (its motif on 11,
/// then the slot, then the pet and the request): one per listing, alive
/// while one of its pages is mounted (11's motif block keeps it while the
/// steps are stacked over it), dropped with the last one; a new session
/// starts a new draft.
final NotifierProviderFamily<ListingBooking, ListingBookingState, ListingId>
listingBookingProvider = NotifierProvider.autoDispose
    .family<ListingBooking, ListingBookingState, ListingId>(ListingBooking.new);

/// Where the request of a new-client booking stands.
sealed class ListingSubmission {
  const new();
}

/// Not sent yet (or a choice changed since).
final class ListingIdle extends ListingSubmission {
  const new();
}

/// On its way.
final class ListingSending extends ListingSubmission {
  const new();
}

/// Refused or not delivered: [error] (an `ApiFailure`); a retry of the
/// same content sends the same key.
final class ListingFailed extends ListingSubmission {
  const new(this.error);

  final Object error;
}

/// Sent: the [request] as the server recorded it (pending until the
/// clinic decides).
final class ListingSent extends ListingSubmission {
  const new(this.request);

  final AppointmentRequest request;
}

/// What [ListingBooking.confirm] led to.
enum ListingOutcome {
  sent,

  /// Another booking took the slot: back to the slot step.
  slotTaken,
  failed,

  /// Nothing sent: incomplete, already on its way or sent, or the booking
  /// was dropped meanwhile.
  ignored,
}

@immutable
final class ListingBookingState {
  const new({
    required this.draft,
    this.clinicName,
    this.submission = const ListingIdle(),
    this.slotTaken = false,
  });

  /// The intent: no clinic of the account (a listing is not one), the
  /// motif, the practitioner, the slot, the new pet; and its key.
  final BookingDraft draft;

  /// The clinic's name, as its sheet showed it (the recap).
  final String? clinicName;
  final ListingSubmission submission;

  /// The last request found its slot taken: the slot step says so until
  /// the next choice.
  final bool slotTaken;
}

final class ListingBooking extends Notifier<ListingBookingState> {
  new(this.listingId);

  final ListingId listingId;

  @override
  ListingBookingState build() {
    ref.watch(sessionStatusProvider);
    return ListingBookingState(
      draft: BookingDraft.start(
        null,
        newKey: ref.watch(bookingKeyFactoryProvider),
      ),
    );
  }

  /// A new choice, the submission back to idle; none while a request is on
  /// its way (its answer is for the draft sent) nor once sent.
  void _choose(BookingDraft Function(BookingDraft draft) change) {
    if (state.submission case ListingSending() || ListingSent()) return;
    state = ListingBookingState(
      draft: change(state.draft),
      clinicName: state.clinicName,
    );
  }

  /// 11: the motif chosen in the clinic's sheet (named [clinicName]); a
  /// booking already sent starts over with a new draft.
  void start(BookingMotif motif, {required String clinicName}) {
    final current = state;
    switch (current.submission) {
      case ListingSending():
        return;
      case ListingSent():
        state = ListingBookingState(
          draft: BookingDraft.start(
            null,
            newKey: ref.read(bookingKeyFactoryProvider),
          ).withMotif(motif),
          clinicName: clinicName,
        );
      case ListingIdle() || ListingFailed():
        state = ListingBookingState(
          draft: current.draft.withMotif(motif),
          clinicName: clinicName,
        );
    }
  }

  /// Step 1: another practitioner (the slot goes).
  void choosePractitioner(Practitioner practitioner) =>
      _choose((draft) => draft.withPractitioner(practitioner));

  /// Step 1: a slot of [practitioner].
  void chooseSlot(Practitioner practitioner, ClinicInstant slot) =>
      _choose((draft) => draft.withPractitioner(practitioner).withSlot(slot));

  /// Step 2: the new pet as typed (the same name and species keep the
  /// draft, so its key).
  void setPet(String name, Species species) =>
      _choose((draft) => draft.withPet(NewPet(name, species)));

  /// Step 2: sends the request with the draft's key. A success reloads the
  /// appointments screen's requests; `409 slot_taken` marks the slot
  /// taken, reloads the availability and sends the owner back to the slot
  /// step.
  Future<ListingOutcome> confirm() async {
    final current = state;
    final draft = current.draft;
    final request = draft.request;
    if (request == null ||
        current.submission is ListingSending ||
        current.submission is ListingSent) {
      return ListingOutcome.ignored;
    }
    // A rebuild meanwhile (another session) or the booking closed gives
    // this ref up: its answer is dropped.
    final built = ref;
    final revision = ref.read(appointmentsRevisionProvider.notifier);
    state = ListingBookingState(
      draft: draft,
      clinicName: current.clinicName,
      submission: const ListingSending(),
    );
    try {
      final sent = await ref
          .read(newClientBookingRepositoryProvider)
          .request(listingId, request, draft.key);
      // Sent whatever became of the booking: screen 4 follows.
      revision.bump();
      if (!built.mounted) return ListingOutcome.ignored;
      state = ListingBookingState(
        draft: draft,
        clinicName: current.clinicName,
        submission: ListingSent(sent),
      );
      return ListingOutcome.sent;
    } on Object catch (error) {
      if (!built.mounted) return ListingOutcome.ignored;
      if (error case ConflictFailure(code: 'slot_taken')) {
        state = ListingBookingState(
          draft: draft.markTaken(request.startAt),
          clinicName: current.clinicName,
          slotTaken: true,
        );
        ref.invalidate(availabilityProvider);
        return ListingOutcome.slotTaken;
      }
      state = ListingBookingState(
        draft: draft,
        clinicName: current.clinicName,
        submission: ListingFailed(error),
      );
      return ListingOutcome.failed;
    }
  }
}
