// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i7;
import 'dart:core' as _i3;

import 'package:collection/collection.dart' as _i6;
import 'package:kiveto_portal_api/src/model/consent_view.dart' as _i5;
import 'package:kiveto_portal_api/src/model/consents_preferred_channel_model.dart'
    as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class Consents extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const Consents({required this.preferredChannel, required this.consents});

  factory Consents.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    throw _i1.SimpleDecodingException(
      r'Simple encoding not supported for Consents: contains complex types',
    );
  }

  factory Consents.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'Consents');
    return Consents(
      preferredChannel: _$map[r'preferredChannel'] == null
          ? null
          : _i4.ConsentsPreferredChannelModel.fromJson(
              _$map[r'preferredChannel'],
            ),
      consents: _$map[r'consents']
          .decodeJsonList<_i3.Object?>(context: r'Consents.consents')
          .map(_i5.ConsentView.fromJson)
          .toList(),
    );
  }

  factory Consents.fromForm(_i3.String? value, {required _i3.bool explode}) {
    throw _i1.FormDecodingException(
      r'Form encoding not supported for Consents: contains complex types',
    );
  }

  final _i4.ConsentsPreferredChannelModel? preferredChannel;

  final _i3.List<_i5.ConsentView> consents;

  @_i3.override
  _i3.Object? toJson() => {
    r'preferredChannel': this.preferredChannel?.toJson(),
    r'consents': this.consents.map((e) => e.toJson()).toList(),
  };

  Consents Function({
    _i4.ConsentsPreferredChannelModel? preferredChannel,
    _i3.List<_i5.ConsentView>? consents,
  })
  get copyWith {
    const _i3.Object _sentinel = _i3.Object();
    return ({
      _i3.Object? preferredChannel = _sentinel,
      _i3.List<_i5.ConsentView>? consents,
    }) => Consents(
      preferredChannel: _i3.identical(preferredChannel, _sentinel)
          ? this.preferredChannel
          : (preferredChannel as _i4.ConsentsPreferredChannelModel?),
      consents: consents ?? this.consents,
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    const _$deepEquals = _i6.DeepCollectionEquality();
    return other is Consents &&
        other.preferredChannel == this.preferredChannel &&
        _$deepEquals.equals(other.consents, this.consents);
  }

  @_i3.override
  _i3.int get hashCode {
    const deepEquals = _i6.DeepCollectionEquality();
    return _i3.Object.hashAll([
      this.preferredChannel,
      deepEquals.hash(this.consents),
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) => throw _i1.EncodingException(
    r'parameterProperties not supported for Consents: contains complex types',
  );

  @_i3.override
  _i3.String uriEncode({
    required _i3.bool allowEmpty,
    required _i7.Encoding textEncoding,
    _i3.bool useQueryComponent = false,
    _i3.bool allowReserved = false,
  }) {
    throw _i1.EncodingException(
      r'Cannot uriEncode Consents: complex types cannot be URI-encoded',
    );
  }
}
