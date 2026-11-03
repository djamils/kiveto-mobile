/// The clinic chosen on this device, per account (a second account on the
/// same device never inherits it).
abstract interface class ActiveClinicStore {
  /// The clinic id chosen for [accountId], or null.
  Future<String?> read(String accountId);

  /// Keeps [clinicId] as the choice of [accountId].
  Future<void> write(String accountId, String clinicId);
}
