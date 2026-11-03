// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i6;
import 'dart:core' as _i3;

import 'package:collection/collection.dart' as _i5;
import 'package:kiveto_portal_api/src/model/clinic_listing_summary_view_address_any_of_model.dart'
    as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class ClinicListingSummaryView extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const ClinicListingSummaryView({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.distanceM,
    required this.onKiveto,
    required this.onlineBooking,
    required this.tags,
    required this.nextAvailableAt,
  });

  factory ClinicListingSummaryView.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    throw _i1.SimpleDecodingException(
      r'Simple encoding not supported for ClinicListingSummaryView: contains complex types',
    );
  }

  factory ClinicListingSummaryView.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'ClinicListingSummaryView');
    return ClinicListingSummaryView(
      id: _$map[r'id'].decodeJsonString(
        context: r'ClinicListingSummaryView.id',
      ),
      name: _$map[r'name'].decodeJsonString(
        context: r'ClinicListingSummaryView.name',
      ),
      address: _$map[r'address'] == null
          ? null
          : _i4.ClinicListingSummaryViewAddressAnyOfModel.fromJson(
              _$map[r'address'],
            ),
      phone: _$map[r'phone'].decodeJsonNullableString(
        context: r'ClinicListingSummaryView.phone',
      ),
      distanceM: _$map[r'distanceM'].decodeJsonNullableInt(
        context: r'ClinicListingSummaryView.distanceM',
      ),
      onKiveto: _$map[r'onKiveto'].decodeJsonBool(
        context: r'ClinicListingSummaryView.onKiveto',
      ),
      onlineBooking: _$map[r'onlineBooking'].decodeJsonBool(
        context: r'ClinicListingSummaryView.onlineBooking',
      ),
      tags: _$map[r'tags'].decodeJsonList<_i3.String>(
        context: r'ClinicListingSummaryView.tags',
      ),
      nextAvailableAt: _$map[r'nextAvailableAt'].decodeJsonNullableDateTime(
        context: r'ClinicListingSummaryView.nextAvailableAt',
      ),
    );
  }

  factory ClinicListingSummaryView.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    throw _i1.FormDecodingException(
      r'Form encoding not supported for ClinicListingSummaryView: contains complex types',
    );
  }

  final _i3.String id;

  final _i3.String name;

  final _i4.ClinicListingSummaryViewAddressAnyOfModel address;

  final _i3.String? phone;

  final _i3.int? distanceM;

  final _i3.bool onKiveto;

  final _i3.bool onlineBooking;

  final _i3.List<_i3.String> tags;

  final _i3.DateTime? nextAvailableAt;

  @_i3.override
  _i3.Object? toJson() => {
    r'id': this.id,
    r'name': this.name,
    r'address': this.address?.toJson(),
    r'phone': this.phone,
    r'distanceM': this.distanceM,
    r'onKiveto': this.onKiveto,
    r'onlineBooking': this.onlineBooking,
    r'tags': this.tags,
    r'nextAvailableAt': this.nextAvailableAt?.toTimeZonedIso8601String(),
  };

  ClinicListingSummaryView Function({
    _i3.String? id,
    _i3.String? name,
    _i4.ClinicListingSummaryViewAddressAnyOfModel? address,
    _i3.String? phone,
    _i3.int? distanceM,
    _i3.bool? onKiveto,
    _i3.bool? onlineBooking,
    _i3.List<_i3.String>? tags,
    _i3.DateTime? nextAvailableAt,
  })
  get copyWith {
    const _i3.Object _sentinel = _i3.Object();
    return ({
      _i3.String? id,
      _i3.String? name,
      _i3.Object? address = _sentinel,
      _i3.Object? phone = _sentinel,
      _i3.Object? distanceM = _sentinel,
      _i3.bool? onKiveto,
      _i3.bool? onlineBooking,
      _i3.List<_i3.String>? tags,
      _i3.Object? nextAvailableAt = _sentinel,
    }) => ClinicListingSummaryView(
      id: id ?? this.id,
      name: name ?? this.name,
      address: _i3.identical(address, _sentinel)
          ? this.address
          : (address as _i4.ClinicListingSummaryViewAddressAnyOfModel),
      phone: _i3.identical(phone, _sentinel)
          ? this.phone
          : (phone as _i3.String?),
      distanceM: _i3.identical(distanceM, _sentinel)
          ? this.distanceM
          : (distanceM as _i3.int?),
      onKiveto: onKiveto ?? this.onKiveto,
      onlineBooking: onlineBooking ?? this.onlineBooking,
      tags: tags ?? this.tags,
      nextAvailableAt: _i3.identical(nextAvailableAt, _sentinel)
          ? this.nextAvailableAt
          : (nextAvailableAt as _i3.DateTime?),
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    const _$deepEquals = _i5.DeepCollectionEquality();
    return other is ClinicListingSummaryView &&
        other.id == this.id &&
        other.name == this.name &&
        other.address == this.address &&
        other.phone == this.phone &&
        other.distanceM == this.distanceM &&
        other.onKiveto == this.onKiveto &&
        other.onlineBooking == this.onlineBooking &&
        _$deepEquals.equals(other.tags, this.tags) &&
        other.nextAvailableAt == this.nextAvailableAt;
  }

  @_i3.override
  _i3.int get hashCode {
    const deepEquals = _i5.DeepCollectionEquality();
    return _i3.Object.hashAll([
      this.id,
      this.name,
      this.address,
      this.phone,
      this.distanceM,
      this.onKiveto,
      this.onlineBooking,
      deepEquals.hash(this.tags),
      this.nextAvailableAt,
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'id'] = _i1.PropertyValue.scalar(this.id);
    _$result[r'name'] = _i1.PropertyValue.scalar(this.name);
    if (this.address != null) {
      _$result[r'address'] = _i1.encodeAnyValueToPropertyValue(
        this.address!.toJson(),
        allowEmpty: allowEmpty,
      );
    }
    if (this.phone != null) {
      _$result[r'phone'] = _i1.PropertyValue.scalar(this.phone!);
    }
    if (this.distanceM != null) {
      _$result[r'distanceM'] = _i1.PropertyValue.scalar(
        this.distanceM!.toString(),
      );
    }
    _$result[r'onKiveto'] = _i1.PropertyValue.scalar(this.onKiveto.toString());
    _$result[r'onlineBooking'] = _i1.PropertyValue.scalar(
      this.onlineBooking.toString(),
    );
    _$result[r'tags'] = _i1.PropertyValue.array(this.tags);
    if (this.nextAvailableAt != null) {
      _$result[r'nextAvailableAt'] = _i1.PropertyValue.scalar(
        this.nextAvailableAt!.toTimeZonedIso8601String(),
      );
    }
    return _$result;
  }

  @_i3.override
  _i3.String uriEncode({
    required _i3.bool allowEmpty,
    required _i6.Encoding textEncoding,
    _i3.bool useQueryComponent = false,
    _i3.bool allowReserved = false,
  }) {
    throw _i1.EncodingException(
      r'Cannot uriEncode ClinicListingSummaryView: complex types cannot be URI-encoded',
    );
  }
}
