// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i9;
import 'dart:core' as _i3;

import 'package:kiveto_portal_api/src/model/pet_last_weight_any_of_model.dart'
    as _i8;
import 'package:kiveto_portal_api/src/model/pet_life_status_model.dart' as _i7;
import 'package:kiveto_portal_api/src/model/pet_sex_model.dart' as _i5;
import 'package:kiveto_portal_api/src/model/pet_species_model.dart' as _i4;
import 'package:kiveto_portal_api/src/model/pet_sterilization_model.dart'
    as _i6;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

/// The listed shape of a pet, plus its latest weight, masked chip and referent vet.
@_i2.immutable
class Pet extends _i1.ObjectParameterEncodable implements _i1.UriEncodable {
  const Pet({
    required this.id,
    required this.name,
    required this.species,
    required this.breed,
    required this.sex,
    required this.sterilization,
    required this.birthDate,
    required this.initial,
    required this.lifeStatus,
    required this.lastWeight,
    required this.chipNumberMasked,
    required this.referentVet,
  });

  factory Pet.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    throw _i1.SimpleDecodingException(
      r'Simple encoding not supported for Pet: contains complex types',
    );
  }

  factory Pet.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'Pet');
    return Pet(
      id: _$map[r'id'].decodeJsonString(context: r'Pet.id'),
      name: _$map[r'name'].decodeJsonString(context: r'Pet.name'),
      species: _i4.PetSpeciesModel.fromJson(_$map[r'species']),
      breed: _$map[r'breed'].decodeJsonNullableString(context: r'Pet.breed'),
      sex: _i5.PetSexModel.fromJson(_$map[r'sex']),
      sterilization: _i6.PetSterilizationModel.fromJson(
        _$map[r'sterilization'],
      ),
      birthDate: _$map[r'birthDate'].decodeJsonNullableDate(
        context: r'Pet.birthDate',
      ),
      initial: _$map[r'initial'].decodeJsonString(context: r'Pet.initial'),
      lifeStatus: _i7.PetLifeStatusModel.fromJson(_$map[r'lifeStatus']),
      lastWeight: _$map[r'lastWeight'] == null
          ? null
          : _i8.PetLastWeightAnyOfModel.fromJson(_$map[r'lastWeight']),
      chipNumberMasked: _$map[r'chipNumberMasked'].decodeJsonNullableString(
        context: r'Pet.chipNumberMasked',
      ),
      referentVet: _$map[r'referentVet'].decodeJsonNullableString(
        context: r'Pet.referentVet',
      ),
    );
  }

  factory Pet.fromForm(_i3.String? value, {required _i3.bool explode}) {
    throw _i1.FormDecodingException(
      r'Form encoding not supported for Pet: contains complex types',
    );
  }

  final _i3.String id;

  final _i3.String name;

  final _i4.PetSpeciesModel species;

  final _i3.String? breed;

  final _i5.PetSexModel sex;

  final _i6.PetSterilizationModel sterilization;

  final _i1.Date? birthDate;

  final _i3.String initial;

  final _i7.PetLifeStatusModel lifeStatus;

  final _i8.PetLastWeightAnyOfModel lastWeight;

  final _i3.String? chipNumberMasked;

  final _i3.String? referentVet;

  @_i3.override
  _i3.Object? toJson() => {
    r'id': this.id,
    r'name': this.name,
    r'species': this.species.toJson(),
    r'breed': this.breed,
    r'sex': this.sex.toJson(),
    r'sterilization': this.sterilization.toJson(),
    r'birthDate': this.birthDate?.toJson(),
    r'initial': this.initial,
    r'lifeStatus': this.lifeStatus.toJson(),
    r'lastWeight': this.lastWeight?.toJson(),
    r'chipNumberMasked': this.chipNumberMasked,
    r'referentVet': this.referentVet,
  };

  Pet Function({
    _i3.String? id,
    _i3.String? name,
    _i4.PetSpeciesModel? species,
    _i3.String? breed,
    _i5.PetSexModel? sex,
    _i6.PetSterilizationModel? sterilization,
    _i1.Date? birthDate,
    _i3.String? initial,
    _i7.PetLifeStatusModel? lifeStatus,
    _i8.PetLastWeightAnyOfModel? lastWeight,
    _i3.String? chipNumberMasked,
    _i3.String? referentVet,
  })
  get copyWith {
    const _i3.Object _sentinel = _i3.Object();
    return ({
      _i3.String? id,
      _i3.String? name,
      _i4.PetSpeciesModel? species,
      _i3.Object? breed = _sentinel,
      _i5.PetSexModel? sex,
      _i6.PetSterilizationModel? sterilization,
      _i3.Object? birthDate = _sentinel,
      _i3.String? initial,
      _i7.PetLifeStatusModel? lifeStatus,
      _i3.Object? lastWeight = _sentinel,
      _i3.Object? chipNumberMasked = _sentinel,
      _i3.Object? referentVet = _sentinel,
    }) => Pet(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      breed: _i3.identical(breed, _sentinel)
          ? this.breed
          : (breed as _i3.String?),
      sex: sex ?? this.sex,
      sterilization: sterilization ?? this.sterilization,
      birthDate: _i3.identical(birthDate, _sentinel)
          ? this.birthDate
          : (birthDate as _i1.Date?),
      initial: initial ?? this.initial,
      lifeStatus: lifeStatus ?? this.lifeStatus,
      lastWeight: _i3.identical(lastWeight, _sentinel)
          ? this.lastWeight
          : (lastWeight as _i8.PetLastWeightAnyOfModel),
      chipNumberMasked: _i3.identical(chipNumberMasked, _sentinel)
          ? this.chipNumberMasked
          : (chipNumberMasked as _i3.String?),
      referentVet: _i3.identical(referentVet, _sentinel)
          ? this.referentVet
          : (referentVet as _i3.String?),
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is Pet &&
        other.id == this.id &&
        other.name == this.name &&
        other.species == this.species &&
        other.breed == this.breed &&
        other.sex == this.sex &&
        other.sterilization == this.sterilization &&
        other.birthDate == this.birthDate &&
        other.initial == this.initial &&
        other.lifeStatus == this.lifeStatus &&
        other.lastWeight == this.lastWeight &&
        other.chipNumberMasked == this.chipNumberMasked &&
        other.referentVet == this.referentVet;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([
      this.id,
      this.name,
      this.species,
      this.breed,
      this.sex,
      this.sterilization,
      this.birthDate,
      this.initial,
      this.lifeStatus,
      this.lastWeight,
      this.chipNumberMasked,
      this.referentVet,
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'id'] = _i1.PropertyValue.scalar(this.id);
    _$result[r'name'] = _i1.PropertyValue.scalar(this.name);
    _$result[r'species'] = _i1.PropertyValue.scalar(this.species.toJson());
    if (this.breed != null) {
      _$result[r'breed'] = _i1.PropertyValue.scalar(this.breed!);
    }
    _$result[r'sex'] = _i1.PropertyValue.scalar(this.sex.toJson());
    _$result[r'sterilization'] = _i1.PropertyValue.scalar(
      this.sterilization.toJson(),
    );
    if (this.birthDate != null) {
      _$result[r'birthDate'] = _i1.PropertyValue.scalar(
        this.birthDate!.toString(),
      );
    }
    _$result[r'initial'] = _i1.PropertyValue.scalar(this.initial);
    _$result[r'lifeStatus'] = _i1.PropertyValue.scalar(
      this.lifeStatus.toJson(),
    );
    if (this.lastWeight != null) {
      _$result[r'lastWeight'] = _i1.encodeAnyValueToPropertyValue(
        this.lastWeight!.toJson(),
        allowEmpty: allowEmpty,
      );
    }
    if (this.chipNumberMasked != null) {
      _$result[r'chipNumberMasked'] = _i1.PropertyValue.scalar(
        this.chipNumberMasked!,
      );
    }
    if (this.referentVet != null) {
      _$result[r'referentVet'] = _i1.PropertyValue.scalar(this.referentVet!);
    }
    return _$result;
  }

  @_i3.override
  _i3.String uriEncode({
    required _i3.bool allowEmpty,
    required _i9.Encoding textEncoding,
    _i3.bool useQueryComponent = false,
    _i3.bool allowReserved = false,
  }) {
    throw _i1.EncodingException(
      r'Cannot uriEncode Pet: complex types cannot be URI-encoded',
    );
  }
}
