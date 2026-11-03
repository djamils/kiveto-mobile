// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i5;
import 'dart:core' as _i3;

import 'package:kiveto_portal_api/src/model/listing_address_view.dart' as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class $RawClinicListingSummaryViewAddressAnyOfModel
    implements _i1.ParameterEncodable, _i1.UriEncodable {
  const $RawClinicListingSummaryViewAddressAnyOfModel({
    this.listingAddressView,
  });

  factory $RawClinicListingSummaryViewAddressAnyOfModel.fromJson(
    _i3.Object? json,
  ) {
    _i4.ListingAddressView? _$decodedlistingAddressView;

    try {
      _$decodedlistingAddressView = _i4.ListingAddressView.fromJson(json);
    } on _i3.Object catch (_) {
      _$decodedlistingAddressView = null;
    }

    if (_$decodedlistingAddressView == null) {
      throw _i1.JsonDecodingException(
        r'Invalid JSON for $RawClinicListingSummaryViewAddressAnyOfModel: all variants failed to decode',
      );
    }
    return $RawClinicListingSummaryViewAddressAnyOfModel(
      listingAddressView: _$decodedlistingAddressView,
    );
  }

  factory $RawClinicListingSummaryViewAddressAnyOfModel.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    _i4.ListingAddressView? _$decodedlistingAddressView;

    try {
      _$decodedlistingAddressView = _i4.ListingAddressView.fromSimple(
        value,
        explode: explode,
        isHeader: isHeader,
      );
    } on _i3.Object catch (_) {
      _$decodedlistingAddressView = null;
    }

    if (_$decodedlistingAddressView == null) {
      throw _i1.SimpleDecodingException(
        r'Invalid simple value for $RawClinicListingSummaryViewAddressAnyOfModel: all variants failed to decode',
      );
    }
    return $RawClinicListingSummaryViewAddressAnyOfModel(
      listingAddressView: _$decodedlistingAddressView,
    );
  }

  factory $RawClinicListingSummaryViewAddressAnyOfModel.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    _i4.ListingAddressView? _$decodedlistingAddressView;

    try {
      _$decodedlistingAddressView = _i4.ListingAddressView.fromForm(
        value,
        explode: explode,
      );
    } on _i3.Object catch (_) {
      _$decodedlistingAddressView = null;
    }

    if (_$decodedlistingAddressView == null) {
      throw _i1.FormDecodingException(
        r'Invalid form value for $RawClinicListingSummaryViewAddressAnyOfModel: all variants failed to decode',
      );
    }
    return $RawClinicListingSummaryViewAddressAnyOfModel(
      listingAddressView: _$decodedlistingAddressView,
    );
  }

  final _i4.ListingAddressView? listingAddressView;

  _i1.EncodingShape get currentEncodingShape {
    final _$shapes = <_i1.EncodingShape>{};
    if (this.listingAddressView != null) {
      _$shapes.add(this.listingAddressView!.currentEncodingShape);
    }
    if (_$shapes.isEmpty) {
      throw _i3.StateError('At least one field must be non-null in anyOf');
    }
    if (_$shapes.length > 1) return _i1.EncodingShape.mixed;
    return _$shapes.first;
  }

  @_i3.override
  _i3.Object? toJson() {
    final _$values = <_i3.Object?>{};
    final _$mapValues = <_i3.Map<_i3.String, _i3.Object?>>[];
    if (this.listingAddressView != null) {
      final _i3.Object? _$listingAddressViewJson = this.listingAddressView!
          .toJson();
      if (_$listingAddressViewJson is _i3.Map<_i3.String, _i3.Object?>) {
        _$mapValues.add(_$listingAddressViewJson);
      } else {
        _$values.add(_$listingAddressViewJson);
      }
    }
    if (_$values.isEmpty && _$mapValues.isEmpty) return null;
    if (_$values.isNotEmpty && _$mapValues.isNotEmpty) {
      throw _i1.EncodingException(
        r'Mixed encoding not supported for $RawClinicListingSummaryViewAddressAnyOfModel: cannot encode both simple and complex values',
      );
    }
    if (_$values.isNotEmpty) {
      return _$values.first;
    }
    if (_$mapValues.isNotEmpty) {
      final _$map = <_i3.String, _i3.Object?>{};
      for (final _$m in _$mapValues) {
        _i1.mergeJsonObject(_$map, _$m);
      }
      return _$map;
    }
    return null;
  }

  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$mapValues = <_i3.Map<_i3.String, _i1.PropertyValue>>[];
    if (this.listingAddressView != null) {
      _$mapValues.add(
        this.listingAddressView!.parameterProperties(allowEmpty: allowEmpty),
      );
    }
    final _$map = <_i3.String, _i1.PropertyValue>{};
    for (final _$m in _$mapValues) {
      _$map.addAll(_$m);
    }
    return _$map;
  }

  @_i3.override
  _i3.String toSimple({
    required _i3.bool explode,
    required _i3.bool allowEmpty,
    _i3.bool literal = false,
  }) {
    final _$mapValues = <_i3.Map<_i3.String, _i1.PropertyValue>>[];
    if (this.listingAddressView != null) {
      final _$listingAddressViewSimple = this.listingAddressView!
          .parameterProperties(allowEmpty: allowEmpty);
      _$mapValues.add(_$listingAddressViewSimple);
    }
    final _$map = <_i3.String, _i1.PropertyValue>{};
    for (final _$m in _$mapValues) {
      _$map.addAll(_$m);
    }
    return _$map.toSimple(
      explode: explode,
      allowEmpty: allowEmpty,
      literal: literal,
    );
  }

  @_i3.override
  _i3.List<_i1.ParameterEntry> toForm(
    _i3.String paramName, {
    required _i3.bool explode,
    required _i3.bool allowEmpty,
    required _i5.Encoding textEncoding,
    _i3.bool useQueryComponent = false,
    _i3.bool allowReserved = false,
    _i3.Map<_i3.String, _i1.FormFieldEncoding> fieldEncodings = const {},
  }) {
    final _$mapValues = <_i3.Map<_i3.String, _i1.PropertyValue>>[];
    if (this.listingAddressView != null) {
      final _$listingAddressViewForm = this.listingAddressView!
          .parameterProperties(allowEmpty: allowEmpty);
      _$mapValues.add(_$listingAddressViewForm);
    }
    final _$map = <_i3.String, _i1.PropertyValue>{};
    for (final _$m in _$mapValues) {
      _$map.addAll(_$m);
    }
    return _$map.toForm(
      paramName,
      explode: explode,
      allowEmpty: allowEmpty,
      useQueryComponent: useQueryComponent,
      allowReserved: allowReserved,
      fieldEncodings: fieldEncodings,
      textEncoding: textEncoding,
    );
  }

  @_i3.override
  _i3.String toLabel({
    required _i3.bool explode,
    required _i3.bool allowEmpty,
  }) {
    final _$mapValues = <_i3.Map<_i3.String, _i1.PropertyValue>>[];
    if (this.listingAddressView != null) {
      final _$listingAddressViewLabel = this.listingAddressView!
          .parameterProperties(allowEmpty: allowEmpty);
      _$mapValues.add(_$listingAddressViewLabel);
    }
    final _$map = <_i3.String, _i1.PropertyValue>{};
    for (final _$m in _$mapValues) {
      _$map.addAll(_$m);
    }
    return _$map.toLabel(explode: explode, allowEmpty: allowEmpty);
  }

  @_i3.override
  _i3.String toMatrix(
    _i3.String paramName, {
    required _i3.bool explode,
    required _i3.bool allowEmpty,
  }) {
    final _$mapValues = <_i3.Map<_i3.String, _i1.PropertyValue>>[];
    if (this.listingAddressView != null) {
      final _$listingAddressViewMatrix = this.listingAddressView!
          .parameterProperties(allowEmpty: allowEmpty);
      _$mapValues.add(_$listingAddressViewMatrix);
    }
    final _$map = <_i3.String, _i1.PropertyValue>{};
    for (final _$m in _$mapValues) {
      _$map.addAll(_$m);
    }
    return _$map.toMatrix(paramName, explode: explode, allowEmpty: allowEmpty);
  }

  @_i3.override
  _i3.List<_i1.ParameterEntry> toDeepObject(
    _i3.String paramName, {
    required _i3.bool explode,
    required _i3.bool allowEmpty,
    _i3.bool allowReserved = false,
  }) {
    return parameterProperties(allowEmpty: allowEmpty).toDeepObject(
      paramName,
      explode: explode,
      allowEmpty: allowEmpty,
      allowReserved: allowReserved,
    );
  }

  @_i3.override
  _i3.List<_i1.ParameterEntry> toPipeDelimited(
    _i3.String paramName, {
    required _i3.bool allowEmpty,
    _i3.bool allowReserved = false,
  }) {
    return parameterProperties(allowEmpty: allowEmpty).toPipeDelimited(
      paramName,
      allowEmpty: allowEmpty,
      allowReserved: allowReserved,
    );
  }

  @_i3.override
  _i3.List<_i1.ParameterEntry> toSpaceDelimited(
    _i3.String paramName, {
    required _i3.bool allowEmpty,
    _i3.bool allowReserved = false,
  }) {
    return parameterProperties(allowEmpty: allowEmpty).toSpaceDelimited(
      paramName,
      allowEmpty: allowEmpty,
      allowReserved: allowReserved,
    );
  }

  @_i3.override
  _i3.String uriEncode({
    required _i3.bool allowEmpty,
    required _i5.Encoding textEncoding,
    _i3.bool useQueryComponent = false,
    _i3.bool allowReserved = false,
  }) {
    if (this.listingAddressView != null) {
      throw _i1.EncodingException(
        r'Cannot uriEncode $RawClinicListingSummaryViewAddressAnyOfModel: contains complex type',
      );
    }
    throw _i1.EncodingException(
      r'Cannot uriEncode $RawClinicListingSummaryViewAddressAnyOfModel: no value set',
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is $RawClinicListingSummaryViewAddressAnyOfModel &&
        other.listingAddressView == this.listingAddressView;
  }

  @_i3.override
  _i3.int get hashCode => this.listingAddressView.hashCode;

  $RawClinicListingSummaryViewAddressAnyOfModel Function({
    _i4.ListingAddressView? listingAddressView,
  })
  get copyWith {
    const _i3.Object _sentinel = _i3.Object();
    return ({_i3.Object? listingAddressView = _sentinel}) =>
        $RawClinicListingSummaryViewAddressAnyOfModel(
          listingAddressView: _i3.identical(listingAddressView, _sentinel)
              ? this.listingAddressView
              : (listingAddressView as _i4.ListingAddressView?),
        );
  }
}

typedef ClinicListingSummaryViewAddressAnyOfModel =
    $RawClinicListingSummaryViewAddressAnyOfModel?;
