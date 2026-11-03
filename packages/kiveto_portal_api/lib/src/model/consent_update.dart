// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i6;
import 'dart:core' as _i3;

import 'package:collection/collection.dart' as _i5;
import 'package:kiveto_portal_api/src/model/consent_update_channels_array_model.dart'
    as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class ConsentUpdate extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const ConsentUpdate({required this.channels});

  factory ConsentUpdate.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {r'channels'},
      listKeys: {r'channels'},
      context: r'ConsentUpdate',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return ConsentUpdate(
      channels: _$values[r'channels']
          .decodeSimpleStringList(
            context: r'ConsentUpdate.channels',
            isHeader: isHeader,
          )
          .map(
            (e) => _i4.ConsentUpdateChannelsArrayModel.fromSimple(
              e,
              explode: explode,
            ),
          )
          .toList(),
    );
  }

  factory ConsentUpdate.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'ConsentUpdate');
    return ConsentUpdate(
      channels: _$map[r'channels']
          .decodeJsonList<_i3.Object?>(context: r'ConsentUpdate.channels')
          .map(_i4.ConsentUpdateChannelsArrayModel.fromJson)
          .toList(),
    );
  }

  factory ConsentUpdate.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {r'channels'},
      listKeys: {r'channels'},
      context: r'ConsentUpdate',
    );
    return ConsentUpdate(
      channels: _$values[r'channels']
          .decodeSimpleStringList(context: r'ConsentUpdate.channels')
          .map(
            (e) => _i4.ConsentUpdateChannelsArrayModel.fromForm(
              e,
              explode: explode,
            ),
          )
          .toList(),
    );
  }

  final _i3.List<_i4.ConsentUpdateChannelsArrayModel> channels;

  @_i3.override
  _i3.Object? toJson() => {
    r'channels': this.channels.map((e) => e.toJson()).toList(),
  };

  ConsentUpdate Function({
    _i3.List<_i4.ConsentUpdateChannelsArrayModel>? channels,
  })
  get copyWith {
    return ({_i3.List<_i4.ConsentUpdateChannelsArrayModel>? channels}) =>
        ConsentUpdate(channels: channels ?? this.channels);
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    const _$deepEquals = _i5.DeepCollectionEquality();
    return other is ConsentUpdate &&
        _$deepEquals.equals(other.channels, this.channels);
  }

  @_i3.override
  _i3.int get hashCode {
    const deepEquals = _i5.DeepCollectionEquality();
    return deepEquals.hash(this.channels);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'channels'] = _i1.PropertyValue.array(
      this.channels.map((e) => e.toJson()).toList(),
    );
    return _$result;
  }

  @_i3.override
  _i3.String uriEncode({
    required _i3.bool allowEmpty,
    required _i6.Encoding textEncoding,
    _i3.bool useQueryComponent = false,
    _i3.bool allowReserved = false,
  }) {
    throw _i1.EncodingException(
      r'Cannot uriEncode ConsentUpdate: complex types cannot be URI-encoded',
    );
  }
}
