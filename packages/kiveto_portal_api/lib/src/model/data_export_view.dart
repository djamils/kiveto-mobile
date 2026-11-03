// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i4;
import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

/// The exports of the account; the route answers a plain JSON array of them.
@_i2.immutable
class DataExportView extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const DataExportView({
    required this.id,
    required this.status,
    required this.requestedAt,
    required this.readyAt,
    required this.expiresAt,
  });

  factory DataExportView.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {
        r'id',
        r'status',
        r'requestedAt',
        r'readyAt',
        r'expiresAt',
      },
      listKeys: {},
      context: r'DataExportView',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return DataExportView(
      id: _$values[r'id'].decodeSimpleString(context: r'DataExportView.id'),
      status: _$values[r'status'].decodeSimpleString(
        context: r'DataExportView.status',
      ),
      requestedAt: _$values[r'requestedAt'].decodeSimpleString(
        context: r'DataExportView.requestedAt',
      ),
      readyAt: _$values[r'readyAt'].decodeSimpleNullableString(
        context: r'DataExportView.readyAt',
      ),
      expiresAt: _$values[r'expiresAt'].decodeSimpleNullableString(
        context: r'DataExportView.expiresAt',
      ),
    );
  }

  factory DataExportView.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'DataExportView');
    return DataExportView(
      id: _$map[r'id'].decodeJsonString(context: r'DataExportView.id'),
      status: _$map[r'status'].decodeJsonString(
        context: r'DataExportView.status',
      ),
      requestedAt: _$map[r'requestedAt'].decodeJsonString(
        context: r'DataExportView.requestedAt',
      ),
      readyAt: _$map[r'readyAt'].decodeJsonNullableString(
        context: r'DataExportView.readyAt',
      ),
      expiresAt: _$map[r'expiresAt'].decodeJsonNullableString(
        context: r'DataExportView.expiresAt',
      ),
    );
  }

  factory DataExportView.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {
        r'id',
        r'status',
        r'requestedAt',
        r'readyAt',
        r'expiresAt',
      },
      listKeys: {},
      context: r'DataExportView',
    );
    return DataExportView(
      id: _$values[r'id'].decodeFormString(context: r'DataExportView.id'),
      status: _$values[r'status'].decodeFormString(
        context: r'DataExportView.status',
      ),
      requestedAt: _$values[r'requestedAt'].decodeFormString(
        context: r'DataExportView.requestedAt',
      ),
      readyAt: _$values[r'readyAt'].decodeFormNullableString(
        context: r'DataExportView.readyAt',
      ),
      expiresAt: _$values[r'expiresAt'].decodeFormNullableString(
        context: r'DataExportView.expiresAt',
      ),
    );
  }

  final _i3.String id;

  final _i3.String status;

  final _i3.String requestedAt;

  final _i3.String? readyAt;

  final _i3.String? expiresAt;

  @_i3.override
  _i3.Object? toJson() => {
    r'id': this.id,
    r'status': this.status,
    r'requestedAt': this.requestedAt,
    r'readyAt': this.readyAt,
    r'expiresAt': this.expiresAt,
  };

  DataExportView Function({
    _i3.String? id,
    _i3.String? status,
    _i3.String? requestedAt,
    _i3.String? readyAt,
    _i3.String? expiresAt,
  })
  get copyWith {
    const _i3.Object _sentinel = _i3.Object();
    return ({
      _i3.String? id,
      _i3.String? status,
      _i3.String? requestedAt,
      _i3.Object? readyAt = _sentinel,
      _i3.Object? expiresAt = _sentinel,
    }) => DataExportView(
      id: id ?? this.id,
      status: status ?? this.status,
      requestedAt: requestedAt ?? this.requestedAt,
      readyAt: _i3.identical(readyAt, _sentinel)
          ? this.readyAt
          : (readyAt as _i3.String?),
      expiresAt: _i3.identical(expiresAt, _sentinel)
          ? this.expiresAt
          : (expiresAt as _i3.String?),
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is DataExportView &&
        other.id == this.id &&
        other.status == this.status &&
        other.requestedAt == this.requestedAt &&
        other.readyAt == this.readyAt &&
        other.expiresAt == this.expiresAt;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([
      this.id,
      this.status,
      this.requestedAt,
      this.readyAt,
      this.expiresAt,
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'id'] = _i1.PropertyValue.scalar(this.id);
    _$result[r'status'] = _i1.PropertyValue.scalar(this.status);
    _$result[r'requestedAt'] = _i1.PropertyValue.scalar(this.requestedAt);
    if (this.readyAt != null) {
      _$result[r'readyAt'] = _i1.PropertyValue.scalar(this.readyAt!);
    }
    if (this.expiresAt != null) {
      _$result[r'expiresAt'] = _i1.PropertyValue.scalar(this.expiresAt!);
    }
    return _$result;
  }

  @_i3.override
  _i3.String uriEncode({
    required _i3.bool allowEmpty,
    required _i4.Encoding textEncoding,
    _i3.bool useQueryComponent = false,
    _i3.bool allowReserved = false,
  }) {
    throw _i1.EncodingException(
      r'Cannot uriEncode DataExportView: complex types cannot be URI-encoded',
    );
  }
}
