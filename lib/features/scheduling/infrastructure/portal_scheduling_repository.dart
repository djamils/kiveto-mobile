import 'dart:convert';

import 'package:kiveto_mobile/core/errors/api_failure_mapper.dart';
import 'package:kiveto_mobile/core/network/portal_results.dart';
import 'package:kiveto_mobile/features/scheduling/domain/appointment.dart';
import 'package:kiveto_mobile/features/scheduling/domain/booking.dart';
import 'package:kiveto_mobile/features/scheduling/domain/scheduling_repository.dart';
import 'package:kiveto_mobile/features/scheduling/infrastructure/booking_wire.dart';
import 'package:kiveto_mobile/shared/domain/care_status.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';
import 'package:kiveto_mobile/shared/domain/clinic_instant.dart';
import 'package:kiveto_mobile/shared/domain/idempotency_key.dart';
import 'package:kiveto_mobile/shared/domain/local_date.dart';
import 'package:kiveto_mobile/shared/domain/portal_file.dart';
import 'package:kiveto_portal_api/kiveto_portal_api.dart' as api;
import 'package:tonik_util/tonik_util.dart';

/// [SchedulingRepository] on the generated `SchedulingApi`: the only
/// scheduling code that sees the generated DTOs.
///
/// The six appointment views of the contract (listed, read, booked for a
/// known or a new pet, rescheduled, cancelled) share one wire shape but
/// each has its own wrapper and enum classes: each view hands its fields to
/// one mapper, which reads the three enums through the list view's (same
/// values, same names) — not through a JSON round trip, whose encoding of
/// an `unknown` value throws.
final class PortalSchedulingRepository implements SchedulingRepository {
  new(api.Server server, this._failures) : _api = api.SchedulingApi(server);

  final api.SchedulingApi _api;
  final ApiFailureMapper _failures;

  @override
  Future<List<BookingMotif>> motifs(ClinicId clinicId, {String? petId}) async =>
      switch (await _api.listMotifs(clinicId: clinicId.value, petId: petId)) {
        TonikSuccess(value: api.ListMotifsResponse200(:final body)) => [
          for (final motif in body)
            bookingMotifOf(
              id: motif.id,
              label: motif.label,
              description: motif.description,
              durationMin: motif.durationMin,
              suggested: motif.suggested,
              suggestionReason: motif.suggestionReason,
            ),
        ],
        final other => throw apiFailureOf(other, _failures),
      };

  @override
  Future<List<Practitioner>> practitioners(
    ClinicId clinicId,
    MotifId motifId,
  ) async => switch (await _api.listPractitioners(
    clinicId: clinicId.value,
    motifId: motifId.value,
  )) {
    TonikSuccess(value: api.ListPractitionersResponse200(:final body)) => [
      for (final practitioner in body)
        practitionerOf(
          id: practitioner.id,
          displayName: practitioner.displayName,
        ),
    ],
    final other => throw apiFailureOf(other, _failures),
  };

  @override
  Future<List<AvailabilityDay>> availability(
    ClinicId clinicId,
    MotifId motifId,
    PractitionerId practitionerId,
    LocalDate from,
    LocalDate to,
  ) async => switch (await _api.getAvailability(
    clinicId: clinicId.value,
    motifId: motifId.value,
    practitionerId: practitionerId.value,
    from: dateWire(from),
    to: dateWire(to),
  )) {
    TonikSuccess(value: api.GetAvailabilityResponse200(:final body)) => [
      for (final day in body.days) availabilityDayOf(day),
    ],
    final other => throw apiFailureOf(other, _failures),
  };

  @override
  Future<Appointment> book(
    ClinicId clinicId,
    BookingRequest request,
    IdempotencyKey key,
  ) async => switch (request.pet) {
    ExistingPet(:final petId) => switch (await _api.bookAppointment(
      clinicId: clinicId.value,
      idempotencyKey: key.value,
      body: api.AppointmentBooking(
        petId: petId,
        motifId: request.motifId.value,
        practitionerId: request.practitionerId.value,
        startAt: slotWire(request.startAt),
      ),
    )) {
      TonikSuccess(value: api.BookAppointmentResponse201(:final body)) =>
        _booked(body),
      final other => throw apiFailureOf(other, _failures),
    },
    final NewPet pet => switch (await _api.bookAppointmentWithNewPet(
      clinicId: clinicId.value,
      idempotencyKey: key.value,
      body: api.AppointmentBookingWithNewPet(
        newPet: newPetWire(pet),
        motifId: request.motifId.value,
        practitionerId: request.practitionerId.value,
        startAt: slotWire(request.startAt),
      ),
    )) {
      TonikSuccess(
        value: api.BookAppointmentWithNewPetResponse201(:final body),
      ) =>
        _bookedWithNewPet(body),
      final other => throw apiFailureOf(other, _failures),
    },
  };

  @override
  Future<AppointmentPage> appointments(
    ClinicId clinicId,
    AppointmentScope scope, {
    String? cursor,
  }) async => switch (await _api.listAppointments(
    clinicId: clinicId.value,
    scope: switch (scope) {
      AppointmentScope.upcoming =>
        api.ApiPortalV1ClinicsClinicIdAppointmentsParametersModel.upcoming,
      AppointmentScope.past =>
        api.ApiPortalV1ClinicsClinicIdAppointmentsParametersModel.past,
    },
    cursor: cursor,
  )) {
    TonikSuccess(value: api.ListAppointmentsResponse200(:final body)) =>
      AppointmentPage(
        items: [for (final view in body.items) _listed(view)],
        nextCursor: body.nextCursor,
      ),
    final other => throw apiFailureOf(other, _failures),
  };

  @override
  Future<Appointment> appointment(ClinicId clinicId, AppointmentId id) async =>
      switch (await _api.getAppointment(
        clinicId: clinicId.value,
        appointmentId: id.value,
      )) {
        TonikSuccess(value: api.GetAppointmentResponse200(:final body)) =>
          _detail(body),
        final other => throw apiFailureOf(other, _failures),
      };

  @override
  Future<Appointment> reschedule(
    ClinicId clinicId,
    AppointmentId id, {
    required ClinicInstant startAt,
    required PractitionerId practitionerId,
  }) async => switch (await _api.rescheduleAppointment(
    clinicId: clinicId.value,
    appointmentId: id.value,
    body: api.AppointmentReschedule(
      startAt: slotWire(startAt),
      practitionerId: practitionerId.value,
    ),
  )) {
    TonikSuccess(value: api.RescheduleAppointmentResponse200(:final body)) =>
      _rescheduled(body),
    final other => throw apiFailureOf(other, _failures),
  };

  @override
  Future<Appointment> cancel(
    ClinicId clinicId,
    AppointmentId id,
    CancellationReason reason,
  ) async => switch (await _api.cancelAppointment(
    clinicId: clinicId.value,
    appointmentId: id.value,
    body: api.AppointmentCancellation(
      reason: switch (reason) {
        CancellationReason.unavailable =>
          api.AppointmentCancellationReasonModel.unavailable,
        CancellationReason.noLongerNeeded =>
          api.AppointmentCancellationReasonModel.noLongerNeeded,
        CancellationReason.seenElsewhere =>
          api.AppointmentCancellationReasonModel.seenElsewhere,
        CancellationReason.other =>
          api.AppointmentCancellationReasonModel.other,
      },
    ),
  )) {
    TonikSuccess(value: api.CancelAppointmentResponse200(:final body)) =>
      _cancelled(body),
    final other => throw apiFailureOf(other, _failures),
  };

  @override
  Future<PortalFile> calendar(ClinicId clinicId, AppointmentId id) async =>
      switch (await _api.getAppointmentCalendar(
        clinicId: clinicId.value,
        appointmentId: id.value,
      )) {
        TonikSuccess(
          value: api.GetAppointmentCalendarResponse200(:final body),
        ) =>
          PortalFile(
            utf8.encode(body),
            contentType: 'text/calendar',
            fileName: 'rendez-vous.ics',
          ),
        final other => throw apiFailureOf(other, _failures),
      };

  // The six views, field by field (their pet, care item and enum classes
  // differ; the references and the care item inside are shared).

  static Appointment _listed(api.AppointmentView view) => _appointment(
    id: view.id,
    startAt: view.startAt,
    endAt: view.endAt,
    pet: view.pet?.petReferenceView,
    motif: view.motif,
    practitioner: view.practitioner,
    status: view.status,
    source: view.source,
    cancellableUntil: view.cancellableUntil,
    questionnaire: view.questionnaireStatus,
    care: view.relatedCareItem?.relatedCareItemView,
  );

  static Appointment _detail(api.AppointmentDetailView view) => _appointment(
    id: view.id,
    startAt: view.startAt,
    endAt: view.endAt,
    pet: view.pet?.petReferenceView,
    motif: view.motif,
    practitioner: view.practitioner,
    status: view.status,
    source: view.source,
    cancellableUntil: view.cancellableUntil,
    questionnaire: view.questionnaireStatus,
    care: view.relatedCareItem?.relatedCareItemView,
  );

  static Appointment _booked(api.BookedAppointmentView view) => _appointment(
    id: view.id,
    startAt: view.startAt,
    endAt: view.endAt,
    pet: view.pet?.petReferenceView,
    motif: view.motif,
    practitioner: view.practitioner,
    status: view.status,
    source: view.source,
    cancellableUntil: view.cancellableUntil,
    questionnaire: view.questionnaireStatus,
    care: view.relatedCareItem?.relatedCareItemView,
  );

  static Appointment _bookedWithNewPet(
    api.BookedWithNewPetAppointmentView view,
  ) => _appointment(
    id: view.id,
    startAt: view.startAt,
    endAt: view.endAt,
    pet: view.pet?.petReferenceView,
    motif: view.motif,
    practitioner: view.practitioner,
    status: view.status,
    source: view.source,
    cancellableUntil: view.cancellableUntil,
    questionnaire: view.questionnaireStatus,
    care: view.relatedCareItem?.relatedCareItemView,
  );

  static Appointment _rescheduled(api.RescheduledAppointmentView view) =>
      _appointment(
        id: view.id,
        startAt: view.startAt,
        endAt: view.endAt,
        pet: view.pet?.petReferenceView,
        motif: view.motif,
        practitioner: view.practitioner,
        status: view.status,
        source: view.source,
        cancellableUntil: view.cancellableUntil,
        questionnaire: view.questionnaireStatus,
        care: view.relatedCareItem?.relatedCareItemView,
      );

  static Appointment _cancelled(api.CancelledAppointmentView view) =>
      _appointment(
        id: view.id,
        startAt: view.startAt,
        endAt: view.endAt,
        pet: view.pet?.petReferenceView,
        motif: view.motif,
        practitioner: view.practitioner,
        status: view.status,
        source: view.source,
        cancellableUntil: view.cancellableUntil,
        questionnaire: view.questionnaireStatus,
        care: view.relatedCareItem?.relatedCareItemView,
      );

  /// One appointment, whichever view it came in. Each view's status,
  /// source and questionnaire enums have the list view's values under the
  /// same names: they are read as the list view's, every value (`unknown`
  /// included) mapped by an exhaustive switch.
  static Appointment _appointment({
    required String id,
    required DateTime startAt,
    required DateTime endAt,
    required api.PetReferenceView? pet,
    required api.MotifReferenceView motif,
    required api.PractitionerView practitioner,
    required Enum status,
    required Enum source,
    required DateTime? cancellableUntil,
    required Enum questionnaire,
    required api.RelatedCareItemView? care,
  }) => Appointment(
    id: AppointmentId(id),
    startAt: clinicInstantOf(startAt),
    endAt: clinicInstantOf(endAt),
    petId: pet?.id,
    petName: pet?.name,
    motifId: switch (motif.id) {
      final String id => MotifId(id),
      null => null,
    },
    motifLabel: motif.label,
    practitionerId: PractitionerId(practitioner.id),
    practitionerName: practitioner.displayName,
    status: switch (sameName(
      api.AppointmentViewStatusModel.values,
      status,
      api.AppointmentViewStatusModel.unknown,
    )) {
      api.AppointmentViewStatusModel.confirmed => AppointmentStatus.confirmed,
      api.AppointmentViewStatusModel.pendingClinicConfirmation =>
        AppointmentStatus.pendingClinicConfirmation,
      api.AppointmentViewStatusModel.cancelledByClient =>
        AppointmentStatus.cancelledByClient,
      api.AppointmentViewStatusModel.cancelledByClinic =>
        AppointmentStatus.cancelledByClinic,
      api.AppointmentViewStatusModel.declined => AppointmentStatus.declined,
      api.AppointmentViewStatusModel.completed => AppointmentStatus.completed,
      api.AppointmentViewStatusModel.noShow => AppointmentStatus.noShow,
      api.AppointmentViewStatusModel.unknown => AppointmentStatus.unknown,
    },
    source: switch (sameName(
      api.AppointmentViewSourceModel.values,
      source,
      api.AppointmentViewSourceModel.unknown,
    )) {
      api.AppointmentViewSourceModel.clinic => AppointmentSource.clinic,
      api.AppointmentViewSourceModel.portal => AppointmentSource.portal,
      api.AppointmentViewSourceModel.unknown => AppointmentSource.unknown,
    },
    cancellableUntil: switch (cancellableUntil) {
      final DateTime until => clinicInstantOf(until),
      null => null,
    },
    questionnaire: switch (sameName(
      api.AppointmentViewQuestionnaireStatusModel.values,
      questionnaire,
      api.AppointmentViewQuestionnaireStatusModel.unknown,
    )) {
      api.AppointmentViewQuestionnaireStatusModel.notStarted =>
        QuestionnaireStatus.notStarted,
      api.AppointmentViewQuestionnaireStatusModel.submitted =>
        QuestionnaireStatus.submitted,
      api.AppointmentViewQuestionnaireStatusModel.unknown =>
        QuestionnaireStatus.unknown,
    },
    relatedCareItem: switch (care) {
      final api.RelatedCareItemView item => RelatedCareItem(
        kind: item.kind,
        label: item.label,
        dueOn: localDateOf(item.dueOn),
        status: switch (item.status) {
          api.RelatedCareItemViewStatusModel.booked => CareStatus.booked,
          api.RelatedCareItemViewStatusModel.overdue => CareStatus.overdue,
          api.RelatedCareItemViewStatusModel.dueSoon => CareStatus.dueSoon,
          api.RelatedCareItemViewStatusModel.upToDate => CareStatus.upToDate,
          api.RelatedCareItemViewStatusModel.unknown => CareStatus.unknown,
        },
      ),
      null => null,
    },
  );
}
