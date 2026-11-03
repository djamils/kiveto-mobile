import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:kiveto_mobile/app/routing/shell_seams.dart';
import 'package:kiveto_mobile/features/client/client.dart';

/// The shell seams, filled by the slices (`ProviderScope.overrides`).
///
/// Each reads its account provider through an `AsyncData` pattern: while
/// `GET /me` loads for a new session, the seams are unknown (null, 0),
/// never the previous account's values.
List<Override> featureOverrides() => [
  hasConfirmedClinicProvider.overrideWith(
    (ref) => switch (ref.watch(meProvider)) {
      AsyncData(:final value) => value.hasConfirmedClinic,
      _ => null,
    },
  ),
  accountInitialsProvider.overrideWith(
    (ref) => switch (ref.watch(meProvider)) {
      AsyncData(:final value) => value.account.initials,
      _ => null,
    },
  ),
  unreadDocumentsCountProvider.overrideWith(
    (ref) => switch (ref.watch(activeClinicProvider)) {
      AsyncData(value: final clinic?) => clinic.unreadDocuments,
      _ => 0,
    },
  ),
];
