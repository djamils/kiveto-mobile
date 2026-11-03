// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i7;
import 'dart:core' as _i4;

import 'package:dio/dio.dart' as _i6;
import 'package:kiveto_portal_api/src/model/api_portal_v1_clinics_clinic_id_appointments_parameters_model.dart'
    as _i3;
import 'package:kiveto_portal_api/src/model/appointment_list.dart' as _i8;
import 'package:kiveto_portal_api/src/operation/dio_operation.dart' as _i1;
import 'package:kiveto_portal_api/src/response_wrapper/list_appointments_response.dart'
    as _i2;
import 'package:tonik_util/tonik_util.dart' as _i5;

final class ListAppointments
    extends _i1.DioOperation<_i2.ListAppointmentsResponse> {
  ListAppointments(super.baseUrl, super.clientAccessor);

  static const _i3.ApiPortalV1ClinicsClinicIdAppointmentsParametersModel
  scopeDefault =
      _i3.ApiPortalV1ClinicsClinicIdAppointmentsParametersModel.upcoming;

  _i4.Future<
    _i5.TonikResult<_i2.ListAppointmentsResponse, _i6.Response<_i4.Object?>>
  >
  call({
    required _i4.String clinicId,
    _i3.ApiPortalV1ClinicsClinicIdAppointmentsParametersModel scope =
        scopeDefault,
    _i4.String? cursor,
    _i4.int? limit,
    _i5.TonikCancellation? cancellation,
  }) {
    return this.execute(
      cancellation: cancellation,
      prepare: () => _i1.DioOperationRequest(
        path: _path(clinicId: clinicId),
        query: _queryParameters(scope: scope, cursor: cursor, limit: limit),
        data: _data(),
        options: _options(),
      ),
      decode: _parseResponse,
    );
  }

  _i4.List<_i4.String> _path({required _i4.String clinicId}) {
    return [
      r'api',
      r'portal',
      r'v1',
      r'clinics',
      clinicId.toSimple(explode: false, allowEmpty: false),
      r'appointments',
    ];
  }

  _i4.Object? _data() {
    return null;
  }

  _i4.String? _queryParameters({
    _i3.ApiPortalV1ClinicsClinicIdAppointmentsParametersModel? scope,
    _i4.String? cursor,
    _i4.int? limit,
  }) {
    final _$entries = <_i5.ParameterEntry>[];
    if (scope != null) {
      _$entries.addAll(
        scope.toForm(
          r'scope',
          explode: true,
          allowEmpty: false,
          textEncoding: _i7.utf8,
        ),
      );
    }
    if (cursor != null) {
      _$entries.addAll(
        cursor.toForm(
          r'cursor',
          explode: true,
          allowEmpty: false,
          textEncoding: _i7.utf8,
        ),
      );
    }
    if (limit != null) {
      _$entries.addAll(
        limit.toForm(
          r'limit',
          explode: true,
          allowEmpty: false,
          textEncoding: _i7.utf8,
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

  _i6.Options _options() {
    final _$headers = <_i4.String, _i4.dynamic>{};
    _$headers['Accept'] = r'application/json';
    return _i6.Options(
      method: 'GET',
      headers: _$headers,
      responseType: _i6.ResponseType.bytes,
      validateStatus: (_) => true,
    );
  }

  _i2.ListAppointmentsResponse _parseResponse(
    _i6.Response<_i4.List<_i4.int>> response,
  ) {
    final _$mediaType = _i5.extractMediaType(
      response.headers.value('content-type'),
    );
    switch ((response.statusCode, _$mediaType)) {
      case (200, r'application/json'):
        final _$json = _i5.decodeResponseJson<_i4.Object?>(response.data);
        final _$body = _i8.AppointmentList.fromJson(_$json);
        return _i2.ListAppointmentsResponse200(body: _$body);
      case (200, _):
        final _$content =
            response.headers.value('content-type') ?? 'not specified';
        final _$matched = _$mediaType ?? 'none';
        final _$status = response.statusCode;
        throw _i5.ResponseDecodingException(
          'Unexpected content type: ${_$content} (matched as: ${_$matched}) for status code: ${_$status}',
        );
      case (400, _):
        return _i2.ListAppointmentsResponse400();
      case (401, _):
        return _i2.ListAppointmentsResponse401();
      case (404, _):
        return _i2.ListAppointmentsResponse404();
      case (422, _):
        return _i2.ListAppointmentsResponse422();
      default:
        final _$content =
            response.headers.value('content-type') ?? 'not specified';
        final _$matched = _$mediaType ?? 'none';
        final _$status = response.statusCode;
        throw _i5.ResponseDecodingException(
          'Unexpected content type: ${_$content} (matched as: ${_$matched}) for status code: ${_$status}',
        );
    }
  }
}
