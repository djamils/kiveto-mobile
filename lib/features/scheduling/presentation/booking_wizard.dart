import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiveto_mobile/core/di/core_providers.dart';
import 'package:kiveto_mobile/features/scheduling/di.dart';
import 'package:kiveto_mobile/features/scheduling/domain/appointment.dart';
import 'package:kiveto_mobile/features/scheduling/domain/booking.dart';
import 'package:kiveto_mobile/features/scheduling/domain/booking_draft.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/scheduling_providers.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';
import 'package:kiveto_mobile/shared/domain/clinic_instant.dart';
import 'package:kiveto_mobile/shared/domain/idempotency_key.dart';

/// The keys of the booking intents (a seam for the tests).
final bookingKeyFactoryProvider = Provider<IdempotencyKey Function()>(
  (ref) => IdempotencyKey.generate,
);

/// The id of the active clinic as the wizard sees it: a new value on a
/// session change or another clinic, none while `/me` reloads.
final FutureProvider<ClinicId?> _wizardClinicIdProvider =
    FutureProvider.autoDispose<ClinicId?>(activeClinicIdOf);

/// The booking wizard (screens 12 → 13 → 3 → 14): alive while one of its
/// pages is mounted, dropped with the last one (closed, done); a new
/// session or another active clinic starts a new draft.
final NotifierProvider<BookingWizard, BookingWizardState>
bookingWizardProvider =
    NotifierProvider.autoDispose<BookingWizard, BookingWizardState>(
      BookingWizard.new,
    );

/// Where the confirmation of a booking stands.
sealed class BookingSubmission {
  const new();
}

/// Not sent yet (or a choice changed since).
final class BookingIdle extends BookingSubmission {
  const new();
}

/// On its way.
final class BookingSubmitting extends BookingSubmission {
  const new();
}

/// Refused or not delivered: [error] (an `ApiFailure`); a retry sends the
/// same key.
final class BookingFailed extends BookingSubmission {
  const new(this.error);

  final Object error;
}

/// Booked: the [appointment] as the server recorded it.
final class BookingDone extends BookingSubmission {
  const new(this.appointment);

  final Appointment appointment;
}

/// What [BookingWizard.confirm] led to.
enum BookingOutcome {
  booked,

  /// Another booking took the slot: back to the slot step.
  slotTaken,
  failed,

  /// Nothing sent: incomplete, already on its way or done, or the wizard
  /// was dropped meanwhile.
  ignored,
}

@immutable
final class BookingWizardState {
  const new({
    required this.draft,
    this.submission = const BookingIdle(),
    this.slotTaken = false,
  });

  final BookingDraft draft;
  final BookingSubmission submission;

  /// The last confirmation found its slot taken: the slot step says so
  /// until the next choice.
  final bool slotTaken;
}

final class BookingWizard extends Notifier<BookingWizardState> {
  @override
  BookingWizardState build() {
    ref.watch(sessionStatusProvider);
    // A record of the loaded id: a reload of the id (a new session) starts
    // over, the same id kept does not.
    final clinicId = ref.watch(
      _wizardClinicIdProvider.select(
        (value) => switch (value) {
          AsyncData(:final value) => (value,),
          _ => null,
        },
      ),
    );
    return BookingWizardState(
      draft: BookingDraft.start(
        clinicId?.$1,
        newKey: ref.watch(bookingKeyFactoryProvider),
      ),
    );
  }

  /// A new choice, the submission back to idle; none while a confirmation
  /// is on its way (its answer is for the draft sent, and a second
  /// confirmation would book again with another key) nor once booked.
  void _choose(BookingDraft Function(BookingDraft draft) change) {
    if (state.submission case BookingSubmitting() || BookingDone()) return;
    state = BookingWizardState(draft: change(state.draft));
  }

  /// Step 12: who the appointment is for.
  void choosePet(BookingPet pet) => _choose((draft) => draft.withPet(pet));

  /// Step 13: why.
  void chooseMotif(BookingMotif motif) =>
      _choose((draft) => draft.withMotif(motif));

  /// Step 3: another practitioner (the slot goes).
  void choosePractitioner(Practitioner practitioner) =>
      _choose((draft) => draft.withPractitioner(practitioner));

  /// Step 3: a slot of [practitioner].
  void chooseSlot(Practitioner practitioner, ClinicInstant slot) =>
      _choose((draft) => draft.withPractitioner(practitioner).withSlot(slot));

  /// Step 14: books the draft with its key. A success reloads the
  /// appointments lists and the home, the pet's care items (and the pets
  /// after a new one); `409 slot_taken` marks the slot taken, reloads the
  /// availability and sends the owner back to the slot step.
  Future<BookingOutcome> confirm() async {
    final current = state;
    final draft = current.draft;
    final clinicId = draft.clinicId;
    final request = draft.request;
    if (clinicId == null ||
        request == null ||
        current.submission is BookingSubmitting ||
        current.submission is BookingDone) {
      return BookingOutcome.ignored;
    }
    // A rebuild meanwhile (another session or clinic) or the wizard closed
    // gives this ref up: its answer is dropped.
    final built = ref;
    final revision = ref.read(appointmentsRevisionProvider.notifier);
    state = BookingWizardState(
      draft: draft,
      submission: const BookingSubmitting(),
    );
    try {
      final appointment = await ref
          .read(schedulingRepositoryProvider)
          .book(clinicId, request, draft.key);
      // Booked whatever became of the wizard: the lists follow.
      revision.bump(newPet: request.pet is NewPet);
      if (!built.mounted) return BookingOutcome.ignored;
      state = BookingWizardState(
        draft: draft,
        submission: BookingDone(appointment),
      );
      return BookingOutcome.booked;
    } on Object catch (error) {
      if (!built.mounted) return BookingOutcome.ignored;
      if (error case ConflictFailure(code: 'slot_taken')) {
        state = BookingWizardState(
          draft: draft.markTaken(request.startAt),
          slotTaken: true,
        );
        ref.invalidate(availabilityProvider);
        return BookingOutcome.slotTaken;
      }
      state = BookingWizardState(
        draft: draft,
        submission: BookingFailed(error),
      );
      return BookingOutcome.failed;
    }
  }
}
