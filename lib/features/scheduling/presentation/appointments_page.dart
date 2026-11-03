import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiveto_mobile/core/di/core_providers.dart';
import 'package:kiveto_mobile/features/client/client.dart';
import 'package:kiveto_mobile/features/scheduling/domain/appointment.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/appointment_card.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/cancel_appointment_sheet.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/scheduling_messages.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/scheduling_providers.dart';
import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';
import 'package:kiveto_mobile/shared/presentation/async/async_views.dart';
import 'package:kiveto_mobile/shared/presentation/icons/lucide_glyph.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/kit/navigation.dart';
import 'package:kiveto_mobile/shared/presentation/kit/surfaces.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_colors.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_layout.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_text.dart';
import 'package:material_ui/material_ui.dart';

/// Screen 4, « Rendez-vous » (mockup 04): the appointments of the active
/// clinic, « À venir » (from the nearest) and « Passés » (from the most
/// recent, page after page), as C-28 cards; « Annuler » opens the
/// cancellation sheet (16).
///
/// Exits: [onBook] (the round plus button, the empty upcoming tab),
/// [onReschedule] and [onFillQuestionnaire] with an appointment id.
class AppointmentsPage extends ConsumerStatefulWidget {
  const new({
    required this.onBook,
    required this.onReschedule,
    required this.onFillQuestionnaire,
    super.key,
  });

  final void Function(BuildContext context) onBook;
  final void Function(BuildContext context, String appointmentId) onReschedule;
  final void Function(BuildContext context, String appointmentId)
  onFillQuestionnaire;

  @override
  ConsumerState<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends ConsumerState<AppointmentsPage> {
  AppointmentScope _scope = AppointmentScope.upcoming;

  void _retry(Object error) {
    if (failureCause(error) is NotFoundFailure) {
      // The link with the clinic may be gone: /me says which clinics
      // remain, and both lists reload.
      ref
        ..invalidate(meProvider)
        ..invalidate(appointmentListProvider);
      return;
    }
    // A failure of /me reaches the list through the active clinic.
    if (ref.read(meProvider).hasError) ref.invalidate(meProvider);
    ref.invalidate(appointmentListProvider(_scope));
  }

  /// Pull-to-refresh: both lists from their first page; done when the
  /// shown one answered.
  Future<void> _refresh() async {
    ref.invalidate(appointmentListProvider);
    try {
      await ref.read(appointmentListProvider(_scope).future);
    } on Object {
      // The page shows the failure.
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
                  KivetoSpace.xl2,
                ),
                sliver: SliverList.list(
                  children: [
                    KivetoPageHeader(
                      l10n.screenAppointmentsTitle,
                      trailing: KivetoIconButton.fab(
                        glyph: LucideGlyph.plus,
                        semanticLabel: l10n.appointmentsNew,
                        onPressed: () => widget.onBook(context),
                      ),
                    ),
                    const SizedBox(height: KivetoSpace.xl2),
                    KivetoSegmentedControl<AppointmentScope>(
                      segments: [
                        KivetoSegment(
                          AppointmentScope.upcoming,
                          l10n.appointmentsUpcoming,
                        ),
                        KivetoSegment(
                          AppointmentScope.past,
                          l10n.appointmentsPast,
                        ),
                      ],
                      selected: _scope,
                      onChanged: (scope) => setState(() => _scope = scope),
                    ),
                  ],
                ),
              ),
              ..._content(l10n),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _content(AppLocalizations l10n) {
    Widget fill(Widget child) =>
        SliverFillRemaining(hasScrollBody: false, child: child);
    final scope = _scope;
    switch (ref.watch(appointmentListProvider(scope))) {
      // A retry after an error: loading, not the error again.
      case AsyncValue(isLoading: true, hasError: true):
        return [fill(const LoadingView())];
      case AsyncData(:final value):
        final clinicId = value.clinicId;
        // An empty page with a next one is no empty list: its footer reads
        // on.
        if (clinicId == null ||
            (value.items.isEmpty && value.nextCursor == null)) {
          return [fill(_empty(l10n, scope))];
        }
        final clinic = switch (ref.watch(activeClinicProvider)) {
          AsyncData(:final value?) when value.clinicId == clinicId => value,
          _ => null,
        };
        final now = ref.watch(clockProvider).now();
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
                  const SizedBox(height: KivetoSpace.xl2),
              itemBuilder: (context, index) {
                if (index == items.length) {
                  return _MoreFooter(
                    loading: value.loadingMore,
                    failed: value.moreError != null,
                    onLoad: () => unawaited(
                      ref
                          .read(appointmentListProvider(scope).notifier)
                          .loadMore(),
                    ),
                  );
                }
                final appointment = items[index];
                return AppointmentCard(
                  key: ValueKey((scope, appointment.id)),
                  appointment: appointment,
                  upcoming: scope == AppointmentScope.upcoming,
                  now: now,
                  clinicName: clinic?.name,
                  onReschedule: () =>
                      widget.onReschedule(context, appointment.id.value),
                  onCancel: () => _cancel(clinicId, appointment),
                  onFillQuestionnaire: () =>
                      widget.onFillQuestionnaire(context, appointment.id.value),
                  onAddToCalendar: () => unawaited(
                    shareAppointmentCalendar(
                      context,
                      ref,
                      clinicId: clinicId,
                      appointment: appointment,
                    ),
                  ),
                );
              },
            ),
          ),
        ];
      case AsyncError(:final error):
        return [
          fill(
            failureCause(error) is NotFoundFailure
                ? ErrorView(
                    error: error,
                    title: l10n.appointmentsClinicGoneTitle,
                    message: l10n.appointmentsClinicGoneBody,
                    onRetry: () => _retry(error),
                  )
                : ErrorView(error: error, onRetry: () => _retry(error)),
          ),
        ];
      default:
        return [fill(const LoadingView())];
    }
  }

  void _cancel(ClinicId clinicId, Appointment appointment) => unawaited(
    showCancelAppointmentSheet(
      context,
      appointment,
      clinicId: clinicId,
      onReschedule: () => widget.onReschedule(context, appointment.id.value),
    ),
  );

  Widget _empty(AppLocalizations l10n, AppointmentScope scope) =>
      switch (scope) {
        AppointmentScope.upcoming => EmptyState(
          glyph: LucideGlyph.calendar,
          title: l10n.appointmentsEmptyUpcomingTitle,
          action: KivetoButton.primary(
            label: l10n.appointmentsBook,
            size: KivetoButtonSize.small,
            onPressed: () => widget.onBook(context),
          ),
        ),
        AppointmentScope.past => EmptyState(
          glyph: LucideGlyph.calendar,
          title: l10n.appointmentsEmptyPastTitle,
        ),
      };
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
              l10n.appointmentsMoreError,
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
