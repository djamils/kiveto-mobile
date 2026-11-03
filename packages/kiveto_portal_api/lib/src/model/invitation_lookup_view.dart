// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i6;
import 'dart:core' as _i3;

import 'package:collection/collection.dart' as _i5;
import 'package:kiveto_portal_api/src/model/invitation_clinic_view.dart' as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class InvitationLookupView extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const InvitationLookupView({
    required this.invitationId,
    required this.clinic,
    required this.email,
    required this.maskedPhone,
    required this.petNames,
    required this.expiresAt,
  });

  factory InvitationLookupView.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    throw _i1.SimpleDecodingException(
      r'Simple encoding not supported for InvitationLookupView: contains complex types',
    );
  }

  factory InvitationLookupView.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'InvitationLookupView');
    return InvitationLookupView(
      invitationId: _$map[r'invitationId'].decodeJsonString(
        context: r'InvitationLookupView.invitationId',
      ),
      clinic: _i4.InvitationClinicView.fromJson(_$map[r'clinic']),
      email: _$map[r'email'].decodeJsonNullableString(
        context: r'InvitationLookupView.email',
      ),
      maskedPhone: _$map[r'maskedPhone'].decodeJsonString(
        context: r'InvitationLookupView.maskedPhone',
      ),
      petNames: _$map[r'petNames'].decodeJsonList<_i3.String>(
        context: r'InvitationLookupView.petNames',
      ),
      expiresAt: _$map[r'expiresAt'].decodeJsonDateTime(
        context: r'InvitationLookupView.expiresAt',
      ),
    );
  }

  factory InvitationLookupView.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    throw _i1.FormDecodingException(
      r'Form encoding not supported for InvitationLookupView: contains complex types',
    );
  }

  final _i3.String invitationId;

  final _i4.InvitationClinicView clinic;

  final _i3.String? email;

  final _i3.String maskedPhone;

  final _i3.List<_i3.String> petNames;

  final _i3.DateTime expiresAt;

  @_i3.override
  _i3.Object? toJson() => {
    r'invitationId': this.invitationId,
    r'clinic': this.clinic.toJson(),
    r'email': this.email,
    r'maskedPhone': this.maskedPhone,
    r'petNames': this.petNames,
    r'expiresAt': this.expiresAt.toTimeZonedIso8601String(),
  };

  InvitationLookupView Function({
    _i3.String? invitationId,
    _i4.InvitationClinicView? clinic,
    _i3.String? email,
    _i3.String? maskedPhone,
    _i3.List<_i3.String>? petNames,
    _i3.DateTime? expiresAt,
  })
  get copyWith {
    const _i3.Object _sentinel = _i3.Object();
    return ({
      _i3.String? invitationId,
      _i4.InvitationClinicView? clinic,
      _i3.Object? email = _sentinel,
      _i3.String? maskedPhone,
      _i3.List<_i3.String>? petNames,
      _i3.DateTime? expiresAt,
    }) => InvitationLookupView(
      invitationId: invitationId ?? this.invitationId,
      clinic: clinic ?? this.clinic,
      email: _i3.identical(email, _sentinel)
          ? this.email
          : (email as _i3.String?),
      maskedPhone: maskedPhone ?? this.maskedPhone,
      petNames: petNames ?? this.petNames,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    const _$deepEquals = _i5.DeepCollectionEquality();
    return other is InvitationLookupView &&
        other.invitationId == this.invitationId &&
        other.clinic == this.clinic &&
        other.email == this.email &&
        other.maskedPhone == this.maskedPhone &&
        _$deepEquals.equals(other.petNames, this.petNames) &&
        other.expiresAt == this.expiresAt;
  }

  @_i3.override
  _i3.int get hashCode {
    const deepEquals = _i5.DeepCollectionEquality();
    return _i3.Object.hashAll([
      this.invitationId,
      this.clinic,
      this.email,
      this.maskedPhone,
      deepEquals.hash(this.petNames),
      this.expiresAt,
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) => throw _i1.EncodingException(
    r'parameterProperties not supported for InvitationLookupView: contains complex types',
  );

  @_i3.override
  _i3.String uriEncode({
    required _i3.bool allowEmpty,
    required _i6.Encoding textEncoding,
    _i3.bool useQueryComponent = false,
    _i3.bool allowReserved = false,
  }) {
    throw _i1.EncodingException(
      r'Cannot uriEncode InvitationLookupView: complex types cannot be URI-encoded',
    );
  }
}
