// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i9;
import 'dart:core' as _i3;

import 'package:collection/collection.dart' as _i8;
import 'package:kiveto_portal_api/src/model/document_view.dart' as _i7;
import 'package:kiveto_portal_api/src/model/home_care_item_view.dart' as _i6;
import 'package:kiveto_portal_api/src/model/home_next_appointment_any_of_model.dart'
    as _i4;
import 'package:kiveto_portal_api/src/model/pet_summary.dart' as _i5;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class Home extends _i1.ObjectParameterEncodable implements _i1.UriEncodable {
  const Home({
    required this.nextAppointment,
    required this.pets,
    required this.careItems,
    required this.latestDocuments,
  });

  factory Home.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    throw _i1.SimpleDecodingException(
      r'Simple encoding not supported for Home: contains complex types',
    );
  }

  factory Home.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'Home');
    return Home(
      nextAppointment: _$map[r'nextAppointment'] == null
          ? null
          : _i4.HomeNextAppointmentAnyOfModel.fromJson(
              _$map[r'nextAppointment'],
            ),
      pets: _$map[r'pets']
          .decodeJsonList<_i3.Object?>(context: r'Home.pets')
          .map(_i5.PetSummary.fromJson)
          .toList(),
      careItems: _$map[r'careItems']
          .decodeJsonList<_i3.Object?>(context: r'Home.careItems')
          .map(_i6.HomeCareItemView.fromJson)
          .toList(),
      latestDocuments: _$map[r'latestDocuments']
          .decodeJsonList<_i3.Object?>(context: r'Home.latestDocuments')
          .map(_i7.DocumentView.fromJson)
          .toList(),
    );
  }

  factory Home.fromForm(_i3.String? value, {required _i3.bool explode}) {
    throw _i1.FormDecodingException(
      r'Form encoding not supported for Home: contains complex types',
    );
  }

  final _i4.HomeNextAppointmentAnyOfModel nextAppointment;

  final _i3.List<_i5.PetSummary> pets;

  final _i3.List<_i6.HomeCareItemView> careItems;

  final _i3.List<_i7.DocumentView> latestDocuments;

  @_i3.override
  _i3.Object? toJson() => {
    r'nextAppointment': this.nextAppointment?.toJson(),
    r'pets': this.pets.map((e) => e.toJson()).toList(),
    r'careItems': this.careItems.map((e) => e.toJson()).toList(),
    r'latestDocuments': this.latestDocuments.map((e) => e.toJson()).toList(),
  };

  Home Function({
    _i4.HomeNextAppointmentAnyOfModel? nextAppointment,
    _i3.List<_i5.PetSummary>? pets,
    _i3.List<_i6.HomeCareItemView>? careItems,
    _i3.List<_i7.DocumentView>? latestDocuments,
  })
  get copyWith {
    const _i3.Object _sentinel = _i3.Object();
    return ({
      _i3.Object? nextAppointment = _sentinel,
      _i3.List<_i5.PetSummary>? pets,
      _i3.List<_i6.HomeCareItemView>? careItems,
      _i3.List<_i7.DocumentView>? latestDocuments,
    }) => Home(
      nextAppointment: _i3.identical(nextAppointment, _sentinel)
          ? this.nextAppointment
          : (nextAppointment as _i4.HomeNextAppointmentAnyOfModel),
      pets: pets ?? this.pets,
      careItems: careItems ?? this.careItems,
      latestDocuments: latestDocuments ?? this.latestDocuments,
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    const _$deepEquals = _i8.DeepCollectionEquality();
    return other is Home &&
        other.nextAppointment == this.nextAppointment &&
        _$deepEquals.equals(other.pets, this.pets) &&
        _$deepEquals.equals(other.careItems, this.careItems) &&
        _$deepEquals.equals(other.latestDocuments, this.latestDocuments);
  }

  @_i3.override
  _i3.int get hashCode {
    const deepEquals = _i8.DeepCollectionEquality();
    return _i3.Object.hashAll([
      this.nextAppointment,
      deepEquals.hash(this.pets),
      deepEquals.hash(this.careItems),
      deepEquals.hash(this.latestDocuments),
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) => throw _i1.EncodingException(
    r'parameterProperties not supported for Home: contains complex types',
  );

  @_i3.override
  _i3.String uriEncode({
    required _i3.bool allowEmpty,
    required _i9.Encoding textEncoding,
    _i3.bool useQueryComponent = false,
    _i3.bool allowReserved = false,
  }) {
    throw _i1.EncodingException(
      r'Cannot uriEncode Home: complex types cannot be URI-encoded',
    );
  }
}
