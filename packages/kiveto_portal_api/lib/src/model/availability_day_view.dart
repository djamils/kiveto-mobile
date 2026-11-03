// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i6;
import 'dart:core' as _i3;

import 'package:collection/collection.dart' as _i5;
import 'package:kiveto_portal_api/src/model/availability_slot_view.dart' as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class AvailabilityDayView extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const AvailabilityDayView({
    required this.date,
    required this.open,
    required this.slots,
  });

  factory AvailabilityDayView.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    throw _i1.SimpleDecodingException(
      r'Simple encoding not supported for AvailabilityDayView: contains complex types',
    );
  }

  factory AvailabilityDayView.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'AvailabilityDayView');
    return AvailabilityDayView(
      date: _$map[r'date'].decodeJsonDate(context: r'AvailabilityDayView.date'),
      open: _$map[r'open'].decodeJsonBool(context: r'AvailabilityDayView.open'),
      slots: _$map[r'slots']
          .decodeJsonList<_i3.Object?>(context: r'AvailabilityDayView.slots')
          .map(_i4.AvailabilitySlotView.fromJson)
          .toList(),
    );
  }

  factory AvailabilityDayView.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    throw _i1.FormDecodingException(
      r'Form encoding not supported for AvailabilityDayView: contains complex types',
    );
  }

  final _i1.Date date;

  final _i3.bool open;

  final _i3.List<_i4.AvailabilitySlotView> slots;

  @_i3.override
  _i3.Object? toJson() => {
    r'date': this.date.toJson(),
    r'open': this.open,
    r'slots': this.slots.map((e) => e.toJson()).toList(),
  };

  AvailabilityDayView Function({
    _i1.Date? date,
    _i3.bool? open,
    _i3.List<_i4.AvailabilitySlotView>? slots,
  })
  get copyWith {
    return ({
      _i1.Date? date,
      _i3.bool? open,
      _i3.List<_i4.AvailabilitySlotView>? slots,
    }) => AvailabilityDayView(
      date: date ?? this.date,
      open: open ?? this.open,
      slots: slots ?? this.slots,
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    const _$deepEquals = _i5.DeepCollectionEquality();
    return other is AvailabilityDayView &&
        other.date == this.date &&
        other.open == this.open &&
        _$deepEquals.equals(other.slots, this.slots);
  }

  @_i3.override
  _i3.int get hashCode {
    const deepEquals = _i5.DeepCollectionEquality();
    return _i3.Object.hashAll([
      this.date,
      this.open,
      deepEquals.hash(this.slots),
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) => throw _i1.EncodingException(
    r'parameterProperties not supported for AvailabilityDayView: contains complex types',
  );

  @_i3.override
  _i3.String uriEncode({
    required _i3.bool allowEmpty,
    required _i6.Encoding textEncoding,
    _i3.bool useQueryComponent = false,
    _i3.bool allowReserved = false,
  }) {
    throw _i1.EncodingException(
      r'Cannot uriEncode AvailabilityDayView: complex types cannot be URI-encoded',
    );
  }
}
