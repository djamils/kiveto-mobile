// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i8;
import 'dart:core' as _i3;

import 'package:kiveto_portal_api/src/model/pet_summary_life_status_model.dart'
    as _i7;
import 'package:kiveto_portal_api/src/model/pet_summary_sex_model.dart' as _i5;
import 'package:kiveto_portal_api/src/model/pet_summary_species_model.dart'
    as _i4;
import 'package:kiveto_portal_api/src/model/pet_summary_sterilization_model.dart'
    as _i6;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class PetSummary extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const PetSummary({
    required this.id,
    required this.name,
    required this.species,
    required this.breed,
    required this.sex,
    required this.sterilization,
    required this.birthDate,
    required this.initial,
    required this.lifeStatus,
  });

  factory PetSummary.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {
        r'id',
        r'name',
        r'species',
        r'breed',
        r'sex',
        r'sterilization',
        r'birthDate',
        r'initial',
        r'lifeStatus',
      },
      listKeys: {},
      context: r'PetSummary',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return PetSummary(
      id: _$values[r'id'].decodeSimpleString(context: r'PetSummary.id'),
      name: _$values[r'name'].decodeSimpleString(context: r'PetSummary.name'),
      species: _i4.PetSummarySpeciesModel.fromSimple(
        _$values[r'species'],
        explode: explode,
      ),
      breed: _$values[r'breed'].decodeSimpleNullableString(
        context: r'PetSummary.breed',
      ),
      sex: _i5.PetSummarySexModel.fromSimple(
        _$values[r'sex'],
        explode: explode,
      ),
      sterilization: _i6.PetSummarySterilizationModel.fromSimple(
        _$values[r'sterilization'],
        explode: explode,
      ),
      birthDate: _$values[r'birthDate'].decodeSimpleNullableDate(
        context: r'PetSummary.birthDate',
      ),
      initial: _$values[r'initial'].decodeSimpleString(
        context: r'PetSummary.initial',
      ),
      lifeStatus: _i7.PetSummaryLifeStatusModel.fromSimple(
        _$values[r'lifeStatus'],
        explode: explode,
      ),
    );
  }

  factory PetSummary.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'PetSummary');
    return PetSummary(
      id: _$map[r'id'].decodeJsonString(context: r'PetSummary.id'),
      name: _$map[r'name'].decodeJsonString(context: r'PetSummary.name'),
      species: _i4.PetSummarySpeciesModel.fromJson(_$map[r'species']),
      breed: _$map[r'breed'].decodeJsonNullableString(
        context: r'PetSummary.breed',
      ),
      sex: _i5.PetSummarySexModel.fromJson(_$map[r'sex']),
      sterilization: _i6.PetSummarySterilizationModel.fromJson(
        _$map[r'sterilization'],
      ),
      birthDate: _$map[r'birthDate'].decodeJsonNullableDate(
        context: r'PetSummary.birthDate',
      ),
      initial: _$map[r'initial'].decodeJsonString(
        context: r'PetSummary.initial',
      ),
      lifeStatus: _i7.PetSummaryLifeStatusModel.fromJson(_$map[r'lifeStatus']),
    );
  }

  factory PetSummary.fromForm(_i3.String? value, {required _i3.bool explode}) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {
        r'id',
        r'name',
        r'species',
        r'breed',
        r'sex',
        r'sterilization',
        r'birthDate',
        r'initial',
        r'lifeStatus',
      },
      listKeys: {},
      context: r'PetSummary',
    );
    return PetSummary(
      id: _$values[r'id'].decodeFormString(context: r'PetSummary.id'),
      name: _$values[r'name'].decodeFormString(context: r'PetSummary.name'),
      species: _i4.PetSummarySpeciesModel.fromForm(
        _$values[r'species'],
        explode: explode,
      ),
      breed: _$values[r'breed'].decodeFormNullableString(
        context: r'PetSummary.breed',
      ),
      sex: _i5.PetSummarySexModel.fromForm(_$values[r'sex'], explode: explode),
      sterilization: _i6.PetSummarySterilizationModel.fromForm(
        _$values[r'sterilization'],
        explode: explode,
      ),
      birthDate: _$values[r'birthDate'].decodeFormNullableDate(
        context: r'PetSummary.birthDate',
      ),
      initial: _$values[r'initial'].decodeFormString(
        context: r'PetSummary.initial',
      ),
      lifeStatus: _i7.PetSummaryLifeStatusModel.fromForm(
        _$values[r'lifeStatus'],
        explode: explode,
      ),
    );
  }

  final _i3.String id;

  final _i3.String name;

  final _i4.PetSummarySpeciesModel species;

  final _i3.String? breed;

  final _i5.PetSummarySexModel sex;

  final _i6.PetSummarySterilizationModel sterilization;

  final _i1.Date? birthDate;

  final _i3.String initial;

  final _i7.PetSummaryLifeStatusModel lifeStatus;

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
  };

  PetSummary Function({
    _i3.String? id,
    _i3.String? name,
    _i4.PetSummarySpeciesModel? species,
    _i3.String? breed,
    _i5.PetSummarySexModel? sex,
    _i6.PetSummarySterilizationModel? sterilization,
    _i1.Date? birthDate,
    _i3.String? initial,
    _i7.PetSummaryLifeStatusModel? lifeStatus,
  })
  get copyWith {
    const _i3.Object _sentinel = _i3.Object();
    return ({
      _i3.String? id,
      _i3.String? name,
      _i4.PetSummarySpeciesModel? species,
      _i3.Object? breed = _sentinel,
      _i5.PetSummarySexModel? sex,
      _i6.PetSummarySterilizationModel? sterilization,
      _i3.Object? birthDate = _sentinel,
      _i3.String? initial,
      _i7.PetSummaryLifeStatusModel? lifeStatus,
    }) => PetSummary(
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
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is PetSummary &&
        other.id == this.id &&
        other.name == this.name &&
        other.species == this.species &&
        other.breed == this.breed &&
        other.sex == this.sex &&
        other.sterilization == this.sterilization &&
        other.birthDate == this.birthDate &&
        other.initial == this.initial &&
        other.lifeStatus == this.lifeStatus;
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
    return _$result;
  }

  @_i3.override
  _i3.String uriEncode({
    required _i3.bool allowEmpty,
    required _i8.Encoding textEncoding,
    _i3.bool useQueryComponent = false,
    _i3.bool allowReserved = false,
  }) {
    throw _i1.EncodingException(
      r'Cannot uriEncode PetSummary: complex types cannot be URI-encoded',
    );
  }
}
