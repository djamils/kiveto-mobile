// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i4;
import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class AppointmentReschedule extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const AppointmentReschedule({this.startAt, this.practitionerId});

  factory AppointmentReschedule.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {r'startAt', r'practitionerId'},
      listKeys: {},
      context: r'AppointmentReschedule',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return AppointmentReschedule(
      startAt: _$values[r'startAt'].decodeSimpleNullableDateTime(
        context: r'AppointmentReschedule.startAt',
      ),
      practitionerId: _$values[r'practitionerId'].decodeSimpleNullableString(
        context: r'AppointmentReschedule.practitionerId',
      ),
    );
  }

  factory AppointmentReschedule.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'AppointmentReschedule');
    return AppointmentReschedule(
      startAt: _$map[r'startAt'].decodeJsonNullableDateTime(
        context: r'AppointmentReschedule.startAt',
      ),
      practitionerId: _$map[r'practitionerId'].decodeJsonNullableString(
        context: r'AppointmentReschedule.practitionerId',
      ),
    );
  }

  factory AppointmentReschedule.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {r'startAt', r'practitionerId'},
      listKeys: {},
      context: r'AppointmentReschedule',
    );
    return AppointmentReschedule(
      startAt: _$values[r'startAt'].decodeFormNullableDateTime(
        context: r'AppointmentReschedule.startAt',
      ),
      practitionerId: _$values[r'practitionerId'].decodeFormNullableString(
        context: r'AppointmentReschedule.practitionerId',
      ),
    );
  }

  final _i3.DateTime? startAt;

  final _i3.String? practitionerId;

  @_i3.override
  _i3.Object? toJson() => {
    if (this.startAt != null)
      r'startAt': this.startAt?.toTimeZonedIso8601String(),
    if (this.practitionerId != null) r'practitionerId': this.practitionerId,
  };

  AppointmentReschedule Function({
    _i3.DateTime? startAt,
    _i3.String? practitionerId,
  })
  get copyWith {
    const _i3.Object _sentinel = _i3.Object();
    return ({
      _i3.Object? startAt = _sentinel,
      _i3.Object? practitionerId = _sentinel,
    }) => AppointmentReschedule(
      startAt: _i3.identical(startAt, _sentinel)
          ? this.startAt
          : (startAt as _i3.DateTime?),
      practitionerId: _i3.identical(practitionerId, _sentinel)
          ? this.practitionerId
          : (practitionerId as _i3.String?),
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is AppointmentReschedule &&
        other.startAt == this.startAt &&
        other.practitionerId == this.practitionerId;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([this.startAt, this.practitionerId]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    if (this.startAt != null) {
      _$result[r'startAt'] = _i1.PropertyValue.scalar(
        this.startAt!.toTimeZonedIso8601String(),
      );
    }
    if (this.practitionerId != null) {
      _$result[r'practitionerId'] = _i1.PropertyValue.scalar(
        this.practitionerId!,
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
      r'Cannot uriEncode AppointmentReschedule: complex types cannot be URI-encoded',
    );
  }
}
