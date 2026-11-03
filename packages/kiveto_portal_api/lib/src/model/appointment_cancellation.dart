// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i5;
import 'dart:core' as _i3;

import 'package:kiveto_portal_api/src/model/appointment_cancellation_reason_model.dart'
    as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class AppointmentCancellation extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const AppointmentCancellation({this.reason});

  factory AppointmentCancellation.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {r'reason'},
      listKeys: {},
      context: r'AppointmentCancellation',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return AppointmentCancellation(
      reason: _$values[r'reason'] == null
          ? null
          : _i4.AppointmentCancellationReasonModel.fromSimple(
              _$values[r'reason'],
              explode: explode,
            ),
    );
  }

  factory AppointmentCancellation.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'AppointmentCancellation');
    return AppointmentCancellation(
      reason: _$map[r'reason'] == null
          ? null
          : _i4.AppointmentCancellationReasonModel.fromJson(_$map[r'reason']),
    );
  }

  factory AppointmentCancellation.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {r'reason'},
      listKeys: {},
      context: r'AppointmentCancellation',
    );
    return AppointmentCancellation(
      reason: _$values[r'reason'] == null
          ? null
          : _i4.AppointmentCancellationReasonModel.fromForm(
              _$values[r'reason'],
              explode: explode,
            ),
    );
  }

  final _i4.AppointmentCancellationReasonModel? reason;

  @_i3.override
  _i3.Object? toJson() => {
    if (this.reason != null) r'reason': this.reason?.toJson(),
  };

  AppointmentCancellation Function({
    _i4.AppointmentCancellationReasonModel? reason,
  })
  get copyWith {
    const _i3.Object _sentinel = _i3.Object();
    return ({_i3.Object? reason = _sentinel}) => AppointmentCancellation(
      reason: _i3.identical(reason, _sentinel)
          ? this.reason
          : (reason as _i4.AppointmentCancellationReasonModel?),
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is AppointmentCancellation && other.reason == this.reason;
  }

  @_i3.override
  _i3.int get hashCode => this.reason.hashCode;

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    if (this.reason != null) {
      _$result[r'reason'] = _i1.PropertyValue.scalar(this.reason!.toJson());
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
      r'Cannot uriEncode AppointmentCancellation: complex types cannot be URI-encoded',
    );
  }
}
