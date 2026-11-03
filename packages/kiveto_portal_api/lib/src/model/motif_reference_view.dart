// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i4;
import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class MotifReferenceView extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const MotifReferenceView({required this.id, required this.label});

  factory MotifReferenceView.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {r'id', r'label'},
      listKeys: {},
      context: r'MotifReferenceView',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return MotifReferenceView(
      id: _$values[r'id'].decodeSimpleNullableString(
        context: r'MotifReferenceView.id',
      ),
      label: _$values[r'label'].decodeSimpleString(
        context: r'MotifReferenceView.label',
      ),
    );
  }

  factory MotifReferenceView.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'MotifReferenceView');
    return MotifReferenceView(
      id: _$map[r'id'].decodeJsonNullableString(
        context: r'MotifReferenceView.id',
      ),
      label: _$map[r'label'].decodeJsonString(
        context: r'MotifReferenceView.label',
      ),
    );
  }

  factory MotifReferenceView.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {r'id', r'label'},
      listKeys: {},
      context: r'MotifReferenceView',
    );
    return MotifReferenceView(
      id: _$values[r'id'].decodeFormNullableString(
        context: r'MotifReferenceView.id',
      ),
      label: _$values[r'label'].decodeFormString(
        context: r'MotifReferenceView.label',
      ),
    );
  }

  final _i3.String? id;

  final _i3.String label;

  @_i3.override
  _i3.Object? toJson() => {r'id': this.id, r'label': this.label};

  MotifReferenceView Function({_i3.String? id, _i3.String? label})
  get copyWith {
    const _i3.Object _sentinel = _i3.Object();
    return ({_i3.Object? id = _sentinel, _i3.String? label}) =>
        MotifReferenceView(
          id: _i3.identical(id, _sentinel) ? this.id : (id as _i3.String?),
          label: label ?? this.label,
        );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is MotifReferenceView &&
        other.id == this.id &&
        other.label == this.label;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([this.id, this.label]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    if (this.id != null) {
      _$result[r'id'] = _i1.PropertyValue.scalar(this.id!);
    }
    _$result[r'label'] = _i1.PropertyValue.scalar(this.label);
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
      r'Cannot uriEncode MotifReferenceView: complex types cannot be URI-encoded',
    );
  }
}
