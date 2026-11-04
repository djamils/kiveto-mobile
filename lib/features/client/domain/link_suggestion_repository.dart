import 'package:kiveto_mobile/features/client/domain/link_suggestion.dart';
import 'package:kiveto_mobile/features/client/domain/me.dart';

/// The clinics' records at the account's phone number (Portal API). Every
/// method throws an `ApiFailure` on a failure.
abstract interface class LinkSuggestionRepository {
  /// The records the server suggests linking, in its order.
  Future<List<LinkSuggestion>> suggestions();

  /// Asks to be linked to the clinic of the suggestion [id]: the link is
  /// then pending until the clinic confirms it (the status the server
  /// answers). A replay of a pending request answers the same.
  Future<LinkStatus> accept(String id);
}
