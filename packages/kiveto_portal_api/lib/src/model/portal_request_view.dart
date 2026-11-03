// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i7;
import 'dart:core' as _i3;

import 'package:kiveto_portal_api/src/model/portal_request_view_field_model.dart'
    as _i5;
import 'package:kiveto_portal_api/src/model/portal_request_view_kind_model.dart'
    as _i4;
import 'package:kiveto_portal_api/src/model/portal_request_view_status_model.dart'
    as _i6;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class PortalRequestView extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const PortalRequestView({
    required this.id,
    required this.kind,
    required this.petId,
    required this.field,
    required this.proposedValue,
    required this.prescriptionId,
    required this.status,
    required this.submittedAt,
    required this.resolvedAt,
    required this.resolutionMessage,
    required this.resultingPrescriptionId,
  });

  factory PortalRequestView.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {
        r'id',
        r'kind',
        r'petId',
        r'field',
        r'proposedValue',
        r'prescriptionId',
        r'status',
        r'submittedAt',
        r'resolvedAt',
        r'resolutionMessage',
        r'resultingPrescriptionId',
      },
      listKeys: {},
      context: r'PortalRequestView',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return PortalRequestView(
      id: _$values[r'id'].decodeSimpleString(context: r'PortalRequestView.id'),
      kind: _i4.PortalRequestViewKindModel.fromSimple(
        _$values[r'kind'],
        explode: explode,
      ),
      petId: _$values[r'petId'].decodeSimpleString(
        context: r'PortalRequestView.petId',
      ),
      field: _$values[r'field'] == null
          ? null
          : _i5.PortalRequestViewFieldModel.fromSimple(
              _$values[r'field'],
              explode: explode,
            ),
      proposedValue: _$values[r'proposedValue'].decodeSimpleNullableString(
        context: r'PortalRequestView.proposedValue',
      ),
      prescriptionId: _$values[r'prescriptionId'].decodeSimpleNullableString(
        context: r'PortalRequestView.prescriptionId',
      ),
      status: _i6.PortalRequestViewStatusModel.fromSimple(
        _$values[r'status'],
        explode: explode,
      ),
      submittedAt: _$values[r'submittedAt'].decodeSimpleDateTime(
        context: r'PortalRequestView.submittedAt',
      ),
      resolvedAt: _$values[r'resolvedAt'].decodeSimpleNullableDateTime(
        context: r'PortalRequestView.resolvedAt',
      ),
      resolutionMessage: _$values[r'resolutionMessage']
          .decodeSimpleNullableString(
            context: r'PortalRequestView.resolutionMessage',
          ),
      resultingPrescriptionId: _$values[r'resultingPrescriptionId']
          .decodeSimpleNullableString(
            context: r'PortalRequestView.resultingPrescriptionId',
          ),
    );
  }

  factory PortalRequestView.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'PortalRequestView');
    return PortalRequestView(
      id: _$map[r'id'].decodeJsonString(context: r'PortalRequestView.id'),
      kind: _i4.PortalRequestViewKindModel.fromJson(_$map[r'kind']),
      petId: _$map[r'petId'].decodeJsonString(
        context: r'PortalRequestView.petId',
      ),
      field: _$map[r'field'] == null
          ? null
          : _i5.PortalRequestViewFieldModel.fromJson(_$map[r'field']),
      proposedValue: _$map[r'proposedValue'].decodeJsonNullableString(
        context: r'PortalRequestView.proposedValue',
      ),
      prescriptionId: _$map[r'prescriptionId'].decodeJsonNullableString(
        context: r'PortalRequestView.prescriptionId',
      ),
      status: _i6.PortalRequestViewStatusModel.fromJson(_$map[r'status']),
      submittedAt: _$map[r'submittedAt'].decodeJsonDateTime(
        context: r'PortalRequestView.submittedAt',
      ),
      resolvedAt: _$map[r'resolvedAt'].decodeJsonNullableDateTime(
        context: r'PortalRequestView.resolvedAt',
      ),
      resolutionMessage: _$map[r'resolutionMessage'].decodeJsonNullableString(
        context: r'PortalRequestView.resolutionMessage',
      ),
      resultingPrescriptionId: _$map[r'resultingPrescriptionId']
          .decodeJsonNullableString(
            context: r'PortalRequestView.resultingPrescriptionId',
          ),
    );
  }

  factory PortalRequestView.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {
        r'id',
        r'kind',
        r'petId',
        r'field',
        r'proposedValue',
        r'prescriptionId',
        r'status',
        r'submittedAt',
        r'resolvedAt',
        r'resolutionMessage',
        r'resultingPrescriptionId',
      },
      listKeys: {},
      context: r'PortalRequestView',
    );
    return PortalRequestView(
      id: _$values[r'id'].decodeFormString(context: r'PortalRequestView.id'),
      kind: _i4.PortalRequestViewKindModel.fromForm(
        _$values[r'kind'],
        explode: explode,
      ),
      petId: _$values[r'petId'].decodeFormString(
        context: r'PortalRequestView.petId',
      ),
      field: _$values[r'field'] == null
          ? null
          : _i5.PortalRequestViewFieldModel.fromForm(
              _$values[r'field'],
              explode: explode,
            ),
      proposedValue: _$values[r'proposedValue'].decodeFormNullableString(
        context: r'PortalRequestView.proposedValue',
      ),
      prescriptionId: _$values[r'prescriptionId'].decodeFormNullableString(
        context: r'PortalRequestView.prescriptionId',
      ),
      status: _i6.PortalRequestViewStatusModel.fromForm(
        _$values[r'status'],
        explode: explode,
      ),
      submittedAt: _$values[r'submittedAt'].decodeFormDateTime(
        context: r'PortalRequestView.submittedAt',
      ),
      resolvedAt: _$values[r'resolvedAt'].decodeFormNullableDateTime(
        context: r'PortalRequestView.resolvedAt',
      ),
      resolutionMessage: _$values[r'resolutionMessage']
          .decodeFormNullableString(
            context: r'PortalRequestView.resolutionMessage',
          ),
      resultingPrescriptionId: _$values[r'resultingPrescriptionId']
          .decodeFormNullableString(
            context: r'PortalRequestView.resultingPrescriptionId',
          ),
    );
  }

  final _i3.String id;

  final _i4.PortalRequestViewKindModel kind;

  final _i3.String petId;

  final _i5.PortalRequestViewFieldModel? field;

  final _i3.String? proposedValue;

  final _i3.String? prescriptionId;

  final _i6.PortalRequestViewStatusModel status;

  final _i3.DateTime submittedAt;

  final _i3.DateTime? resolvedAt;

  final _i3.String? resolutionMessage;

  final _i3.String? resultingPrescriptionId;

  @_i3.override
  _i3.Object? toJson() => {
    r'id': this.id,
    r'kind': this.kind.toJson(),
    r'petId': this.petId,
    r'field': this.field?.toJson(),
    r'proposedValue': this.proposedValue,
    r'prescriptionId': this.prescriptionId,
    r'status': this.status.toJson(),
    r'submittedAt': this.submittedAt.toTimeZonedIso8601String(),
    r'resolvedAt': this.resolvedAt?.toTimeZonedIso8601String(),
    r'resolutionMessage': this.resolutionMessage,
    r'resultingPrescriptionId': this.resultingPrescriptionId,
  };

  PortalRequestView Function({
    _i3.String? id,
    _i4.PortalRequestViewKindModel? kind,
    _i3.String? petId,
    _i5.PortalRequestViewFieldModel? field,
    _i3.String? proposedValue,
    _i3.String? prescriptionId,
    _i6.PortalRequestViewStatusModel? status,
    _i3.DateTime? submittedAt,
    _i3.DateTime? resolvedAt,
    _i3.String? resolutionMessage,
    _i3.String? resultingPrescriptionId,
  })
  get copyWith {
    const _i3.Object _sentinel = _i3.Object();
    return ({
      _i3.String? id,
      _i4.PortalRequestViewKindModel? kind,
      _i3.String? petId,
      _i3.Object? field = _sentinel,
      _i3.Object? proposedValue = _sentinel,
      _i3.Object? prescriptionId = _sentinel,
      _i6.PortalRequestViewStatusModel? status,
      _i3.DateTime? submittedAt,
      _i3.Object? resolvedAt = _sentinel,
      _i3.Object? resolutionMessage = _sentinel,
      _i3.Object? resultingPrescriptionId = _sentinel,
    }) => PortalRequestView(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      petId: petId ?? this.petId,
      field: _i3.identical(field, _sentinel)
          ? this.field
          : (field as _i5.PortalRequestViewFieldModel?),
      proposedValue: _i3.identical(proposedValue, _sentinel)
          ? this.proposedValue
          : (proposedValue as _i3.String?),
      prescriptionId: _i3.identical(prescriptionId, _sentinel)
          ? this.prescriptionId
          : (prescriptionId as _i3.String?),
      status: status ?? this.status,
      submittedAt: submittedAt ?? this.submittedAt,
      resolvedAt: _i3.identical(resolvedAt, _sentinel)
          ? this.resolvedAt
          : (resolvedAt as _i3.DateTime?),
      resolutionMessage: _i3.identical(resolutionMessage, _sentinel)
          ? this.resolutionMessage
          : (resolutionMessage as _i3.String?),
      resultingPrescriptionId: _i3.identical(resultingPrescriptionId, _sentinel)
          ? this.resultingPrescriptionId
          : (resultingPrescriptionId as _i3.String?),
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is PortalRequestView &&
        other.id == this.id &&
        other.kind == this.kind &&
        other.petId == this.petId &&
        other.field == this.field &&
        other.proposedValue == this.proposedValue &&
        other.prescriptionId == this.prescriptionId &&
        other.status == this.status &&
        other.submittedAt == this.submittedAt &&
        other.resolvedAt == this.resolvedAt &&
        other.resolutionMessage == this.resolutionMessage &&
        other.resultingPrescriptionId == this.resultingPrescriptionId;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([
      this.id,
      this.kind,
      this.petId,
      this.field,
      this.proposedValue,
      this.prescriptionId,
      this.status,
      this.submittedAt,
      this.resolvedAt,
      this.resolutionMessage,
      this.resultingPrescriptionId,
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'id'] = _i1.PropertyValue.scalar(this.id);
    _$result[r'kind'] = _i1.PropertyValue.scalar(this.kind.toJson());
    _$result[r'petId'] = _i1.PropertyValue.scalar(this.petId);
    if (this.field != null) {
      _$result[r'field'] = _i1.PropertyValue.scalar(this.field!.toJson());
    }
    if (this.proposedValue != null) {
      _$result[r'proposedValue'] = _i1.PropertyValue.scalar(
        this.proposedValue!,
      );
    }
    if (this.prescriptionId != null) {
      _$result[r'prescriptionId'] = _i1.PropertyValue.scalar(
        this.prescriptionId!,
      );
    }
    _$result[r'status'] = _i1.PropertyValue.scalar(this.status.toJson());
    _$result[r'submittedAt'] = _i1.PropertyValue.scalar(
      this.submittedAt.toTimeZonedIso8601String(),
    );
    if (this.resolvedAt != null) {
      _$result[r'resolvedAt'] = _i1.PropertyValue.scalar(
        this.resolvedAt!.toTimeZonedIso8601String(),
      );
    }
    if (this.resolutionMessage != null) {
      _$result[r'resolutionMessage'] = _i1.PropertyValue.scalar(
        this.resolutionMessage!,
      );
    }
    if (this.resultingPrescriptionId != null) {
      _$result[r'resultingPrescriptionId'] = _i1.PropertyValue.scalar(
        this.resultingPrescriptionId!,
      );
    }
    return _$result;
  }

  @_i3.override
  _i3.String uriEncode({
    required _i3.bool allowEmpty,
    required _i7.Encoding textEncoding,
    _i3.bool useQueryComponent = false,
    _i3.bool allowReserved = false,
  }) {
    throw _i1.EncodingException(
      r'Cannot uriEncode PortalRequestView: complex types cannot be URI-encoded',
    );
  }
}
