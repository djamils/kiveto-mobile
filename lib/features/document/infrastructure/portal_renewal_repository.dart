import 'package:kiveto_mobile/core/errors/api_failure_mapper.dart';
import 'package:kiveto_mobile/core/network/portal_results.dart';
import 'package:kiveto_mobile/features/document/domain/document.dart';
import 'package:kiveto_mobile/features/document/domain/renewal.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';
import 'package:kiveto_mobile/shared/domain/idempotency_key.dart';
import 'package:kiveto_portal_api/kiveto_portal_api.dart' as api;
import 'package:tonik_util/tonik_util.dart';

/// [RenewalRepository] on the generated `RequestsApi`: the only renewal
/// code that sees the generated DTOs.
final class PortalRenewalRepository implements RenewalRepository {
  new(api.Server server, this._failures) : _api = api.RequestsApi(server);

  final api.RequestsApi _api;
  final ApiFailureMapper _failures;

  @override
  Future<RenewalReceipt> requestRenewal(
    ClinicId clinicId,
    PrescriptionId prescriptionId,
    RenewalRequestDraft draft,
    IdempotencyKey key,
  ) async => switch (await _api.requestRenewal(
    clinicId: clinicId.value,
    prescriptionId: prescriptionId.value,
    idempotencyKey: key.value,
    body: api.RenewalRequestCreation(
      petCondition: switch (draft.condition) {
        PetCondition.improved =>
          api.RenewalRequestCreationPetConditionModel.improved,
        PetCondition.noImprovement =>
          api.RenewalRequestCreationPetConditionModel.noImprovement,
        PetCondition.adverseEffects =>
          api.RenewalRequestCreationPetConditionModel.adverseEffects,
      },
      note: draft.note,
    ),
  )) {
    TonikSuccess(value: api.RequestRenewalResponse202(:final body)) =>
      RenewalReceipt(
        requestId: body.requestId,
        // By name: the wire's status values are the domain's (an unknown
        // one kept unknown), never read through its JSON value.
        status:
            RenewalStatus.values.asNameMap()[body.status.name] ??
            RenewalStatus.unknown,
      ),
    final other => throw apiFailureOf(other, _failures),
  };
}
