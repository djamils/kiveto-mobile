// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i5;
import 'dart:core' as _i3;

import 'package:kiveto_portal_api/src/model/link_suggestion_acceptance_link_suggestion_accepted_view_link_status_model.dart'
    as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class LinkSuggestionAcceptedView extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const LinkSuggestionAcceptedView({required this.linkStatus});

  factory LinkSuggestionAcceptedView.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {r'linkStatus'},
      listKeys: {},
      context: r'LinkSuggestionAcceptedView',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return LinkSuggestionAcceptedView(
      linkStatus:
          _i4.LinkSuggestionAcceptanceLinkSuggestionAcceptedViewLinkStatusModel.fromSimple(
            _$values[r'linkStatus'],
            explode: explode,
          ),
    );
  }

  factory LinkSuggestionAcceptedView.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'LinkSuggestionAcceptedView');
    return LinkSuggestionAcceptedView(
      linkStatus:
          _i4.LinkSuggestionAcceptanceLinkSuggestionAcceptedViewLinkStatusModel.fromJson(
            _$map[r'linkStatus'],
          ),
    );
  }

  factory LinkSuggestionAcceptedView.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {r'linkStatus'},
      listKeys: {},
      context: r'LinkSuggestionAcceptedView',
    );
    return LinkSuggestionAcceptedView(
      linkStatus:
          _i4.LinkSuggestionAcceptanceLinkSuggestionAcceptedViewLinkStatusModel.fromForm(
            _$values[r'linkStatus'],
            explode: explode,
          ),
    );
  }

  final _i4.LinkSuggestionAcceptanceLinkSuggestionAcceptedViewLinkStatusModel
  linkStatus;

  @_i3.override
  _i3.Object? toJson() => {r'linkStatus': this.linkStatus.toJson()};

  LinkSuggestionAcceptedView Function({
    _i4.LinkSuggestionAcceptanceLinkSuggestionAcceptedViewLinkStatusModel?
    linkStatus,
  })
  get copyWith {
    return ({
      _i4.LinkSuggestionAcceptanceLinkSuggestionAcceptedViewLinkStatusModel?
      linkStatus,
    }) => LinkSuggestionAcceptedView(linkStatus: linkStatus ?? this.linkStatus);
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is LinkSuggestionAcceptedView &&
        other.linkStatus == this.linkStatus;
  }

  @_i3.override
  _i3.int get hashCode => this.linkStatus.hashCode;

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'linkStatus'] = _i1.PropertyValue.scalar(
      this.linkStatus.toJson(),
    );
    return _$result;
  }

  @_i3.override
  _i3.String uriEncode({
    required _i3.bool allowEmpty,
    required _i5.Encoding textEncoding,
    _i3.bool useQueryComponent = false,
    _i3.bool allowReserved = false,
  }) {
    throw _i1.EncodingException(
      r'Cannot uriEncode LinkSuggestionAcceptedView: complex types cannot be URI-encoded',
    );
  }
}
