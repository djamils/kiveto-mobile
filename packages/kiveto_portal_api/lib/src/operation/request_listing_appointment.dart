// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i7;
import 'dart:core' as _i3;

import 'package:dio/dio.dart' as _i5;
import 'package:kiveto_portal_api/src/model/constraint_violation.dart' as _i11;
import 'package:kiveto_portal_api/src/model/listing_booking.dart' as _i6;
import 'package:kiveto_portal_api/src/model/listing_booking_request_view.dart'
    as _i8;
import 'package:kiveto_portal_api/src/model/problem_details.dart' as _i9;
import 'package:kiveto_portal_api/src/operation/dio_operation.dart' as _i1;
import 'package:kiveto_portal_api/src/response/api_portal_v1_clinic_listings_listing_id_booking_appointments_post400_response.dart'
    as _i10;
import 'package:kiveto_portal_api/src/response/api_portal_v1_clinic_listings_listing_id_booking_appointments_post422_response.dart'
    as _i12;
import 'package:kiveto_portal_api/src/response_wrapper/request_listing_appointment_response.dart'
    as _i2;
import 'package:tonik_util/tonik_util.dart' as _i4;

final class RequestListingAppointment
    extends _i1.DioOperation<_i2.RequestListingAppointmentResponse> {
  RequestListingAppointment(super.baseUrl, super.clientAccessor);

  _i3.Future<
    _i4.TonikResult<
      _i2.RequestListingAppointmentResponse,
      _i5.Response<_i3.Object?>
    >
  >
  call({
    required _i6.ListingBooking body,
    required _i3.String listingId,
    required _i3.String idempotencyKey,
    _i4.TonikCancellation? cancellation,
  }) {
    return this.execute(
      cancellation: cancellation,
      prepare: () => _i1.DioOperationRequest(
        path: _path(listingId: listingId),
        query: null,
        data: _data(body: body),
        options: _options(idempotencyKey: idempotencyKey),
      ),
      decode: _parseResponse,
    );
  }

  _i3.List<_i3.String> _path({required _i3.String listingId}) {
    return [
      r'api',
      r'portal',
      r'v1',
      r'clinic-listings',
      listingId.toSimple(explode: false, allowEmpty: false),
      r'booking',
      r'appointments',
    ];
  }

  _i3.Object? _data({required _i6.ListingBooking body}) {
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

  _i2.RequestListingAppointmentResponse _parseResponse(
    _i5.Response<_i3.List<_i3.int>> response,
  ) {
    final _$mediaType = _i4.extractMediaType(
      response.headers.value('content-type'),
    );
    switch ((response.statusCode, _$mediaType)) {
      case (201, r'application/json'):
        final _$json = _i4.decodeResponseJson<_i3.Object?>(response.data);
        final _$body = _i8.ListingBookingRequestView.fromJson(_$json);
        return _i2.RequestListingAppointmentResponse201(body: _$body);
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
        return _i2.RequestListingAppointmentResponse400(
          body:
              _i10.ApiPortalV1ClinicListingsListingIdBookingAppointmentsPost400ResponseProblemJson(
                body: _$body,
              ),
        );
      case (400, r'application/json'):
        final _$json = _i4.decodeResponseJson<_i3.Object?>(response.data);
        final _$body = _i9.ProblemDetails.fromJson(_$json);
        return _i2.RequestListingAppointmentResponse400(
          body:
              _i10.ApiPortalV1ClinicListingsListingIdBookingAppointmentsPost400ResponseJson(
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
        return _i2.RequestListingAppointmentResponse401();
      case (404, _):
        return _i2.RequestListingAppointmentResponse404();
      case (409, _):
        return _i2.RequestListingAppointmentResponse409();
      case (422, r'application/problem+json'):
        final _$json = _i4.decodeResponseJson<_i3.Object?>(response.data);
        final _$body = _i11.ConstraintViolation.fromJson(_$json);
        return _i2.RequestListingAppointmentResponse422(
          body:
              _i12.ApiPortalV1ClinicListingsListingIdBookingAppointmentsPost422ResponseProblemJson(
                body: _$body,
              ),
        );
      case (422, r'application/json'):
        final _$json = _i4.decodeResponseJson<_i3.Object?>(response.data);
        final _$body = _i11.ConstraintViolation.fromJson(_$json);
        return _i2.RequestListingAppointmentResponse422(
          body:
              _i12.ApiPortalV1ClinicListingsListingIdBookingAppointmentsPost422ResponseJson(
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
        return _i2.RequestListingAppointmentResponse429();
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
