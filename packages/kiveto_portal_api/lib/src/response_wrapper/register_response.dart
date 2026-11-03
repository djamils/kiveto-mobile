// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:kiveto_portal_api/src/model/registration_result_view.dart'
    as _i2;
import 'package:kiveto_portal_api/src/response/api_portal_v1_auth_register_post400_response.dart'
    as _i5;
import 'package:kiveto_portal_api/src/response/api_portal_v1_auth_register_post422_response.dart'
    as _i4;
import 'package:meta/meta.dart' as _i1;

sealed class RegisterResponse {
  const RegisterResponse();
}

@_i1.immutable
class RegisterResponse201 extends RegisterResponse {
  const RegisterResponse201({required this.body});

  final _i2.RegistrationResultView body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RegisterResponse201 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class RegisterResponse401 extends RegisterResponse {
  const RegisterResponse401();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RegisterResponse401;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class RegisterResponse403 extends RegisterResponse {
  const RegisterResponse403();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RegisterResponse403;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class RegisterResponse409 extends RegisterResponse {
  const RegisterResponse409();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RegisterResponse409;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class RegisterResponse422 extends RegisterResponse {
  const RegisterResponse422({required this.body});

  final _i4.ApiPortalV1AuthRegisterPost422Response body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RegisterResponse422 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class RegisterResponse429 extends RegisterResponse {
  const RegisterResponse429();

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RegisterResponse429;
  }

  @_i3.override
  _i3.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class RegisterResponse400 extends RegisterResponse {
  const RegisterResponse400({required this.body});

  final _i5.ApiPortalV1AuthRegisterPost400Response body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RegisterResponse400 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}
