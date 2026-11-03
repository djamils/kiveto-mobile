// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:kiveto_portal_api/src/model/link_suggestion_accepted_view.dart'
    as _i2;
import 'package:kiveto_portal_api/src/response/api_portal_v1_me_link_suggestions_suggestion_id_accept_post400_response.dart'
    as _i4;
import 'package:kiveto_portal_api/src/response/api_portal_v1_me_link_suggestions_suggestion_id_accept_post422_response.dart'
    as _i5;
import 'package:meta/meta.dart' as _i1;

sealed class AcceptLinkSuggestionResponse {
  const AcceptLinkSuggestionResponse();
}

@_i1.immutable
class AcceptLinkSuggestionResponse202 extends AcceptLinkSuggestionResponse {
  const AcceptLinkSuggestionResponse202({required this.body});

  final _i2.LinkSuggestionAcceptedView body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is AcceptLinkSuggestionResponse202 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class AcceptLinkSuggestionResponse401 extends AcceptLinkSuggestionResponse {
  const AcceptLinkSuggestionResponse401();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is AcceptLinkSuggestionResponse401;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class AcceptLinkSuggestionResponse404 extends AcceptLinkSuggestionResponse {
  const AcceptLinkSuggestionResponse404();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is AcceptLinkSuggestionResponse404;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class AcceptLinkSuggestionResponse400 extends AcceptLinkSuggestionResponse {
  const AcceptLinkSuggestionResponse400({required this.body});

  final _i4.ApiPortalV1MeLinkSuggestionsSuggestionIdAcceptPost400Response body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is AcceptLinkSuggestionResponse400 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class AcceptLinkSuggestionResponse422 extends AcceptLinkSuggestionResponse {
  const AcceptLinkSuggestionResponse422({required this.body});

  final _i5.ApiPortalV1MeLinkSuggestionsSuggestionIdAcceptPost422Response body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is AcceptLinkSuggestionResponse422 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}
