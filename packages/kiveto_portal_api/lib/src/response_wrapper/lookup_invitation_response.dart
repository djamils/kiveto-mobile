// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:kiveto_portal_api/src/model/invitation_lookup_view.dart' as _i2;
import 'package:kiveto_portal_api/src/response/api_portal_v1_invitations_lookup_post400_response.dart'
    as _i4;
import 'package:kiveto_portal_api/src/response/api_portal_v1_invitations_lookup_post422_response.dart'
    as _i5;
import 'package:meta/meta.dart' as _i1;

sealed class LookupInvitationResponse {
  const LookupInvitationResponse();
}

@_i1.immutable
class LookupInvitationResponse200 extends LookupInvitationResponse {
  const LookupInvitationResponse200({required this.body});

  final _i2.InvitationLookupView body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is LookupInvitationResponse200 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class LookupInvitationResponse404 extends LookupInvitationResponse {
  const LookupInvitationResponse404();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is LookupInvitationResponse404;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class LookupInvitationResponse410 extends LookupInvitationResponse {
  const LookupInvitationResponse410();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is LookupInvitationResponse410;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class LookupInvitationResponse400 extends LookupInvitationResponse {
  const LookupInvitationResponse400({required this.body});

  final _i4.ApiPortalV1InvitationsLookupPost400Response body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is LookupInvitationResponse400 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class LookupInvitationResponse422 extends LookupInvitationResponse {
  const LookupInvitationResponse422({required this.body});

  final _i5.ApiPortalV1InvitationsLookupPost422Response body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is LookupInvitationResponse422 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}
