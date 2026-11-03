// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i7;
import 'dart:core' as _i3;

import 'package:collection/collection.dart' as _i6;
import 'package:kiveto_portal_api/src/model/clinic_listing_detail_address_any_of_model.dart'
    as _i4;
import 'package:kiveto_portal_api/src/model/opening_hours_view.dart' as _i5;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

/// A clinic of the directory, in full; `id` is the listing id, never the clinic's.
@_i2.immutable
class ClinicListingDetail extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const ClinicListingDetail({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.timezone,
    required this.openingHours,
    required this.acceptsNewClients,
    required this.onlineBooking,
    required this.tags,
  });

  factory ClinicListingDetail.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    throw _i1.SimpleDecodingException(
      r'Simple encoding not supported for ClinicListingDetail: contains complex types',
    );
  }

  factory ClinicListingDetail.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'ClinicListingDetail');
    return ClinicListingDetail(
      id: _$map[r'id'].decodeJsonString(context: r'ClinicListingDetail.id'),
      name: _$map[r'name'].decodeJsonString(
        context: r'ClinicListingDetail.name',
      ),
      address: _$map[r'address'] == null
          ? null
          : _i4.ClinicListingDetailAddressAnyOfModel.fromJson(
              _$map[r'address'],
            ),
      phone: _$map[r'phone'].decodeJsonNullableString(
        context: r'ClinicListingDetail.phone',
      ),
      timezone: _$map[r'timezone'].decodeJsonString(
        context: r'ClinicListingDetail.timezone',
      ),
      openingHours: _$map[r'openingHours']
          .decodeJsonList<_i3.Object?>(
            context: r'ClinicListingDetail.openingHours',
          )
          .map(_i5.OpeningHoursView.fromJson)
          .toList(),
      acceptsNewClients: _$map[r'acceptsNewClients'].decodeJsonBool(
        context: r'ClinicListingDetail.acceptsNewClients',
      ),
      onlineBooking: _$map[r'onlineBooking'].decodeJsonBool(
        context: r'ClinicListingDetail.onlineBooking',
      ),
      tags: _$map[r'tags'].decodeJsonList<_i3.String>(
        context: r'ClinicListingDetail.tags',
      ),
    );
  }

  factory ClinicListingDetail.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    throw _i1.FormDecodingException(
      r'Form encoding not supported for ClinicListingDetail: contains complex types',
    );
  }

  final _i3.String id;

  final _i3.String name;

  final _i4.ClinicListingDetailAddressAnyOfModel address;

  final _i3.String? phone;

  final _i3.String timezone;

  final _i3.List<_i5.OpeningHoursView> openingHours;

  final _i3.bool acceptsNewClients;

  final _i3.bool onlineBooking;

  final _i3.List<_i3.String> tags;

  @_i3.override
  _i3.Object? toJson() => {
    r'id': this.id,
    r'name': this.name,
    r'address': this.address?.toJson(),
    r'phone': this.phone,
    r'timezone': this.timezone,
    r'openingHours': this.openingHours.map((e) => e.toJson()).toList(),
    r'acceptsNewClients': this.acceptsNewClients,
    r'onlineBooking': this.onlineBooking,
    r'tags': this.tags,
  };

  ClinicListingDetail Function({
    _i3.String? id,
    _i3.String? name,
    _i4.ClinicListingDetailAddressAnyOfModel? address,
    _i3.String? phone,
    _i3.String? timezone,
    _i3.List<_i5.OpeningHoursView>? openingHours,
    _i3.bool? acceptsNewClients,
    _i3.bool? onlineBooking,
    _i3.List<_i3.String>? tags,
  })
  get copyWith {
    const _i3.Object _sentinel = _i3.Object();
    return ({
      _i3.String? id,
      _i3.String? name,
      _i3.Object? address = _sentinel,
      _i3.Object? phone = _sentinel,
      _i3.String? timezone,
      _i3.List<_i5.OpeningHoursView>? openingHours,
      _i3.bool? acceptsNewClients,
      _i3.bool? onlineBooking,
      _i3.List<_i3.String>? tags,
    }) => ClinicListingDetail(
      id: id ?? this.id,
      name: name ?? this.name,
      address: _i3.identical(address, _sentinel)
          ? this.address
          : (address as _i4.ClinicListingDetailAddressAnyOfModel),
      phone: _i3.identical(phone, _sentinel)
          ? this.phone
          : (phone as _i3.String?),
      timezone: timezone ?? this.timezone,
      openingHours: openingHours ?? this.openingHours,
      acceptsNewClients: acceptsNewClients ?? this.acceptsNewClients,
      onlineBooking: onlineBooking ?? this.onlineBooking,
      tags: tags ?? this.tags,
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    const _$deepEquals = _i6.DeepCollectionEquality();
    return other is ClinicListingDetail &&
        other.id == this.id &&
        other.name == this.name &&
        other.address == this.address &&
        other.phone == this.phone &&
        other.timezone == this.timezone &&
        _$deepEquals.equals(other.openingHours, this.openingHours) &&
        other.acceptsNewClients == this.acceptsNewClients &&
        other.onlineBooking == this.onlineBooking &&
        _$deepEquals.equals(other.tags, this.tags);
  }

  @_i3.override
  _i3.int get hashCode {
    const deepEquals = _i6.DeepCollectionEquality();
    return _i3.Object.hashAll([
      this.id,
      this.name,
      this.address,
      this.phone,
      this.timezone,
      deepEquals.hash(this.openingHours),
      this.acceptsNewClients,
      this.onlineBooking,
      deepEquals.hash(this.tags),
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) => throw _i1.EncodingException(
    r'parameterProperties not supported for ClinicListingDetail: contains complex types',
  );

  @_i3.override
  _i3.String uriEncode({
    required _i3.bool allowEmpty,
    required _i7.Encoding textEncoding,
    _i3.bool useQueryComponent = false,
    _i3.bool allowReserved = false,
  }) {
    throw _i1.EncodingException(
      r'Cannot uriEncode ClinicListingDetail: complex types cannot be URI-encoded',
    );
  }
}
