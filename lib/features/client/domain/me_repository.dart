import 'package:kiveto_mobile/features/client/domain/me.dart';

/// The account of the session; throws an `ApiFailure` (shared/domain).
abstract interface class MeRepository {
  /// `GET /me`.
  Future<Me> me();
}
