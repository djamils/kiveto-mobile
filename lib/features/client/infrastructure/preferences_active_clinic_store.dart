import 'package:kiveto_mobile/features/client/domain/active_clinic_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// [ActiveClinicStore] in the platform preferences, one key per account:
/// `client.activeClinic.<accountId>` (an id, not a secret).
///
/// The preferences are opened at the first use, so that an unavailable
/// platform fails that call (the caller falls back to the default clinic)
/// rather than the construction.
final class PreferencesActiveClinicStore implements ActiveClinicStore {
  new(this._open);

  final SharedPreferencesAsync Function() _open;
  late final SharedPreferencesAsync _preferences = _open();

  static String keyOf(String accountId) => 'client.activeClinic.$accountId';

  @override
  Future<String?> read(String accountId) async {
    final clinicId = await _preferences.getString(keyOf(accountId));
    return clinicId;
  }

  @override
  Future<void> write(String accountId, String clinicId) async {
    await _preferences.setString(keyOf(accountId), clinicId);
  }
}
