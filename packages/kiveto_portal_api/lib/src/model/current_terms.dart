// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i4;
import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class CurrentTerms extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const CurrentTerms({required this.version, required this.url});

  factory CurrentTerms.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {r'version', r'url'},
      listKeys: {},
      context: r'CurrentTerms',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return CurrentTerms(
      version: _$values[r'version'].decodeSimpleString(
        context: r'CurrentTerms.version',
      ),
      url: _$values[r'url'].decodeSimpleString(context: r'CurrentTerms.url'),
    );
  }

  factory CurrentTerms.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'CurrentTerms');
    return CurrentTerms(
      version: _$map[r'version'].decodeJsonString(
        context: r'CurrentTerms.version',
      ),
      url: _$map[r'url'].decodeJsonString(context: r'CurrentTerms.url'),
    );
  }

  factory CurrentTerms.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {r'version', r'url'},
      listKeys: {},
      context: r'CurrentTerms',
    );
    return CurrentTerms(
      version: _$values[r'version'].decodeFormString(
        context: r'CurrentTerms.version',
      ),
      url: _$values[r'url'].decodeFormString(context: r'CurrentTerms.url'),
    );
  }

  final _i3.String version;

  final _i3.String url;

  @_i3.override
  _i3.Object? toJson() => {r'version': this.version, r'url': this.url};

  CurrentTerms Function({_i3.String? version, _i3.String? url}) get copyWith {
    return ({_i3.String? version, _i3.String? url}) =>
        CurrentTerms(version: version ?? this.version, url: url ?? this.url);
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is CurrentTerms &&
        other.version == this.version &&
        other.url == this.url;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([this.version, this.url]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'version'] = _i1.PropertyValue.scalar(this.version);
    _$result[r'url'] = _i1.PropertyValue.scalar(this.url);
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
      r'Cannot uriEncode CurrentTerms: complex types cannot be URI-encoded',
    );
  }
}
