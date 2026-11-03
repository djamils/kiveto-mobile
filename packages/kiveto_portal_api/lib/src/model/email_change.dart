// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i4;
import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class EmailChange extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const EmailChange({
    required this.challengeId,
    required this.code,
    required this.email,
  });

  factory EmailChange.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {r'challengeId', r'code', r'email'},
      listKeys: {},
      context: r'EmailChange',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return EmailChange(
      challengeId: _$values[r'challengeId'].decodeSimpleString(
        context: r'EmailChange.challengeId',
      ),
      code: _$values[r'code'].decodeSimpleString(context: r'EmailChange.code'),
      email: _$values[r'email'].decodeSimpleString(
        context: r'EmailChange.email',
      ),
    );
  }

  factory EmailChange.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'EmailChange');
    return EmailChange(
      challengeId: _$map[r'challengeId'].decodeJsonString(
        context: r'EmailChange.challengeId',
      ),
      code: _$map[r'code'].decodeJsonString(context: r'EmailChange.code'),
      email: _$map[r'email'].decodeJsonString(context: r'EmailChange.email'),
    );
  }

  factory EmailChange.fromForm(_i3.String? value, {required _i3.bool explode}) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {r'challengeId', r'code', r'email'},
      listKeys: {},
      context: r'EmailChange',
    );
    return EmailChange(
      challengeId: _$values[r'challengeId'].decodeFormString(
        context: r'EmailChange.challengeId',
      ),
      code: _$values[r'code'].decodeFormString(context: r'EmailChange.code'),
      email: _$values[r'email'].decodeFormString(context: r'EmailChange.email'),
    );
  }

  final _i3.String challengeId;

  final _i3.String code;

  final _i3.String email;

  @_i3.override
  _i3.Object? toJson() => {
    r'challengeId': this.challengeId,
    r'code': this.code,
    r'email': this.email,
  };

  EmailChange Function({
    _i3.String? challengeId,
    _i3.String? code,
    _i3.String? email,
  })
  get copyWith {
    return ({_i3.String? challengeId, _i3.String? code, _i3.String? email}) =>
        EmailChange(
          challengeId: challengeId ?? this.challengeId,
          code: code ?? this.code,
          email: email ?? this.email,
        );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is EmailChange &&
        other.challengeId == this.challengeId &&
        other.code == this.code &&
        other.email == this.email;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([this.challengeId, this.code, this.email]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'challengeId'] = _i1.PropertyValue.scalar(this.challengeId);
    _$result[r'code'] = _i1.PropertyValue.scalar(this.code);
    _$result[r'email'] = _i1.PropertyValue.scalar(this.email);
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
      r'Cannot uriEncode EmailChange: complex types cannot be URI-encoded',
    );
  }
}
