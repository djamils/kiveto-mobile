// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i6;
import 'dart:core' as _i3;

import 'package:kiveto_portal_api/src/model/invoice_summary_view_payment_status_model.dart'
    as _i5;
import 'package:kiveto_portal_api/src/model/money_view.dart' as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class InvoiceSummaryView extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const InvoiceSummaryView({required this.total, required this.paymentStatus});

  factory InvoiceSummaryView.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    throw _i1.SimpleDecodingException(
      r'Simple encoding not supported for InvoiceSummaryView: contains complex types',
    );
  }

  factory InvoiceSummaryView.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'InvoiceSummaryView');
    return InvoiceSummaryView(
      total: _i4.MoneyView.fromJson(_$map[r'total']),
      paymentStatus: _i5.InvoiceSummaryViewPaymentStatusModel.fromJson(
        _$map[r'paymentStatus'],
      ),
    );
  }

  factory InvoiceSummaryView.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    throw _i1.FormDecodingException(
      r'Form encoding not supported for InvoiceSummaryView: contains complex types',
    );
  }

  final _i4.MoneyView total;

  final _i5.InvoiceSummaryViewPaymentStatusModel paymentStatus;

  @_i3.override
  _i3.Object? toJson() => {
    r'total': this.total.toJson(),
    r'paymentStatus': this.paymentStatus.toJson(),
  };

  InvoiceSummaryView Function({
    _i4.MoneyView? total,
    _i5.InvoiceSummaryViewPaymentStatusModel? paymentStatus,
  })
  get copyWith {
    return ({
      _i4.MoneyView? total,
      _i5.InvoiceSummaryViewPaymentStatusModel? paymentStatus,
    }) => InvoiceSummaryView(
      total: total ?? this.total,
      paymentStatus: paymentStatus ?? this.paymentStatus,
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is InvoiceSummaryView &&
        other.total == this.total &&
        other.paymentStatus == this.paymentStatus;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([this.total, this.paymentStatus]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) => throw _i1.EncodingException(
    r'parameterProperties not supported for InvoiceSummaryView: contains complex types',
  );

  @_i3.override
  _i3.String uriEncode({
    required _i3.bool allowEmpty,
    required _i6.Encoding textEncoding,
    _i3.bool useQueryComponent = false,
    _i3.bool allowReserved = false,
  }) {
    throw _i1.EncodingException(
      r'Cannot uriEncode InvoiceSummaryView: complex types cannot be URI-encoded',
    );
  }
}
