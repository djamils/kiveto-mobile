// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:dio/dio.dart' as _i5;
import 'package:kiveto_portal_api/src/model/constraint_violation.dart' as _i9;
import 'package:kiveto_portal_api/src/model/email_change_otp_challenge_view.dart'
    as _i6;
import 'package:kiveto_portal_api/src/model/error.dart' as _i7;
import 'package:kiveto_portal_api/src/operation/dio_operation.dart' as _i1;
import 'package:kiveto_portal_api/src/response/api_portal_v1_me_email_change_otp_post400_response.dart'
    as _i8;
import 'package:kiveto_portal_api/src/response/api_portal_v1_me_email_change_otp_post422_response.dart'
    as _i10;
import 'package:kiveto_portal_api/src/response_wrapper/request_email_change_otp_response.dart'
    as _i2;
import 'package:tonik_util/tonik_util.dart' as _i4;

final class RequestEmailChangeOtp
    extends _i1.DioOperation<_i2.RequestEmailChangeOtpResponse> {
  RequestEmailChangeOtp(super.baseUrl, super.clientAccessor);

  _i3.Future<
    _i4.TonikResult<
      _i2.RequestEmailChangeOtpResponse,
      _i5.Response<_i3.Object?>
    >
  >
  call({_i4.TonikCancellation? cancellation}) {
    return this.execute(
      cancellation: cancellation,
      prepare: () => _i1.DioOperationRequest(
        path: _path(),
        query: null,
        data: _data(),
        options: _options(),
      ),
      decode: _parseResponse,
    );
  }

  _i3.List<_i3.String> _path() {
    return [r'api', r'portal', r'v1', r'me', r'email-change', r'otp'];
  }

  _i3.Object? _data() {
    return null;
  }

  _i5.Options _options() {
    final _$headers = <_i3.String, _i3.dynamic>{};
    _$headers['Accept'] = r'application/json,application/problem+json';
    return _i5.Options(
      method: 'POST',
      headers: _$headers,
      responseType: _i5.ResponseType.bytes,
      validateStatus: (_) => true,
    );
  }

  _i2.RequestEmailChangeOtpResponse _parseResponse(
    _i5.Response<_i3.List<_i3.int>> response,
  ) {
    final _$mediaType = _i4.extractMediaType(
      response.headers.value('content-type'),
    );
    switch ((response.statusCode, _$mediaType)) {
      case (202, r'application/json'):
        final _$json = _i4.decodeResponseJson<_i3.Object?>(response.data);
        final _$body = _i6.EmailChangeOtpChallengeView.fromJson(_$json);
        return _i2.RequestEmailChangeOtpResponse202(body: _$body);
      case (202, _):
        final _$content =
            response.headers.value('content-type') ?? 'not specified';
        final _$matched = _$mediaType ?? 'none';
        final _$status = response.statusCode;
        throw _i4.ResponseDecodingException(
          'Unexpected content type: ${_$content} (matched as: ${_$matched}) for status code: ${_$status}',
        );
      case (400, r'application/problem+json'):
        final _$json = _i4.decodeResponseJson<_i3.Object?>(response.data);
        final _$body = _i7.Error.fromJson(_$json);
        return _i2.RequestEmailChangeOtpResponse400(
          body: _i8.ApiPortalV1MeEmailChangeOtpPost400ResponseProblemJson(
            body: _$body,
          ),
        );
      case (400, r'application/json'):
        final _$json = _i4.decodeResponseJson<_i3.Object?>(response.data);
        final _$body = _i7.Error.fromJson(_$json);
        return _i2.RequestEmailChangeOtpResponse400(
          body: _i8.ApiPortalV1MeEmailChangeOtpPost400ResponseJson(
            body: _$body,
          ),
        );
      case (400, _):
        final _$content =
            response.headers.value('content-type') ?? 'not specified';
        final _$matched = _$mediaType ?? 'none';
        final _$status = response.statusCode;
        throw _i4.ResponseDecodingException(
          'Unexpected content type: ${_$content} (matched as: ${_$matched}) for status code: ${_$status}',
        );
      case (401, _):
        return _i2.RequestEmailChangeOtpResponse401();
      case (422, r'application/problem+json'):
        final _$json = _i4.decodeResponseJson<_i3.Object?>(response.data);
        final _$body = _i9.ConstraintViolation.fromJson(_$json);
        return _i2.RequestEmailChangeOtpResponse422(
          body: _i10.ApiPortalV1MeEmailChangeOtpPost422ResponseProblemJson(
            body: _$body,
          ),
        );
      case (422, r'application/json'):
        final _$json = _i4.decodeResponseJson<_i3.Object?>(response.data);
        final _$body = _i9.ConstraintViolation.fromJson(_$json);
        return _i2.RequestEmailChangeOtpResponse422(
          body: _i10.ApiPortalV1MeEmailChangeOtpPost422ResponseJson(
            body: _$body,
          ),
        );
      case (422, _):
        final _$content =
            response.headers.value('content-type') ?? 'not specified';
        final _$matched = _$mediaType ?? 'none';
        final _$status = response.statusCode;
        throw _i4.ResponseDecodingException(
          'Unexpected content type: ${_$content} (matched as: ${_$matched}) for status code: ${_$status}',
        );
      case (429, _):
        return _i2.RequestEmailChangeOtpResponse429();
      default:
        final _$content =
            response.headers.value('content-type') ?? 'not specified';
        final _$matched = _$mediaType ?? 'none';
        final _$status = response.statusCode;
        throw _i4.ResponseDecodingException(
          'Unexpected content type: ${_$content} (matched as: ${_$matched}) for status code: ${_$status}',
        );
    }
  }
}
