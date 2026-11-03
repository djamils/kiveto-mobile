// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i5;
import 'dart:core' as _i3;

import 'package:kiveto_portal_api/src/model/otp_resend_channel_model.dart'
    as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class OtpResend extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const OtpResend({required this.channel});

  factory OtpResend.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {r'channel'},
      listKeys: {},
      context: r'OtpResend',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return OtpResend(
      channel: _i4.OtpResendChannelModel.fromSimple(
        _$values[r'channel'],
        explode: explode,
      ),
    );
  }

  factory OtpResend.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'OtpResend');
    return OtpResend(
      channel: _i4.OtpResendChannelModel.fromJson(_$map[r'channel']),
    );
  }

  factory OtpResend.fromForm(_i3.String? value, {required _i3.bool explode}) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {r'channel'},
      listKeys: {},
      context: r'OtpResend',
    );
    return OtpResend(
      channel: _i4.OtpResendChannelModel.fromForm(
        _$values[r'channel'],
        explode: explode,
      ),
    );
  }

  final _i4.OtpResendChannelModel channel;

  @_i3.override
  _i3.Object? toJson() => {r'channel': this.channel.toJson()};

  OtpResend Function({_i4.OtpResendChannelModel? channel}) get copyWith {
    return ({_i4.OtpResendChannelModel? channel}) =>
        OtpResend(channel: channel ?? this.channel);
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is OtpResend && other.channel == this.channel;
  }

  @_i3.override
  _i3.int get hashCode => this.channel.hashCode;

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'channel'] = _i1.PropertyValue.scalar(this.channel.toJson());
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
      r'Cannot uriEncode OtpResend: complex types cannot be URI-encoded',
    );
  }
}
