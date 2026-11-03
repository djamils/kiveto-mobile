import 'package:kiveto_mobile/features/client/domain/me.dart';
import 'package:kiveto_mobile/features/client/domain/profile_update.dart';

/// The account of the session; throws an `ApiFailure` (shared/domain).
abstract interface class MeRepository {
  /// `GET /me`.
  Future<Me> me();

  /// `PATCH /me` (a merge patch): the account as the server stored it; a
  /// refused field is a `ValidationFailure` naming it (`firstName`,
  /// `address.city`…).
  Future<Account> updateProfile(ProfileUpdate update);
}
