// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i4;
import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class OtpVerificationOtpVerificationViewPendingInvitationsArrayClinicModel
    extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const OtpVerificationOtpVerificationViewPendingInvitationsArrayClinicModel({
    required this.name,
    required this.city,
  });

  factory OtpVerificationOtpVerificationViewPendingInvitationsArrayClinicModel.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {r'name', r'city'},
      listKeys: {},
      context: r'OtpVerificationOtpVerificationViewPendingInvitationsArrayClinicModel',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return OtpVerificationOtpVerificationViewPendingInvitationsArrayClinicModel(
      name: _$values[r'name'].decodeSimpleString(
        context: r'OtpVerificationOtpVerificationViewPendingInvitationsArrayClinicModel.name',
      ),
      city: _$values[r'city'].decodeSimpleNullableString(
        context: r'OtpVerificationOtpVerificationViewPendingInvitationsArrayClinicModel.city',
      ),
    );
  }

  factory OtpVerificationOtpVerificationViewPendingInvitationsArrayClinicModel.fromJson(
    _i3.Object? json,
  ) {
    final _$map = json.decodeMap(
      context: r'OtpVerificationOtpVerificationViewPendingInvitationsArrayClinicModel',
    );
    return OtpVerificationOtpVerificationViewPendingInvitationsArrayClinicModel(
      name: _$map[r'name'].decodeJsonString(
        context: r'OtpVerificationOtpVerificationViewPendingInvitationsArrayClinicModel.name',
      ),
      city: _$map[r'city'].decodeJsonNullableString(
        context: r'OtpVerificationOtpVerificationViewPendingInvitationsArrayClinicModel.city',
      ),
    );
  }

  factory OtpVerificationOtpVerificationViewPendingInvitationsArrayClinicModel.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {r'name', r'city'},
      listKeys: {},
      context: r'OtpVerificationOtpVerificationViewPendingInvitationsArrayClinicModel',
    );
    return OtpVerificationOtpVerificationViewPendingInvitationsArrayClinicModel(
      name: _$values[r'name'].decodeFormString(
        context: r'OtpVerificationOtpVerificationViewPendingInvitationsArrayClinicModel.name',
      ),
      city: _$values[r'city'].decodeFormNullableString(
        context: r'OtpVerificationOtpVerificationViewPendingInvitationsArrayClinicModel.city',
      ),
    );
  }

  final _i3.String name;

  final _i3.String? city;

  @_i3.override
  _i3.Object? toJson() => {r'name': this.name, r'city': this.city};

  OtpVerificationOtpVerificationViewPendingInvitationsArrayClinicModel
  Function({_i3.String? name, _i3.String? city})
  get copyWith {
    const _i3.Object _sentinel = _i3.Object();
    return ({_i3.String? name, _i3.Object? city = _sentinel}) =>
        OtpVerificationOtpVerificationViewPendingInvitationsArrayClinicModel(
          name: name ?? this.name,
          city: _i3.identical(city, _sentinel)
              ? this.city
              : (city as _i3.String?),
        );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other
            is OtpVerificationOtpVerificationViewPendingInvitationsArrayClinicModel &&
        other.name == this.name &&
        other.city == this.city;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([this.name, this.city]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'name'] = _i1.PropertyValue.scalar(this.name);
    if (this.city != null) {
      _$result[r'city'] = _i1.PropertyValue.scalar(this.city!);
    }
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
      r'Cannot uriEncode OtpVerificationOtpVerificationViewPendingInvitationsArrayClinicModel: complex types cannot be URI-encoded',
    );
  }
}
