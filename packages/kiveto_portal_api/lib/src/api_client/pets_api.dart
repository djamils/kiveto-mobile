// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i8;

import 'package:dio/dio.dart' as _i11;
import 'package:kiveto_portal_api/src/operation/get_home.dart' as _i2;
import 'package:kiveto_portal_api/src/operation/get_pet.dart' as _i4;
import 'package:kiveto_portal_api/src/operation/get_pet_timeline.dart' as _i6;
import 'package:kiveto_portal_api/src/operation/get_vaccination_booklet.dart'
    as _i7;
import 'package:kiveto_portal_api/src/operation/list_pet_care_items.dart'
    as _i5;
import 'package:kiveto_portal_api/src/operation/list_pets.dart' as _i3;
import 'package:kiveto_portal_api/src/response_wrapper/get_home_response.dart'
    as _i10;
import 'package:kiveto_portal_api/src/response_wrapper/get_pet_response.dart'
    as _i13;
import 'package:kiveto_portal_api/src/response_wrapper/get_pet_timeline_response.dart'
    as _i15;
import 'package:kiveto_portal_api/src/response_wrapper/get_vaccination_booklet_response.dart'
    as _i16;
import 'package:kiveto_portal_api/src/response_wrapper/list_pet_care_items_response.dart'
    as _i14;
import 'package:kiveto_portal_api/src/response_wrapper/list_pets_response.dart'
    as _i12;
import 'package:kiveto_portal_api/src/server/server.dart' as _i1;
import 'package:tonik_util/tonik_util.dart' as _i9;

/// Resource 'Animaux' operations.
class PetsApi {
  PetsApi(_i1.Server server)
    : _getHome = _i2.GetHome(server.baseUrl, () => server.dio),
      _listPets = _i3.ListPets(server.baseUrl, () => server.dio),
      _getPet = _i4.GetPet(server.baseUrl, () => server.dio),
      _listPetCareItems = _i5.ListPetCareItems(
        server.baseUrl,
        () => server.dio,
      ),
      _getPetTimeline = _i6.GetPetTimeline(server.baseUrl, () => server.dio),
      _getVaccinationBooklet = _i7.GetVaccinationBooklet(
        server.baseUrl,
        () => server.dio,
      );

  final _i2.GetHome _getHome;

  final _i3.ListPets _listPets;

  final _i4.GetPet _getPet;

  final _i5.ListPetCareItems _listPetCareItems;

  final _i6.GetPetTimeline _getPetTimeline;

  final _i7.GetVaccinationBooklet _getVaccinationBooklet;

  /// L'accueil du propriétaire dans cette clinique.
  /// Animaux vivants seulement. Prochain rendez-vous (forme complète d'un rendez-vous), 3 soins aux échéances les plus proches, 2 derniers documents. Une section vide est un tableau vide (`nextAppointment: null`).
  _i8.Future<_i9.TonikResult<_i10.GetHomeResponse, _i11.Response<_i8.Object?>>>
  getHome({
    required _i8.String clinicId,
    _i9.TonikCancellation? cancellation,
  }) async => this._getHome(clinicId: clinicId, cancellation: cancellation);

  /// Les animaux du propriétaire dans cette clinique.
  /// Décédés et disparus compris (`lifeStatus`). Vivants d'abord, puis par nom.
  _i8.Future<_i9.TonikResult<_i12.ListPetsResponse, _i11.Response<_i8.Object?>>>
  listPets({
    required _i8.String clinicId,
    _i9.TonikCancellation? cancellation,
  }) async => this._listPets(clinicId: clinicId, cancellation: cancellation);

  /// La fiche d'un animal.
  /// `lastWeight` = pesée la plus récente entre la fiche animal et les consultations clôturées (à date égale, la fiche l'emporte). `referentVet` = vétérinaire du dernier compte rendu partagé avec l'appelant.
  _i8.Future<_i9.TonikResult<_i13.GetPetResponse, _i11.Response<_i8.Object?>>>
  getPet({
    required _i8.String clinicId,
    required _i8.String petId,
    _i9.TonikCancellation? cancellation,
  }) async => this._getPet(
    clinicId: clinicId,
    petId: petId,
    cancellation: cancellation,
  );

  /// Les soins préventifs à suivre pour un animal.
  /// Dernier acte de chaque protocole ayant une prochaine échéance, par échéance croissante. « Aujourd'hui » = date locale de la clinique. Vide pour un animal décédé ou disparu.
  _i8.Future<
    _i9.TonikResult<_i14.ListPetCareItemsResponse, _i11.Response<_i8.Object?>>
  >
  listPetCareItems({
    required _i8.String clinicId,
    required _i8.String petId,
    _i9.TonikCancellation? cancellation,
  }) async => this._listPetCareItems(
    clinicId: clinicId,
    petId: petId,
    cancellation: cancellation,
  );

  /// Les visites d'un animal dont le compte rendu a été partagé avec l'appelant.
  /// Par date de clôture décroissante. `date` = début de la consultation, avec le décalage de la clinique ; `vet` = nom figé au partage.
  _i8.Future<
    _i9.TonikResult<_i15.GetPetTimelineResponse, _i11.Response<_i8.Object?>>
  >
  getPetTimeline({
    required _i8.String clinicId,
    required _i8.String petId,
    _i8.String? cursor,
    _i8.int? limit,
    _i9.TonikCancellation? cancellation,
  }) async => this._getPetTimeline(
    clinicId: clinicId,
    petId: petId,
    cursor: cursor,
    limit: limit,
    cancellation: cancellation,
  );

  /// Télécharger le carnet de vaccination d'un animal.
  /// PDF généré à la volée et mis en cache tant que ses données ne changent pas (vaccinations, identité, puce, en-tête de la clinique). « Aucune vaccination enregistrée » quand il n'y en a pas. Servi aussi pour un animal décédé. Redirige vers une URL signée valable 5 minutes.
  _i8.Future<
    _i9.TonikResult<
      _i16.GetVaccinationBookletResponse,
      _i11.Response<_i8.Object?>
    >
  >
  getVaccinationBooklet({
    required _i8.String clinicId,
    required _i8.String petId,
    _i9.TonikCancellation? cancellation,
  }) async => this._getVaccinationBooklet(
    clinicId: clinicId,
    petId: petId,
    cancellation: cancellation,
  );
}
