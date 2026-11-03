// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i4;
import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class OngoingTreatmentView extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const OngoingTreatmentView({required this.has, required this.details});

  factory OngoingTreatmentView.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {r'has', r'details'},
      listKeys: {},
      context: r'OngoingTreatmentView',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return OngoingTreatmentView(
      has: _$values[r'has'].decodeSimpleBool(
        context: r'OngoingTreatmentView.has',
      ),
      details: _$values[r'details'].decodeSimpleNullableString(
        context: r'OngoingTreatmentView.details',
      ),
    );
  }

  factory OngoingTreatmentView.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'OngoingTreatmentView');
    return OngoingTreatmentView(
      has: _$map[r'has'].decodeJsonBool(context: r'OngoingTreatmentView.has'),
      details: _$map[r'details'].decodeJsonNullableString(
        context: r'OngoingTreatmentView.details',
      ),
    );
  }

  factory OngoingTreatmentView.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {r'has', r'details'},
      listKeys: {},
      context: r'OngoingTreatmentView',
    );
    return OngoingTreatmentView(
      has: _$values[r'has'].decodeFormBool(
        context: r'OngoingTreatmentView.has',
      ),
      details: _$values[r'details'].decodeFormNullableString(
        context: r'OngoingTreatmentView.details',
      ),
    );
  }

  final _i3.bool has;

  final _i3.String? details;

  @_i3.override
  _i3.Object? toJson() => {r'has': this.has, r'details': this.details};

  OngoingTreatmentView Function({_i3.bool? has, _i3.String? details})
  get copyWith {
    const _i3.Object _sentinel = _i3.Object();
    return ({_i3.bool? has, _i3.Object? details = _sentinel}) =>
        OngoingTreatmentView(
          has: has ?? this.has,
          details: _i3.identical(details, _sentinel)
              ? this.details
              : (details as _i3.String?),
        );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is OngoingTreatmentView &&
        other.has == this.has &&
        other.details == this.details;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([this.has, this.details]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'has'] = _i1.PropertyValue.scalar(this.has.toString());
    if (this.details != null) {
      _$result[r'details'] = _i1.PropertyValue.scalar(this.details!);
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
      r'Cannot uriEncode OngoingTreatmentView: complex types cannot be URI-encoded',
    );
  }
}
