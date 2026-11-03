// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i6;
import 'dart:core' as _i3;

import 'package:kiveto_portal_api/src/model/home_care_item_view_status_model.dart'
    as _i5;
import 'package:kiveto_portal_api/src/model/pet_reference_view.dart' as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class HomeCareItemView extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const HomeCareItemView({
    required this.pet,
    required this.kind,
    required this.label,
    required this.lastDoneOn,
    required this.dueOn,
    required this.status,
  });

  factory HomeCareItemView.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    throw _i1.SimpleDecodingException(
      r'Simple encoding not supported for HomeCareItemView: contains complex types',
    );
  }

  factory HomeCareItemView.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'HomeCareItemView');
    return HomeCareItemView(
      pet: _i4.PetReferenceView.fromJson(_$map[r'pet']),
      kind: _$map[r'kind'].decodeJsonString(context: r'HomeCareItemView.kind'),
      label: _$map[r'label'].decodeJsonString(
        context: r'HomeCareItemView.label',
      ),
      lastDoneOn: _$map[r'lastDoneOn'].decodeJsonDate(
        context: r'HomeCareItemView.lastDoneOn',
      ),
      dueOn: _$map[r'dueOn'].decodeJsonDate(context: r'HomeCareItemView.dueOn'),
      status: _i5.HomeCareItemViewStatusModel.fromJson(_$map[r'status']),
    );
  }

  factory HomeCareItemView.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    throw _i1.FormDecodingException(
      r'Form encoding not supported for HomeCareItemView: contains complex types',
    );
  }

  final _i4.PetReferenceView pet;

  final _i3.String kind;

  final _i3.String label;

  final _i1.Date lastDoneOn;

  final _i1.Date dueOn;

  final _i5.HomeCareItemViewStatusModel status;

  @_i3.override
  _i3.Object? toJson() => {
    r'pet': this.pet.toJson(),
    r'kind': this.kind,
    r'label': this.label,
    r'lastDoneOn': this.lastDoneOn.toJson(),
    r'dueOn': this.dueOn.toJson(),
    r'status': this.status.toJson(),
  };

  HomeCareItemView Function({
    _i4.PetReferenceView? pet,
    _i3.String? kind,
    _i3.String? label,
    _i1.Date? lastDoneOn,
    _i1.Date? dueOn,
    _i5.HomeCareItemViewStatusModel? status,
  })
  get copyWith {
    return ({
      _i4.PetReferenceView? pet,
      _i3.String? kind,
      _i3.String? label,
      _i1.Date? lastDoneOn,
      _i1.Date? dueOn,
      _i5.HomeCareItemViewStatusModel? status,
    }) => HomeCareItemView(
      pet: pet ?? this.pet,
      kind: kind ?? this.kind,
      label: label ?? this.label,
      lastDoneOn: lastDoneOn ?? this.lastDoneOn,
      dueOn: dueOn ?? this.dueOn,
      status: status ?? this.status,
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is HomeCareItemView &&
        other.pet == this.pet &&
        other.kind == this.kind &&
        other.label == this.label &&
        other.lastDoneOn == this.lastDoneOn &&
        other.dueOn == this.dueOn &&
        other.status == this.status;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([
      this.pet,
      this.kind,
      this.label,
      this.lastDoneOn,
      this.dueOn,
      this.status,
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) => throw _i1.EncodingException(
    r'parameterProperties not supported for HomeCareItemView: contains complex types',
  );

  @_i3.override
  _i3.String uriEncode({
    required _i3.bool allowEmpty,
    required _i6.Encoding textEncoding,
    _i3.bool useQueryComponent = false,
    _i3.bool allowReserved = false,
  }) {
    throw _i1.EncodingException(
      r'Cannot uriEncode HomeCareItemView: complex types cannot be URI-encoded',
    );
  }
}
