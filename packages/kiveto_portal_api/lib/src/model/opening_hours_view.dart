// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i4;
import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class OpeningHoursView extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const OpeningHoursView({
    required this.day,
    required this.opensAt,
    required this.closesAt,
  });

  factory OpeningHoursView.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {r'day', r'opensAt', r'closesAt'},
      listKeys: {},
      context: r'OpeningHoursView',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return OpeningHoursView(
      day: _$values[r'day'].decodeSimpleInt(context: r'OpeningHoursView.day'),
      opensAt: _$values[r'opensAt'].decodeSimpleString(
        context: r'OpeningHoursView.opensAt',
      ),
      closesAt: _$values[r'closesAt'].decodeSimpleString(
        context: r'OpeningHoursView.closesAt',
      ),
    );
  }

  factory OpeningHoursView.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'OpeningHoursView');
    return OpeningHoursView(
      day: _$map[r'day'].decodeJsonInt(context: r'OpeningHoursView.day'),
      opensAt: _$map[r'opensAt'].decodeJsonString(
        context: r'OpeningHoursView.opensAt',
      ),
      closesAt: _$map[r'closesAt'].decodeJsonString(
        context: r'OpeningHoursView.closesAt',
      ),
    );
  }

  factory OpeningHoursView.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {r'day', r'opensAt', r'closesAt'},
      listKeys: {},
      context: r'OpeningHoursView',
    );
    return OpeningHoursView(
      day: _$values[r'day'].decodeFormInt(context: r'OpeningHoursView.day'),
      opensAt: _$values[r'opensAt'].decodeFormString(
        context: r'OpeningHoursView.opensAt',
      ),
      closesAt: _$values[r'closesAt'].decodeFormString(
        context: r'OpeningHoursView.closesAt',
      ),
    );
  }

  final _i3.int day;

  final _i3.String opensAt;

  final _i3.String closesAt;

  @_i3.override
  _i3.Object? toJson() => {
    r'day': this.day,
    r'opensAt': this.opensAt,
    r'closesAt': this.closesAt,
  };

  OpeningHoursView Function({
    _i3.int? day,
    _i3.String? opensAt,
    _i3.String? closesAt,
  })
  get copyWith {
    return ({_i3.int? day, _i3.String? opensAt, _i3.String? closesAt}) =>
        OpeningHoursView(
          day: day ?? this.day,
          opensAt: opensAt ?? this.opensAt,
          closesAt: closesAt ?? this.closesAt,
        );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is OpeningHoursView &&
        other.day == this.day &&
        other.opensAt == this.opensAt &&
        other.closesAt == this.closesAt;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([this.day, this.opensAt, this.closesAt]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'day'] = _i1.PropertyValue.scalar(this.day.toString());
    _$result[r'opensAt'] = _i1.PropertyValue.scalar(this.opensAt);
    _$result[r'closesAt'] = _i1.PropertyValue.scalar(this.closesAt);
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
      r'Cannot uriEncode OpeningHoursView: complex types cannot be URI-encoded',
    );
  }
}
