// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i4;
import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

/// A practitioner a new client may book online for the motif; the route answers a plain JSON array of them.
@_i2.immutable
class ListingPractitionerView extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const ListingPractitionerView({required this.id, required this.displayName});

  factory ListingPractitionerView.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {r'id', r'displayName'},
      listKeys: {},
      context: r'ListingPractitionerView',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return ListingPractitionerView(
      id: _$values[r'id'].decodeSimpleString(
        context: r'ListingPractitionerView.id',
      ),
      displayName: _$values[r'displayName'].decodeSimpleNullableString(
        context: r'ListingPractitionerView.displayName',
      ),
    );
  }

  factory ListingPractitionerView.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'ListingPractitionerView');
    return ListingPractitionerView(
      id: _$map[r'id'].decodeJsonString(context: r'ListingPractitionerView.id'),
      displayName: _$map[r'displayName'].decodeJsonNullableString(
        context: r'ListingPractitionerView.displayName',
      ),
    );
  }

  factory ListingPractitionerView.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {r'id', r'displayName'},
      listKeys: {},
      context: r'ListingPractitionerView',
    );
    return ListingPractitionerView(
      id: _$values[r'id'].decodeFormString(
        context: r'ListingPractitionerView.id',
      ),
      displayName: _$values[r'displayName'].decodeFormNullableString(
        context: r'ListingPractitionerView.displayName',
      ),
    );
  }

  final _i3.String id;

  final _i3.String? displayName;

  @_i3.override
  _i3.Object? toJson() => {r'id': this.id, r'displayName': this.displayName};

  ListingPractitionerView Function({_i3.String? id, _i3.String? displayName})
  get copyWith {
    const _i3.Object _sentinel = _i3.Object();
    return ({_i3.String? id, _i3.Object? displayName = _sentinel}) =>
        ListingPractitionerView(
          id: id ?? this.id,
          displayName: _i3.identical(displayName, _sentinel)
              ? this.displayName
              : (displayName as _i3.String?),
        );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is ListingPractitionerView &&
        other.id == this.id &&
        other.displayName == this.displayName;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([this.id, this.displayName]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'id'] = _i1.PropertyValue.scalar(this.id);
    if (this.displayName != null) {
      _$result[r'displayName'] = _i1.PropertyValue.scalar(this.displayName!);
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
      r'Cannot uriEncode ListingPractitionerView: complex types cannot be URI-encoded',
    );
  }
}
