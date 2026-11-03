// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i7;
import 'dart:core' as _i3;

import 'package:dio/dio.dart' as _i5;
import 'package:kiveto_portal_api/src/model/constraint_violation.dart' as _i11;
import 'package:kiveto_portal_api/src/model/error.dart' as _i9;
import 'package:kiveto_portal_api/src/model/updated_account_view.dart' as _i8;
import 'package:kiveto_portal_api/src/operation/dio_operation.dart' as _i1;
import 'package:kiveto_portal_api/src/request_body/api_portal_v1_me_patch_body_request_body.dart'
    as _i6;
import 'package:kiveto_portal_api/src/response/api_portal_v1_me_patch400_response.dart'
    as _i10;
import 'package:kiveto_portal_api/src/response/api_portal_v1_me_patch422_response.dart'
    as _i12;
import 'package:kiveto_portal_api/src/response_wrapper/update_me_response.dart'
    as _i2;
import 'package:tonik_util/tonik_util.dart' as _i4;

final class UpdateMe extends _i1.DioOperation<_i2.UpdateMeResponse> {
  UpdateMe(super.baseUrl, super.clientAccessor);

  _i3.Future<_i4.TonikResult<_i2.UpdateMeResponse, _i5.Response<_i3.Object?>>>
  call({
    required _i6.ApiPortalV1MePatchBodyRequestBody body,
    _i4.TonikCancellation? cancellation,
  }) {
    return this.execute(
      cancellation: cancellation,
      prepare: () => _i1.DioOperationRequest(
        path: _path(),
        query: null,
        data: _data(body: body),
        options: _options(body: body),
      ),
      decode: _parseResponse,
    );
  }

  _i3.List<_i3.String> _path() {
    return [r'api', r'portal', r'v1', r'me'];
  }

  _i3.Object? _data({required _i6.ApiPortalV1MePatchBodyRequestBody body}) {
    return switch (body) {
      final _i6.ApiPortalV1MePatchBodyRequestBodyJson value => _i7.jsonEncode(
        value.value.toJson(),
      ),
      final _i6.ApiPortalV1MePatchBodyRequestBodyMergePatchJson value =>
        _i7.jsonEncode(value.value.toJson()),
    };
  }

  _i5.Options _options({required _i6.ApiPortalV1MePatchBodyRequestBody body}) {
    final _$contentType = switch (body) {
      _i6.ApiPortalV1MePatchBodyRequestBodyJson _ => r'application/json',

      _i6.ApiPortalV1MePatchBodyRequestBodyMergePatchJson _ =>
        r'application/merge-patch+json',
    };
    final _$headers = <_i3.String, _i3.dynamic>{};
    _$headers['Accept'] = r'application/json,application/problem+json';
    return _i5.Options(
      method: 'PATCH',
      headers: _$headers,
      contentType: _$contentType,
      responseType: _i5.ResponseType.bytes,
      validateStatus: (_) => true,
    );
  }

  _i2.UpdateMeResponse _parseResponse(
    _i5.Response<_i3.List<_i3.int>> response,
  ) {
    final _$mediaType = _i4.extractMediaType(
      response.headers.value('content-type'),
    );
    switch ((response.statusCode, _$mediaType)) {
      case (200, r'application/json'):
        final _$json = _i4.decodeResponseJson<_i3.Object?>(response.data);
        final _$body = _i8.UpdatedAccountView.fromJson(_$json);
        return _i2.UpdateMeResponse200(body: _$body);
      case (200, _):
        final _$content =
            response.headers.value('content-type') ?? 'not specified';
        final _$matched = _$mediaType ?? 'none';
        final _$status = response.statusCode;
        throw _i4.ResponseDecodingException(
          'Unexpected content type: ${_$content} (matched as: ${_$matched}) for status code: ${_$status}',
        );
      case (400, r'application/problem+json'):
        final _$json = _i4.decodeResponseJson<_i3.Object?>(response.data);
        final _$body = _i9.Error.fromJson(_$json);
        return _i2.UpdateMeResponse400(
          body: _i10.ApiPortalV1MePatch400ResponseProblemJson(body: _$body),
        );
      case (400, r'application/json'):
        final _$json = _i4.decodeResponseJson<_i3.Object?>(response.data);
        final _$body = _i9.Error.fromJson(_$json);
        return _i2.UpdateMeResponse400(
          body: _i10.ApiPortalV1MePatch400ResponseJson(body: _$body),
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
        return _i2.UpdateMeResponse401();
      case (404, _):
        return _i2.UpdateMeResponse404();
      case (422, r'application/problem+json'):
        final _$json = _i4.decodeResponseJson<_i3.Object?>(response.data);
        final _$body = _i11.ConstraintViolation.fromJson(_$json);
        return _i2.UpdateMeResponse422(
          body: _i12.ApiPortalV1MePatch422ResponseProblemJson(body: _$body),
        );
      case (422, r'application/json'):
        final _$json = _i4.decodeResponseJson<_i3.Object?>(response.data);
        final _$body = _i11.ConstraintViolation.fromJson(_$json);
        return _i2.UpdateMeResponse422(
          body: _i12.ApiPortalV1MePatch422ResponseJson(body: _$body),
        );
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
