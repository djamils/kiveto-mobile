import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show AsyncNotifierProviderFamily;
import 'package:kiveto_mobile/core/di/core_providers.dart';
import 'package:kiveto_mobile/features/client/client.dart';
import 'package:kiveto_mobile/features/consultation/di.dart';
import 'package:kiveto_mobile/features/consultation/domain/timeline.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';

/// The visits of a pet (its id) in the active clinic, page after page. It
/// belongs to the account: it watches the session and only the id of the
/// active clinic. Read it through `AsyncData` patterns, never `.value`.
final AsyncNotifierProviderFamily<PetTimelineNotifier, PetTimelineState, String>
petTimelineProvider =
    AsyncNotifierProvider.family<PetTimelineNotifier, PetTimelineState, String>(
      PetTimelineNotifier.new,
    );

/// The pages of a pet's visits read so far.
@immutable
final class PetTimelineState {
  const new({
    this.clinicId,
    this.items = const [],
    this.nextCursor,
    this.loadingMore = false,
    this.moreError,
  });

  /// No active clinic: nothing to list.
  const new empty() : this();

  /// The clinic the visits belong to (null: no active clinic).
  final ClinicId? clinicId;
  final List<TimelineEntry> items;

  /// Reads the next page; null after the last one.
  final String? nextCursor;

  /// A next page is on its way.
  final bool loadingMore;

  /// Why the last next page failed (the visits read so far stay).
  final Object? moreError;
}

final class PetTimelineNotifier extends AsyncNotifier<PetTimelineState> {
  new(this.petId);

  final String petId;

  @override
  Future<PetTimelineState> build() async {
    ref.watch(sessionStatusProvider);
    final repository = ref.watch(timelineRepositoryProvider);
    final clinicId = await ref.watch(
      activeClinicProvider.selectAsync((clinic) => clinic?.clinicId),
    );
    if (clinicId == null) return const PetTimelineState.empty();
    final page = await repository.timeline(clinicId, petId);
    return PetTimelineState(
      clinicId: clinicId,
      items: page.items,
      nextCursor: page.nextCursor,
    );
  }

  /// Reads the next page (nothing on the last page, while a page loads, or
  /// while the list reloads). A failure keeps the visits and sets
  /// `moreError`; a `400 cursor_invalid` reloads from the first page.
  Future<void> loadMore() async {
    final current = switch (state) {
      AsyncData(:final value, isLoading: false) => value,
      _ => null,
    };
    final clinicId = current?.clinicId;
    final cursor = current?.nextCursor;
    if (current == null ||
        clinicId == null ||
        cursor == null ||
        current.loadingMore) {
      return;
    }
    // A rebuild meanwhile (another session or clinic, a reload) gives the
    // notifier a new ref: the answer for this one is dropped.
    final built = ref;
    state = AsyncData(
      PetTimelineState(
        clinicId: clinicId,
        items: current.items,
        nextCursor: cursor,
        loadingMore: true,
      ),
    );
    try {
      final page = await ref
          .read(timelineRepositoryProvider)
          .timeline(clinicId, petId, cursor: cursor);
      if (!built.mounted) return;
      if (state case AsyncData(:final value)) {
        state = AsyncData(
          PetTimelineState(
            clinicId: clinicId,
            items: [...value.items, ...page.items],
            nextCursor: page.nextCursor,
          ),
        );
      }
    } on Object catch (error) {
      if (!built.mounted) return;
      if (error case BusinessFailure(code: 'cursor_invalid')) {
        ref.invalidateSelf();
        return;
      }
      if (state case AsyncData(:final value)) {
        state = AsyncData(
          PetTimelineState(
            clinicId: clinicId,
            items: value.items,
            nextCursor: cursor,
            moreError: error,
          ),
        );
      }
    }
  }
}
