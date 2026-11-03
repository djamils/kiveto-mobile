// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i5;
import 'dart:core' as _i3;

import 'package:kiveto_portal_api/src/model/pet_change_request_creation_field_model.dart'
    as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class PetChangeRequestCreation extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const PetChangeRequestCreation({
    required this.field,
    required this.proposedValue,
    this.measuredOn,
    this.note,
  });

  factory PetChangeRequestCreation.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {r'field', r'proposedValue', r'measuredOn', r'note'},
      listKeys: {},
      context: r'PetChangeRequestCreation',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return PetChangeRequestCreation(
      field: _i4.PetChangeRequestCreationFieldModel.fromSimple(
        _$values[r'field'],
        explode: explode,
      ),
      proposedValue: _$values[r'proposedValue'].decodeSimpleString(
        context: r'PetChangeRequestCreation.proposedValue',
      ),
      measuredOn: _$values[r'measuredOn'].decodeSimpleNullableDate(
        context: r'PetChangeRequestCreation.measuredOn',
      ),
      note: _$values[r'note'].decodeSimpleNullableString(
        context: r'PetChangeRequestCreation.note',
      ),
    );
  }

  factory PetChangeRequestCreation.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'PetChangeRequestCreation');
    return PetChangeRequestCreation(
      field: _i4.PetChangeRequestCreationFieldModel.fromJson(_$map[r'field']),
      proposedValue: _$map[r'proposedValue'].decodeJsonString(
        context: r'PetChangeRequestCreation.proposedValue',
      ),
      measuredOn: _$map[r'measuredOn'].decodeJsonNullableDate(
        context: r'PetChangeRequestCreation.measuredOn',
      ),
      note: _$map[r'note'].decodeJsonNullableString(
        context: r'PetChangeRequestCreation.note',
      ),
    );
  }

  factory PetChangeRequestCreation.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {r'field', r'proposedValue', r'measuredOn', r'note'},
      listKeys: {},
      context: r'PetChangeRequestCreation',
    );
    return PetChangeRequestCreation(
      field: _i4.PetChangeRequestCreationFieldModel.fromForm(
        _$values[r'field'],
        explode: explode,
      ),
      proposedValue: _$values[r'proposedValue'].decodeFormString(
        context: r'PetChangeRequestCreation.proposedValue',
      ),
      measuredOn: _$values[r'measuredOn'].decodeFormNullableDate(
        context: r'PetChangeRequestCreation.measuredOn',
      ),
      note: _$values[r'note'].decodeFormNullableString(
        context: r'PetChangeRequestCreation.note',
      ),
    );
  }

  final _i4.PetChangeRequestCreationFieldModel field;

  final _i3.String proposedValue;

  final _i1.Date? measuredOn;

  final _i3.String? note;

  @_i3.override
  _i3.Object? toJson() => {
    r'field': this.field.toJson(),
    r'proposedValue': this.proposedValue,
    r'measuredOn': this.measuredOn?.toJson(),
    r'note': this.note,
  };

  PetChangeRequestCreation Function({
    _i4.PetChangeRequestCreationFieldModel? field,
    _i3.String? proposedValue,
    _i1.Date? measuredOn,
    _i3.String? note,
  })
  get copyWith {
    const _i3.Object _sentinel = _i3.Object();
    return ({
      _i4.PetChangeRequestCreationFieldModel? field,
      _i3.String? proposedValue,
      _i3.Object? measuredOn = _sentinel,
      _i3.Object? note = _sentinel,
    }) => PetChangeRequestCreation(
      field: field ?? this.field,
      proposedValue: proposedValue ?? this.proposedValue,
      measuredOn: _i3.identical(measuredOn, _sentinel)
          ? this.measuredOn
          : (measuredOn as _i1.Date?),
      note: _i3.identical(note, _sentinel) ? this.note : (note as _i3.String?),
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is PetChangeRequestCreation &&
        other.field == this.field &&
        other.proposedValue == this.proposedValue &&
        other.measuredOn == this.measuredOn &&
        other.note == this.note;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([
      this.field,
      this.proposedValue,
      this.measuredOn,
      this.note,
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'field'] = _i1.PropertyValue.scalar(this.field.toJson());
    _$result[r'proposedValue'] = _i1.PropertyValue.scalar(this.proposedValue);
    if (this.measuredOn != null) {
      _$result[r'measuredOn'] = _i1.PropertyValue.scalar(
        this.measuredOn!.toString(),
      );
    }
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
      r'Cannot uriEncode PetChangeRequestCreation: complex types cannot be URI-encoded',
    );
  }
}
