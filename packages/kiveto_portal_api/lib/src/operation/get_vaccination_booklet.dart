// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:dio/dio.dart' as _i5;
import 'package:kiveto_portal_api/src/operation/dio_operation.dart' as _i1;
import 'package:kiveto_portal_api/src/response_wrapper/get_vaccination_booklet_response.dart'
    as _i2;
import 'package:tonik_util/tonik_util.dart' as _i4;

final class GetVaccinationBooklet
    extends _i1.DioOperation<_i2.GetVaccinationBookletResponse> {
  GetVaccinationBooklet(super.baseUrl, super.clientAccessor);

  _i3.Future<
    _i4.TonikResult<
      _i2.GetVaccinationBookletResponse,
      _i5.Response<_i3.Object?>
    >
  >
  call({
    required _i3.String clinicId,
    required _i3.String petId,
    _i4.TonikCancellation? cancellation,
  }) {
    return this.execute(
      cancellation: cancellation,
      prepare: () => _i1.DioOperationRequest(
        path: _path(clinicId: clinicId, petId: petId),
        query: null,
        data: _data(),
        options: _options(),
      ),
      decode: _parseResponse,
    );
  }

  _i3.List<_i3.String> _path({
    required _i3.String clinicId,
    required _i3.String petId,
  }) {
    return [
      r'api',
      r'portal',
      r'v1',
      r'clinics',
      clinicId.toSimple(explode: false, allowEmpty: false),
      r'pets',
      petId.toSimple(explode: false, allowEmpty: false),
      r'vaccination-booklet',
    ];
  }

  _i3.Object? _data() {
    return null;
  }

  _i5.Options _options() {
    final _$headers = <_i3.String, _i3.dynamic>{};
    _$headers['Accept'] = r'*/*';
    return _i5.Options(
      method: 'GET',
      headers: _$headers,
      responseType: _i5.ResponseType.bytes,
      validateStatus: (_) => true,
    );
  }

  _i2.GetVaccinationBookletResponse _parseResponse(
    _i5.Response<_i3.List<_i3.int>> response,
  ) {
    final _$mediaType = _i4.extractMediaType(
      response.headers.value('content-type'),
    );
    switch ((response.statusCode, _$mediaType)) {
      case (302, _):
        return _i2.GetVaccinationBookletResponse302();
      case (401, _):
        return _i2.GetVaccinationBookletResponse401();
      case (404, _):
        return _i2.GetVaccinationBookletResponse404();
      case (503, _):
        return _i2.GetVaccinationBookletResponse503();
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
