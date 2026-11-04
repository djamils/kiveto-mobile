/// What made the server suggest a clinic's record: the account's phone
/// number, or a reason this app does not know yet.
enum LinkMatch { phone, unknown }

/// A clinic that has a record at the account's phone number (screen 10):
/// the owner may ask to be linked to it (`POST …/accept`); the clinic then
/// confirms the link.
final class LinkSuggestion {
  const new({
    required this.id,
    required this.clinicName,
    required this.matchedOn,
    this.clinicCity,
  });

  /// The suggestion's id, as the server sends it (opaque).
  final String id;
  final String clinicName;
  final String? clinicCity;
  final LinkMatch matchedOn;

  @override
  String toString() => 'LinkSuggestion($id, $clinicName)';
}
