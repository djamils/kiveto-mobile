// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i5;
import 'dart:core' as _i3;

import 'package:kiveto_portal_api/src/model/me_update_json_merge_patch_address_any_of_model.dart'
    as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class MeUpdate extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const MeUpdate({this.firstName, this.lastName, this.address});

  factory MeUpdate.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    throw _i1.SimpleDecodingException(
      r'Simple encoding not supported for MeUpdate: contains complex types',
    );
  }

  factory MeUpdate.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'MeUpdate');
    return MeUpdate(
      firstName: _$map[r'firstName'].decodeJsonNullableString(
        context: r'MeUpdate.firstName',
      ),
      lastName: _$map[r'lastName'].decodeJsonNullableString(
        context: r'MeUpdate.lastName',
      ),
      address: _$map[r'address'] == null
          ? null
          : _i4.MeUpdateJsonMergePatchAddressAnyOfModel.fromJson(
              _$map[r'address'],
            ),
    );
  }

  factory MeUpdate.fromForm(_i3.String? value, {required _i3.bool explode}) {
    throw _i1.FormDecodingException(
      r'Form encoding not supported for MeUpdate: contains complex types',
    );
  }

  final _i3.String? firstName;

  final _i3.String? lastName;

  final _i4.MeUpdateJsonMergePatchAddressAnyOfModel? address;

  @_i3.override
  _i3.Object? toJson() => {
    r'firstName': this.firstName,
    r'lastName': this.lastName,
    if (this.address != null) r'address': this.address?.toJson(),
  };

  MeUpdate Function({
    _i3.String? firstName,
    _i3.String? lastName,
    _i4.MeUpdateJsonMergePatchAddressAnyOfModel? address,
  })
  get copyWith {
    const _i3.Object _sentinel = _i3.Object();
    return ({
      _i3.Object? firstName = _sentinel,
      _i3.Object? lastName = _sentinel,
      _i3.Object? address = _sentinel,
    }) => MeUpdate(
      firstName: _i3.identical(firstName, _sentinel)
          ? this.firstName
          : (firstName as _i3.String?),
      lastName: _i3.identical(lastName, _sentinel)
          ? this.lastName
          : (lastName as _i3.String?),
      address: _i3.identical(address, _sentinel)
          ? this.address
          : (address as _i4.MeUpdateJsonMergePatchAddressAnyOfModel?),
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is MeUpdate &&
        other.firstName == this.firstName &&
        other.lastName == this.lastName &&
        other.address == this.address;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([this.firstName, this.lastName, this.address]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    if (this.firstName != null) {
      _$result[r'firstName'] = _i1.PropertyValue.scalar(this.firstName!);
    }
    if (this.lastName != null) {
      _$result[r'lastName'] = _i1.PropertyValue.scalar(this.lastName!);
    }
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
      r'Cannot uriEncode MeUpdate: complex types cannot be URI-encoded',
    );
  }
}
