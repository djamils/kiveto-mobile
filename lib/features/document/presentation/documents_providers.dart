import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart'
    show AsyncNotifierProviderFamily, FutureProviderFamily;
import 'package:kiveto_mobile/core/di/core_providers.dart';
import 'package:kiveto_mobile/features/client/client.dart';
import 'package:kiveto_mobile/features/document/di.dart';
import 'package:kiveto_mobile/features/document/domain/document.dart';
import 'package:kiveto_mobile/features/document/domain/prescription.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';
import 'package:kiveto_mobile/shared/domain/document_kind.dart';

// The state of the documents screen. Every provider belongs to the account:
// each watches the session and only the id of the active clinic
// (`selectAsync` notifies neither while the clinic reloads nor for the same
// id, so invalidating `meProvider` after a read refreshes the badge without
// reloading the list). Read them through `AsyncData` patterns or
// `AsyncValueView`, never `.value`.

/// The documents of the active clinic for one filter (null: every
/// document), page after page; each filter keeps its own list.
final AsyncNotifierProviderFamily<
  DocumentListNotifier,
  DocumentListState,
  DocumentKind?
>
documentListProvider =
    AsyncNotifierProvider.family<
      DocumentListNotifier,
      DocumentListState,
      DocumentKind?
    >(DocumentListNotifier.new);

/// The pages read so far of one filter.
@immutable
final class DocumentListState {
  const new({
    this.clinicId,
    this.items = const [],
    this.nextCursor,
    this.loadingMore = false,
    this.moreError,
  });

  /// No active clinic: nothing to list.
  const new empty() : this();

  /// The clinic the items belong to (null: no active clinic).
  final ClinicId? clinicId;
  final List<Document> items;

  /// Reads the next page; null after the last one.
  final String? nextCursor;

  /// A next page is on its way.
  final bool loadingMore;

  /// Why the last next page failed (the items read so far stay).
  final Object? moreError;
}

final class DocumentListNotifier extends AsyncNotifier<DocumentListState> {
  new(this.kind);

  /// The filter (null: every document).
  final DocumentKind? kind;

  @override
  Future<DocumentListState> build() async {
    ref.watch(sessionStatusProvider);
    final repository = ref.watch(documentRepositoryProvider);
    final clinicId = await ref.watch(
      activeClinicProvider.selectAsync((clinic) => clinic?.clinicId),
    );
    if (clinicId == null) return const DocumentListState.empty();
    final page = await repository.documents(clinicId, kind: kind);
    return DocumentListState(
      clinicId: clinicId,
      items: page.items,
      nextCursor: page.nextCursor,
    );
  }

  /// Reads the next page (nothing on the last page, while a page loads, or
  /// while the list reloads). A failure keeps the items and sets
  /// `moreError`; a `400 cursor_invalid` reloads the list from its first
  /// page.
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
      DocumentListState(
        clinicId: clinicId,
        items: current.items,
        nextCursor: cursor,
        loadingMore: true,
      ),
    );
    try {
      final page = await ref
          .read(documentRepositoryProvider)
          .documents(clinicId, kind: kind, cursor: cursor);
      if (!built.mounted) return;
      if (state case AsyncData(:final value)) {
        state = AsyncData(
          DocumentListState(
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
          DocumentListState(
            clinicId: clinicId,
            items: value.items,
            nextCursor: cursor,
            moreError: error,
          ),
        );
      }
    }
  }

  /// [id] was opened (the server counted the read): its dot goes.
  void markRead(DocumentId id) {
    if (!ref.mounted) return;
    if (state case AsyncData(:final value, isLoading: false)) {
      state = AsyncData(
        DocumentListState(
          clinicId: value.clinicId,
          items: [
            for (final document in value.items)
              if (document.id == id) document.markedRead() else document,
          ],
          nextCursor: value.nextCursor,
          loadingMore: value.loadingMore,
          moreError: value.moreError,
        ),
      );
    }
  }
}

/// The names of the pets of the active clinic, by id, to name the pets of
/// a document. A failure stays an error (the page then shows the meta
/// lines without names; its retry and refresh read them again).
final documentPetNamesProvider = FutureProvider<Map<String, String>>((
  ref,
) async {
  ref.watch(sessionStatusProvider);
  final repository = ref.watch(petNameRepositoryProvider);
  final clinicId = await ref.watch(
    activeClinicProvider.selectAsync((clinic) => clinic?.clinicId),
  );
  if (clinicId == null) return const {};
  return await repository.petNames(clinicId);
});

/// A prescription and its lines (the sheet of the documents screen; the
/// renewal screen of slice 6).
final FutureProviderFamily<Prescription, (ClinicId, PrescriptionId)>
prescriptionProvider = FutureProvider.autoDispose
    .family<Prescription, (ClinicId, PrescriptionId)>((ref, ids) {
      ref.watch(sessionStatusProvider);
      final (clinicId, prescriptionId) = ids;
      return ref
          .watch(documentRepositoryProvider)
          .prescription(clinicId, prescriptionId);
    });
