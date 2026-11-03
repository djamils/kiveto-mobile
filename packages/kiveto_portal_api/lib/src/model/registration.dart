// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i4;
import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class Registration extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const Registration({
    required this.registrationToken,
    required this.firstName,
    required this.lastName,
    required this.termsVersion,
    this.email,
  });

  factory Registration.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {
        r'registrationToken',
        r'firstName',
        r'lastName',
        r'email',
        r'termsVersion',
      },
      listKeys: {},
      context: r'Registration',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return Registration(
      registrationToken: _$values[r'registrationToken'].decodeSimpleString(
        context: r'Registration.registrationToken',
      ),
      firstName: _$values[r'firstName'].decodeSimpleString(
        context: r'Registration.firstName',
      ),
      lastName: _$values[r'lastName'].decodeSimpleString(
        context: r'Registration.lastName',
      ),
      email: _$values[r'email'].decodeSimpleNullableString(
        context: r'Registration.email',
      ),
      termsVersion: _$values[r'termsVersion'].decodeSimpleString(
        context: r'Registration.termsVersion',
      ),
    );
  }

  factory Registration.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'Registration');
    return Registration(
      registrationToken: _$map[r'registrationToken'].decodeJsonString(
        context: r'Registration.registrationToken',
      ),
      firstName: _$map[r'firstName'].decodeJsonString(
        context: r'Registration.firstName',
      ),
      lastName: _$map[r'lastName'].decodeJsonString(
        context: r'Registration.lastName',
      ),
      email: _$map[r'email'].decodeJsonNullableString(
        context: r'Registration.email',
      ),
      termsVersion: _$map[r'termsVersion'].decodeJsonString(
        context: r'Registration.termsVersion',
      ),
    );
  }

  factory Registration.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {
        r'registrationToken',
        r'firstName',
        r'lastName',
        r'email',
        r'termsVersion',
      },
      listKeys: {},
      context: r'Registration',
    );
    return Registration(
      registrationToken: _$values[r'registrationToken'].decodeFormString(
        context: r'Registration.registrationToken',
      ),
      firstName: _$values[r'firstName'].decodeFormString(
        context: r'Registration.firstName',
      ),
      lastName: _$values[r'lastName'].decodeFormString(
        context: r'Registration.lastName',
      ),
      email: _$values[r'email'].decodeFormNullableString(
        context: r'Registration.email',
      ),
      termsVersion: _$values[r'termsVersion'].decodeFormString(
        context: r'Registration.termsVersion',
      ),
    );
  }

  final _i3.String registrationToken;

  final _i3.String firstName;

  final _i3.String lastName;

  /// Optional, never verified; ignored when another account already uses it.
  final _i3.String? email;

  /// The `version` of /legal/terms/current.
  final _i3.String termsVersion;

  @_i3.override
  _i3.Object? toJson() => {
    r'registrationToken': this.registrationToken,
    r'firstName': this.firstName,
    r'lastName': this.lastName,
    r'email': this.email,
    r'termsVersion': this.termsVersion,
  };

  Registration Function({
    _i3.String? registrationToken,
    _i3.String? firstName,
    _i3.String? lastName,
    _i3.String? email,
    _i3.String? termsVersion,
  })
  get copyWith {
    const _i3.Object _sentinel = _i3.Object();
    return ({
      _i3.String? registrationToken,
      _i3.String? firstName,
      _i3.String? lastName,
      _i3.Object? email = _sentinel,
      _i3.String? termsVersion,
    }) => Registration(
      registrationToken: registrationToken ?? this.registrationToken,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: _i3.identical(email, _sentinel)
          ? this.email
          : (email as _i3.String?),
      termsVersion: termsVersion ?? this.termsVersion,
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is Registration &&
        other.registrationToken == this.registrationToken &&
        other.firstName == this.firstName &&
        other.lastName == this.lastName &&
        other.email == this.email &&
        other.termsVersion == this.termsVersion;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([
      this.registrationToken,
      this.firstName,
      this.lastName,
      this.email,
      this.termsVersion,
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'registrationToken'] = _i1.PropertyValue.scalar(
      this.registrationToken,
    );
    _$result[r'firstName'] = _i1.PropertyValue.scalar(this.firstName);
    _$result[r'lastName'] = _i1.PropertyValue.scalar(this.lastName);
    if (this.email != null) {
      _$result[r'email'] = _i1.PropertyValue.scalar(this.email!);
    }
    _$result[r'termsVersion'] = _i1.PropertyValue.scalar(this.termsVersion);
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
      r'Cannot uriEncode Registration: complex types cannot be URI-encoded',
    );
  }
}
