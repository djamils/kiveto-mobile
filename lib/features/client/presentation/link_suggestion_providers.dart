import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiveto_mobile/core/di/core_providers.dart';
import 'package:kiveto_mobile/features/client/di.dart';
import 'package:kiveto_mobile/features/client/domain/link_suggestion.dart';
import 'package:kiveto_mobile/features/client/domain/me.dart';
import 'package:kiveto_mobile/features/client/presentation/client_providers.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';

/// The clinics' records at the account's phone number (screen 10), for the
/// account of the session: rebuilt on every sign-in and sign-out. Signed
/// out, it fails with an [UnauthorizedFailure] without calling the API.
/// Read it through `AsyncData` patterns, never `.value`.
final linkSuggestionsProvider = FutureProvider<List<LinkSuggestion>>((ref) {
  if (ref.watch(sessionStatusProvider) == SessionStatus.signedOut) {
    throw const UnauthorizedFailure();
  }
  return ref.watch(linkSuggestionRepositoryProvider).suggestions();
});

/// Asks to be linked to the clinic of [suggestion] (the owner's tap on
/// « Rattacher ce dossier », nowhere else). Accepted, `/me` lists the
/// clinic as pending and the suggestions are read again; a suggestion no
/// longer offered (`404`) reloads the suggestions too, and the failure is
/// rethrown for the page to say so. [container] is captured before the
/// call: the page may close meanwhile.
Future<void> acceptLinkSuggestion(
  ProviderContainer container,
  LinkSuggestion suggestion,
) async {
  final repository = container.read(linkSuggestionRepositoryProvider);
  try {
    await repository.accept(suggestion.id);
  } on NotFoundFailure {
    container.invalidate(linkSuggestionsProvider);
    rethrow;
  }
  container
    ..invalidate(meProvider)
    ..invalidate(linkSuggestionsProvider);
}

/// Makes the confirmed clinic of the account named [name] (trimmed, case
/// ignored) the active clinic, when exactly one matches; true then. A
/// listing of the directory is not a clinic of the account (other ids):
/// the name is the best effort to book as a known client.
Future<bool> selectConfirmedClinicNamed(
  ProviderContainer container,
  String name,
) async {
  final Me me;
  try {
    me = await container.read(meProvider.future);
  } on Object {
    return false;
  }
  String normalized(String text) => text.trim().toLowerCase();
  final wanted = normalized(name);
  final matches = [
    for (final clinic in me.confirmedClinics)
      if (normalized(clinic.name) == wanted) clinic,
  ];
  if (matches.length != 1) return false;
  await container
      .read(activeClinicProvider.notifier)
      .select(matches.single.clinicId);
  return true;
}
