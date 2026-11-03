import 'package:kiveto_mobile/features/identity_access/domain/terms.dart';

/// The terms of use of the Portal API; throws an `ApiFailure`.
abstract interface class TermsRepository {
  /// `GET /legal/terms/current`.
  Future<Terms> current();
}
