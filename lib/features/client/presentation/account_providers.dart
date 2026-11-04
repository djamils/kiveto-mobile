import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show AsyncNotifierProviderFamily;
import 'package:kiveto_mobile/core/di/core_providers.dart';
import 'package:kiveto_mobile/features/client/di.dart';
import 'package:kiveto_mobile/features/client/domain/consent.dart';
import 'package:kiveto_mobile/features/client/domain/data_export.dart';
import 'package:kiveto_mobile/features/client/presentation/client_providers.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';
import 'package:kiveto_mobile/shared/domain/portal_file.dart';
import 'package:share_plus/share_plus.dart';

// The state of the account screen (6). Every provider belongs to the
// account: each watches the session (and the consents only the id of the
// active clinic: `selectAsync` notifies neither while `/me` reloads nor for
// the same id). Read them through `AsyncData` patterns or `AsyncValueView`,
// never `.value`.

/// The consents of the account in the active clinic; null without an
/// active clinic. [ConsentsNotifier.setChannel] changes one channel of one
/// kind.
final consentsProvider =
    AsyncNotifierProvider<ConsentsNotifier, ConsentsState?>(
      ConsentsNotifier.new,
    );

/// The consents of one clinic, and the kinds whose change is on its way.
@immutable
final class ConsentsState {
  const new({
    required this.clinicId,
    required this.consents,
    this.saving = const {},
  });

  final ClinicId clinicId;

  /// As shown: a kind being saved shows the change asked for.
  final ClinicConsents consents;

  /// The kinds whose change the server has not answered yet.
  final Set<ConsentKind> saving;
}

final class ConsentsNotifier extends AsyncNotifier<ConsentsState?> {
  @override
  Future<ConsentsState?> build() async {
    ref.watch(sessionStatusProvider);
    final repository = ref.watch(consentRepositoryProvider);
    final clinicId = await ref.watch(
      activeClinicProvider.selectAsync((clinic) => clinic?.clinicId),
    );
    if (clinicId == null) return null;
    return ConsentsState(
      clinicId: clinicId,
      consents: await repository.consents(clinicId),
    );
  }

  /// Turns [channel] of [kind] on ([enabled]) or off: shown at once, the
  /// kind's tiles disabled until the server answers; then the consents the
  /// server stored (the kinds still being saved keep the change asked
  /// for), and `GET /me` reloads. A refusal puts the kind back as it was
  /// and is rethrown (a `409 conflict` reloads every consent first). An
  /// answer for a clinic or a session the state no longer shows is
  /// dropped. Nothing while the consents load, or while [kind] is saved.
  Future<void> setChannel(
    ConsentKind kind,
    ConsentChannel channel, {
    required bool enabled,
  }) async {
    final current = switch (state) {
      AsyncData(value: final value?, isLoading: false) => value,
      _ => null,
    };
    final before = current?.consents.of(kind);
    if (current == null || before == null || current.saving.contains(kind)) {
      return;
    }
    final asked = before.withChannel(channel, on: enabled);
    final clinicId = current.clinicId;
    // A rebuild meanwhile (another session or clinic, a reload) gives the
    // notifier a new ref: the answer for this one is dropped.
    final built = ref;
    state = AsyncData(
      ConsentsState(
        clinicId: clinicId,
        consents: current.consents.replacing(asked),
        saving: {...current.saving, kind},
      ),
    );
    try {
      final stored = await ref
          .read(consentRepositoryProvider)
          .update(clinicId, kind, asked.channels);
      if (built.mounted) {
        if (state case AsyncData(value: final value?)
            when value.clinicId == clinicId) {
          final saving = {...value.saving}..remove(kind);
          var consents = stored;
          for (final other in saving) {
            if (value.consents.of(other) case final pending?) {
              consents = consents.replacing(pending);
            }
          }
          state = AsyncData(
            ConsentsState(
              clinicId: clinicId,
              consents: consents,
              saving: saving,
            ),
          );
        }
      }
      // Stored whatever the state shows now: the account follows.
      if (ref.mounted) ref.invalidate(meProvider);
    } on Object catch (error) {
      if (built.mounted) {
        if (error is ConflictFailure) {
          ref.invalidateSelf();
        } else if (state case AsyncData(value: final value?)
            when value.clinicId == clinicId) {
          state = AsyncData(
            ConsentsState(
              clinicId: clinicId,
              consents: value.consents.replacing(before),
              saving: {...value.saving}..remove(kind),
            ),
          );
        }
      }
      rethrow;
    }
  }
}

/// The consent history of a clinic, page after page (the history sheet).
final AsyncNotifierProviderFamily<
  ConsentHistoryNotifier,
  ConsentHistoryState,
  ClinicId
>
consentHistoryProvider = AsyncNotifierProvider.autoDispose
    .family<ConsentHistoryNotifier, ConsentHistoryState, ClinicId>(
      ConsentHistoryNotifier.new,
    );

/// The pages of the history read so far.
@immutable
final class ConsentHistoryState {
  const new({
    this.items = const [],
    this.nextCursor,
    this.loadingMore = false,
    this.moreError,
  });

  final List<ConsentHistoryEntry> items;

  /// Reads the next page; null after the last one.
  final String? nextCursor;

  /// A next page is on its way.
  final bool loadingMore;

  /// Why the last next page failed (the items read so far stay).
  final Object? moreError;
}

final class ConsentHistoryNotifier extends AsyncNotifier<ConsentHistoryState> {
  new(this.clinicId);

  final ClinicId clinicId;

  @override
  Future<ConsentHistoryState> build() async {
    ref.watch(sessionStatusProvider);
    final page = await ref.watch(consentRepositoryProvider).history(clinicId);
    return ConsentHistoryState(items: page.items, nextCursor: page.nextCursor);
  }

  /// Reads the next page (nothing on the last page, while a page loads, or
  /// while the history reloads); a failure keeps the items and sets
  /// `moreError`.
  Future<void> loadMore() async {
    final current = switch (state) {
      AsyncData(:final value, isLoading: false) => value,
      _ => null,
    };
    final cursor = current?.nextCursor;
    if (current == null || cursor == null || current.loadingMore) return;
    final built = ref;
    state = AsyncData(
      ConsentHistoryState(
        items: current.items,
        nextCursor: cursor,
        loadingMore: true,
      ),
    );
    try {
      final page = await ref
          .read(consentRepositoryProvider)
          .history(clinicId, cursor: cursor);
      if (!built.mounted) return;
      state = AsyncData(
        ConsentHistoryState(
          items: [...current.items, ...page.items],
          nextCursor: page.nextCursor,
        ),
      );
    } on Object catch (error) {
      if (!built.mounted) return;
      state = AsyncData(
        ConsentHistoryState(
          items: current.items,
          nextCursor: cursor,
          moreError: error,
        ),
      );
    }
  }
}

/// The data exports of the account (the export sheet), newest first.
final FutureProvider<List<DataExport>> dataExportsProvider =
    FutureProvider.autoDispose<List<DataExport>>((ref) {
      if (ref.watch(sessionStatusProvider) == SessionStatus.signedOut) {
        throw const UnauthorizedFailure();
      }
      return ref.watch(dataExportRepositoryProvider).exports();
    });

/// Hands an export's ZIP to the system share sheet (a seam for the tests:
/// share_plus talks to the platform), as `kiveto-export.zip` when the
/// server named none.
final dataExportSharerProvider =
    Provider<Future<void> Function(PortalFile file)>(
      (ref) => (file) async {
        await SharePlus.instance.share(
          ShareParams(
            files: [
              XFile.fromData(
                Uint8List.fromList(file.bytes),
                mimeType: 'application/zip',
              ),
            ],
            fileNameOverrides: [file.fileName ?? 'kiveto-export.zip'],
          ),
        );
      },
    );
