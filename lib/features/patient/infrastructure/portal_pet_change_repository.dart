import 'package:kiveto_mobile/core/errors/api_failure_mapper.dart';
import 'package:kiveto_mobile/core/network/portal_results.dart';
import 'package:kiveto_mobile/features/patient/domain/pet.dart';
import 'package:kiveto_mobile/features/patient/domain/pet_change.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';
import 'package:kiveto_mobile/shared/domain/idempotency_key.dart';
import 'package:kiveto_portal_api/kiveto_portal_api.dart' as api;
import 'package:tonik_util/tonik_util.dart';

/// [PetChangeRepository] on the generated `RequestsApi`: the only change
/// request code that sees the generated DTOs. Every wire enum is read by
/// an exhaustive switch (`unknown` kept), never by its JSON value.
final class PortalPetChangeRepository implements PetChangeRepository {
  new(api.Server server, this._failures) : _api = api.RequestsApi(server);

  /// The requests read at once: the pending ones of every pet are among
  /// the newest (3 open per pet and field at most, 10 a day per clinic).
  static const pageSize = 50;

  final api.RequestsApi _api;
  final ApiFailureMapper _failures;

  @override
  Future<String> requestChange(
    ClinicId clinicId,
    PetId petId,
    PetChangeDraft draft,
    IdempotencyKey key,
  ) async => switch (await _api.requestPetChange(
    clinicId: clinicId.value,
    petId: petId.value,
    idempotencyKey: key.value,
    body: api.PetChangeRequestCreation(
      field: _wireField(draft.field),
      proposedValue: draft.proposedValue,
      measuredOn: switch (draft.measuredOn) {
        final date? => Date(date.year, date.month, date.day),
        null => null,
      },
      note: draft.note,
    ),
  )) {
    TonikSuccess(value: api.RequestPetChangeResponse202(:final body)) =>
      body.requestId,
    final other => throw apiFailureOf(other, _failures),
  };

  @override
  Future<List<PetChangeRequest>> changeRequests(ClinicId clinicId) async =>
      switch (await _api.listRequests(
        clinicId: clinicId.value,
        limit: pageSize,
      )) {
        TonikSuccess(value: api.ListRequestsResponse200(:final body)) => [
          for (final view in body.items)
            if (view.kind == api.PortalRequestViewKindModel.petChange)
              _request(view),
        ],
        final other => throw apiFailureOf(other, _failures),
      };

  /// The field on the wire; [PetChangeField.unknown] has no value to send
  /// (the sheet never offers it).
  static api.PetChangeRequestCreationFieldModel _wireField(
    PetChangeField field,
  ) => switch (field) {
    PetChangeField.name => api.PetChangeRequestCreationFieldModel.name,
    PetChangeField.weight => api.PetChangeRequestCreationFieldModel.weight,
    PetChangeField.sterilization =>
      api.PetChangeRequestCreationFieldModel.sterilization,
    PetChangeField.chipNumber =>
      api.PetChangeRequestCreationFieldModel.chipNumber,
    PetChangeField.other => api.PetChangeRequestCreationFieldModel.other,
    PetChangeField.unknown => throw ArgumentError.value(
      field,
      'field',
      'an unknown field cannot be sent',
    ),
  };

  static PetChangeRequest _request(
    api.PortalRequestView view,
  ) => PetChangeRequest(
    id: view.id,
    petId: PetId(view.petId),
    field: switch (view.field) {
      api.$RawPortalRequestViewFieldModel.name => PetChangeField.name,
      api.$RawPortalRequestViewFieldModel.weight => PetChangeField.weight,
      api.$RawPortalRequestViewFieldModel.sterilization =>
        PetChangeField.sterilization,
      api.$RawPortalRequestViewFieldModel.chipNumber =>
        PetChangeField.chipNumber,
      api.$RawPortalRequestViewFieldModel.other => PetChangeField.other,
      api.$RawPortalRequestViewFieldModel.unknown ||
      null => PetChangeField.unknown,
    },
    proposedValue: view.proposedValue,
    status: switch (view.status) {
      api.PortalRequestViewStatusModel.submitted =>
        PortalRequestStatus.submitted,
      api.PortalRequestViewStatusModel.done => PortalRequestStatus.done,
      api.PortalRequestViewStatusModel.rejected => PortalRequestStatus.rejected,
      api.PortalRequestViewStatusModel.closed => PortalRequestStatus.closed,
      api.PortalRequestViewStatusModel.unknown => PortalRequestStatus.unknown,
    },
    submittedAt: clinicInstantOf(view.submittedAt),
  );
}
