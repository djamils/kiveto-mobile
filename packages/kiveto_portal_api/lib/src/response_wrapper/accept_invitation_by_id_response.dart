// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:kiveto_portal_api/src/model/accepted_invitation_grant_view.dart'
    as _i2;
import 'package:kiveto_portal_api/src/response/api_portal_v1_invitations_invitation_id_accept_post400_response.dart'
    as _i5;
import 'package:kiveto_portal_api/src/response/api_portal_v1_invitations_invitation_id_accept_post422_response.dart'
    as _i4;
import 'package:meta/meta.dart' as _i1;

sealed class AcceptInvitationByIdResponse {
  const AcceptInvitationByIdResponse();
}

@_i1.immutable
class AcceptInvitationByIdResponse200 extends AcceptInvitationByIdResponse {
  const AcceptInvitationByIdResponse200({required this.body});

  final _i2.AcceptedInvitationGrantView body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is AcceptInvitationByIdResponse200 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class AcceptInvitationByIdResponse401 extends AcceptInvitationByIdResponse {
  const AcceptInvitationByIdResponse401();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is AcceptInvitationByIdResponse401;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class AcceptInvitationByIdResponse403 extends AcceptInvitationByIdResponse {
  const AcceptInvitationByIdResponse403();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is AcceptInvitationByIdResponse403;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class AcceptInvitationByIdResponse404 extends AcceptInvitationByIdResponse {
  const AcceptInvitationByIdResponse404();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is AcceptInvitationByIdResponse404;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class AcceptInvitationByIdResponse422 extends AcceptInvitationByIdResponse {
  const AcceptInvitationByIdResponse422({required this.body});

  final _i4.ApiPortalV1InvitationsInvitationIdAcceptPost422Response body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is AcceptInvitationByIdResponse422 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class AcceptInvitationByIdResponse400 extends AcceptInvitationByIdResponse {
  const AcceptInvitationByIdResponse400({required this.body});

  final _i5.ApiPortalV1InvitationsInvitationIdAcceptPost400Response body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is AcceptInvitationByIdResponse400 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}
