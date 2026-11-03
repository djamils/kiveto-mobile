// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i8;
import 'dart:core' as _i3;

import 'package:collection/collection.dart' as _i7;
import 'package:kiveto_portal_api/src/model/ongoing_treatment_view.dart' as _i5;
import 'package:kiveto_portal_api/src/model/questionnaire_answers_view_symptoms_array_model.dart'
    as _i4;
import 'package:kiveto_portal_api/src/model/questionnaire_answers_view_temperament_model.dart'
    as _i6;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class QuestionnaireAnswersView extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const QuestionnaireAnswersView({
    required this.symptoms,
    required this.ongoingTreatment,
    required this.temperament,
    required this.notes,
  });

  factory QuestionnaireAnswersView.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    throw _i1.SimpleDecodingException(
      r'Simple encoding not supported for QuestionnaireAnswersView: contains complex types',
    );
  }

  factory QuestionnaireAnswersView.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'QuestionnaireAnswersView');
    return QuestionnaireAnswersView(
      symptoms: _$map[r'symptoms']
          .decodeJsonList<_i3.Object?>(
            context: r'QuestionnaireAnswersView.symptoms',
          )
          .map(_i4.QuestionnaireAnswersViewSymptomsArrayModel.fromJson)
          .toList(),
      ongoingTreatment: _i5.OngoingTreatmentView.fromJson(
        _$map[r'ongoingTreatment'],
      ),
      temperament: _i6.QuestionnaireAnswersViewTemperamentModel.fromJson(
        _$map[r'temperament'],
      ),
      notes: _$map[r'notes'].decodeJsonNullableString(
        context: r'QuestionnaireAnswersView.notes',
      ),
    );
  }

  factory QuestionnaireAnswersView.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    throw _i1.FormDecodingException(
      r'Form encoding not supported for QuestionnaireAnswersView: contains complex types',
    );
  }

  final _i3.List<_i4.QuestionnaireAnswersViewSymptomsArrayModel> symptoms;

  final _i5.OngoingTreatmentView ongoingTreatment;

  final _i6.QuestionnaireAnswersViewTemperamentModel temperament;

  final _i3.String? notes;

  @_i3.override
  _i3.Object? toJson() => {
    r'symptoms': this.symptoms.map((e) => e.toJson()).toList(),
    r'ongoingTreatment': this.ongoingTreatment.toJson(),
    r'temperament': this.temperament.toJson(),
    r'notes': this.notes,
  };

  QuestionnaireAnswersView Function({
    _i3.List<_i4.QuestionnaireAnswersViewSymptomsArrayModel>? symptoms,
    _i5.OngoingTreatmentView? ongoingTreatment,
    _i6.QuestionnaireAnswersViewTemperamentModel? temperament,
    _i3.String? notes,
  })
  get copyWith {
    const _i3.Object _sentinel = _i3.Object();
    return ({
      _i3.List<_i4.QuestionnaireAnswersViewSymptomsArrayModel>? symptoms,
      _i5.OngoingTreatmentView? ongoingTreatment,
      _i6.QuestionnaireAnswersViewTemperamentModel? temperament,
      _i3.Object? notes = _sentinel,
    }) => QuestionnaireAnswersView(
      symptoms: symptoms ?? this.symptoms,
      ongoingTreatment: ongoingTreatment ?? this.ongoingTreatment,
      temperament: temperament ?? this.temperament,
      notes: _i3.identical(notes, _sentinel)
          ? this.notes
          : (notes as _i3.String?),
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    const _$deepEquals = _i7.DeepCollectionEquality();
    return other is QuestionnaireAnswersView &&
        _$deepEquals.equals(other.symptoms, this.symptoms) &&
        other.ongoingTreatment == this.ongoingTreatment &&
        other.temperament == this.temperament &&
        other.notes == this.notes;
  }

  @_i3.override
  _i3.int get hashCode {
    const deepEquals = _i7.DeepCollectionEquality();
    return _i3.Object.hashAll([
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
  }) => throw _i1.EncodingException(
    r'parameterProperties not supported for QuestionnaireAnswersView: contains complex types',
  );

  @_i3.override
  _i3.String uriEncode({
    required _i3.bool allowEmpty,
    required _i8.Encoding textEncoding,
    _i3.bool useQueryComponent = false,
    _i3.bool allowReserved = false,
  }) {
    throw _i1.EncodingException(
      r'Cannot uriEncode QuestionnaireAnswersView: complex types cannot be URI-encoded',
    );
  }
}
