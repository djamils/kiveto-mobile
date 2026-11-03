// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i5;
import 'dart:core' as _i3;

import 'package:kiveto_portal_api/src/model/care_item_status_model.dart' as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

/// The latest act of a preventive protocol and where it stands against its
/// due date. The care-items route answers a plain JSON array of it.
@_i2.immutable
class CareItem extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const CareItem({
    required this.kind,
    required this.label,
    required this.lastDoneOn,
    required this.dueOn,
    required this.status,
  });

  factory CareItem.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {r'kind', r'label', r'lastDoneOn', r'dueOn', r'status'},
      listKeys: {},
      context: r'CareItem',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return CareItem(
      kind: _$values[r'kind'].decodeSimpleString(context: r'CareItem.kind'),
      label: _$values[r'label'].decodeSimpleString(context: r'CareItem.label'),
      lastDoneOn: _$values[r'lastDoneOn'].decodeSimpleDate(
        context: r'CareItem.lastDoneOn',
      ),
      dueOn: _$values[r'dueOn'].decodeSimpleDate(context: r'CareItem.dueOn'),
      status: _i4.CareItemStatusModel.fromSimple(
        _$values[r'status'],
        explode: explode,
      ),
    );
  }

  factory CareItem.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'CareItem');
    return CareItem(
      kind: _$map[r'kind'].decodeJsonString(context: r'CareItem.kind'),
      label: _$map[r'label'].decodeJsonString(context: r'CareItem.label'),
      lastDoneOn: _$map[r'lastDoneOn'].decodeJsonDate(
        context: r'CareItem.lastDoneOn',
      ),
      dueOn: _$map[r'dueOn'].decodeJsonDate(context: r'CareItem.dueOn'),
      status: _i4.CareItemStatusModel.fromJson(_$map[r'status']),
    );
  }

  factory CareItem.fromForm(_i3.String? value, {required _i3.bool explode}) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {r'kind', r'label', r'lastDoneOn', r'dueOn', r'status'},
      listKeys: {},
      context: r'CareItem',
    );
    return CareItem(
      kind: _$values[r'kind'].decodeFormString(context: r'CareItem.kind'),
      label: _$values[r'label'].decodeFormString(context: r'CareItem.label'),
      lastDoneOn: _$values[r'lastDoneOn'].decodeFormDate(
        context: r'CareItem.lastDoneOn',
      ),
      dueOn: _$values[r'dueOn'].decodeFormDate(context: r'CareItem.dueOn'),
      status: _i4.CareItemStatusModel.fromForm(
        _$values[r'status'],
        explode: explode,
      ),
    );
  }

  final _i3.String kind;

  final _i3.String label;

  final _i1.Date lastDoneOn;

  final _i1.Date dueOn;

  final _i4.CareItemStatusModel status;

  @_i3.override
  _i3.Object? toJson() => {
    r'kind': this.kind,
    r'label': this.label,
    r'lastDoneOn': this.lastDoneOn.toJson(),
    r'dueOn': this.dueOn.toJson(),
    r'status': this.status.toJson(),
  };

  CareItem Function({
    _i3.String? kind,
    _i3.String? label,
    _i1.Date? lastDoneOn,
    _i1.Date? dueOn,
    _i4.CareItemStatusModel? status,
  })
  get copyWith {
    return ({
      _i3.String? kind,
      _i3.String? label,
      _i1.Date? lastDoneOn,
      _i1.Date? dueOn,
      _i4.CareItemStatusModel? status,
    }) => CareItem(
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
    return other is CareItem &&
        other.kind == this.kind &&
        other.label == this.label &&
        other.lastDoneOn == this.lastDoneOn &&
        other.dueOn == this.dueOn &&
        other.status == this.status;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([
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
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'kind'] = _i1.PropertyValue.scalar(this.kind);
    _$result[r'label'] = _i1.PropertyValue.scalar(this.label);
    _$result[r'lastDoneOn'] = _i1.PropertyValue.scalar(
      this.lastDoneOn.toString(),
    );
    _$result[r'dueOn'] = _i1.PropertyValue.scalar(this.dueOn.toString());
    _$result[r'status'] = _i1.PropertyValue.scalar(this.status.toJson());
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
      r'Cannot uriEncode CareItem: complex types cannot be URI-encoded',
    );
  }
}
