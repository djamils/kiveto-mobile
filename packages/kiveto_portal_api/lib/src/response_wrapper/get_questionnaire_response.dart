// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:kiveto_portal_api/src/model/questionnaire_view.dart' as _i2;
import 'package:meta/meta.dart' as _i1;

sealed class GetQuestionnaireResponse {
  const GetQuestionnaireResponse();
}

@_i1.immutable
class GetQuestionnaireResponse200 extends GetQuestionnaireResponse {
  const GetQuestionnaireResponse200({required this.body});

  final _i2.QuestionnaireView body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is GetQuestionnaireResponse200 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class GetQuestionnaireResponse401 extends GetQuestionnaireResponse {
  const GetQuestionnaireResponse401();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is GetQuestionnaireResponse401;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class GetQuestionnaireResponse404 extends GetQuestionnaireResponse {
  const GetQuestionnaireResponse404();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is GetQuestionnaireResponse404;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}
