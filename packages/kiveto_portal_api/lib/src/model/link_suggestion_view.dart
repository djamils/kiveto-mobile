// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i6;
import 'dart:core' as _i3;

import 'package:kiveto_portal_api/src/model/clinic_summary_view.dart' as _i4;
import 'package:kiveto_portal_api/src/model/link_suggestions_link_suggestion_view_matched_on_model.dart'
    as _i5;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

/// The clinics the account may ask to be linked to; the route answers a plain JSON array of them.
@_i2.immutable
class LinkSuggestionView extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const LinkSuggestionView({
    required this.id,
    required this.clinic,
    required this.matchedOn,
  });

  factory LinkSuggestionView.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    throw _i1.SimpleDecodingException(
      r'Simple encoding not supported for LinkSuggestionView: contains complex types',
    );
  }

  factory LinkSuggestionView.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'LinkSuggestionView');
    return LinkSuggestionView(
      id: _$map[r'id'].decodeJsonString(context: r'LinkSuggestionView.id'),
      clinic: _i4.ClinicSummaryView.fromJson(_$map[r'clinic']),
      matchedOn: _i5.LinkSuggestionsLinkSuggestionViewMatchedOnModel.fromJson(
        _$map[r'matchedOn'],
      ),
    );
  }

  factory LinkSuggestionView.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    throw _i1.FormDecodingException(
      r'Form encoding not supported for LinkSuggestionView: contains complex types',
    );
  }

  /// Opaque: names neither the clinic nor a client file.
  final _i3.String id;

  final _i4.ClinicSummaryView clinic;

  final _i5.LinkSuggestionsLinkSuggestionViewMatchedOnModel matchedOn;

  @_i3.override
  _i3.Object? toJson() => {
    r'id': this.id,
    r'clinic': this.clinic.toJson(),
    r'matchedOn': this.matchedOn.toJson(),
  };

  LinkSuggestionView Function({
    _i3.String? id,
    _i4.ClinicSummaryView? clinic,
    _i5.LinkSuggestionsLinkSuggestionViewMatchedOnModel? matchedOn,
  })
  get copyWith {
    return ({
      _i3.String? id,
      _i4.ClinicSummaryView? clinic,
      _i5.LinkSuggestionsLinkSuggestionViewMatchedOnModel? matchedOn,
    }) => LinkSuggestionView(
      id: id ?? this.id,
      clinic: clinic ?? this.clinic,
      matchedOn: matchedOn ?? this.matchedOn,
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is LinkSuggestionView &&
        other.id == this.id &&
        other.clinic == this.clinic &&
        other.matchedOn == this.matchedOn;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([this.id, this.clinic, this.matchedOn]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) => throw _i1.EncodingException(
    r'parameterProperties not supported for LinkSuggestionView: contains complex types',
  );

  @_i3.override
  _i3.String uriEncode({
    required _i3.bool allowEmpty,
    required _i6.Encoding textEncoding,
    _i3.bool useQueryComponent = false,
    _i3.bool allowReserved = false,
  }) {
    throw _i1.EncodingException(
      r'Cannot uriEncode LinkSuggestionView: complex types cannot be URI-encoded',
    );
  }
}
