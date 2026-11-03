import 'package:kiveto_mobile/features/scheduling/domain/appointment.dart';
import 'package:kiveto_mobile/features/scheduling/domain/booking.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';
import 'package:kiveto_mobile/shared/domain/clinic_instant.dart';
import 'package:kiveto_mobile/shared/domain/idempotency_key.dart';
import 'package:kiveto_mobile/shared/domain/local_date.dart';
import 'package:kiveto_mobile/shared/domain/portal_file.dart';

/// The booking and the appointments of the owner in a clinic (Portal API).
/// Every method throws an `ApiFailure` on a failure; which slots exist,
/// whether a pet may book, the confirmation mode and the cancellation
/// window are the server's answers.
abstract interface class SchedulingRepository {
  /// The motifs open to online booking, in the clinic's order; with
  /// [petId], those matching a care item of the pet due are `suggested`.
  Future<List<BookingMotif>> motifs(ClinicId clinicId, {String? petId});

  /// The practitioners bookable online for [motifId], by name.
  Future<List<Practitioner>> practitioners(ClinicId clinicId, MotifId motifId);

  /// One day per clinic-local date from [from] to [to] (both included, 14
  /// days at most, [from] not before the clinic's today).
  Future<List<AvailabilityDay>> availability(
    ClinicId clinicId,
    MotifId motifId,
    PractitionerId practitionerId,
    LocalDate from,
    LocalDate to,
  );

  /// Books [request] (a known pet, or a new one created with the booking),
  /// sent with [key]: a retry with the same key answers the same
  /// appointment.
  Future<Appointment> book(
    ClinicId clinicId,
    BookingRequest request,
    IdempotencyKey key,
  );

  /// One page of the appointments of [scope]; [cursor] reads the next one.
  Future<AppointmentPage> appointments(
    ClinicId clinicId,
    AppointmentScope scope, {
    String? cursor,
  });

  Future<Appointment> appointment(ClinicId clinicId, AppointmentId id);

  /// Moves a portal appointment to [startAt] with [practitionerId].
  Future<Appointment> reschedule(
    ClinicId clinicId,
    AppointmentId id, {
    required ClinicInstant startAt,
    required PractitionerId practitionerId,
  });

  Future<Appointment> cancel(
    ClinicId clinicId,
    AppointmentId id,
    CancellationReason reason,
  );

  /// The `.ics` of an appointment (`text/calendar`).
  Future<PortalFile> calendar(ClinicId clinicId, AppointmentId id);
}
