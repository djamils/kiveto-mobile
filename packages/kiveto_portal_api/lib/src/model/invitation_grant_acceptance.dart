// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i4;
import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class InvitationGrantAcceptance extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const InvitationGrantAcceptance({
    required this.onboardingToken,
    required this.termsVersion,
  });

  factory InvitationGrantAcceptance.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {r'onboardingToken', r'termsVersion'},
      listKeys: {},
      context: r'InvitationGrantAcceptance',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return InvitationGrantAcceptance(
      onboardingToken: _$values[r'onboardingToken'].decodeSimpleString(
        context: r'InvitationGrantAcceptance.onboardingToken',
      ),
      termsVersion: _$values[r'termsVersion'].decodeSimpleString(
        context: r'InvitationGrantAcceptance.termsVersion',
      ),
    );
  }

  factory InvitationGrantAcceptance.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'InvitationGrantAcceptance');
    return InvitationGrantAcceptance(
      onboardingToken: _$map[r'onboardingToken'].decodeJsonString(
        context: r'InvitationGrantAcceptance.onboardingToken',
      ),
      termsVersion: _$map[r'termsVersion'].decodeJsonString(
        context: r'InvitationGrantAcceptance.termsVersion',
      ),
    );
  }

  factory InvitationGrantAcceptance.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {r'onboardingToken', r'termsVersion'},
      listKeys: {},
      context: r'InvitationGrantAcceptance',
    );
    return InvitationGrantAcceptance(
      onboardingToken: _$values[r'onboardingToken'].decodeFormString(
        context: r'InvitationGrantAcceptance.onboardingToken',
      ),
      termsVersion: _$values[r'termsVersion'].decodeFormString(
        context: r'InvitationGrantAcceptance.termsVersion',
      ),
    );
  }

  final _i3.String onboardingToken;

  /// The `version` of /legal/terms/current.
  final _i3.String termsVersion;

  @_i3.override
  _i3.Object? toJson() => {
    r'onboardingToken': this.onboardingToken,
    r'termsVersion': this.termsVersion,
  };

  InvitationGrantAcceptance Function({
    _i3.String? onboardingToken,
    _i3.String? termsVersion,
  })
  get copyWith {
    return ({_i3.String? onboardingToken, _i3.String? termsVersion}) =>
        InvitationGrantAcceptance(
          onboardingToken: onboardingToken ?? this.onboardingToken,
          termsVersion: termsVersion ?? this.termsVersion,
        );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is InvitationGrantAcceptance &&
        other.onboardingToken == this.onboardingToken &&
        other.termsVersion == this.termsVersion;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([this.onboardingToken, this.termsVersion]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'onboardingToken'] = _i1.PropertyValue.scalar(
      this.onboardingToken,
    );
    _$result[r'termsVersion'] = _i1.PropertyValue.scalar(this.termsVersion);
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
      r'Cannot uriEncode InvitationGrantAcceptance: complex types cannot be URI-encoded',
    );
  }
}
