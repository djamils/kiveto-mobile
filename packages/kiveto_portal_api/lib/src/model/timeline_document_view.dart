// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i5;
import 'dart:core' as _i3;

import 'package:kiveto_portal_api/src/model/timeline_document_view_type_model.dart'
    as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class TimelineDocumentView extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const TimelineDocumentView({required this.id, required this.kind});

  factory TimelineDocumentView.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {r'id', r'type'},
      listKeys: {},
      context: r'TimelineDocumentView',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return TimelineDocumentView(
      id: _$values[r'id'].decodeSimpleString(
        context: r'TimelineDocumentView.id',
      ),
      kind: _i4.TimelineDocumentViewTypeModel.fromSimple(
        _$values[r'type'],
        explode: explode,
      ),
    );
  }

  factory TimelineDocumentView.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'TimelineDocumentView');
    return TimelineDocumentView(
      id: _$map[r'id'].decodeJsonString(context: r'TimelineDocumentView.id'),
      kind: _i4.TimelineDocumentViewTypeModel.fromJson(_$map[r'type']),
    );
  }

  factory TimelineDocumentView.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {r'id', r'type'},
      listKeys: {},
      context: r'TimelineDocumentView',
    );
    return TimelineDocumentView(
      id: _$values[r'id'].decodeFormString(context: r'TimelineDocumentView.id'),
      kind: _i4.TimelineDocumentViewTypeModel.fromForm(
        _$values[r'type'],
        explode: explode,
      ),
    );
  }

  final _i3.String id;

  final _i4.TimelineDocumentViewTypeModel kind;

  @_i3.override
  _i3.Object? toJson() => {r'id': this.id, r'type': this.kind.toJson()};

  TimelineDocumentView Function({
    _i3.String? id,
    _i4.TimelineDocumentViewTypeModel? kind,
  })
  get copyWith {
    return ({_i3.String? id, _i4.TimelineDocumentViewTypeModel? kind}) =>
        TimelineDocumentView(id: id ?? this.id, kind: kind ?? this.kind);
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is TimelineDocumentView &&
        other.id == this.id &&
        other.kind == this.kind;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([this.id, this.kind]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'id'] = _i1.PropertyValue.scalar(this.id);
    _$result[r'type'] = _i1.PropertyValue.scalar(this.kind.toJson());
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
      r'Cannot uriEncode TimelineDocumentView: complex types cannot be URI-encoded',
    );
  }
}
