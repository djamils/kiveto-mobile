// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i6;
import 'dart:core' as _i3;

import 'package:dio/dio.dart' as _i5;
import 'package:kiveto_portal_api/src/model/owner_request_list.dart' as _i7;
import 'package:kiveto_portal_api/src/operation/dio_operation.dart' as _i1;
import 'package:kiveto_portal_api/src/response_wrapper/list_requests_response.dart'
    as _i2;
import 'package:tonik_util/tonik_util.dart' as _i4;

final class ListRequests extends _i1.DioOperation<_i2.ListRequestsResponse> {
  ListRequests(super.baseUrl, super.clientAccessor);

  _i3.Future<
    _i4.TonikResult<_i2.ListRequestsResponse, _i5.Response<_i3.Object?>>
  >
  call({
    required _i3.String clinicId,
    _i3.String? cursor,
    _i3.int? limit,
    _i4.TonikCancellation? cancellation,
  }) {
    return this.execute(
      cancellation: cancellation,
      prepare: () => _i1.DioOperationRequest(
        path: _path(clinicId: clinicId),
        query: _queryParameters(cursor: cursor, limit: limit),
        data: _data(),
        options: _options(),
      ),
      decode: _parseResponse,
    );
  }

  _i3.List<_i3.String> _path({required _i3.String clinicId}) {
    return [
      r'api',
      r'portal',
      r'v1',
      r'clinics',
      clinicId.toSimple(explode: false, allowEmpty: false),
      r'requests',
    ];
  }

  _i3.Object? _data() {
    return null;
  }

  _i3.String? _queryParameters({_i3.String? cursor, _i3.int? limit}) {
    final _$entries = <_i4.ParameterEntry>[];
    if (cursor != null) {
      _$entries.addAll(
        cursor.toForm(
          r'cursor',
          explode: true,
          allowEmpty: false,
          textEncoding: _i6.utf8,
        ),
      );
    }
    if (limit != null) {
      _$entries.addAll(
        limit.toForm(
          r'limit',
          explode: true,
          allowEmpty: false,
          textEncoding: _i6.utf8,
        ),
      );
    }
    if (_$entries.isEmpty) {
      return null;
    }
    return _$entries
        .map((e) => e.name.isEmpty ? e.value : '${e.name}=${e.value}')
        .join('&');
  }

  _i5.Options _options() {
    final _$headers = <_i3.String, _i3.dynamic>{};
    _$headers['Accept'] = r'application/json';
    return _i5.Options(
      method: 'GET',
      headers: _$headers,
      responseType: _i5.ResponseType.bytes,
      validateStatus: (_) => true,
    );
  }

  _i2.ListRequestsResponse _parseResponse(
    _i5.Response<_i3.List<_i3.int>> response,
  ) {
    final _$mediaType = _i4.extractMediaType(
      response.headers.value('content-type'),
    );
    switch ((response.statusCode, _$mediaType)) {
      case (200, r'application/json'):
        final _$json = _i4.decodeResponseJson<_i3.Object?>(response.data);
        final _$body = _i7.OwnerRequestList.fromJson(_$json);
        return _i2.ListRequestsResponse200(body: _$body);
      case (200, _):
        final _$content =
            response.headers.value('content-type') ?? 'not specified';
        final _$matched = _$mediaType ?? 'none';
        final _$status = response.statusCode;
        throw _i4.ResponseDecodingException(
          'Unexpected content type: ${_$content} (matched as: ${_$matched}) for status code: ${_$status}',
        );
      case (400, _):
        return _i2.ListRequestsResponse400();
      case (401, _):
        return _i2.ListRequestsResponse401();
      case (404, _):
        return _i2.ListRequestsResponse404();
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
