// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i11;
import 'dart:core' as _i3;

import 'package:kiveto_portal_api/src/model/appointment_cancellation_appointment_view_pet_any_of_model.dart'
    as _i4;
import 'package:kiveto_portal_api/src/model/appointment_cancellation_appointment_view_questionnaire_status_model.dart'
    as _i9;
import 'package:kiveto_portal_api/src/model/appointment_cancellation_appointment_view_related_care_item_any_of_model.dart'
    as _i10;
import 'package:kiveto_portal_api/src/model/appointment_cancellation_appointment_view_source_model.dart'
    as _i8;
import 'package:kiveto_portal_api/src/model/appointment_cancellation_appointment_view_status_model.dart'
    as _i7;
import 'package:kiveto_portal_api/src/model/motif_reference_view.dart' as _i5;
import 'package:kiveto_portal_api/src/model/practitioner_view.dart' as _i6;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class CancelledAppointmentView extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const CancelledAppointmentView({
    required this.id,
    required this.startAt,
    required this.endAt,
    required this.pet,
    required this.motif,
    required this.practitioner,
    required this.status,
    required this.source,
    required this.cancellableUntil,
    required this.questionnaireStatus,
    required this.relatedCareItem,
  });

  factory CancelledAppointmentView.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    throw _i1.SimpleDecodingException(
      r'Simple encoding not supported for CancelledAppointmentView: contains complex types',
    );
  }

  factory CancelledAppointmentView.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'CancelledAppointmentView');
    return CancelledAppointmentView(
      id: _$map[r'id'].decodeJsonString(
        context: r'CancelledAppointmentView.id',
      ),
      startAt: _$map[r'startAt'].decodeJsonDateTime(
        context: r'CancelledAppointmentView.startAt',
      ),
      endAt: _$map[r'endAt'].decodeJsonDateTime(
        context: r'CancelledAppointmentView.endAt',
      ),
      pet: _$map[r'pet'] == null
          ? null
          : _i4.AppointmentCancellationAppointmentViewPetAnyOfModel.fromJson(
              _$map[r'pet'],
            ),
      motif: _i5.MotifReferenceView.fromJson(_$map[r'motif']),
      practitioner: _i6.PractitionerView.fromJson(_$map[r'practitioner']),
      status: _i7.AppointmentCancellationAppointmentViewStatusModel.fromJson(
        _$map[r'status'],
      ),
      source: _i8.AppointmentCancellationAppointmentViewSourceModel.fromJson(
        _$map[r'source'],
      ),
      cancellableUntil: _$map[r'cancellableUntil'].decodeJsonNullableDateTime(
        context: r'CancelledAppointmentView.cancellableUntil',
      ),
      questionnaireStatus:
          _i9.AppointmentCancellationAppointmentViewQuestionnaireStatusModel.fromJson(
            _$map[r'questionnaireStatus'],
          ),
      relatedCareItem: _$map[r'relatedCareItem'] == null
          ? null
          : _i10.AppointmentCancellationAppointmentViewRelatedCareItemAnyOfModel.fromJson(
              _$map[r'relatedCareItem'],
            ),
    );
  }

  factory CancelledAppointmentView.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    throw _i1.FormDecodingException(
      r'Form encoding not supported for CancelledAppointmentView: contains complex types',
    );
  }

  final _i3.String id;

  final _i3.DateTime startAt;

  final _i3.DateTime endAt;

  final _i4.AppointmentCancellationAppointmentViewPetAnyOfModel pet;

  final _i5.MotifReferenceView motif;

  final _i6.PractitionerView practitioner;

  final _i7.AppointmentCancellationAppointmentViewStatusModel status;

  final _i8.AppointmentCancellationAppointmentViewSourceModel source;

  final _i3.DateTime? cancellableUntil;

  final _i9.AppointmentCancellationAppointmentViewQuestionnaireStatusModel
  questionnaireStatus;

  final _i10.AppointmentCancellationAppointmentViewRelatedCareItemAnyOfModel
  relatedCareItem;

  @_i3.override
  _i3.Object? toJson() => {
    r'id': this.id,
    r'startAt': this.startAt.toTimeZonedIso8601String(),
    r'endAt': this.endAt.toTimeZonedIso8601String(),
    r'pet': this.pet?.toJson(),
    r'motif': this.motif.toJson(),
    r'practitioner': this.practitioner.toJson(),
    r'status': this.status.toJson(),
    r'source': this.source.toJson(),
    r'cancellableUntil': this.cancellableUntil?.toTimeZonedIso8601String(),
    r'questionnaireStatus': this.questionnaireStatus.toJson(),
    r'relatedCareItem': this.relatedCareItem?.toJson(),
  };

  CancelledAppointmentView Function({
    _i3.String? id,
    _i3.DateTime? startAt,
    _i3.DateTime? endAt,
    _i4.AppointmentCancellationAppointmentViewPetAnyOfModel? pet,
    _i5.MotifReferenceView? motif,
    _i6.PractitionerView? practitioner,
    _i7.AppointmentCancellationAppointmentViewStatusModel? status,
    _i8.AppointmentCancellationAppointmentViewSourceModel? source,
    _i3.DateTime? cancellableUntil,
    _i9.AppointmentCancellationAppointmentViewQuestionnaireStatusModel?
    questionnaireStatus,
    _i10.AppointmentCancellationAppointmentViewRelatedCareItemAnyOfModel?
    relatedCareItem,
  })
  get copyWith {
    const _i3.Object _sentinel = _i3.Object();
    return ({
      _i3.String? id,
      _i3.DateTime? startAt,
      _i3.DateTime? endAt,
      _i3.Object? pet = _sentinel,
      _i5.MotifReferenceView? motif,
      _i6.PractitionerView? practitioner,
      _i7.AppointmentCancellationAppointmentViewStatusModel? status,
      _i8.AppointmentCancellationAppointmentViewSourceModel? source,
      _i3.Object? cancellableUntil = _sentinel,
      _i9.AppointmentCancellationAppointmentViewQuestionnaireStatusModel?
      questionnaireStatus,
      _i3.Object? relatedCareItem = _sentinel,
    }) => CancelledAppointmentView(
      id: id ?? this.id,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      pet: _i3.identical(pet, _sentinel)
          ? this.pet
          : (pet as _i4.AppointmentCancellationAppointmentViewPetAnyOfModel),
      motif: motif ?? this.motif,
      practitioner: practitioner ?? this.practitioner,
      status: status ?? this.status,
      source: source ?? this.source,
      cancellableUntil: _i3.identical(cancellableUntil, _sentinel)
          ? this.cancellableUntil
          : (cancellableUntil as _i3.DateTime?),
      questionnaireStatus: questionnaireStatus ?? this.questionnaireStatus,
      relatedCareItem: _i3.identical(relatedCareItem, _sentinel)
          ? this.relatedCareItem
          : (relatedCareItem
                as _i10.AppointmentCancellationAppointmentViewRelatedCareItemAnyOfModel),
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is CancelledAppointmentView &&
        other.id == this.id &&
        other.startAt == this.startAt &&
        other.endAt == this.endAt &&
        other.pet == this.pet &&
        other.motif == this.motif &&
        other.practitioner == this.practitioner &&
        other.status == this.status &&
        other.source == this.source &&
        other.cancellableUntil == this.cancellableUntil &&
        other.questionnaireStatus == this.questionnaireStatus &&
        other.relatedCareItem == this.relatedCareItem;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([
      this.id,
      this.startAt,
      this.endAt,
      this.pet,
      this.motif,
      this.practitioner,
      this.status,
      this.source,
      this.cancellableUntil,
      this.questionnaireStatus,
      this.relatedCareItem,
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) => throw _i1.EncodingException(
    r'parameterProperties not supported for CancelledAppointmentView: contains complex types',
  );

  @_i3.override
  _i3.String uriEncode({
    required _i3.bool allowEmpty,
    required _i11.Encoding textEncoding,
    _i3.bool useQueryComponent = false,
    _i3.bool allowReserved = false,
  }) {
    throw _i1.EncodingException(
      r'Cannot uriEncode CancelledAppointmentView: complex types cannot be URI-encoded',
    );
  }
}
