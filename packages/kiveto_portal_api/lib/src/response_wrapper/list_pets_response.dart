// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i2;

import 'package:collection/collection.dart' as _i4;
import 'package:kiveto_portal_api/src/model/pet_summary.dart' as _i3;
import 'package:meta/meta.dart' as _i1;

sealed class ListPetsResponse {
  const ListPetsResponse();
}

@_i1.immutable
class ListPetsResponse200 extends ListPetsResponse {
  const ListPetsResponse200({required this.body});

  final _i2.List<_i3.PetSummary> body;

  @_i2.override
  _i2.bool operator ==(_i2.Object other) {
    if (_i2.identical(this, other)) return true;
    const _$deepEquals = _i4.DeepCollectionEquality();
    return other is ListPetsResponse200 &&
        _$deepEquals.equals(other.body, this.body);
  }

  @_i2.override
  _i2.int get hashCode {
    const deepEquals = _i4.DeepCollectionEquality();
    return deepEquals.hash(this.body);
  }
}

@_i1.immutable
class ListPetsResponse401 extends ListPetsResponse {
  const ListPetsResponse401();

  @_i2.override
  _i2.bool operator ==(_i2.Object other) {
    if (_i2.identical(this, other)) return true;
    return other is ListPetsResponse401;
  }

  @_i2.override
  _i2.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class ListPetsResponse404 extends ListPetsResponse {
  const ListPetsResponse404();

  @_i2.override
  _i2.bool operator ==(_i2.Object other) {
    if (_i2.identical(this, other)) return true;
    return other is ListPetsResponse404;
  }

  @_i2.override
  _i2.int get hashCode => this.runtimeType.hashCode;
}
