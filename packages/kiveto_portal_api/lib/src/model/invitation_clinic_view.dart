// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i4;
import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class InvitationClinicView extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const InvitationClinicView({
    required this.id,
    required this.name,
    required this.city,
  });

  factory InvitationClinicView.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {r'id', r'name', r'city'},
      listKeys: {},
      context: r'InvitationClinicView',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return InvitationClinicView(
      id: _$values[r'id'].decodeSimpleString(
        context: r'InvitationClinicView.id',
      ),
      name: _$values[r'name'].decodeSimpleString(
        context: r'InvitationClinicView.name',
      ),
      city: _$values[r'city'].decodeSimpleNullableString(
        context: r'InvitationClinicView.city',
      ),
    );
  }

  factory InvitationClinicView.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'InvitationClinicView');
    return InvitationClinicView(
      id: _$map[r'id'].decodeJsonString(context: r'InvitationClinicView.id'),
      name: _$map[r'name'].decodeJsonString(
        context: r'InvitationClinicView.name',
      ),
      city: _$map[r'city'].decodeJsonNullableString(
        context: r'InvitationClinicView.city',
      ),
    );
  }

  factory InvitationClinicView.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {r'id', r'name', r'city'},
      listKeys: {},
      context: r'InvitationClinicView',
    );
    return InvitationClinicView(
      id: _$values[r'id'].decodeFormString(context: r'InvitationClinicView.id'),
      name: _$values[r'name'].decodeFormString(
        context: r'InvitationClinicView.name',
      ),
      city: _$values[r'city'].decodeFormNullableString(
        context: r'InvitationClinicView.city',
      ),
    );
  }

  final _i3.String id;

  final _i3.String name;

  final _i3.String? city;

  @_i3.override
  _i3.Object? toJson() => {
    r'id': this.id,
    r'name': this.name,
    r'city': this.city,
  };

  InvitationClinicView Function({
    _i3.String? id,
    _i3.String? name,
    _i3.String? city,
  })
  get copyWith {
    const _i3.Object _sentinel = _i3.Object();
    return ({_i3.String? id, _i3.String? name, _i3.Object? city = _sentinel}) =>
        InvitationClinicView(
          id: id ?? this.id,
          name: name ?? this.name,
          city: _i3.identical(city, _sentinel)
              ? this.city
              : (city as _i3.String?),
        );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is InvitationClinicView &&
        other.id == this.id &&
        other.name == this.name &&
        other.city == this.city;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([this.id, this.name, this.city]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'id'] = _i1.PropertyValue.scalar(this.id);
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
      r'Cannot uriEncode InvitationClinicView: complex types cannot be URI-encoded',
    );
  }
}
