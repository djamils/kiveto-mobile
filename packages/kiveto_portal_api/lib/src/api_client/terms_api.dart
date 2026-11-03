// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:dio/dio.dart' as _i6;
import 'package:kiveto_portal_api/src/operation/get_current_terms.dart' as _i2;
import 'package:kiveto_portal_api/src/response_wrapper/get_current_terms_response.dart'
    as _i5;
import 'package:kiveto_portal_api/src/server/server.dart' as _i1;
import 'package:tonik_util/tonik_util.dart' as _i4;

/// Resource 'CGU' operations.
class TermsApi {
  TermsApi(_i1.Server server)
    : _getCurrentTerms = _i2.GetCurrentTerms(server.baseUrl, () => server.dio);

  final _i2.GetCurrentTerms _getCurrentTerms;

  /// Version courante des conditions d'utilisation du Portal.
  /// Publique. `version` est la valeur attendue par les routes d'acceptation (`termsVersion`).
  _i3.Future<
    _i4.TonikResult<_i5.GetCurrentTermsResponse, _i6.Response<_i3.Object?>>
  >
  getCurrentTerms({_i4.TonikCancellation? cancellation}) async =>
      this._getCurrentTerms(cancellation: cancellation);
}
