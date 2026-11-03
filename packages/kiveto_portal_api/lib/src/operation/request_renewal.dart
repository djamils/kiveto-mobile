// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i7;
import 'dart:core' as _i3;

import 'package:dio/dio.dart' as _i5;
import 'package:kiveto_portal_api/src/model/constraint_violation.dart' as _i11;
import 'package:kiveto_portal_api/src/model/problem_details.dart' as _i9;
import 'package:kiveto_portal_api/src/model/renewal_request_created_view.dart'
    as _i8;
import 'package:kiveto_portal_api/src/model/renewal_request_creation.dart'
    as _i6;
import 'package:kiveto_portal_api/src/operation/dio_operation.dart' as _i1;
import 'package:kiveto_portal_api/src/response/api_portal_v1_clinics_clinic_id_prescriptions_prescription_id_renewal_requests_post400_response.dart'
    as _i10;
import 'package:kiveto_portal_api/src/response/api_portal_v1_clinics_clinic_id_prescriptions_prescription_id_renewal_requests_post422_response.dart'
    as _i12;
import 'package:kiveto_portal_api/src/response_wrapper/request_renewal_response.dart'
    as _i2;
import 'package:tonik_util/tonik_util.dart' as _i4;

final class RequestRenewal
    extends _i1.DioOperation<_i2.RequestRenewalResponse> {
  RequestRenewal(super.baseUrl, super.clientAccessor);

  _i3.Future<
    _i4.TonikResult<_i2.RequestRenewalResponse, _i5.Response<_i3.Object?>>
  >
  call({
    required _i6.RenewalRequestCreation body,
    required _i3.String clinicId,
    required _i3.String prescriptionId,
    required _i3.String idempotencyKey,
    _i4.TonikCancellation? cancellation,
  }) {
    return this.execute(
      cancellation: cancellation,
      prepare: () => _i1.DioOperationRequest(
        path: _path(clinicId: clinicId, prescriptionId: prescriptionId),
        query: null,
        data: _data(body: body),
        options: _options(idempotencyKey: idempotencyKey),
      ),
      decode: _parseResponse,
    );
  }

  _i3.List<_i3.String> _path({
    required _i3.String clinicId,
    required _i3.String prescriptionId,
  }) {
    return [
      r'api',
      r'portal',
      r'v1',
      r'clinics',
      clinicId.toSimple(explode: false, allowEmpty: false),
      r'prescriptions',
      prescriptionId.toSimple(explode: false, allowEmpty: false),
      r'renewal-requests',
    ];
  }

  _i3.Object? _data({required _i6.RenewalRequestCreation body}) {
    return _i7.jsonEncode(body.toJson());
  }

  _i5.Options _options({required _i3.String idempotencyKey}) {
    final _$headers = <_i3.String, _i3.dynamic>{};
    _$headers['Accept'] = r'application/json,application/problem+json';
    _$headers[r'Idempotency-Key'] = idempotencyKey.toSimple(
      explode: false,
      allowEmpty: false,
      literal: true,
    );
    return _i5.Options(
      method: 'POST',
      headers: _$headers,
      contentType: r'application/json',
      responseType: _i5.ResponseType.bytes,
      validateStatus: (_) => true,
    );
  }

  _i2.RequestRenewalResponse _parseResponse(
    _i5.Response<_i3.List<_i3.int>> response,
  ) {
    final _$mediaType = _i4.extractMediaType(
      response.headers.value('content-type'),
    );
    switch ((response.statusCode, _$mediaType)) {
      case (202, r'application/json'):
        final _$json = _i4.decodeResponseJson<_i3.Object?>(response.data);
        final _$body = _i8.RenewalRequestCreatedView.fromJson(_$json);
        return _i2.RequestRenewalResponse202(body: _$body);
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
        final _$body = _i9.ProblemDetails.fromJson(_$json);
        return _i2.RequestRenewalResponse400(
          body:
              _i10.ApiPortalV1ClinicsClinicIdPrescriptionsPrescriptionIdRenewalRequestsPost400ResponseProblemJson(
                body: _$body,
              ),
        );
      case (400, r'application/json'):
        final _$json = _i4.decodeResponseJson<_i3.Object?>(response.data);
        final _$body = _i9.ProblemDetails.fromJson(_$json);
        return _i2.RequestRenewalResponse400(
          body:
              _i10.ApiPortalV1ClinicsClinicIdPrescriptionsPrescriptionIdRenewalRequestsPost400ResponseJson(
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
        return _i2.RequestRenewalResponse401();
      case (404, _):
        return _i2.RequestRenewalResponse404();
      case (422, r'application/problem+json'):
        final _$json = _i4.decodeResponseJson<_i3.Object?>(response.data);
        final _$body = _i11.ConstraintViolation.fromJson(_$json);
        return _i2.RequestRenewalResponse422(
          body:
              _i12.ApiPortalV1ClinicsClinicIdPrescriptionsPrescriptionIdRenewalRequestsPost422ResponseProblemJson(
                body: _$body,
              ),
        );
      case (422, r'application/json'):
        final _$json = _i4.decodeResponseJson<_i3.Object?>(response.data);
        final _$body = _i11.ConstraintViolation.fromJson(_$json);
        return _i2.RequestRenewalResponse422(
          body:
              _i12.ApiPortalV1ClinicsClinicIdPrescriptionsPrescriptionIdRenewalRequestsPost422ResponseJson(
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
        return _i2.RequestRenewalResponse429();
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
