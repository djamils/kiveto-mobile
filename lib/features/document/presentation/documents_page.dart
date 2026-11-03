import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiveto_mobile/features/client/client.dart';
import 'package:kiveto_mobile/features/document/domain/document.dart';
import 'package:kiveto_mobile/features/document/presentation/document_card.dart';
import 'package:kiveto_mobile/features/document/presentation/document_messages.dart';
import 'package:kiveto_mobile/features/document/presentation/documents_providers.dart';
import 'package:kiveto_mobile/features/document/presentation/pdf_file_page.dart';
import 'package:kiveto_mobile/features/document/presentation/prescription_sheet.dart';
import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';
import 'package:kiveto_mobile/shared/presentation/async/async_views.dart';
import 'package:kiveto_mobile/shared/presentation/icons/lucide_glyph.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/kit/pills.dart';
import 'package:kiveto_mobile/shared/presentation/kit/surfaces.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_colors.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_layout.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_text.dart';
import 'package:material_ui/material_ui.dart';

/// Screen 5, « Documents publiés » (mockup 05): the documents the active
/// clinic shared, newest first, filtered by type, page after page. A card
/// opens its file in the app (a prescription opens its sheet first); the
/// open button always opens the file.
///
/// Exit: [onRequestRenewal] with a prescription id (screen 17).
class DocumentsPage extends ConsumerStatefulWidget {
  const new({required this.onRequestRenewal, super.key});

  final void Function(BuildContext context, String prescriptionId)
  onRequestRenewal;

  @override
  ConsumerState<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends ConsumerState<DocumentsPage> {
  /// Null: every document.
  DocumentKind? _filter;

  /// The lists that hold [document]: its dot goes from each once it is
  /// read (the lists not loaded yet will read it from the server).
  VoidCallback _onRead(Document document) {
    final lists = [
      for (final kind in <DocumentKind?>{null, document.kind})
        if (ref.exists(documentListProvider(kind)))
          ref.read(documentListProvider(kind).notifier),
    ];
    return () {
      for (final list in lists) {
        list.markRead(document.id);
      }
    };
  }

  void _open(ClinicId clinicId, Document document) => unawaited(
    openDocumentFile(
      context,
      clinicId: clinicId,
      documentId: document.id,
      title: document.title,
      onRead: _onRead(document),
    ),
  );

  void _tap(ClinicId clinicId, Document document) {
    final prescription = document.prescription;
    if (prescription == null) return _open(clinicId, document);
    unawaited(
      showPrescriptionSheet(
        context,
        clinicId: clinicId,
        document: document,
        prescription: prescription,
        onRequestRenewal: widget.onRequestRenewal,
        onRead: _onRead(document),
      ),
    );
  }

  void _retry(Object error) {
    ref.invalidate(documentPetNamesProvider);
    if (error is NotFoundFailure) {
      // The link with the clinic may be gone: /me says which clinics
      // remain, and every filter reloads.
      ref
        ..invalidate(meProvider)
        ..invalidate(documentListProvider);
      return;
    }
    // A failure of /me reaches the list through the active clinic.
    if (ref.read(meProvider).hasError) ref.invalidate(meProvider);
    ref.invalidate(documentListProvider(_filter));
  }

  /// Pull-to-refresh: /me (the badge, the clinics), every filter from its
  /// first page, the pet names; done when the shown list answered.
  Future<void> _refresh() async {
    ref
      ..invalidate(meProvider)
      ..invalidate(documentListProvider)
      ..invalidate(documentPetNamesProvider);
    try {
      await ref.read(documentListProvider(_filter).future);
    } on Object {
      // The page shows the failure.
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final clinic = switch (ref.watch(activeClinicProvider)) {
      AsyncData(:final value) => value,
      _ => null,
    };
    final filter = _filter;
    // Watched here, not only once the list answered: both requests run
    // together.
    final names = ref.watch(documentPetNamesProvider);
    return Scaffold(
      backgroundColor: KivetoColors.canvas,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: KivetoColors.brand,
          onRefresh: _refresh,
          child: CustomScrollView(
            // A short list can be pulled too.
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  KivetoSpace.gutter,
                  KivetoSpace.xl3,
                  KivetoSpace.gutter,
                  KivetoSpace.xl,
                ),
                sliver: SliverList.list(
                  children: [
                    KivetoPageHeader(
                      l10n.screenDocumentsTitle,
                      subtitle: clinic == null
                          ? null
                          : l10n.documentsSubtitle(clinic.name),
                    ),
                    const SizedBox(height: KivetoSpace.xl),
                    Semantics(
                      container: true,
                      label: l10n.documentsFilterGroup,
                      child: Wrap(
                        spacing: KivetoSpace.sm,
                        runSpacing: KivetoSpace.sm,
                        children: [
                          for (final kind in documentFilters)
                            KivetoFilterChip(
                              label: filterLabel(l10n, kind),
                              selected: kind == filter,
                              onSelected: () => setState(() => _filter = kind),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ..._content(l10n, clinic, names),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _content(
    AppLocalizations l10n,
    ClinicLink? clinic,
    AsyncValue<Map<String, String>> names,
  ) {
    Widget fill(Widget child) =>
        SliverFillRemaining(hasScrollBody: false, child: child);
    final filter = _filter;
    switch (ref.watch(documentListProvider(filter))) {
      // A retry after an error: loading, not the error again.
      case AsyncValue(isLoading: true, hasError: true):
        return [fill(const LoadingView())];
      case AsyncData(:final value):
        final clinicId = value.clinicId;
        // An empty page with a next one (rows the server left out) is no
        // empty list: its footer reads on.
        if (clinicId == null ||
            (value.items.isEmpty && value.nextCursor == null)) {
          return [
            fill(
              EmptyState(
                glyph: LucideGlyph.fileText,
                title: emptyTitle(l10n, filter),
                body: clinic == null
                    ? null
                    : l10n.documentsEmptyBody(clinic.name),
              ),
            ),
          ];
        }
        // The names first, so that the meta lines do not change under the
        // eye; without them (a failure), the lines go without names.
        final petNames = switch (names) {
          AsyncData(:final value) => value,
          AsyncError() => const <String, String>{},
          _ => null,
        };
        if (petNames == null) return [fill(const LoadingView())];
        final items = value.items;
        final more = value.nextCursor != null;
        return [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              KivetoSpace.gutter,
              0,
              KivetoSpace.gutter,
              KivetoSpace.xl,
            ),
            sliver: SliverList.separated(
              itemCount: items.length + (more ? 1 : 0),
              separatorBuilder: (context, index) =>
                  const SizedBox(height: KivetoSpace.sm),
              itemBuilder: (context, index) {
                if (index == items.length) {
                  return _MoreFooter(
                    loading: value.loadingMore,
                    failed: value.moreError != null,
                    onLoad: () => unawaited(
                      ref
                          .read(documentListProvider(filter).notifier)
                          .loadMore(),
                    ),
                  );
                }
                final document = items[index];
                final prescription = document.prescription;
                return DocumentCard(
                  key: ValueKey(document.id),
                  document: document,
                  meta: documentMeta(l10n, document, petNames),
                  onTap: () => _tap(clinicId, document),
                  onOpen: () => _open(clinicId, document),
                  onRequestRenewal: () {
                    if (prescription == null) return;
                    widget.onRequestRenewal(context, prescription.id.value);
                  },
                );
              },
            ),
          ),
        ];
      case AsyncError(:final error):
        return [
          fill(
            error is NotFoundFailure
                ? ErrorView(
                    error: error,
                    title: l10n.documentsLinkGoneTitle,
                    message: l10n.documentsLinkGoneBody,
                    onRetry: () => _retry(error),
                  )
                : ErrorView(error: error, onRetry: () => _retry(error)),
          ),
        ];
      default:
        return [fill(const LoadingView())];
    }
  }
}

/// The end of a list with more pages: built as it nears the viewport, it
/// reads the next page; a spinner while it comes, « Impossible de charger
/// la suite. » and a retry when it failed.
class _MoreFooter extends StatefulWidget {
  const new({
    required this.loading,
    required this.failed,
    required this.onLoad,
  });

  final bool loading;
  final bool failed;
  final VoidCallback onLoad;

  @override
  State<_MoreFooter> createState() => _MoreFooterState();
}

class _MoreFooterState extends State<_MoreFooter> {
  @override
  void initState() {
    super.initState();
    _loadWhenIdle();
  }

  @override
  void didUpdateWidget(_MoreFooter oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Also when the list was replaced under a footer kept in place (a
    // reload from the first page after a stale cursor).
    _loadWhenIdle();
  }

  /// Built and neither loading nor failed: read the next page (after the
  /// frame: the list's state changes; `loadMore` ignores a second call).
  void _loadWhenIdle() {
    if (widget.loading || widget.failed) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onLoad();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (widget.failed && !widget.loading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: KivetoSpace.sm),
        child: Column(
          children: [
            Text(
              l10n.documentsMoreError,
              textAlign: TextAlign.center,
              style: KivetoText.bodySmall,
            ),
            const SizedBox(height: KivetoSpace.sm),
            KivetoButton.outline(
              label: l10n.commonRetry,
              size: KivetoButtonSize.small,
              onPressed: widget.onLoad,
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: KivetoSpace.ml),
      child: Center(
        child: SizedBox.square(
          dimension: 24,
          child: CircularProgressIndicator(
            color: KivetoColors.brand,
            strokeWidth: 2.5,
            semanticsLabel: l10n.commonLoading,
          ),
        ),
      ),
    );
  }
}
