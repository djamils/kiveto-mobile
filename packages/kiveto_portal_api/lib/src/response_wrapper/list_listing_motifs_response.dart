// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i2;

import 'package:collection/collection.dart' as _i4;
import 'package:kiveto_portal_api/src/model/listing_motif_view.dart' as _i3;
import 'package:meta/meta.dart' as _i1;

sealed class ListListingMotifsResponse {
  const ListListingMotifsResponse();
}

@_i1.immutable
class ListListingMotifsResponse200 extends ListListingMotifsResponse {
  const ListListingMotifsResponse200({required this.body});

  final _i2.List<_i3.ListingMotifView> body;

  @_i2.override
  _i2.bool operator ==(_i2.Object other) {
    if (_i2.identical(this, other)) return true;
    const _$deepEquals = _i4.DeepCollectionEquality();
    return other is ListListingMotifsResponse200 &&
        _$deepEquals.equals(other.body, this.body);
  }

  @_i2.override
  _i2.int get hashCode {
    const deepEquals = _i4.DeepCollectionEquality();
    return deepEquals.hash(this.body);
  }
}

@_i1.immutable
class ListListingMotifsResponse404 extends ListListingMotifsResponse {
  const ListListingMotifsResponse404();

  @_i2.override
  _i2.bool operator ==(_i2.Object other) {
    if (_i2.identical(this, other)) return true;
    return other is ListListingMotifsResponse404;
  }

  @_i2.override
  _i2.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class ListListingMotifsResponse422 extends ListListingMotifsResponse {
  const ListListingMotifsResponse422();

  @_i2.override
  _i2.bool operator ==(_i2.Object other) {
    if (_i2.identical(this, other)) return true;
    return other is ListListingMotifsResponse422;
  }

  @_i2.override
  _i2.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class ListListingMotifsResponse429 extends ListListingMotifsResponse {
  const ListListingMotifsResponse429();

  @_i2.override
  _i2.bool operator ==(_i2.Object other) {
    if (_i2.identical(this, other)) return true;
    return other is ListListingMotifsResponse429;
  }

  @_i2.override
  _i2.int get hashCode => this.runtimeType.hashCode;
}
