// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i4;
import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

/// A motif the owner may book online; the route answers a plain JSON array of them.
@_i2.immutable
class BookingMotifView extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const BookingMotifView({
    required this.id,
    required this.label,
    required this.description,
    required this.durationMin,
    required this.suggested,
    required this.suggestionReason,
  });

  factory BookingMotifView.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {
        r'id',
        r'label',
        r'description',
        r'durationMin',
        r'suggested',
        r'suggestionReason',
      },
      listKeys: {},
      context: r'BookingMotifView',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return BookingMotifView(
      id: _$values[r'id'].decodeSimpleString(context: r'BookingMotifView.id'),
      label: _$values[r'label'].decodeSimpleString(
        context: r'BookingMotifView.label',
      ),
      description: _$values[r'description'].decodeSimpleNullableString(
        context: r'BookingMotifView.description',
      ),
      durationMin: _$values[r'durationMin'].decodeSimpleInt(
        context: r'BookingMotifView.durationMin',
      ),
      suggested: _$values[r'suggested'].decodeSimpleBool(
        context: r'BookingMotifView.suggested',
      ),
      suggestionReason: _$values[r'suggestionReason']
          .decodeSimpleNullableString(
            context: r'BookingMotifView.suggestionReason',
          ),
    );
  }

  factory BookingMotifView.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'BookingMotifView');
    return BookingMotifView(
      id: _$map[r'id'].decodeJsonString(context: r'BookingMotifView.id'),
      label: _$map[r'label'].decodeJsonString(
        context: r'BookingMotifView.label',
      ),
      description: _$map[r'description'].decodeJsonNullableString(
        context: r'BookingMotifView.description',
      ),
      durationMin: _$map[r'durationMin'].decodeJsonInt(
        context: r'BookingMotifView.durationMin',
      ),
      suggested: _$map[r'suggested'].decodeJsonBool(
        context: r'BookingMotifView.suggested',
      ),
      suggestionReason: _$map[r'suggestionReason'].decodeJsonNullableString(
        context: r'BookingMotifView.suggestionReason',
      ),
    );
  }

  factory BookingMotifView.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {
        r'id',
        r'label',
        r'description',
        r'durationMin',
        r'suggested',
        r'suggestionReason',
      },
      listKeys: {},
      context: r'BookingMotifView',
    );
    return BookingMotifView(
      id: _$values[r'id'].decodeFormString(context: r'BookingMotifView.id'),
      label: _$values[r'label'].decodeFormString(
        context: r'BookingMotifView.label',
      ),
      description: _$values[r'description'].decodeFormNullableString(
        context: r'BookingMotifView.description',
      ),
      durationMin: _$values[r'durationMin'].decodeFormInt(
        context: r'BookingMotifView.durationMin',
      ),
      suggested: _$values[r'suggested'].decodeFormBool(
        context: r'BookingMotifView.suggested',
      ),
      suggestionReason: _$values[r'suggestionReason'].decodeFormNullableString(
        context: r'BookingMotifView.suggestionReason',
      ),
    );
  }

  final _i3.String id;

  final _i3.String label;

  final _i3.String? description;

  final _i3.int durationMin;

  final _i3.bool suggested;

  /// « Rappel de vaccin en retard », « Rappel de vaccin à prévoir »…, null when not suggested.
  final _i3.String? suggestionReason;

  @_i3.override
  _i3.Object? toJson() => {
    r'id': this.id,
    r'label': this.label,
    r'description': this.description,
    r'durationMin': this.durationMin,
    r'suggested': this.suggested,
    r'suggestionReason': this.suggestionReason,
  };

  BookingMotifView Function({
    _i3.String? id,
    _i3.String? label,
    _i3.String? description,
    _i3.int? durationMin,
    _i3.bool? suggested,
    _i3.String? suggestionReason,
  })
  get copyWith {
    const _i3.Object _sentinel = _i3.Object();
    return ({
      _i3.String? id,
      _i3.String? label,
      _i3.Object? description = _sentinel,
      _i3.int? durationMin,
      _i3.bool? suggested,
      _i3.Object? suggestionReason = _sentinel,
    }) => BookingMotifView(
      id: id ?? this.id,
      label: label ?? this.label,
      description: _i3.identical(description, _sentinel)
          ? this.description
          : (description as _i3.String?),
      durationMin: durationMin ?? this.durationMin,
      suggested: suggested ?? this.suggested,
      suggestionReason: _i3.identical(suggestionReason, _sentinel)
          ? this.suggestionReason
          : (suggestionReason as _i3.String?),
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is BookingMotifView &&
        other.id == this.id &&
        other.label == this.label &&
        other.description == this.description &&
        other.durationMin == this.durationMin &&
        other.suggested == this.suggested &&
        other.suggestionReason == this.suggestionReason;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([
      this.id,
      this.label,
      this.description,
      this.durationMin,
      this.suggested,
      this.suggestionReason,
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'id'] = _i1.PropertyValue.scalar(this.id);
    _$result[r'label'] = _i1.PropertyValue.scalar(this.label);
    if (this.description != null) {
      _$result[r'description'] = _i1.PropertyValue.scalar(this.description!);
    }
    _$result[r'durationMin'] = _i1.PropertyValue.scalar(
      this.durationMin.toString(),
    );
    _$result[r'suggested'] = _i1.PropertyValue.scalar(
      this.suggested.toString(),
    );
    if (this.suggestionReason != null) {
      _$result[r'suggestionReason'] = _i1.PropertyValue.scalar(
        this.suggestionReason!,
      );
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
      r'Cannot uriEncode BookingMotifView: complex types cannot be URI-encoded',
    );
  }
}
