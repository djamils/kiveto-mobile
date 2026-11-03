// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:kiveto_portal_api/src/model/accepted_invitation_view.dart'
    as _i2;
import 'package:kiveto_portal_api/src/response/api_portal_v1_invitations_accept_post400_response.dart'
    as _i5;
import 'package:kiveto_portal_api/src/response/api_portal_v1_invitations_accept_post422_response.dart'
    as _i4;
import 'package:meta/meta.dart' as _i1;

sealed class AcceptInvitationResponse {
  const AcceptInvitationResponse();
}

@_i1.immutable
class AcceptInvitationResponse200 extends AcceptInvitationResponse {
  const AcceptInvitationResponse200({required this.body});

  final _i2.AcceptedInvitationView body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is AcceptInvitationResponse200 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class AcceptInvitationResponse403 extends AcceptInvitationResponse {
  const AcceptInvitationResponse403();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is AcceptInvitationResponse403;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class AcceptInvitationResponse404 extends AcceptInvitationResponse {
  const AcceptInvitationResponse404();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is AcceptInvitationResponse404;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class AcceptInvitationResponse410 extends AcceptInvitationResponse {
  const AcceptInvitationResponse410();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is AcceptInvitationResponse410;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class AcceptInvitationResponse422 extends AcceptInvitationResponse {
  const AcceptInvitationResponse422({required this.body});

  final _i4.ApiPortalV1InvitationsAcceptPost422Response body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is AcceptInvitationResponse422 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class AcceptInvitationResponse400 extends AcceptInvitationResponse {
  const AcceptInvitationResponse400({required this.body});

  final _i5.ApiPortalV1InvitationsAcceptPost400Response body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is AcceptInvitationResponse400 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}
