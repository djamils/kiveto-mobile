// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i6;
import 'dart:core' as _i3;

import 'package:collection/collection.dart' as _i5;
import 'package:kiveto_portal_api/src/model/timeline_entry_view.dart' as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class PetTimeline extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const PetTimeline({required this.items, required this.nextCursor});

  factory PetTimeline.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    throw _i1.SimpleDecodingException(
      r'Simple encoding not supported for PetTimeline: contains complex types',
    );
  }

  factory PetTimeline.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'PetTimeline');
    return PetTimeline(
      items: _$map[r'items']
          .decodeJsonList<_i3.Object?>(context: r'PetTimeline.items')
          .map(_i4.TimelineEntryView.fromJson)
          .toList(),
      nextCursor: _$map[r'nextCursor'].decodeJsonNullableString(
        context: r'PetTimeline.nextCursor',
      ),
    );
  }

  factory PetTimeline.fromForm(_i3.String? value, {required _i3.bool explode}) {
    throw _i1.FormDecodingException(
      r'Form encoding not supported for PetTimeline: contains complex types',
    );
  }

  final _i3.List<_i4.TimelineEntryView> items;

  final _i3.String? nextCursor;

  @_i3.override
  _i3.Object? toJson() => {
    r'items': this.items.map((e) => e.toJson()).toList(),
    r'nextCursor': this.nextCursor,
  };

  PetTimeline Function({
    _i3.List<_i4.TimelineEntryView>? items,
    _i3.String? nextCursor,
  })
  get copyWith {
    const _i3.Object _sentinel = _i3.Object();
    return ({
      _i3.List<_i4.TimelineEntryView>? items,
      _i3.Object? nextCursor = _sentinel,
    }) => PetTimeline(
      items: items ?? this.items,
      nextCursor: _i3.identical(nextCursor, _sentinel)
          ? this.nextCursor
          : (nextCursor as _i3.String?),
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    const _$deepEquals = _i5.DeepCollectionEquality();
    return other is PetTimeline &&
        _$deepEquals.equals(other.items, this.items) &&
        other.nextCursor == this.nextCursor;
  }

  @_i3.override
  _i3.int get hashCode {
    const deepEquals = _i5.DeepCollectionEquality();
    return _i3.Object.hashAll([deepEquals.hash(this.items), this.nextCursor]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) => throw _i1.EncodingException(
    r'parameterProperties not supported for PetTimeline: contains complex types',
  );

  @_i3.override
  _i3.String uriEncode({
    required _i3.bool allowEmpty,
    required _i6.Encoding textEncoding,
    _i3.bool useQueryComponent = false,
    _i3.bool allowReserved = false,
  }) {
    throw _i1.EncodingException(
      r'Cannot uriEncode PetTimeline: complex types cannot be URI-encoded',
    );
  }
}
