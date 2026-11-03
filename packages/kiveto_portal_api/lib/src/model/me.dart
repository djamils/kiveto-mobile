// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i7;
import 'dart:core' as _i3;

import 'package:collection/collection.dart' as _i6;
import 'package:kiveto_portal_api/src/model/account_view.dart' as _i4;
import 'package:kiveto_portal_api/src/model/clinic_link_view.dart' as _i5;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class Me extends _i1.ObjectParameterEncodable implements _i1.UriEncodable {
  const Me({required this.account, required this.clinics});

  factory Me.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    throw _i1.SimpleDecodingException(
      r'Simple encoding not supported for Me: contains complex types',
    );
  }

  factory Me.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'Me');
    return Me(
      account: _i4.AccountView.fromJson(_$map[r'account']),
      clinics: _$map[r'clinics']
          .decodeJsonList<_i3.Object?>(context: r'Me.clinics')
          .map(_i5.ClinicLinkView.fromJson)
          .toList(),
    );
  }

  factory Me.fromForm(_i3.String? value, {required _i3.bool explode}) {
    throw _i1.FormDecodingException(
      r'Form encoding not supported for Me: contains complex types',
    );
  }

  final _i4.AccountView account;

  final _i3.List<_i5.ClinicLinkView> clinics;

  @_i3.override
  _i3.Object? toJson() => {
    r'account': this.account.toJson(),
    r'clinics': this.clinics.map((e) => e.toJson()).toList(),
  };

  Me Function({_i4.AccountView? account, _i3.List<_i5.ClinicLinkView>? clinics})
  get copyWith {
    return ({
      _i4.AccountView? account,
      _i3.List<_i5.ClinicLinkView>? clinics,
    }) =>
        Me(account: account ?? this.account, clinics: clinics ?? this.clinics);
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    const _$deepEquals = _i6.DeepCollectionEquality();
    return other is Me &&
        other.account == this.account &&
        _$deepEquals.equals(other.clinics, this.clinics);
  }

  @_i3.override
  _i3.int get hashCode {
    const deepEquals = _i6.DeepCollectionEquality();
    return _i3.Object.hashAll([this.account, deepEquals.hash(this.clinics)]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) => throw _i1.EncodingException(
    r'parameterProperties not supported for Me: contains complex types',
  );

  @_i3.override
  _i3.String uriEncode({
    required _i3.bool allowEmpty,
    required _i7.Encoding textEncoding,
    _i3.bool useQueryComponent = false,
    _i3.bool allowReserved = false,
  }) {
    throw _i1.EncodingException(
      r'Cannot uriEncode Me: complex types cannot be URI-encoded',
    );
  }
}
