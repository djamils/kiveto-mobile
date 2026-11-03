// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i8;
import 'dart:core' as _i3;

import 'package:collection/collection.dart' as _i7;
import 'package:kiveto_portal_api/src/model/document_view_invoice_any_of_model.dart'
    as _i5;
import 'package:kiveto_portal_api/src/model/document_view_prescription_any_of_model.dart'
    as _i6;
import 'package:kiveto_portal_api/src/model/document_view_type_model.dart'
    as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class DocumentView extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const DocumentView({
    required this.id,
    required this.kind,
    required this.title,
    required this.petIds,
    required this.issuedAt,
    required this.unread,
    required this.invoice,
    required this.prescription,
  });

  factory DocumentView.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    throw _i1.SimpleDecodingException(
      r'Simple encoding not supported for DocumentView: contains complex types',
    );
  }

  factory DocumentView.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'DocumentView');
    return DocumentView(
      id: _$map[r'id'].decodeJsonString(context: r'DocumentView.id'),
      kind: _i4.DocumentViewTypeModel.fromJson(_$map[r'type']),
      title: _$map[r'title'].decodeJsonString(context: r'DocumentView.title'),
      petIds: _$map[r'petIds'].decodeJsonList<_i3.String>(
        context: r'DocumentView.petIds',
      ),
      issuedAt: _$map[r'issuedAt'].decodeJsonDateTime(
        context: r'DocumentView.issuedAt',
      ),
      unread: _$map[r'unread'].decodeJsonBool(context: r'DocumentView.unread'),
      invoice: _$map[r'invoice'] == null
          ? null
          : _i5.DocumentViewInvoiceAnyOfModel.fromJson(_$map[r'invoice']),
      prescription: _$map[r'prescription'] == null
          ? null
          : _i6.DocumentViewPrescriptionAnyOfModel.fromJson(
              _$map[r'prescription'],
            ),
    );
  }

  factory DocumentView.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    throw _i1.FormDecodingException(
      r'Form encoding not supported for DocumentView: contains complex types',
    );
  }

  final _i3.String id;

  final _i4.DocumentViewTypeModel kind;

  final _i3.String title;

  final _i3.List<_i3.String> petIds;

  final _i3.DateTime issuedAt;

  final _i3.bool unread;

  final _i5.DocumentViewInvoiceAnyOfModel invoice;

  final _i6.DocumentViewPrescriptionAnyOfModel prescription;

  @_i3.override
  _i3.Object? toJson() => {
    r'id': this.id,
    r'type': this.kind.toJson(),
    r'title': this.title,
    r'petIds': this.petIds,
    r'issuedAt': this.issuedAt.toTimeZonedIso8601String(),
    r'unread': this.unread,
    r'invoice': this.invoice?.toJson(),
    r'prescription': this.prescription?.toJson(),
  };

  DocumentView Function({
    _i3.String? id,
    _i4.DocumentViewTypeModel? kind,
    _i3.String? title,
    _i3.List<_i3.String>? petIds,
    _i3.DateTime? issuedAt,
    _i3.bool? unread,
    _i5.DocumentViewInvoiceAnyOfModel? invoice,
    _i6.DocumentViewPrescriptionAnyOfModel? prescription,
  })
  get copyWith {
    const _i3.Object _sentinel = _i3.Object();
    return ({
      _i3.String? id,
      _i4.DocumentViewTypeModel? kind,
      _i3.String? title,
      _i3.List<_i3.String>? petIds,
      _i3.DateTime? issuedAt,
      _i3.bool? unread,
      _i3.Object? invoice = _sentinel,
      _i3.Object? prescription = _sentinel,
    }) => DocumentView(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      title: title ?? this.title,
      petIds: petIds ?? this.petIds,
      issuedAt: issuedAt ?? this.issuedAt,
      unread: unread ?? this.unread,
      invoice: _i3.identical(invoice, _sentinel)
          ? this.invoice
          : (invoice as _i5.DocumentViewInvoiceAnyOfModel),
      prescription: _i3.identical(prescription, _sentinel)
          ? this.prescription
          : (prescription as _i6.DocumentViewPrescriptionAnyOfModel),
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    const _$deepEquals = _i7.DeepCollectionEquality();
    return other is DocumentView &&
        other.id == this.id &&
        other.kind == this.kind &&
        other.title == this.title &&
        _$deepEquals.equals(other.petIds, this.petIds) &&
        other.issuedAt == this.issuedAt &&
        other.unread == this.unread &&
        other.invoice == this.invoice &&
        other.prescription == this.prescription;
  }

  @_i3.override
  _i3.int get hashCode {
    const deepEquals = _i7.DeepCollectionEquality();
    return _i3.Object.hashAll([
      this.id,
      this.kind,
      this.title,
      deepEquals.hash(this.petIds),
      this.issuedAt,
      this.unread,
      this.invoice,
      this.prescription,
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'id'] = _i1.PropertyValue.scalar(this.id);
    _$result[r'type'] = _i1.PropertyValue.scalar(this.kind.toJson());
    _$result[r'title'] = _i1.PropertyValue.scalar(this.title);
    _$result[r'petIds'] = _i1.PropertyValue.array(this.petIds);
    _$result[r'issuedAt'] = _i1.PropertyValue.scalar(
      this.issuedAt.toTimeZonedIso8601String(),
    );
    _$result[r'unread'] = _i1.PropertyValue.scalar(this.unread.toString());
    if (this.invoice != null) {
      _$result[r'invoice'] = _i1.encodeAnyValueToPropertyValue(
        this.invoice!.toJson(),
        allowEmpty: allowEmpty,
      );
    }
    if (this.prescription != null) {
      _$result[r'prescription'] = _i1.encodeAnyValueToPropertyValue(
        this.prescription!.toJson(),
        allowEmpty: allowEmpty,
      );
    }
    return _$result;
  }

  @_i3.override
  _i3.String uriEncode({
    required _i3.bool allowEmpty,
    required _i8.Encoding textEncoding,
    _i3.bool useQueryComponent = false,
    _i3.bool allowReserved = false,
  }) {
    throw _i1.EncodingException(
      r'Cannot uriEncode DocumentView: complex types cannot be URI-encoded',
    );
  }
}
