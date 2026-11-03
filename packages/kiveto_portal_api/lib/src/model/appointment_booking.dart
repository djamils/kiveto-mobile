// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i4;
import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class AppointmentBooking extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const AppointmentBooking({
    this.petId,
    this.motifId,
    this.practitionerId,
    this.startAt,
  });

  factory AppointmentBooking.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {r'petId', r'motifId', r'practitionerId', r'startAt'},
      listKeys: {},
      context: r'AppointmentBooking',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return AppointmentBooking(
      petId: _$values[r'petId'].decodeSimpleNullableString(
        context: r'AppointmentBooking.petId',
      ),
      motifId: _$values[r'motifId'].decodeSimpleNullableString(
        context: r'AppointmentBooking.motifId',
      ),
      practitionerId: _$values[r'practitionerId'].decodeSimpleNullableString(
        context: r'AppointmentBooking.practitionerId',
      ),
      startAt: _$values[r'startAt'].decodeSimpleNullableDateTime(
        context: r'AppointmentBooking.startAt',
      ),
    );
  }

  factory AppointmentBooking.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'AppointmentBooking');
    return AppointmentBooking(
      petId: _$map[r'petId'].decodeJsonNullableString(
        context: r'AppointmentBooking.petId',
      ),
      motifId: _$map[r'motifId'].decodeJsonNullableString(
        context: r'AppointmentBooking.motifId',
      ),
      practitionerId: _$map[r'practitionerId'].decodeJsonNullableString(
        context: r'AppointmentBooking.practitionerId',
      ),
      startAt: _$map[r'startAt'].decodeJsonNullableDateTime(
        context: r'AppointmentBooking.startAt',
      ),
    );
  }

  factory AppointmentBooking.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {r'petId', r'motifId', r'practitionerId', r'startAt'},
      listKeys: {},
      context: r'AppointmentBooking',
    );
    return AppointmentBooking(
      petId: _$values[r'petId'].decodeFormNullableString(
        context: r'AppointmentBooking.petId',
      ),
      motifId: _$values[r'motifId'].decodeFormNullableString(
        context: r'AppointmentBooking.motifId',
      ),
      practitionerId: _$values[r'practitionerId'].decodeFormNullableString(
        context: r'AppointmentBooking.practitionerId',
      ),
      startAt: _$values[r'startAt'].decodeFormNullableDateTime(
        context: r'AppointmentBooking.startAt',
      ),
    );
  }

  final _i3.String? petId;

  final _i3.String? motifId;

  final _i3.String? practitionerId;

  final _i3.DateTime? startAt;

  @_i3.override
  _i3.Object? toJson() => {
    if (this.petId != null) r'petId': this.petId,
    if (this.motifId != null) r'motifId': this.motifId,
    if (this.practitionerId != null) r'practitionerId': this.practitionerId,
    if (this.startAt != null)
      r'startAt': this.startAt?.toTimeZonedIso8601String(),
  };

  AppointmentBooking Function({
    _i3.String? petId,
    _i3.String? motifId,
    _i3.String? practitionerId,
    _i3.DateTime? startAt,
  })
  get copyWith {
    const _i3.Object _sentinel = _i3.Object();
    return ({
      _i3.Object? petId = _sentinel,
      _i3.Object? motifId = _sentinel,
      _i3.Object? practitionerId = _sentinel,
      _i3.Object? startAt = _sentinel,
    }) => AppointmentBooking(
      petId: _i3.identical(petId, _sentinel)
          ? this.petId
          : (petId as _i3.String?),
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
    return other is AppointmentBooking &&
        other.petId == this.petId &&
        other.motifId == this.motifId &&
        other.practitionerId == this.practitionerId &&
        other.startAt == this.startAt;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([
      this.petId,
      this.motifId,
      this.practitionerId,
      this.startAt,
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    if (this.petId != null) {
      _$result[r'petId'] = _i1.PropertyValue.scalar(this.petId!);
    }
    if (this.motifId != null) {
      _$result[r'motifId'] = _i1.PropertyValue.scalar(this.motifId!);
    }
    if (this.practitionerId != null) {
      _$result[r'practitionerId'] = _i1.PropertyValue.scalar(
        this.practitionerId!,
      );
    }
    if (this.startAt != null) {
      _$result[r'startAt'] = _i1.PropertyValue.scalar(
        this.startAt!.toTimeZonedIso8601String(),
      );
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
      r'Cannot uriEncode AppointmentBooking: complex types cannot be URI-encoded',
    );
  }
}
