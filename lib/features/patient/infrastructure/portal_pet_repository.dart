import 'package:kiveto_mobile/core/errors/api_failure_mapper.dart';
import 'package:kiveto_mobile/core/network/portal_file_downloader.dart';
import 'package:kiveto_mobile/core/network/portal_results.dart';
import 'package:kiveto_mobile/features/patient/domain/care_item.dart';
import 'package:kiveto_mobile/features/patient/domain/pet.dart';
import 'package:kiveto_mobile/features/patient/domain/pet_repository.dart';
import 'package:kiveto_mobile/shared/domain/care_status.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';
import 'package:kiveto_mobile/shared/domain/local_date.dart';
import 'package:kiveto_mobile/shared/domain/portal_file.dart';
import 'package:kiveto_mobile/shared/domain/species.dart';
import 'package:kiveto_portal_api/kiveto_portal_api.dart' as api;
import 'package:tonik_util/tonik_util.dart';

/// [PetRepository] on the generated `PetsApi`; the booklet through the
/// [PortalFileDownloader] (never the generated `getVaccinationBooklet`,
/// whose 302 dart:io would follow to the unresolvable dev host).
///
/// The list and the sheet have their own generated enums (`PetSummary*`,
/// `Pet*`): both are mapped, `unknown` kept.
final class PortalPetRepository implements PetRepository {
  new(api.Server server, this._downloader, this._failures)
    : _api = api.PetsApi(server);

  final api.PetsApi _api;
  final PortalFileDownloader _downloader;
  final ApiFailureMapper _failures;

  @override
  Future<List<PetSummary>> pets(ClinicId clinicId) async =>
      switch (await _api.listPets(clinicId: clinicId.value)) {
        TonikSuccess(value: api.ListPetsResponse200(:final body)) => [
          for (final pet in body) _summary(pet),
        ],
        final other => throw apiFailureOf(other, _failures),
      };

  @override
  Future<Pet> pet(ClinicId clinicId, PetId petId) async => switch (await _api
      .getPet(clinicId: clinicId.value, petId: petId.value)) {
    TonikSuccess(value: api.GetPetResponse200(:final body)) => Pet(
      summary: PetSummary(
        id: PetId(body.id),
        name: body.name,
        species: switch (body.species) {
          api.PetSpeciesModel.dog => Species.dog,
          api.PetSpeciesModel.cat => Species.cat,
          api.PetSpeciesModel.nac => Species.nac,
          api.PetSpeciesModel.other => Species.other,
          api.PetSpeciesModel.unknown => Species.unknown,
        },
        breed: body.breed,
        sex: switch (body.sex) {
          api.PetSexModel.male => Sex.male,
          api.PetSexModel.female => Sex.female,
          api.PetSexModel.unknown || api.PetSexModel.unknown2 => Sex.unknown,
        },
        sterilization: switch (body.sterilization) {
          api.PetSterilizationModel.intact => Sterilization.intact,
          api.PetSterilizationModel.neutered => Sterilization.neutered,
          api.PetSterilizationModel.unknown ||
          api.PetSterilizationModel.unknown2 => Sterilization.unknown,
        },
        birthDate: _date(body.birthDate),
        initial: body.initial,
        lifeStatus: switch (body.lifeStatus) {
          api.PetLifeStatusModel.alive => LifeStatus.alive,
          api.PetLifeStatusModel.deceased => LifeStatus.deceased,
          api.PetLifeStatusModel.missing => LifeStatus.missing,
          api.PetLifeStatusModel.unknown => LifeStatus.unknown,
        },
      ),
      lastWeight: switch (body.lastWeight?.petWeightView) {
        final api.PetWeightView weight => PetWeight(
          grams: weight.weightGrams,
          at: localDateOf(weight.at),
        ),
        null => null,
      },
      chipNumberMasked: body.chipNumberMasked,
      referentVet: body.referentVet,
    ),
    final other => throw apiFailureOf(other, _failures),
  };

  @override
  Future<List<CareItem>> careItems(ClinicId clinicId, PetId petId) async =>
      switch (await _api.listPetCareItems(
        clinicId: clinicId.value,
        petId: petId.value,
      )) {
        TonikSuccess(value: api.ListPetCareItemsResponse200(:final body)) => [
          for (final item in body)
            CareItem(
              kind: item.kind,
              label: item.label,
              lastDoneOn: localDateOf(item.lastDoneOn),
              dueOn: localDateOf(item.dueOn),
              status: switch (item.status) {
                api.CareItemStatusModel.booked => CareStatus.booked,
                api.CareItemStatusModel.overdue => CareStatus.overdue,
                api.CareItemStatusModel.dueSoon => CareStatus.dueSoon,
                api.CareItemStatusModel.upToDate => CareStatus.upToDate,
                api.CareItemStatusModel.unknown => CareStatus.unknown,
              },
            ),
        ],
        final other => throw apiFailureOf(other, _failures),
      };

  @override
  Future<PortalFile> vaccinationBooklet(ClinicId clinicId, PetId petId) async {
    final file = await _downloader.download(
      '/api/portal/v1/clinics/${Uri.encodeComponent(clinicId.value)}'
      '/pets/${Uri.encodeComponent(petId.value)}/vaccination-booklet',
    );
    return PortalFile(
      file.bytes,
      contentType: file.contentType,
      fileName: file.fileName,
    );
  }

  static PetSummary _summary(api.PetSummary pet) => PetSummary(
    id: PetId(pet.id),
    name: pet.name,
    species: switch (pet.species) {
      api.PetSummarySpeciesModel.dog => Species.dog,
      api.PetSummarySpeciesModel.cat => Species.cat,
      api.PetSummarySpeciesModel.nac => Species.nac,
      api.PetSummarySpeciesModel.other => Species.other,
      api.PetSummarySpeciesModel.unknown => Species.unknown,
    },
    breed: pet.breed,
    sex: switch (pet.sex) {
      api.PetSummarySexModel.male => Sex.male,
      api.PetSummarySexModel.female => Sex.female,
      api.PetSummarySexModel.unknown ||
      api.PetSummarySexModel.unknown2 => Sex.unknown,
    },
    sterilization: switch (pet.sterilization) {
      api.PetSummarySterilizationModel.intact => Sterilization.intact,
      api.PetSummarySterilizationModel.neutered => Sterilization.neutered,
      api.PetSummarySterilizationModel.unknown ||
      api.PetSummarySterilizationModel.unknown2 => Sterilization.unknown,
    },
    birthDate: _date(pet.birthDate),
    initial: pet.initial,
    lifeStatus: switch (pet.lifeStatus) {
      api.PetSummaryLifeStatusModel.alive => LifeStatus.alive,
      api.PetSummaryLifeStatusModel.deceased => LifeStatus.deceased,
      api.PetSummaryLifeStatusModel.missing => LifeStatus.missing,
      api.PetSummaryLifeStatusModel.unknown => LifeStatus.unknown,
    },
  );

  static LocalDate? _date(Date? date) => switch (date) {
    final Date date => localDateOf(date),
    null => null,
  };
}
