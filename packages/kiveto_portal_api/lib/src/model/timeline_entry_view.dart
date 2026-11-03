// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i6;
import 'dart:core' as _i3;

import 'package:collection/collection.dart' as _i5;
import 'package:kiveto_portal_api/src/model/timeline_document_view.dart' as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class TimelineEntryView extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const TimelineEntryView({
    required this.visitId,
    required this.date,
    required this.vet,
    required this.title,
    required this.documents,
  });

  factory TimelineEntryView.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    throw _i1.SimpleDecodingException(
      r'Simple encoding not supported for TimelineEntryView: contains complex types',
    );
  }

  factory TimelineEntryView.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'TimelineEntryView');
    return TimelineEntryView(
      visitId: _$map[r'visitId'].decodeJsonString(
        context: r'TimelineEntryView.visitId',
      ),
      date: _$map[r'date'].decodeJsonDateTime(
        context: r'TimelineEntryView.date',
      ),
      vet: _$map[r'vet'].decodeJsonNullableString(
        context: r'TimelineEntryView.vet',
      ),
      title: _$map[r'title'].decodeJsonString(
        context: r'TimelineEntryView.title',
      ),
      documents: _$map[r'documents']
          .decodeJsonList<_i3.Object?>(context: r'TimelineEntryView.documents')
          .map(_i4.TimelineDocumentView.fromJson)
          .toList(),
    );
  }

  factory TimelineEntryView.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    throw _i1.FormDecodingException(
      r'Form encoding not supported for TimelineEntryView: contains complex types',
    );
  }

  final _i3.String visitId;

  final _i3.DateTime date;

  final _i3.String? vet;

  final _i3.String title;

  final _i3.List<_i4.TimelineDocumentView> documents;

  @_i3.override
  _i3.Object? toJson() => {
    r'visitId': this.visitId,
    r'date': this.date.toTimeZonedIso8601String(),
    r'vet': this.vet,
    r'title': this.title,
    r'documents': this.documents.map((e) => e.toJson()).toList(),
  };

  TimelineEntryView Function({
    _i3.String? visitId,
    _i3.DateTime? date,
    _i3.String? vet,
    _i3.String? title,
    _i3.List<_i4.TimelineDocumentView>? documents,
  })
  get copyWith {
    const _i3.Object _sentinel = _i3.Object();
    return ({
      _i3.String? visitId,
      _i3.DateTime? date,
      _i3.Object? vet = _sentinel,
      _i3.String? title,
      _i3.List<_i4.TimelineDocumentView>? documents,
    }) => TimelineEntryView(
      visitId: visitId ?? this.visitId,
      date: date ?? this.date,
      vet: _i3.identical(vet, _sentinel) ? this.vet : (vet as _i3.String?),
      title: title ?? this.title,
      documents: documents ?? this.documents,
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    const _$deepEquals = _i5.DeepCollectionEquality();
    return other is TimelineEntryView &&
        other.visitId == this.visitId &&
        other.date == this.date &&
        other.vet == this.vet &&
        other.title == this.title &&
        _$deepEquals.equals(other.documents, this.documents);
  }

  @_i3.override
  _i3.int get hashCode {
    const deepEquals = _i5.DeepCollectionEquality();
    return _i3.Object.hashAll([
      this.visitId,
      this.date,
      this.vet,
      this.title,
      deepEquals.hash(this.documents),
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) => throw _i1.EncodingException(
    r'parameterProperties not supported for TimelineEntryView: contains complex types',
  );

  @_i3.override
  _i3.String uriEncode({
    required _i3.bool allowEmpty,
    required _i6.Encoding textEncoding,
    _i3.bool useQueryComponent = false,
    _i3.bool allowReserved = false,
  }) {
    throw _i1.EncodingException(
      r'Cannot uriEncode TimelineEntryView: complex types cannot be URI-encoded',
    );
  }
}
