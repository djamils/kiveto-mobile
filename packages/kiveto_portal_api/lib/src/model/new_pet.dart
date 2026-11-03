// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i5;
import 'dart:core' as _i3;

import 'package:kiveto_portal_api/src/model/new_pet_species_model.dart' as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class NewPet extends _i1.ObjectParameterEncodable implements _i1.UriEncodable {
  const NewPet({required this.name, this.species});

  factory NewPet.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {r'name', r'species'},
      listKeys: {},
      context: r'NewPet',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return NewPet(
      name: _$values[r'name'].decodeSimpleString(context: r'NewPet.name'),
      species: _$values[r'species'] == null
          ? null
          : _i4.NewPetSpeciesModel.fromSimple(
              _$values[r'species'],
              explode: explode,
            ),
    );
  }

  factory NewPet.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'NewPet');
    return NewPet(
      name: _$map[r'name'].decodeJsonString(context: r'NewPet.name'),
      species: _$map[r'species'] == null
          ? null
          : _i4.NewPetSpeciesModel.fromJson(_$map[r'species']),
    );
  }

  factory NewPet.fromForm(_i3.String? value, {required _i3.bool explode}) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {r'name', r'species'},
      listKeys: {},
      context: r'NewPet',
    );
    return NewPet(
      name: _$values[r'name'].decodeFormString(context: r'NewPet.name'),
      species: _$values[r'species'] == null
          ? null
          : _i4.NewPetSpeciesModel.fromForm(
              _$values[r'species'],
              explode: explode,
            ),
    );
  }

  final _i3.String name;

  final _i4.NewPetSpeciesModel? species;

  @_i3.override
  _i3.Object? toJson() => {
    r'name': this.name,
    if (this.species != null) r'species': this.species?.toJson(),
  };

  NewPet Function({_i3.String? name, _i4.NewPetSpeciesModel? species})
  get copyWith {
    const _i3.Object _sentinel = _i3.Object();
    return ({_i3.String? name, _i3.Object? species = _sentinel}) => NewPet(
      name: name ?? this.name,
      species: _i3.identical(species, _sentinel)
          ? this.species
          : (species as _i4.NewPetSpeciesModel?),
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is NewPet &&
        other.name == this.name &&
        other.species == this.species;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([this.name, this.species]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'name'] = _i1.PropertyValue.scalar(this.name);
    if (this.species != null) {
      _$result[r'species'] = _i1.PropertyValue.scalar(this.species!.toJson());
    }
    return _$result;
  }

  @_i3.override
  _i3.String uriEncode({
    required _i3.bool allowEmpty,
    required _i5.Encoding textEncoding,
    _i3.bool useQueryComponent = false,
    _i3.bool allowReserved = false,
  }) {
    throw _i1.EncodingException(
      r'Cannot uriEncode NewPet: complex types cannot be URI-encoded',
    );
  }
}
