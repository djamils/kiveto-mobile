// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i6;
import 'dart:core' as _i3;

import 'package:collection/collection.dart' as _i5;
import 'package:kiveto_portal_api/src/model/clinic_link_view_link_status_model.dart'
    as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class ClinicLinkView extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const ClinicLinkView({
    required this.clinicId,
    required this.name,
    required this.city,
    required this.timezone,
    required this.linkStatus,
    required this.linkedAt,
    required this.petNames,
    required this.tags,
    required this.unreadDocuments,
  });

  factory ClinicLinkView.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {
        r'clinicId',
        r'name',
        r'city',
        r'timezone',
        r'linkStatus',
        r'linkedAt',
        r'petNames',
        r'tags',
        r'unreadDocuments',
      },
      listKeys: {r'petNames', r'tags'},
      context: r'ClinicLinkView',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return ClinicLinkView(
      clinicId: _$values[r'clinicId'].decodeSimpleString(
        context: r'ClinicLinkView.clinicId',
      ),
      name: _$values[r'name'].decodeSimpleString(
        context: r'ClinicLinkView.name',
      ),
      city: _$values[r'city'].decodeSimpleNullableString(
        context: r'ClinicLinkView.city',
      ),
      timezone: _$values[r'timezone'].decodeSimpleString(
        context: r'ClinicLinkView.timezone',
      ),
      linkStatus: _i4.ClinicLinkViewLinkStatusModel.fromSimple(
        _$values[r'linkStatus'],
        explode: explode,
      ),
      linkedAt: _$values[r'linkedAt'].decodeSimpleNullableDateTime(
        context: r'ClinicLinkView.linkedAt',
      ),
      petNames: _$values[r'petNames'].decodeSimpleStringList(
        context: r'ClinicLinkView.petNames',
        isHeader: isHeader,
      ),
      tags: _$values[r'tags'].decodeSimpleStringList(
        context: r'ClinicLinkView.tags',
        isHeader: isHeader,
      ),
      unreadDocuments: _$values[r'unreadDocuments'].decodeSimpleInt(
        context: r'ClinicLinkView.unreadDocuments',
      ),
    );
  }

  factory ClinicLinkView.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'ClinicLinkView');
    return ClinicLinkView(
      clinicId: _$map[r'clinicId'].decodeJsonString(
        context: r'ClinicLinkView.clinicId',
      ),
      name: _$map[r'name'].decodeJsonString(context: r'ClinicLinkView.name'),
      city: _$map[r'city'].decodeJsonNullableString(
        context: r'ClinicLinkView.city',
      ),
      timezone: _$map[r'timezone'].decodeJsonString(
        context: r'ClinicLinkView.timezone',
      ),
      linkStatus: _i4.ClinicLinkViewLinkStatusModel.fromJson(
        _$map[r'linkStatus'],
      ),
      linkedAt: _$map[r'linkedAt'].decodeJsonNullableDateTime(
        context: r'ClinicLinkView.linkedAt',
      ),
      petNames: _$map[r'petNames'].decodeJsonList<_i3.String>(
        context: r'ClinicLinkView.petNames',
      ),
      tags: _$map[r'tags'].decodeJsonList<_i3.String>(
        context: r'ClinicLinkView.tags',
      ),
      unreadDocuments: _$map[r'unreadDocuments'].decodeJsonInt(
        context: r'ClinicLinkView.unreadDocuments',
      ),
    );
  }

  factory ClinicLinkView.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {
        r'clinicId',
        r'name',
        r'city',
        r'timezone',
        r'linkStatus',
        r'linkedAt',
        r'petNames',
        r'tags',
        r'unreadDocuments',
      },
      listKeys: {r'petNames', r'tags'},
      context: r'ClinicLinkView',
    );
    return ClinicLinkView(
      clinicId: _$values[r'clinicId'].decodeFormString(
        context: r'ClinicLinkView.clinicId',
      ),
      name: _$values[r'name'].decodeFormString(context: r'ClinicLinkView.name'),
      city: _$values[r'city'].decodeFormNullableString(
        context: r'ClinicLinkView.city',
      ),
      timezone: _$values[r'timezone'].decodeFormString(
        context: r'ClinicLinkView.timezone',
      ),
      linkStatus: _i4.ClinicLinkViewLinkStatusModel.fromForm(
        _$values[r'linkStatus'],
        explode: explode,
      ),
      linkedAt: _$values[r'linkedAt'].decodeFormNullableDateTime(
        context: r'ClinicLinkView.linkedAt',
      ),
      petNames: _$values[r'petNames'].decodeFormStringList(
        context: r'ClinicLinkView.petNames',
      ),
      tags: _$values[r'tags'].decodeFormStringList(
        context: r'ClinicLinkView.tags',
      ),
      unreadDocuments: _$values[r'unreadDocuments'].decodeFormInt(
        context: r'ClinicLinkView.unreadDocuments',
      ),
    );
  }

  final _i3.String clinicId;

  final _i3.String name;

  final _i3.String? city;

  final _i3.String timezone;

  final _i4.ClinicLinkViewLinkStatusModel linkStatus;

  final _i3.DateTime? linkedAt;

  final _i3.List<_i3.String> petNames;

  final _i3.List<_i3.String> tags;

  final _i3.int unreadDocuments;

  @_i3.override
  _i3.Object? toJson() => {
    r'clinicId': this.clinicId,
    r'name': this.name,
    r'city': this.city,
    r'timezone': this.timezone,
    r'linkStatus': this.linkStatus.toJson(),
    r'linkedAt': this.linkedAt?.toTimeZonedIso8601String(),
    r'petNames': this.petNames,
    r'tags': this.tags,
    r'unreadDocuments': this.unreadDocuments,
  };

  ClinicLinkView Function({
    _i3.String? clinicId,
    _i3.String? name,
    _i3.String? city,
    _i3.String? timezone,
    _i4.ClinicLinkViewLinkStatusModel? linkStatus,
    _i3.DateTime? linkedAt,
    _i3.List<_i3.String>? petNames,
    _i3.List<_i3.String>? tags,
    _i3.int? unreadDocuments,
  })
  get copyWith {
    const _i3.Object _sentinel = _i3.Object();
    return ({
      _i3.String? clinicId,
      _i3.String? name,
      _i3.Object? city = _sentinel,
      _i3.String? timezone,
      _i4.ClinicLinkViewLinkStatusModel? linkStatus,
      _i3.Object? linkedAt = _sentinel,
      _i3.List<_i3.String>? petNames,
      _i3.List<_i3.String>? tags,
      _i3.int? unreadDocuments,
    }) => ClinicLinkView(
      clinicId: clinicId ?? this.clinicId,
      name: name ?? this.name,
      city: _i3.identical(city, _sentinel) ? this.city : (city as _i3.String?),
      timezone: timezone ?? this.timezone,
      linkStatus: linkStatus ?? this.linkStatus,
      linkedAt: _i3.identical(linkedAt, _sentinel)
          ? this.linkedAt
          : (linkedAt as _i3.DateTime?),
      petNames: petNames ?? this.petNames,
      tags: tags ?? this.tags,
      unreadDocuments: unreadDocuments ?? this.unreadDocuments,
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    const _$deepEquals = _i5.DeepCollectionEquality();
    return other is ClinicLinkView &&
        other.clinicId == this.clinicId &&
        other.name == this.name &&
        other.city == this.city &&
        other.timezone == this.timezone &&
        other.linkStatus == this.linkStatus &&
        other.linkedAt == this.linkedAt &&
        _$deepEquals.equals(other.petNames, this.petNames) &&
        _$deepEquals.equals(other.tags, this.tags) &&
        other.unreadDocuments == this.unreadDocuments;
  }

  @_i3.override
  _i3.int get hashCode {
    const deepEquals = _i5.DeepCollectionEquality();
    return _i3.Object.hashAll([
      this.clinicId,
      this.name,
      this.city,
      this.timezone,
      this.linkStatus,
      this.linkedAt,
      deepEquals.hash(this.petNames),
      deepEquals.hash(this.tags),
      this.unreadDocuments,
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'clinicId'] = _i1.PropertyValue.scalar(this.clinicId);
    _$result[r'name'] = _i1.PropertyValue.scalar(this.name);
    if (this.city != null) {
      _$result[r'city'] = _i1.PropertyValue.scalar(this.city!);
    }
    _$result[r'timezone'] = _i1.PropertyValue.scalar(this.timezone);
    _$result[r'linkStatus'] = _i1.PropertyValue.scalar(
      this.linkStatus.toJson(),
    );
    if (this.linkedAt != null) {
      _$result[r'linkedAt'] = _i1.PropertyValue.scalar(
        this.linkedAt!.toTimeZonedIso8601String(),
      );
    }
    _$result[r'petNames'] = _i1.PropertyValue.array(this.petNames);
    _$result[r'tags'] = _i1.PropertyValue.array(this.tags);
    _$result[r'unreadDocuments'] = _i1.PropertyValue.scalar(
      this.unreadDocuments.toString(),
    );
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
      r'Cannot uriEncode ClinicLinkView: complex types cannot be URI-encoded',
    );
  }
}
