// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i8;
import 'dart:core' as _i3;

import 'package:kiveto_portal_api/src/model/consent_history_item_view_action_model.dart'
    as _i6;
import 'package:kiveto_portal_api/src/model/consent_history_item_view_channel_model.dart'
    as _i5;
import 'package:kiveto_portal_api/src/model/consent_history_item_view_kind_model.dart'
    as _i4;
import 'package:kiveto_portal_api/src/model/consent_history_item_view_source_model.dart'
    as _i7;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class ConsentHistoryItemView extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const ConsentHistoryItemView({
    required this.kind,
    required this.channel,
    required this.action,
    required this.at,
    required this.source,
    required this.author,
    required this.approximate,
  });

  factory ConsentHistoryItemView.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {
        r'kind',
        r'channel',
        r'action',
        r'at',
        r'source',
        r'author',
        r'approximate',
      },
      listKeys: {},
      context: r'ConsentHistoryItemView',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return ConsentHistoryItemView(
      kind: _i4.ConsentHistoryItemViewKindModel.fromSimple(
        _$values[r'kind'],
        explode: explode,
      ),
      channel: _i5.ConsentHistoryItemViewChannelModel.fromSimple(
        _$values[r'channel'],
        explode: explode,
      ),
      action: _i6.ConsentHistoryItemViewActionModel.fromSimple(
        _$values[r'action'],
        explode: explode,
      ),
      at: _$values[r'at'].decodeSimpleDateTime(
        context: r'ConsentHistoryItemView.at',
      ),
      source: _i7.ConsentHistoryItemViewSourceModel.fromSimple(
        _$values[r'source'],
        explode: explode,
      ),
      author: _$values[r'author'].decodeSimpleString(
        context: r'ConsentHistoryItemView.author',
      ),
      approximate: _$values[r'approximate'].decodeSimpleBool(
        context: r'ConsentHistoryItemView.approximate',
      ),
    );
  }

  factory ConsentHistoryItemView.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'ConsentHistoryItemView');
    return ConsentHistoryItemView(
      kind: _i4.ConsentHistoryItemViewKindModel.fromJson(_$map[r'kind']),
      channel: _i5.ConsentHistoryItemViewChannelModel.fromJson(
        _$map[r'channel'],
      ),
      action: _i6.ConsentHistoryItemViewActionModel.fromJson(_$map[r'action']),
      at: _$map[r'at'].decodeJsonDateTime(
        context: r'ConsentHistoryItemView.at',
      ),
      source: _i7.ConsentHistoryItemViewSourceModel.fromJson(_$map[r'source']),
      author: _$map[r'author'].decodeJsonString(
        context: r'ConsentHistoryItemView.author',
      ),
      approximate: _$map[r'approximate'].decodeJsonBool(
        context: r'ConsentHistoryItemView.approximate',
      ),
    );
  }

  factory ConsentHistoryItemView.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {
        r'kind',
        r'channel',
        r'action',
        r'at',
        r'source',
        r'author',
        r'approximate',
      },
      listKeys: {},
      context: r'ConsentHistoryItemView',
    );
    return ConsentHistoryItemView(
      kind: _i4.ConsentHistoryItemViewKindModel.fromForm(
        _$values[r'kind'],
        explode: explode,
      ),
      channel: _i5.ConsentHistoryItemViewChannelModel.fromForm(
        _$values[r'channel'],
        explode: explode,
      ),
      action: _i6.ConsentHistoryItemViewActionModel.fromForm(
        _$values[r'action'],
        explode: explode,
      ),
      at: _$values[r'at'].decodeFormDateTime(
        context: r'ConsentHistoryItemView.at',
      ),
      source: _i7.ConsentHistoryItemViewSourceModel.fromForm(
        _$values[r'source'],
        explode: explode,
      ),
      author: _$values[r'author'].decodeFormString(
        context: r'ConsentHistoryItemView.author',
      ),
      approximate: _$values[r'approximate'].decodeFormBool(
        context: r'ConsentHistoryItemView.approximate',
      ),
    );
  }

  final _i4.ConsentHistoryItemViewKindModel kind;

  final _i5.ConsentHistoryItemViewChannelModel channel;

  final _i6.ConsentHistoryItemViewActionModel action;

  final _i3.DateTime at;

  final _i7.ConsentHistoryItemViewSourceModel source;

  final _i3.String author;

  final _i3.bool approximate;

  @_i3.override
  _i3.Object? toJson() => {
    r'kind': this.kind.toJson(),
    r'channel': this.channel.toJson(),
    r'action': this.action.toJson(),
    r'at': this.at.toTimeZonedIso8601String(),
    r'source': this.source.toJson(),
    r'author': this.author,
    r'approximate': this.approximate,
  };

  ConsentHistoryItemView Function({
    _i4.ConsentHistoryItemViewKindModel? kind,
    _i5.ConsentHistoryItemViewChannelModel? channel,
    _i6.ConsentHistoryItemViewActionModel? action,
    _i3.DateTime? at,
    _i7.ConsentHistoryItemViewSourceModel? source,
    _i3.String? author,
    _i3.bool? approximate,
  })
  get copyWith {
    return ({
      _i4.ConsentHistoryItemViewKindModel? kind,
      _i5.ConsentHistoryItemViewChannelModel? channel,
      _i6.ConsentHistoryItemViewActionModel? action,
      _i3.DateTime? at,
      _i7.ConsentHistoryItemViewSourceModel? source,
      _i3.String? author,
      _i3.bool? approximate,
    }) => ConsentHistoryItemView(
      kind: kind ?? this.kind,
      channel: channel ?? this.channel,
      action: action ?? this.action,
      at: at ?? this.at,
      source: source ?? this.source,
      author: author ?? this.author,
      approximate: approximate ?? this.approximate,
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is ConsentHistoryItemView &&
        other.kind == this.kind &&
        other.channel == this.channel &&
        other.action == this.action &&
        other.at == this.at &&
        other.source == this.source &&
        other.author == this.author &&
        other.approximate == this.approximate;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([
      this.kind,
      this.channel,
      this.action,
      this.at,
      this.source,
      this.author,
      this.approximate,
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'kind'] = _i1.PropertyValue.scalar(this.kind.toJson());
    _$result[r'channel'] = _i1.PropertyValue.scalar(this.channel.toJson());
    _$result[r'action'] = _i1.PropertyValue.scalar(this.action.toJson());
    _$result[r'at'] = _i1.PropertyValue.scalar(
      this.at.toTimeZonedIso8601String(),
    );
    _$result[r'source'] = _i1.PropertyValue.scalar(this.source.toJson());
    _$result[r'author'] = _i1.PropertyValue.scalar(this.author);
    _$result[r'approximate'] = _i1.PropertyValue.scalar(
      this.approximate.toString(),
    );
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
      r'Cannot uriEncode ConsentHistoryItemView: complex types cannot be URI-encoded',
    );
  }
}
