// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i6;
import 'dart:core' as _i3;

import 'package:collection/collection.dart' as _i5;
import 'package:kiveto_portal_api/src/model/availability_day_view.dart' as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class BookingAvailability extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const BookingAvailability({required this.days});

  factory BookingAvailability.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    throw _i1.SimpleDecodingException(
      r'Simple encoding not supported for BookingAvailability: contains complex types',
    );
  }

  factory BookingAvailability.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'BookingAvailability');
    return BookingAvailability(
      days: _$map[r'days']
          .decodeJsonList<_i3.Object?>(context: r'BookingAvailability.days')
          .map(_i4.AvailabilityDayView.fromJson)
          .toList(),
    );
  }

  factory BookingAvailability.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    throw _i1.FormDecodingException(
      r'Form encoding not supported for BookingAvailability: contains complex types',
    );
  }

  final _i3.List<_i4.AvailabilityDayView> days;

  @_i3.override
  _i3.Object? toJson() => {r'days': this.days.map((e) => e.toJson()).toList()};

  BookingAvailability Function({_i3.List<_i4.AvailabilityDayView>? days})
  get copyWith {
    return ({_i3.List<_i4.AvailabilityDayView>? days}) =>
        BookingAvailability(days: days ?? this.days);
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    const _$deepEquals = _i5.DeepCollectionEquality();
    return other is BookingAvailability &&
        _$deepEquals.equals(other.days, this.days);
  }

  @_i3.override
  _i3.int get hashCode {
    const deepEquals = _i5.DeepCollectionEquality();
    return deepEquals.hash(this.days);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) => throw _i1.EncodingException(
    r'parameterProperties not supported for BookingAvailability: contains complex types',
  );

  @_i3.override
  _i3.String uriEncode({
    required _i3.bool allowEmpty,
    required _i6.Encoding textEncoding,
    _i3.bool useQueryComponent = false,
    _i3.bool allowReserved = false,
  }) {
    throw _i1.EncodingException(
      r'Cannot uriEncode BookingAvailability: complex types cannot be URI-encoded',
    );
  }
}
