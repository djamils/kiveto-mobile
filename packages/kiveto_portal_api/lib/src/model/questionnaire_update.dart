// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i9;
import 'dart:core' as _i3;

import 'package:collection/collection.dart' as _i8;
import 'package:kiveto_portal_api/src/model/questionnaire_update_ongoing_treatment_any_of_model.dart'
    as _i6;
import 'package:kiveto_portal_api/src/model/questionnaire_update_symptoms_array_model.dart'
    as _i5;
import 'package:kiveto_portal_api/src/model/questionnaire_update_temperament_model.dart'
    as _i7;
import 'package:kiveto_portal_api/src/model/questionnaire_update_version_model.dart'
    as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class QuestionnaireUpdate extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const QuestionnaireUpdate({
    required this.version,
    required this.symptoms,
    required this.ongoingTreatment,
    required this.temperament,
    this.notes,
  });

  factory QuestionnaireUpdate.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    throw _i1.SimpleDecodingException(
      r'Simple encoding not supported for QuestionnaireUpdate: contains complex types',
    );
  }

  factory QuestionnaireUpdate.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'QuestionnaireUpdate');
    return QuestionnaireUpdate(
      version: _i4.QuestionnaireUpdateVersionModel.fromJson(_$map[r'version']),
      symptoms: _$map[r'symptoms']
          .decodeJsonList<_i3.Object?>(context: r'QuestionnaireUpdate.symptoms')
          .map(_i5.QuestionnaireUpdateSymptomsArrayModel.fromJson)
          .toList(),
      ongoingTreatment: _$map[r'ongoingTreatment'] == null
          ? null
          : _i6.QuestionnaireUpdateOngoingTreatmentAnyOfModel.fromJson(
              _$map[r'ongoingTreatment'],
            ),
      temperament: _i7.QuestionnaireUpdateTemperamentModel.fromJson(
        _$map[r'temperament'],
      ),
      notes: _$map[r'notes'].decodeJsonNullableString(
        context: r'QuestionnaireUpdate.notes',
      ),
    );
  }

  factory QuestionnaireUpdate.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    throw _i1.FormDecodingException(
      r'Form encoding not supported for QuestionnaireUpdate: contains complex types',
    );
  }

  final _i4.QuestionnaireUpdateVersionModel version;

  final _i3.List<_i5.QuestionnaireUpdateSymptomsArrayModel> symptoms;

  final _i6.QuestionnaireUpdateOngoingTreatmentAnyOfModel ongoingTreatment;

  final _i7.QuestionnaireUpdateTemperamentModel temperament;

  final _i3.String? notes;

  @_i3.override
  _i3.Object? toJson() => {
    r'version': this.version.toJson(),
    r'symptoms': this.symptoms.map((e) => e.toJson()).toList(),
    r'ongoingTreatment': this.ongoingTreatment?.toJson(),
    r'temperament': this.temperament.toJson(),
    r'notes': this.notes,
  };

  QuestionnaireUpdate Function({
    _i4.QuestionnaireUpdateVersionModel? version,
    _i3.List<_i5.QuestionnaireUpdateSymptomsArrayModel>? symptoms,
    _i6.QuestionnaireUpdateOngoingTreatmentAnyOfModel? ongoingTreatment,
    _i7.QuestionnaireUpdateTemperamentModel? temperament,
    _i3.String? notes,
  })
  get copyWith {
    const _i3.Object _sentinel = _i3.Object();
    return ({
      _i4.QuestionnaireUpdateVersionModel? version,
      _i3.List<_i5.QuestionnaireUpdateSymptomsArrayModel>? symptoms,
      _i3.Object? ongoingTreatment = _sentinel,
      _i7.QuestionnaireUpdateTemperamentModel? temperament,
      _i3.Object? notes = _sentinel,
    }) => QuestionnaireUpdate(
      version: version ?? this.version,
      symptoms: symptoms ?? this.symptoms,
      ongoingTreatment: _i3.identical(ongoingTreatment, _sentinel)
          ? this.ongoingTreatment
          : (ongoingTreatment
                as _i6.QuestionnaireUpdateOngoingTreatmentAnyOfModel),
      temperament: temperament ?? this.temperament,
      notes: _i3.identical(notes, _sentinel)
          ? this.notes
          : (notes as _i3.String?),
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    const _$deepEquals = _i8.DeepCollectionEquality();
    return other is QuestionnaireUpdate &&
        other.version == this.version &&
        _$deepEquals.equals(other.symptoms, this.symptoms) &&
        other.ongoingTreatment == this.ongoingTreatment &&
        other.temperament == this.temperament &&
        other.notes == this.notes;
  }

  @_i3.override
  _i3.int get hashCode {
    const deepEquals = _i8.DeepCollectionEquality();
    return _i3.Object.hashAll([
      this.version,
      deepEquals.hash(this.symptoms),
      this.ongoingTreatment,
      this.temperament,
      this.notes,
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'version'] = _i1.PropertyValue.scalar(
      this.version.toJson().toString(),
    );
    _$result[r'symptoms'] = _i1.PropertyValue.array(
      this.symptoms.map((e) => e.toJson()).toList(),
    );
    if (this.ongoingTreatment != null) {
      _$result[r'ongoingTreatment'] = _i1.encodeAnyValueToPropertyValue(
        this.ongoingTreatment!.toJson(),
        allowEmpty: allowEmpty,
      );
    }
    _$result[r'temperament'] = _i1.PropertyValue.scalar(
      this.temperament.toJson(),
    );
    if (this.notes != null) {
      _$result[r'notes'] = _i1.PropertyValue.scalar(this.notes!);
    }
    return _$result;
  }

  @_i3.override
  _i3.String uriEncode({
    required _i3.bool allowEmpty,
    required _i9.Encoding textEncoding,
    _i3.bool useQueryComponent = false,
    _i3.bool allowReserved = false,
  }) {
    throw _i1.EncodingException(
      r'Cannot uriEncode QuestionnaireUpdate: complex types cannot be URI-encoded',
    );
  }
}
