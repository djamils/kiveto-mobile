// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i5;
import 'dart:core' as _i3;

import 'package:kiveto_portal_api/src/model/related_care_item_view_status_model.dart'
    as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class RelatedCareItemView extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const RelatedCareItemView({
    required this.kind,
    required this.label,
    required this.dueOn,
    required this.status,
  });

  factory RelatedCareItemView.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {r'kind', r'label', r'dueOn', r'status'},
      listKeys: {},
      context: r'RelatedCareItemView',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return RelatedCareItemView(
      kind: _$values[r'kind'].decodeSimpleString(
        context: r'RelatedCareItemView.kind',
      ),
      label: _$values[r'label'].decodeSimpleString(
        context: r'RelatedCareItemView.label',
      ),
      dueOn: _$values[r'dueOn'].decodeSimpleDate(
        context: r'RelatedCareItemView.dueOn',
      ),
      status: _i4.RelatedCareItemViewStatusModel.fromSimple(
        _$values[r'status'],
        explode: explode,
      ),
    );
  }

  factory RelatedCareItemView.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'RelatedCareItemView');
    return RelatedCareItemView(
      kind: _$map[r'kind'].decodeJsonString(
        context: r'RelatedCareItemView.kind',
      ),
      label: _$map[r'label'].decodeJsonString(
        context: r'RelatedCareItemView.label',
      ),
      dueOn: _$map[r'dueOn'].decodeJsonDate(
        context: r'RelatedCareItemView.dueOn',
      ),
      status: _i4.RelatedCareItemViewStatusModel.fromJson(_$map[r'status']),
    );
  }

  factory RelatedCareItemView.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {r'kind', r'label', r'dueOn', r'status'},
      listKeys: {},
      context: r'RelatedCareItemView',
    );
    return RelatedCareItemView(
      kind: _$values[r'kind'].decodeFormString(
        context: r'RelatedCareItemView.kind',
      ),
      label: _$values[r'label'].decodeFormString(
        context: r'RelatedCareItemView.label',
      ),
      dueOn: _$values[r'dueOn'].decodeFormDate(
        context: r'RelatedCareItemView.dueOn',
      ),
      status: _i4.RelatedCareItemViewStatusModel.fromForm(
        _$values[r'status'],
        explode: explode,
      ),
    );
  }

  final _i3.String kind;

  final _i3.String label;

  final _i1.Date dueOn;

  final _i4.RelatedCareItemViewStatusModel status;

  @_i3.override
  _i3.Object? toJson() => {
    r'kind': this.kind,
    r'label': this.label,
    r'dueOn': this.dueOn.toJson(),
    r'status': this.status.toJson(),
  };

  RelatedCareItemView Function({
    _i3.String? kind,
    _i3.String? label,
    _i1.Date? dueOn,
    _i4.RelatedCareItemViewStatusModel? status,
  })
  get copyWith {
    return ({
      _i3.String? kind,
      _i3.String? label,
      _i1.Date? dueOn,
      _i4.RelatedCareItemViewStatusModel? status,
    }) => RelatedCareItemView(
      kind: kind ?? this.kind,
      label: label ?? this.label,
      dueOn: dueOn ?? this.dueOn,
      status: status ?? this.status,
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RelatedCareItemView &&
        other.kind == this.kind &&
        other.label == this.label &&
        other.dueOn == this.dueOn &&
        other.status == this.status;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([this.kind, this.label, this.dueOn, this.status]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'kind'] = _i1.PropertyValue.scalar(this.kind);
    _$result[r'label'] = _i1.PropertyValue.scalar(this.label);
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
      r'Cannot uriEncode RelatedCareItemView: complex types cannot be URI-encoded',
    );
  }
}
