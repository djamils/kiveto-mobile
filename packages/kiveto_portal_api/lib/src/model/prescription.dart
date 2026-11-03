// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i7;
import 'dart:core' as _i3;

import 'package:collection/collection.dart' as _i6;
import 'package:kiveto_portal_api/src/model/pet_reference_view.dart' as _i4;
import 'package:kiveto_portal_api/src/model/prescription_line_view.dart' as _i5;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class Prescription extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const Prescription({
    required this.id,
    required this.issuedAt,
    required this.vet,
    required this.pet,
    required this.lines,
  });

  factory Prescription.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    throw _i1.SimpleDecodingException(
      r'Simple encoding not supported for Prescription: contains complex types',
    );
  }

  factory Prescription.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'Prescription');
    return Prescription(
      id: _$map[r'id'].decodeJsonString(context: r'Prescription.id'),
      issuedAt: _$map[r'issuedAt'].decodeJsonDateTime(
        context: r'Prescription.issuedAt',
      ),
      vet: _$map[r'vet'].decodeJsonString(context: r'Prescription.vet'),
      pet: _i4.PetReferenceView.fromJson(_$map[r'pet']),
      lines: _$map[r'lines']
          .decodeJsonList<_i3.Object?>(context: r'Prescription.lines')
          .map(_i5.PrescriptionLineView.fromJson)
          .toList(),
    );
  }

  factory Prescription.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    throw _i1.FormDecodingException(
      r'Form encoding not supported for Prescription: contains complex types',
    );
  }

  final _i3.String id;

  final _i3.DateTime issuedAt;

  final _i3.String vet;

  final _i4.PetReferenceView pet;

  final _i3.List<_i5.PrescriptionLineView> lines;

  @_i3.override
  _i3.Object? toJson() => {
    r'id': this.id,
    r'issuedAt': this.issuedAt.toTimeZonedIso8601String(),
    r'vet': this.vet,
    r'pet': this.pet.toJson(),
    r'lines': this.lines.map((e) => e.toJson()).toList(),
  };

  Prescription Function({
    _i3.String? id,
    _i3.DateTime? issuedAt,
    _i3.String? vet,
    _i4.PetReferenceView? pet,
    _i3.List<_i5.PrescriptionLineView>? lines,
  })
  get copyWith {
    return ({
      _i3.String? id,
      _i3.DateTime? issuedAt,
      _i3.String? vet,
      _i4.PetReferenceView? pet,
      _i3.List<_i5.PrescriptionLineView>? lines,
    }) => Prescription(
      id: id ?? this.id,
      issuedAt: issuedAt ?? this.issuedAt,
      vet: vet ?? this.vet,
      pet: pet ?? this.pet,
      lines: lines ?? this.lines,
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    const _$deepEquals = _i6.DeepCollectionEquality();
    return other is Prescription &&
        other.id == this.id &&
        other.issuedAt == this.issuedAt &&
        other.vet == this.vet &&
        other.pet == this.pet &&
        _$deepEquals.equals(other.lines, this.lines);
  }

  @_i3.override
  _i3.int get hashCode {
    const deepEquals = _i6.DeepCollectionEquality();
    return _i3.Object.hashAll([
      this.id,
      this.issuedAt,
      this.vet,
      this.pet,
      deepEquals.hash(this.lines),
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) => throw _i1.EncodingException(
    r'parameterProperties not supported for Prescription: contains complex types',
  );

  @_i3.override
  _i3.String uriEncode({
    required _i3.bool allowEmpty,
    required _i7.Encoding textEncoding,
    _i3.bool useQueryComponent = false,
    _i3.bool allowReserved = false,
  }) {
    throw _i1.EncodingException(
      r'Cannot uriEncode Prescription: complex types cannot be URI-encoded',
    );
  }
}
