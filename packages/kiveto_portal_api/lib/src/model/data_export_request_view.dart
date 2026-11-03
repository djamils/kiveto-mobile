// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i4;
import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class DataExportRequestView extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const DataExportRequestView({required this.id, required this.status});

  factory DataExportRequestView.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {r'id', r'status'},
      listKeys: {},
      context: r'DataExportRequestView',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return DataExportRequestView(
      id: _$values[r'id'].decodeSimpleString(
        context: r'DataExportRequestView.id',
      ),
      status: _$values[r'status'].decodeSimpleString(
        context: r'DataExportRequestView.status',
      ),
    );
  }

  factory DataExportRequestView.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'DataExportRequestView');
    return DataExportRequestView(
      id: _$map[r'id'].decodeJsonString(context: r'DataExportRequestView.id'),
      status: _$map[r'status'].decodeJsonString(
        context: r'DataExportRequestView.status',
      ),
    );
  }

  factory DataExportRequestView.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {r'id', r'status'},
      listKeys: {},
      context: r'DataExportRequestView',
    );
    return DataExportRequestView(
      id: _$values[r'id'].decodeFormString(
        context: r'DataExportRequestView.id',
      ),
      status: _$values[r'status'].decodeFormString(
        context: r'DataExportRequestView.status',
      ),
    );
  }

  final _i3.String id;

  final _i3.String status;

  @_i3.override
  _i3.Object? toJson() => {r'id': this.id, r'status': this.status};

  DataExportRequestView Function({_i3.String? id, _i3.String? status})
  get copyWith {
    return ({_i3.String? id, _i3.String? status}) =>
        DataExportRequestView(id: id ?? this.id, status: status ?? this.status);
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is DataExportRequestView &&
        other.id == this.id &&
        other.status == this.status;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([this.id, this.status]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'id'] = _i1.PropertyValue.scalar(this.id);
    _$result[r'status'] = _i1.PropertyValue.scalar(this.status);
    return _$result;
  }

  @_i3.override
  _i3.String uriEncode({
    required _i3.bool allowEmpty,
    required _i4.Encoding textEncoding,
    _i3.bool useQueryComponent = false,
    _i3.bool allowReserved = false,
  }) {
    throw _i1.EncodingException(
      r'Cannot uriEncode DataExportRequestView: complex types cannot be URI-encoded',
    );
  }
}
