// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i8;
import 'dart:core' as _i3;

import 'package:collection/collection.dart' as _i7;
import 'package:kiveto_portal_api/src/model/consent_view_channels_array_model.dart'
    as _i5;
import 'package:kiveto_portal_api/src/model/consent_view_effect_model.dart'
    as _i6;
import 'package:kiveto_portal_api/src/model/consent_view_kind_model.dart'
    as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class ConsentView extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const ConsentView({
    required this.kind,
    required this.channels,
    required this.grantedAt,
    required this.effect,
  });

  factory ConsentView.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {r'kind', r'channels', r'grantedAt', r'effect'},
      listKeys: {r'channels'},
      context: r'ConsentView',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return ConsentView(
      kind: _i4.ConsentViewKindModel.fromSimple(
        _$values[r'kind'],
        explode: explode,
      ),
      channels: _$values[r'channels']
          .decodeSimpleStringList(
            context: r'ConsentView.channels',
            isHeader: isHeader,
          )
          .map(
            (e) => _i5.ConsentViewChannelsArrayModel.fromSimple(
              e,
              explode: explode,
            ),
          )
          .toList(),
      grantedAt: _$values[r'grantedAt'].decodeSimpleNullableDateTime(
        context: r'ConsentView.grantedAt',
      ),
      effect: _i6.ConsentViewEffectModel.fromSimple(
        _$values[r'effect'],
        explode: explode,
      ),
    );
  }

  factory ConsentView.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'ConsentView');
    return ConsentView(
      kind: _i4.ConsentViewKindModel.fromJson(_$map[r'kind']),
      channels: _$map[r'channels']
          .decodeJsonList<_i3.Object?>(context: r'ConsentView.channels')
          .map(_i5.ConsentViewChannelsArrayModel.fromJson)
          .toList(),
      grantedAt: _$map[r'grantedAt'].decodeJsonNullableDateTime(
        context: r'ConsentView.grantedAt',
      ),
      effect: _i6.ConsentViewEffectModel.fromJson(_$map[r'effect']),
    );
  }

  factory ConsentView.fromForm(_i3.String? value, {required _i3.bool explode}) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {r'kind', r'channels', r'grantedAt', r'effect'},
      listKeys: {r'channels'},
      context: r'ConsentView',
    );
    return ConsentView(
      kind: _i4.ConsentViewKindModel.fromForm(
        _$values[r'kind'],
        explode: explode,
      ),
      channels: _$values[r'channels']
          .decodeSimpleStringList(context: r'ConsentView.channels')
          .map(
            (e) =>
                _i5.ConsentViewChannelsArrayModel.fromForm(e, explode: explode),
          )
          .toList(),
      grantedAt: _$values[r'grantedAt'].decodeFormNullableDateTime(
        context: r'ConsentView.grantedAt',
      ),
      effect: _i6.ConsentViewEffectModel.fromForm(
        _$values[r'effect'],
        explode: explode,
      ),
    );
  }

  final _i4.ConsentViewKindModel kind;

  final _i3.List<_i5.ConsentViewChannelsArrayModel> channels;

  final _i3.DateTime? grantedAt;

  final _i6.ConsentViewEffectModel effect;

  @_i3.override
  _i3.Object? toJson() => {
    r'kind': this.kind.toJson(),
    r'channels': this.channels.map((e) => e.toJson()).toList(),
    r'grantedAt': this.grantedAt?.toTimeZonedIso8601String(),
    r'effect': this.effect.toJson(),
  };

  ConsentView Function({
    _i4.ConsentViewKindModel? kind,
    _i3.List<_i5.ConsentViewChannelsArrayModel>? channels,
    _i3.DateTime? grantedAt,
    _i6.ConsentViewEffectModel? effect,
  })
  get copyWith {
    const _i3.Object _sentinel = _i3.Object();
    return ({
      _i4.ConsentViewKindModel? kind,
      _i3.List<_i5.ConsentViewChannelsArrayModel>? channels,
      _i3.Object? grantedAt = _sentinel,
      _i6.ConsentViewEffectModel? effect,
    }) => ConsentView(
      kind: kind ?? this.kind,
      channels: channels ?? this.channels,
      grantedAt: _i3.identical(grantedAt, _sentinel)
          ? this.grantedAt
          : (grantedAt as _i3.DateTime?),
      effect: effect ?? this.effect,
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    const _$deepEquals = _i7.DeepCollectionEquality();
    return other is ConsentView &&
        other.kind == this.kind &&
        _$deepEquals.equals(other.channels, this.channels) &&
        other.grantedAt == this.grantedAt &&
        other.effect == this.effect;
  }

  @_i3.override
  _i3.int get hashCode {
    const deepEquals = _i7.DeepCollectionEquality();
    return _i3.Object.hashAll([
      this.kind,
      deepEquals.hash(this.channels),
      this.grantedAt,
      this.effect,
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'kind'] = _i1.PropertyValue.scalar(this.kind.toJson());
    _$result[r'channels'] = _i1.PropertyValue.array(
      this.channels.map((e) => e.toJson()).toList(),
    );
    if (this.grantedAt != null) {
      _$result[r'grantedAt'] = _i1.PropertyValue.scalar(
        this.grantedAt!.toTimeZonedIso8601String(),
      );
    }
    _$result[r'effect'] = _i1.PropertyValue.scalar(this.effect.toJson());
    return _$result;
  }

  @_i3.override
  _i3.String uriEncode({
    required _i3.bool allowEmpty,
    required _i8.Encoding textEncoding,
    _i3.bool useQueryComponent = false,
    _i3.bool allowReserved = false,
  }) {
    throw _i1.EncodingException(
      r'Cannot uriEncode ConsentView: complex types cannot be URI-encoded',
    );
  }
}
