// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i7;
import 'dart:core' as _i3;

import 'package:kiveto_portal_api/src/model/questionnaire_update_questionnaire_view_answers_any_of_model.dart'
    as _i6;
import 'package:kiveto_portal_api/src/model/questionnaire_update_questionnaire_view_status_model.dart'
    as _i5;
import 'package:kiveto_portal_api/src/model/questionnaire_update_questionnaire_view_version_model.dart'
    as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class SavedQuestionnaireView extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const SavedQuestionnaireView({
    required this.version,
    required this.status,
    required this.answers,
    required this.updatedAt,
    required this.editable,
  });

  factory SavedQuestionnaireView.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    throw _i1.SimpleDecodingException(
      r'Simple encoding not supported for SavedQuestionnaireView: contains complex types',
    );
  }

  factory SavedQuestionnaireView.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'SavedQuestionnaireView');
    return SavedQuestionnaireView(
      version: _i4.QuestionnaireUpdateQuestionnaireViewVersionModel.fromJson(
        _$map[r'version'],
      ),
      status: _i5.QuestionnaireUpdateQuestionnaireViewStatusModel.fromJson(
        _$map[r'status'],
      ),
      answers: _$map[r'answers'] == null
          ? null
          : _i6.QuestionnaireUpdateQuestionnaireViewAnswersAnyOfModel.fromJson(
              _$map[r'answers'],
            ),
      updatedAt: _$map[r'updatedAt'].decodeJsonNullableDateTime(
        context: r'SavedQuestionnaireView.updatedAt',
      ),
      editable: _$map[r'editable'].decodeJsonBool(
        context: r'SavedQuestionnaireView.editable',
      ),
    );
  }

  factory SavedQuestionnaireView.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    throw _i1.FormDecodingException(
      r'Form encoding not supported for SavedQuestionnaireView: contains complex types',
    );
  }

  final _i4.QuestionnaireUpdateQuestionnaireViewVersionModel version;

  final _i5.QuestionnaireUpdateQuestionnaireViewStatusModel status;

  final _i6.QuestionnaireUpdateQuestionnaireViewAnswersAnyOfModel answers;

  final _i3.DateTime? updatedAt;

  final _i3.bool editable;

  @_i3.override
  _i3.Object? toJson() => {
    r'version': this.version.toJson(),
    r'status': this.status.toJson(),
    r'answers': this.answers?.toJson(),
    r'updatedAt': this.updatedAt?.toTimeZonedIso8601String(),
    r'editable': this.editable,
  };

  SavedQuestionnaireView Function({
    _i4.QuestionnaireUpdateQuestionnaireViewVersionModel? version,
    _i5.QuestionnaireUpdateQuestionnaireViewStatusModel? status,
    _i6.QuestionnaireUpdateQuestionnaireViewAnswersAnyOfModel? answers,
    _i3.DateTime? updatedAt,
    _i3.bool? editable,
  })
  get copyWith {
    const _i3.Object _sentinel = _i3.Object();
    return ({
      _i4.QuestionnaireUpdateQuestionnaireViewVersionModel? version,
      _i5.QuestionnaireUpdateQuestionnaireViewStatusModel? status,
      _i3.Object? answers = _sentinel,
      _i3.Object? updatedAt = _sentinel,
      _i3.bool? editable,
    }) => SavedQuestionnaireView(
      version: version ?? this.version,
      status: status ?? this.status,
      answers: _i3.identical(answers, _sentinel)
          ? this.answers
          : (answers
                as _i6.QuestionnaireUpdateQuestionnaireViewAnswersAnyOfModel),
      updatedAt: _i3.identical(updatedAt, _sentinel)
          ? this.updatedAt
          : (updatedAt as _i3.DateTime?),
      editable: editable ?? this.editable,
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is SavedQuestionnaireView &&
        other.version == this.version &&
        other.status == this.status &&
        other.answers == this.answers &&
        other.updatedAt == this.updatedAt &&
        other.editable == this.editable;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([
      this.version,
      this.status,
      this.answers,
      this.updatedAt,
      this.editable,
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
    _$result[r'status'] = _i1.PropertyValue.scalar(this.status.toJson());
    if (this.answers != null) {
      _$result[r'answers'] = _i1.encodeAnyValueToPropertyValue(
        this.answers!.toJson(),
        allowEmpty: allowEmpty,
      );
    }
    if (this.updatedAt != null) {
      _$result[r'updatedAt'] = _i1.PropertyValue.scalar(
        this.updatedAt!.toTimeZonedIso8601String(),
      );
    }
    _$result[r'editable'] = _i1.PropertyValue.scalar(this.editable.toString());
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
      r'Cannot uriEncode SavedQuestionnaireView: complex types cannot be URI-encoded',
    );
  }
}
