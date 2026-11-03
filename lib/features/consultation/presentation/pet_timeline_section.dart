import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiveto_mobile/features/client/client.dart';
import 'package:kiveto_mobile/features/consultation/domain/timeline.dart';
import 'package:kiveto_mobile/features/consultation/presentation/timeline_providers.dart';
import 'package:kiveto_mobile/features/document/document.dart';
import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/presentation/async/async_views.dart';
import 'package:kiveto_mobile/shared/presentation/formatters/kiveto_format.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/kit/pills.dart';
import 'package:kiveto_mobile/shared/presentation/kit/surfaces.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_colors.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_layout.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_text.dart';
import 'package:material_ui/material_ui.dart';

/// « Historique » of the pet sheet (mockup 02, C-32): the visits of
/// [petId] whose report the clinic shared, newest first, page after page.
/// A sliver (place it in a `CustomScrollView`): the next page is read when
/// the end of the list nears the viewport. A document chip opens the file
/// in the app.
class PetTimelineSection extends ConsumerWidget {
  const new({required this.petId, super.key});

  final String petId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final provider = petTimelineProvider(petId);
    void retry() {
      // A failure of /me reaches the list through the active clinic.
      if (ref.read(meProvider).hasError) ref.invalidate(meProvider);
      ref.invalidate(provider);
    }

    Widget box(Widget child) => SliverToBoxAdapter(child: child);
    const loading = Padding(
      padding: EdgeInsets.symmetric(vertical: KivetoSpace.xl3),
      child: LoadingView(),
    );
    final body = switch (ref.watch(provider)) {
      // A retry after an error: loading, not the error again.
      AsyncValue(isLoading: true, hasError: true) => box(loading),
      AsyncData(:final value) => _entries(context, ref, l10n, value),
      AsyncError(:final error) => box(ErrorView(error: error, onRetry: retry)),
      _ => box(loading),
    };
    return SliverMainAxisGroup(
      slivers: [
        box(
          Padding(
            padding: const EdgeInsets.only(bottom: KivetoSpace.m),
            child: KivetoSectionHeader(l10n.timelineTitle),
          ),
        ),
        body,
      ],
    );
  }

  Widget _entries(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    PetTimelineState state,
  ) {
    final clinicId = state.clinicId;
    final items = state.items;
    if (clinicId == null || (items.isEmpty && state.nextCursor == null)) {
      return SliverToBoxAdapter(
        child: Text(l10n.timelineEmpty, style: KivetoText.bodySmall),
      );
    }
    final more = state.nextCursor != null;
    return SliverList.builder(
      itemCount: items.length + (more ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == items.length) {
          return _MoreFooter(
            loading: state.loadingMore,
            failed: state.moreError != null,
            onLoad: () => unawaited(
              ref.read(petTimelineProvider(petId).notifier).loadMore(),
            ),
          );
        }
        return TimelineItem(
          key: ValueKey(items[index].visitId),
          entry: items[index],
          latest: index == 0,
          last: index == items.length - 1 && !more,
          onOpen: (document) => unawaited(
            openDocumentFile(
              context,
              clinicId: clinicId,
              documentId: DocumentId(document.id),
              title: [
                documentKindName(l10n, document.kind),
                items[index].title,
              ].join(' · '),
            ),
          ),
        );
      },
    );
  }
}

/// One visit of the timeline (C-32): the rail (a dot, brand for the
/// [latest] visit, and a line down to the next one unless [last]), the date
/// and the vet, the title, the document chips.
class TimelineItem extends StatelessWidget {
  const new({
    required this.entry,
    required this.latest,
    required this.last,
    required this.onOpen,
    super.key,
  });

  final TimelineEntry entry;
  final bool latest;
  final bool last;
  final void Function(TimelineDocument document) onOpen;

  static const double _rail = 12;
  static const double _dotTop = 4;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vet = entry.vet;
    return Stack(
      children: [
        if (!last)
          const Positioned(
            left: (_rail - 2) / 2,
            top: _dotTop + _rail,
            bottom: 0,
            child: SizedBox(
              width: 2,
              child: ColoredBox(color: KivetoColors.timelineLine),
            ),
          ),
        Positioned(
          left: 0,
          top: _dotTop,
          child: Container(
            width: _rail,
            height: _rail,
            decoration: BoxDecoration(
              color: latest ? KivetoColors.brand : KivetoColors.timelineDot,
              shape: BoxShape.circle,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            left: _rail + KivetoSpace.l,
            bottom: last ? 0 : KivetoSpace.xl2,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                [
                  KivetoFormat.dayMonthYearLong(entry.date),
                  if (vet != null && vet.trim().isNotEmpty) vet,
                ].join(' · '),
                style: KivetoText.captionStrong,
              ),
              const SizedBox(height: KivetoSpace.s),
              Text(entry.title, style: KivetoText.itemTitle),
              const SizedBox(height: KivetoSpace.s),
              if (entry.documents.isEmpty)
                Text(l10n.timelineNoDocument, style: KivetoText.bodySmall)
              else
                Wrap(
                  spacing: KivetoSpace.sm,
                  runSpacing: KivetoSpace.sm,
                  children: [
                    for (final document in entry.documents)
                      KivetoDocumentChip(
                        label: documentKindName(l10n, document.kind),
                        onPressed: () => onOpen(document),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The end of a timeline with more pages: built as it nears the viewport,
/// it reads the next page; a spinner while it comes, « Impossible de
/// charger la suite. » and a retry when it failed.
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
              l10n.timelineMoreError,
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
