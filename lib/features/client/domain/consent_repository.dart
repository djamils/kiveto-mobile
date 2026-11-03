import 'package:kiveto_mobile/features/client/domain/consent.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';

/// The consents of the account in a clinic; throws an `ApiFailure`
/// (shared/domain). The server decides every rule (a `channelPreference`
/// kind keeps one channel at least: `422 validation_failed`; a concurrent
/// change: `409 conflict`).
abstract interface class ConsentRepository {
  /// `GET /clinics/{c}/consents`.
  Future<ClinicConsents> consents(ClinicId clinicId);

  /// `PUT /clinics/{c}/consents/{kind}`: [kind] on exactly [channels]
  /// (empty: withdrawn); the consents as the server stored them. An
  /// [ConsentKind.unknown] kind is an [ArgumentError] (no request).
  Future<ClinicConsents> update(
    ClinicId clinicId,
    ConsentKind kind,
    Set<ConsentChannel> channels,
  );

  /// `GET /clinics/{c}/consents/history`, from [cursor] (null: the first
  /// page).
  Future<ConsentHistoryPage> history(ClinicId clinicId, {String? cursor});
}
