import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiveto_mobile/core/di/core_providers.dart';
import 'package:kiveto_mobile/features/client/di.dart';
import 'package:kiveto_mobile/features/client/domain/me.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';

/// The account of the session (`GET /me`), rebuilt on every sign-in and
/// sign-out (`sessionStatusProvider`), never on a token refresh. Signed
/// out, it fails with an [UnauthorizedFailure] without calling the API.
///
/// Read it through `AsyncData` patterns or `AsyncValueView`, never
/// `.value`: while it reloads for another session, `.value` still holds
/// the previous account.
final meProvider = FutureProvider<Me>((ref) {
  if (ref.watch(sessionStatusProvider) == SessionStatus.signedOut) {
    throw const UnauthorizedFailure();
  }
  return ref.watch(meRepositoryProvider).me();
});

/// The clinic the app works on (every `/clinics/{c}` route): the one chosen
/// on this device for this account when it is still a confirmed clinic,
/// else the first confirmed one, else null (`Me.activeClinic`).
final activeClinicProvider =
    AsyncNotifierProvider<ActiveClinicNotifier, ClinicLink?>(
      ActiveClinicNotifier.new,
    );

final class ActiveClinicNotifier extends AsyncNotifier<ClinicLink?> {
  @override
  Future<ClinicLink?> build() async {
    final me = await ref.watch(meProvider.future);
    String? stored;
    try {
      stored = await ref.watch(activeClinicStoreProvider).read(me.account.id);
    } on Object catch (error) {
      // An unreadable store is the default clinic, not an error.
      debugPrint('activeClinic: store unreadable (${error.runtimeType})');
    }
    return me.activeClinic(preferredClinicId: stored);
  }

  /// Makes [clinicId] the active clinic and keeps the choice on this device
  /// (the clinic switcher's API); a clinic that is not a confirmed one of
  /// the account is ignored, and so is a choice without an account (signed
  /// out, `/me` in error).
  Future<void> select(ClinicId clinicId) async {
    final Me me;
    try {
      // After this notifier's own build (its store read would overwrite the
      // choice), for the account it was built for.
      await future;
      me = await ref.read(meProvider.future);
    } on Object {
      return;
    }
    if (!ref.mounted) return;
    final clinic = me.activeClinic(preferredClinicId: clinicId.value);
    if (clinic == null || clinic.clinicId != clinicId) return;
    state = AsyncData(clinic);
    try {
      await ref
          .read(activeClinicStoreProvider)
          .write(me.account.id, clinicId.value);
    } on Object catch (error) {
      // The choice still holds until the app restarts.
      debugPrint('activeClinic: store not written (${error.runtimeType})');
    }
  }
}
