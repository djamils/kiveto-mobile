import 'package:kiveto_mobile/core/errors/api_failure_mapper.dart';
import 'package:kiveto_mobile/core/network/portal_results.dart';
import 'package:kiveto_mobile/features/document/domain/pet_name_repository.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';
import 'package:kiveto_portal_api/kiveto_portal_api.dart' as api;
import 'package:tonik_util/tonik_util.dart';

/// [PetNameRepository] on the generated `PetsApi` (the pets of the clinic,
/// deceased ones included: an old document may name them).
final class PortalPetNameRepository implements PetNameRepository {
  new(api.Server server, this._failures) : _api = api.PetsApi(server);

  final api.PetsApi _api;
  final ApiFailureMapper _failures;

  @override
  Future<Map<String, String>> petNames(ClinicId clinicId) async =>
      switch (await _api.listPets(clinicId: clinicId.value)) {
        TonikSuccess(value: api.ListPetsResponse200(:final body)) => {
          for (final pet in body) pet.id: pet.name,
        },
        final other => throw apiFailureOf(other, _failures),
      };
}
