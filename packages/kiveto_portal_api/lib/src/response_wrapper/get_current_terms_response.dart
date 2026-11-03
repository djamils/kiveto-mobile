// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:kiveto_portal_api/src/model/current_terms.dart' as _i2;
import 'package:kiveto_portal_api/src/response/api_portal_v1_legal_terms_current_get404_response.dart'
    as _i4;
import 'package:meta/meta.dart' as _i1;

sealed class GetCurrentTermsResponse {
  const GetCurrentTermsResponse();
}

@_i1.immutable
class GetCurrentTermsResponse200 extends GetCurrentTermsResponse {
  const GetCurrentTermsResponse200({required this.body});

  final _i2.CurrentTerms body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is GetCurrentTermsResponse200 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class GetCurrentTermsResponse404 extends GetCurrentTermsResponse {
  const GetCurrentTermsResponse404({required this.body});

  final _i4.ApiPortalV1LegalTermsCurrentGet404Response body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is GetCurrentTermsResponse404 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}
