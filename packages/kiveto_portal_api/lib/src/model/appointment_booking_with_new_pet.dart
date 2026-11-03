// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i5;
import 'dart:core' as _i3;

import 'package:kiveto_portal_api/src/model/new_pet.dart' as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class AppointmentBookingWithNewPet extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const AppointmentBookingWithNewPet({
    required this.newPet,
    this.motifId,
    this.practitionerId,
    this.startAt,
  });

  factory AppointmentBookingWithNewPet.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    throw _i1.SimpleDecodingException(
      r'Simple encoding not supported for AppointmentBookingWithNewPet: contains complex types',
    );
  }

  factory AppointmentBookingWithNewPet.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'AppointmentBookingWithNewPet');
    return AppointmentBookingWithNewPet(
      newPet: _i4.NewPet.fromJson(_$map[r'newPet']),
      motifId: _$map[r'motifId'].decodeJsonNullableString(
        context: r'AppointmentBookingWithNewPet.motifId',
      ),
      practitionerId: _$map[r'practitionerId'].decodeJsonNullableString(
        context: r'AppointmentBookingWithNewPet.practitionerId',
      ),
      startAt: _$map[r'startAt'].decodeJsonNullableDateTime(
        context: r'AppointmentBookingWithNewPet.startAt',
      ),
    );
  }

  factory AppointmentBookingWithNewPet.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    throw _i1.FormDecodingException(
      r'Form encoding not supported for AppointmentBookingWithNewPet: contains complex types',
    );
  }

  final _i4.NewPet newPet;

  final _i3.String? motifId;

  final _i3.String? practitionerId;

  final _i3.DateTime? startAt;

  @_i3.override
  _i3.Object? toJson() => {
    r'newPet': this.newPet.toJson(),
    if (this.motifId != null) r'motifId': this.motifId,
    if (this.practitionerId != null) r'practitionerId': this.practitionerId,
    if (this.startAt != null)
      r'startAt': this.startAt?.toTimeZonedIso8601String(),
  };

  AppointmentBookingWithNewPet Function({
    _i4.NewPet? newPet,
    _i3.String? motifId,
    _i3.String? practitionerId,
    _i3.DateTime? startAt,
  })
  get copyWith {
    const _i3.Object _sentinel = _i3.Object();
    return ({
      _i4.NewPet? newPet,
      _i3.Object? motifId = _sentinel,
      _i3.Object? practitionerId = _sentinel,
      _i3.Object? startAt = _sentinel,
    }) => AppointmentBookingWithNewPet(
      newPet: newPet ?? this.newPet,
      motifId: _i3.identical(motifId, _sentinel)
          ? this.motifId
          : (motifId as _i3.String?),
      practitionerId: _i3.identical(practitionerId, _sentinel)
          ? this.practitionerId
          : (practitionerId as _i3.String?),
      startAt: _i3.identical(startAt, _sentinel)
          ? this.startAt
          : (startAt as _i3.DateTime?),
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is AppointmentBookingWithNewPet &&
        other.newPet == this.newPet &&
        other.motifId == this.motifId &&
        other.practitionerId == this.practitionerId &&
        other.startAt == this.startAt;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([
      this.newPet,
      this.motifId,
      this.practitionerId,
      this.startAt,
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) => throw _i1.EncodingException(
    r'parameterProperties not supported for AppointmentBookingWithNewPet: contains complex types',
  );

  @_i3.override
  _i3.String uriEncode({
    required _i3.bool allowEmpty,
    required _i5.Encoding textEncoding,
    _i3.bool useQueryComponent = false,
    _i3.bool allowReserved = false,
  }) {
    throw _i1.EncodingException(
      r'Cannot uriEncode AppointmentBookingWithNewPet: complex types cannot be URI-encoded',
    );
  }
}
