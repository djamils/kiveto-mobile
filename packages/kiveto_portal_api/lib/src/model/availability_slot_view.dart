// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i4;
import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class AvailabilitySlotView extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const AvailabilitySlotView({required this.startAt});

  factory AvailabilitySlotView.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {r'startAt'},
      listKeys: {},
      context: r'AvailabilitySlotView',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return AvailabilitySlotView(
      startAt: _$values[r'startAt'].decodeSimpleDateTime(
        context: r'AvailabilitySlotView.startAt',
      ),
    );
  }

  factory AvailabilitySlotView.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'AvailabilitySlotView');
    return AvailabilitySlotView(
      startAt: _$map[r'startAt'].decodeJsonDateTime(
        context: r'AvailabilitySlotView.startAt',
      ),
    );
  }

  factory AvailabilitySlotView.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {r'startAt'},
      listKeys: {},
      context: r'AvailabilitySlotView',
    );
    return AvailabilitySlotView(
      startAt: _$values[r'startAt'].decodeFormDateTime(
        context: r'AvailabilitySlotView.startAt',
      ),
    );
  }

  final _i3.DateTime startAt;

  @_i3.override
  _i3.Object? toJson() => {r'startAt': this.startAt.toTimeZonedIso8601String()};

  AvailabilitySlotView Function({_i3.DateTime? startAt}) get copyWith {
    return ({_i3.DateTime? startAt}) =>
        AvailabilitySlotView(startAt: startAt ?? this.startAt);
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is AvailabilitySlotView && other.startAt == this.startAt;
  }

  @_i3.override
  _i3.int get hashCode => this.startAt.hashCode;

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'startAt'] = _i1.PropertyValue.scalar(
      this.startAt.toTimeZonedIso8601String(),
    );
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
      r'Cannot uriEncode AvailabilitySlotView: complex types cannot be URI-encoded',
    );
  }
}
