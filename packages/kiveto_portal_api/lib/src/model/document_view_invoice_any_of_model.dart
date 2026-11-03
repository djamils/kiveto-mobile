// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i5;
import 'dart:core' as _i3;

import 'package:kiveto_portal_api/src/model/invoice_summary_view.dart' as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class $RawDocumentViewInvoiceAnyOfModel
    implements _i1.ParameterEncodable, _i1.UriEncodable {
  const $RawDocumentViewInvoiceAnyOfModel({this.invoiceSummaryView});

  factory $RawDocumentViewInvoiceAnyOfModel.fromJson(_i3.Object? json) {
    _i4.InvoiceSummaryView? _$decodedinvoiceSummaryView;

    try {
      _$decodedinvoiceSummaryView = _i4.InvoiceSummaryView.fromJson(json);
    } on _i3.Object catch (_) {
      _$decodedinvoiceSummaryView = null;
    }

    if (_$decodedinvoiceSummaryView == null) {
      throw _i1.JsonDecodingException(
        r'Invalid JSON for $RawDocumentViewInvoiceAnyOfModel: all variants failed to decode',
      );
    }
    return $RawDocumentViewInvoiceAnyOfModel(
      invoiceSummaryView: _$decodedinvoiceSummaryView,
    );
  }

  factory $RawDocumentViewInvoiceAnyOfModel.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    _i4.InvoiceSummaryView? _$decodedinvoiceSummaryView;

    try {
      _$decodedinvoiceSummaryView = _i4.InvoiceSummaryView.fromSimple(
        value,
        explode: explode,
        isHeader: isHeader,
      );
    } on _i3.Object catch (_) {
      _$decodedinvoiceSummaryView = null;
    }

    if (_$decodedinvoiceSummaryView == null) {
      throw _i1.SimpleDecodingException(
        r'Invalid simple value for $RawDocumentViewInvoiceAnyOfModel: all variants failed to decode',
      );
    }
    return $RawDocumentViewInvoiceAnyOfModel(
      invoiceSummaryView: _$decodedinvoiceSummaryView,
    );
  }

  factory $RawDocumentViewInvoiceAnyOfModel.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    _i4.InvoiceSummaryView? _$decodedinvoiceSummaryView;

    try {
      _$decodedinvoiceSummaryView = _i4.InvoiceSummaryView.fromForm(
        value,
        explode: explode,
      );
    } on _i3.Object catch (_) {
      _$decodedinvoiceSummaryView = null;
    }

    if (_$decodedinvoiceSummaryView == null) {
      throw _i1.FormDecodingException(
        r'Invalid form value for $RawDocumentViewInvoiceAnyOfModel: all variants failed to decode',
      );
    }
    return $RawDocumentViewInvoiceAnyOfModel(
      invoiceSummaryView: _$decodedinvoiceSummaryView,
    );
  }

  final _i4.InvoiceSummaryView? invoiceSummaryView;

  _i1.EncodingShape get currentEncodingShape {
    final _$shapes = <_i1.EncodingShape>{};
    if (this.invoiceSummaryView != null) {
      _$shapes.add(this.invoiceSummaryView!.currentEncodingShape);
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
    if (this.invoiceSummaryView != null) {
      final _i3.Object? _$invoiceSummaryViewJson = this.invoiceSummaryView!
          .toJson();
      if (_$invoiceSummaryViewJson is _i3.Map<_i3.String, _i3.Object?>) {
        _$mapValues.add(_$invoiceSummaryViewJson);
      } else {
        _$values.add(_$invoiceSummaryViewJson);
      }
    }
    if (_$values.isEmpty && _$mapValues.isEmpty) return null;
    if (_$values.isNotEmpty && _$mapValues.isNotEmpty) {
      throw _i1.EncodingException(
        r'Mixed encoding not supported for $RawDocumentViewInvoiceAnyOfModel: cannot encode both simple and complex values',
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
    if (this.invoiceSummaryView != null) {
      _$mapValues.add(
        this.invoiceSummaryView!.parameterProperties(allowEmpty: allowEmpty),
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
    if (this.invoiceSummaryView != null) {
      final _$invoiceSummaryViewSimple = this.invoiceSummaryView!
          .parameterProperties(allowEmpty: allowEmpty);
      _$mapValues.add(_$invoiceSummaryViewSimple);
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
    if (this.invoiceSummaryView != null) {
      final _$invoiceSummaryViewForm = this.invoiceSummaryView!
          .parameterProperties(allowEmpty: allowEmpty);
      _$mapValues.add(_$invoiceSummaryViewForm);
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
    if (this.invoiceSummaryView != null) {
      final _$invoiceSummaryViewLabel = this.invoiceSummaryView!
          .parameterProperties(allowEmpty: allowEmpty);
      _$mapValues.add(_$invoiceSummaryViewLabel);
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
    if (this.invoiceSummaryView != null) {
      final _$invoiceSummaryViewMatrix = this.invoiceSummaryView!
          .parameterProperties(allowEmpty: allowEmpty);
      _$mapValues.add(_$invoiceSummaryViewMatrix);
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
    if (this.invoiceSummaryView != null) {
      throw _i1.EncodingException(
        r'Cannot uriEncode $RawDocumentViewInvoiceAnyOfModel: contains complex type',
      );
    }
    throw _i1.EncodingException(
      r'Cannot uriEncode $RawDocumentViewInvoiceAnyOfModel: no value set',
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is $RawDocumentViewInvoiceAnyOfModel &&
        other.invoiceSummaryView == this.invoiceSummaryView;
  }

  @_i3.override
  _i3.int get hashCode => this.invoiceSummaryView.hashCode;

  $RawDocumentViewInvoiceAnyOfModel Function({
    _i4.InvoiceSummaryView? invoiceSummaryView,
  })
  get copyWith {
    const _i3.Object _sentinel = _i3.Object();
    return ({_i3.Object? invoiceSummaryView = _sentinel}) =>
        $RawDocumentViewInvoiceAnyOfModel(
          invoiceSummaryView: _i3.identical(invoiceSummaryView, _sentinel)
              ? this.invoiceSummaryView
              : (invoiceSummaryView as _i4.InvoiceSummaryView?),
        );
  }
}

typedef DocumentViewInvoiceAnyOfModel = $RawDocumentViewInvoiceAnyOfModel?;
