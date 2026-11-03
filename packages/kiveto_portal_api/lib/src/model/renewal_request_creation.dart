// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i5;
import 'dart:core' as _i3;

import 'package:kiveto_portal_api/src/model/renewal_request_creation_pet_condition_model.dart'
    as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class RenewalRequestCreation extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const RenewalRequestCreation({required this.petCondition, this.note});

  factory RenewalRequestCreation.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {r'petCondition', r'note'},
      listKeys: {},
      context: r'RenewalRequestCreation',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return RenewalRequestCreation(
      petCondition: _i4.RenewalRequestCreationPetConditionModel.fromSimple(
        _$values[r'petCondition'],
        explode: explode,
      ),
      note: _$values[r'note'].decodeSimpleNullableString(
        context: r'RenewalRequestCreation.note',
      ),
    );
  }

  factory RenewalRequestCreation.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'RenewalRequestCreation');
    return RenewalRequestCreation(
      petCondition: _i4.RenewalRequestCreationPetConditionModel.fromJson(
        _$map[r'petCondition'],
      ),
      note: _$map[r'note'].decodeJsonNullableString(
        context: r'RenewalRequestCreation.note',
      ),
    );
  }

  factory RenewalRequestCreation.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {r'petCondition', r'note'},
      listKeys: {},
      context: r'RenewalRequestCreation',
    );
    return RenewalRequestCreation(
      petCondition: _i4.RenewalRequestCreationPetConditionModel.fromForm(
        _$values[r'petCondition'],
        explode: explode,
      ),
      note: _$values[r'note'].decodeFormNullableString(
        context: r'RenewalRequestCreation.note',
      ),
    );
  }

  final _i4.RenewalRequestCreationPetConditionModel petCondition;

  final _i3.String? note;

  @_i3.override
  _i3.Object? toJson() => {
    r'petCondition': this.petCondition.toJson(),
    r'note': this.note,
  };

  RenewalRequestCreation Function({
    _i4.RenewalRequestCreationPetConditionModel? petCondition,
    _i3.String? note,
  })
  get copyWith {
    const _i3.Object _sentinel = _i3.Object();
    return ({
      _i4.RenewalRequestCreationPetConditionModel? petCondition,
      _i3.Object? note = _sentinel,
    }) => RenewalRequestCreation(
      petCondition: petCondition ?? this.petCondition,
      note: _i3.identical(note, _sentinel) ? this.note : (note as _i3.String?),
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RenewalRequestCreation &&
        other.petCondition == this.petCondition &&
        other.note == this.note;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([this.petCondition, this.note]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'petCondition'] = _i1.PropertyValue.scalar(
      this.petCondition.toJson(),
    );
    if (this.note != null) {
      _$result[r'note'] = _i1.PropertyValue.scalar(this.note!);
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
      r'Cannot uriEncode RenewalRequestCreation: complex types cannot be URI-encoded',
    );
  }
}
