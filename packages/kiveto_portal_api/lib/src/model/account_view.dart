// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i5;
import 'dart:core' as _i3;

import 'package:kiveto_portal_api/src/model/account_view_address_any_of_model.dart'
    as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class AccountView extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const AccountView({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.emailVerified,
    required this.maskedPhone,
    required this.address,
  });

  factory AccountView.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    throw _i1.SimpleDecodingException(
      r'Simple encoding not supported for AccountView: contains complex types',
    );
  }

  factory AccountView.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'AccountView');
    return AccountView(
      id: _$map[r'id'].decodeJsonString(context: r'AccountView.id'),
      firstName: _$map[r'firstName'].decodeJsonNullableString(
        context: r'AccountView.firstName',
      ),
      lastName: _$map[r'lastName'].decodeJsonNullableString(
        context: r'AccountView.lastName',
      ),
      email: _$map[r'email'].decodeJsonNullableString(
        context: r'AccountView.email',
      ),
      emailVerified: _$map[r'emailVerified'].decodeJsonBool(
        context: r'AccountView.emailVerified',
      ),
      maskedPhone: _$map[r'maskedPhone'].decodeJsonString(
        context: r'AccountView.maskedPhone',
      ),
      address: _$map[r'address'] == null
          ? null
          : _i4.AccountViewAddressAnyOfModel.fromJson(_$map[r'address']),
    );
  }

  factory AccountView.fromForm(_i3.String? value, {required _i3.bool explode}) {
    throw _i1.FormDecodingException(
      r'Form encoding not supported for AccountView: contains complex types',
    );
  }

  final _i3.String id;

  final _i3.String? firstName;

  final _i3.String? lastName;

  /// Possibly null; see emailVerified.
  final _i3.String? email;

  /// The owner proved the e-mail; a verified e-mail is a second sign-in factor.
  final _i3.bool emailVerified;

  final _i3.String maskedPhone;

  final _i4.AccountViewAddressAnyOfModel address;

  @_i3.override
  _i3.Object? toJson() => {
    r'id': this.id,
    r'firstName': this.firstName,
    r'lastName': this.lastName,
    r'email': this.email,
    r'emailVerified': this.emailVerified,
    r'maskedPhone': this.maskedPhone,
    r'address': this.address?.toJson(),
  };

  AccountView Function({
    _i3.String? id,
    _i3.String? firstName,
    _i3.String? lastName,
    _i3.String? email,
    _i3.bool? emailVerified,
    _i3.String? maskedPhone,
    _i4.AccountViewAddressAnyOfModel? address,
  })
  get copyWith {
    const _i3.Object _sentinel = _i3.Object();
    return ({
      _i3.String? id,
      _i3.Object? firstName = _sentinel,
      _i3.Object? lastName = _sentinel,
      _i3.Object? email = _sentinel,
      _i3.bool? emailVerified,
      _i3.String? maskedPhone,
      _i3.Object? address = _sentinel,
    }) => AccountView(
      id: id ?? this.id,
      firstName: _i3.identical(firstName, _sentinel)
          ? this.firstName
          : (firstName as _i3.String?),
      lastName: _i3.identical(lastName, _sentinel)
          ? this.lastName
          : (lastName as _i3.String?),
      email: _i3.identical(email, _sentinel)
          ? this.email
          : (email as _i3.String?),
      emailVerified: emailVerified ?? this.emailVerified,
      maskedPhone: maskedPhone ?? this.maskedPhone,
      address: _i3.identical(address, _sentinel)
          ? this.address
          : (address as _i4.AccountViewAddressAnyOfModel),
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is AccountView &&
        other.id == this.id &&
        other.firstName == this.firstName &&
        other.lastName == this.lastName &&
        other.email == this.email &&
        other.emailVerified == this.emailVerified &&
        other.maskedPhone == this.maskedPhone &&
        other.address == this.address;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([
      this.id,
      this.firstName,
      this.lastName,
      this.email,
      this.emailVerified,
      this.maskedPhone,
      this.address,
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'id'] = _i1.PropertyValue.scalar(this.id);
    if (this.firstName != null) {
      _$result[r'firstName'] = _i1.PropertyValue.scalar(this.firstName!);
    }
    if (this.lastName != null) {
      _$result[r'lastName'] = _i1.PropertyValue.scalar(this.lastName!);
    }
    if (this.email != null) {
      _$result[r'email'] = _i1.PropertyValue.scalar(this.email!);
    }
    _$result[r'emailVerified'] = _i1.PropertyValue.scalar(
      this.emailVerified.toString(),
    );
    _$result[r'maskedPhone'] = _i1.PropertyValue.scalar(this.maskedPhone);
    if (this.address != null) {
      _$result[r'address'] = _i1.encodeAnyValueToPropertyValue(
        this.address!.toJson(),
        allowEmpty: allowEmpty,
      );
    }
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
      r'Cannot uriEncode AccountView: complex types cannot be URI-encoded',
    );
  }
}
