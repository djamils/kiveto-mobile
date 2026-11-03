// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i7;
import 'dart:core' as _i3;

import 'package:dio/dio.dart' as _i5;
import 'package:kiveto_portal_api/src/model/appointment_booking_with_new_pet.dart'
    as _i6;
import 'package:kiveto_portal_api/src/model/booked_with_new_pet_appointment_view.dart'
    as _i8;
import 'package:kiveto_portal_api/src/model/constraint_violation.dart' as _i11;
import 'package:kiveto_portal_api/src/model/problem_details.dart' as _i9;
import 'package:kiveto_portal_api/src/operation/dio_operation.dart' as _i1;
import 'package:kiveto_portal_api/src/response/api_portal_v1_clinics_clinic_id_appointments_with_new_pet_post400_response.dart'
    as _i10;
import 'package:kiveto_portal_api/src/response/api_portal_v1_clinics_clinic_id_appointments_with_new_pet_post422_response.dart'
    as _i12;
import 'package:kiveto_portal_api/src/response_wrapper/book_appointment_with_new_pet_response.dart'
    as _i2;
import 'package:tonik_util/tonik_util.dart' as _i4;

final class BookAppointmentWithNewPet
    extends _i1.DioOperation<_i2.BookAppointmentWithNewPetResponse> {
  BookAppointmentWithNewPet(super.baseUrl, super.clientAccessor);

  _i3.Future<
    _i4.TonikResult<
      _i2.BookAppointmentWithNewPetResponse,
      _i5.Response<_i3.Object?>
    >
  >
  call({
    required _i6.AppointmentBookingWithNewPet body,
    required _i3.String clinicId,
    required _i3.String idempotencyKey,
    _i4.TonikCancellation? cancellation,
  }) {
    return this.execute(
      cancellation: cancellation,
      prepare: () => _i1.DioOperationRequest(
        path: _path(clinicId: clinicId),
        query: null,
        data: _data(body: body),
        options: _options(idempotencyKey: idempotencyKey),
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
      r'appointments',
      r'with-new-pet',
    ];
  }

  _i3.Object? _data({required _i6.AppointmentBookingWithNewPet body}) {
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

  _i2.BookAppointmentWithNewPetResponse _parseResponse(
    _i5.Response<_i3.List<_i3.int>> response,
  ) {
    final _$mediaType = _i4.extractMediaType(
      response.headers.value('content-type'),
    );
    switch ((response.statusCode, _$mediaType)) {
      case (201, r'application/json'):
        final _$json = _i4.decodeResponseJson<_i3.Object?>(response.data);
        final _$body = _i8.BookedWithNewPetAppointmentView.fromJson(_$json);
        return _i2.BookAppointmentWithNewPetResponse201(body: _$body);
      case (201, _):
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
        return _i2.BookAppointmentWithNewPetResponse400(
          body:
              _i10.ApiPortalV1ClinicsClinicIdAppointmentsWithNewPetPost400ResponseProblemJson(
                body: _$body,
              ),
        );
      case (400, r'application/json'):
        final _$json = _i4.decodeResponseJson<_i3.Object?>(response.data);
        final _$body = _i9.ProblemDetails.fromJson(_$json);
        return _i2.BookAppointmentWithNewPetResponse400(
          body:
              _i10.ApiPortalV1ClinicsClinicIdAppointmentsWithNewPetPost400ResponseJson(
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
        return _i2.BookAppointmentWithNewPetResponse401();
      case (404, _):
        return _i2.BookAppointmentWithNewPetResponse404();
      case (409, _):
        return _i2.BookAppointmentWithNewPetResponse409();
      case (422, r'application/problem+json'):
        final _$json = _i4.decodeResponseJson<_i3.Object?>(response.data);
        final _$body = _i11.ConstraintViolation.fromJson(_$json);
        return _i2.BookAppointmentWithNewPetResponse422(
          body:
              _i12.ApiPortalV1ClinicsClinicIdAppointmentsWithNewPetPost422ResponseProblemJson(
                body: _$body,
              ),
        );
      case (422, r'application/json'):
        final _$json = _i4.decodeResponseJson<_i3.Object?>(response.data);
        final _$body = _i11.ConstraintViolation.fromJson(_$json);
        return _i2.BookAppointmentWithNewPetResponse422(
          body:
              _i12.ApiPortalV1ClinicsClinicIdAppointmentsWithNewPetPost422ResponseJson(
                body: _$body,
              ),
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
