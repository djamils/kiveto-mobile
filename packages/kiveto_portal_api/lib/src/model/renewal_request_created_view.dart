// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i5;
import 'dart:core' as _i3;

import 'package:kiveto_portal_api/src/model/renewal_request_creation_renewal_request_created_view_status_model.dart'
    as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class RenewalRequestCreatedView extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const RenewalRequestCreatedView({
    required this.requestId,
    required this.status,
  });

  factory RenewalRequestCreatedView.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {r'requestId', r'status'},
      listKeys: {},
      context: r'RenewalRequestCreatedView',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return RenewalRequestCreatedView(
      requestId: _$values[r'requestId'].decodeSimpleString(
        context: r'RenewalRequestCreatedView.requestId',
      ),
      status:
          _i4.RenewalRequestCreationRenewalRequestCreatedViewStatusModel.fromSimple(
            _$values[r'status'],
            explode: explode,
          ),
    );
  }

  factory RenewalRequestCreatedView.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'RenewalRequestCreatedView');
    return RenewalRequestCreatedView(
      requestId: _$map[r'requestId'].decodeJsonString(
        context: r'RenewalRequestCreatedView.requestId',
      ),
      status:
          _i4.RenewalRequestCreationRenewalRequestCreatedViewStatusModel.fromJson(
            _$map[r'status'],
          ),
    );
  }

  factory RenewalRequestCreatedView.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {r'requestId', r'status'},
      listKeys: {},
      context: r'RenewalRequestCreatedView',
    );
    return RenewalRequestCreatedView(
      requestId: _$values[r'requestId'].decodeFormString(
        context: r'RenewalRequestCreatedView.requestId',
      ),
      status:
          _i4.RenewalRequestCreationRenewalRequestCreatedViewStatusModel.fromForm(
            _$values[r'status'],
            explode: explode,
          ),
    );
  }

  final _i3.String requestId;

  final _i4.RenewalRequestCreationRenewalRequestCreatedViewStatusModel status;

  @_i3.override
  _i3.Object? toJson() => {
    r'requestId': this.requestId,
    r'status': this.status.toJson(),
  };

  RenewalRequestCreatedView Function({
    _i3.String? requestId,
    _i4.RenewalRequestCreationRenewalRequestCreatedViewStatusModel? status,
  })
  get copyWith {
    return ({
      _i3.String? requestId,
      _i4.RenewalRequestCreationRenewalRequestCreatedViewStatusModel? status,
    }) => RenewalRequestCreatedView(
      requestId: requestId ?? this.requestId,
      status: status ?? this.status,
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is RenewalRequestCreatedView &&
        other.requestId == this.requestId &&
        other.status == this.status;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([this.requestId, this.status]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'requestId'] = _i1.PropertyValue.scalar(this.requestId);
    _$result[r'status'] = _i1.PropertyValue.scalar(this.status.toJson());
    return _$result;
  }

  @_i3.override
  _i3.String uriEncode({
    required _i3.bool allowEmpty,
    required _i5.Encoding textEncoding,
    _i3.bool useQueryComponent = false,
    _i3.bool allowReserved = false,
  }) {
    throw _i1.EncodingException(
      r'Cannot uriEncode RenewalRequestCreatedView: complex types cannot be URI-encoded',
    );
  }
}
