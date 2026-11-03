// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:dio/dio.dart' as _i5;
import 'package:kiveto_portal_api/src/model/listing_motif_view.dart' as _i6;
import 'package:kiveto_portal_api/src/operation/dio_operation.dart' as _i1;
import 'package:kiveto_portal_api/src/response_wrapper/list_listing_motifs_response.dart'
    as _i2;
import 'package:tonik_util/tonik_util.dart' as _i4;

final class ListListingMotifs
    extends _i1.DioOperation<_i2.ListListingMotifsResponse> {
  ListListingMotifs(super.baseUrl, super.clientAccessor);

  _i3.Future<
    _i4.TonikResult<_i2.ListListingMotifsResponse, _i5.Response<_i3.Object?>>
  >
  call({required _i3.String listingId, _i4.TonikCancellation? cancellation}) {
    return this.execute(
      cancellation: cancellation,
      prepare: () => _i1.DioOperationRequest(
        path: _path(listingId: listingId),
        query: null,
        data: _data(),
        options: _options(),
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
      r'motifs',
    ];
  }

  _i3.Object? _data() {
    return null;
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

  _i2.ListListingMotifsResponse _parseResponse(
    _i5.Response<_i3.List<_i3.int>> response,
  ) {
    final _$mediaType = _i4.extractMediaType(
      response.headers.value('content-type'),
    );
    switch ((response.statusCode, _$mediaType)) {
      case (200, r'application/json'):
        final _$json = _i4.decodeResponseJson<_i3.Object?>(response.data);
        final _$body = _$json
            .decodeJsonList<_i3.Object?>()
            .map(_i6.ListingMotifView.fromJson)
            .toList();
        return _i2.ListListingMotifsResponse200(body: _$body);
      case (200, _):
        final _$content =
            response.headers.value('content-type') ?? 'not specified';
        final _$matched = _$mediaType ?? 'none';
        final _$status = response.statusCode;
        throw _i4.ResponseDecodingException(
          'Unexpected content type: ${_$content} (matched as: ${_$matched}) for status code: ${_$status}',
        );
      case (404, _):
        return _i2.ListListingMotifsResponse404();
      case (422, _):
        return _i2.ListListingMotifsResponse422();
      case (429, _):
        return _i2.ListListingMotifsResponse429();
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
