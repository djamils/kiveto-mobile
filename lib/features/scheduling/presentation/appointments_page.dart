import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiveto_mobile/core/di/core_providers.dart';
import 'package:kiveto_mobile/features/client/client.dart';
import 'package:kiveto_mobile/features/scheduling/domain/appointment.dart';
import 'package:kiveto_mobile/features/scheduling/domain/appointment_request.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/appointment_card.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/appointment_request_card.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/cancel_appointment_sheet.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/scheduling_messages.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/scheduling_providers.dart';
import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';
import 'package:kiveto_mobile/shared/presentation/async/async_views.dart';
import 'package:kiveto_mobile/shared/presentation/async/more_footer.dart';
import 'package:kiveto_mobile/shared/presentation/icons/lucide_glyph.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/kit/feedback.dart';
import 'package:kiveto_mobile/shared/presentation/kit/navigation.dart';
import 'package:kiveto_mobile/shared/presentation/kit/surfaces.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_colors.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_layout.dart';
import 'package:material_ui/material_ui.dart';

/// Screen 4, « Rendez-vous » (mockup 04): the account's booking requests as
/// a new client (« Demandes de rendez-vous », those still pending or
/// declined, in the tab of their slot), then the appointments of the
/// active clinic, « À venir » (from the nearest) and « Passés » (from the
/// most recent, page after page), as C-28 cards; « Annuler » opens the
/// cancellation sheet (16). Without an active clinic: the requests, then
/// « Aucune clinique rattachée » and no plus button.
///
/// Exits: [onBook] (the round plus button, the empty upcoming tab),
/// [onReschedule] and [onFillQuestionnaire] with an appointment id,
/// [onFindClinic] (no clinic: the clinic search).
class AppointmentsPage extends ConsumerStatefulWidget {
  const new({
    required this.onBook,
    required this.onReschedule,
    required this.onFillQuestionnaire,
    required this.onFindClinic,
    super.key,
  });

  final void Function(BuildContext context) onBook;
  final void Function(BuildContext context, String appointmentId) onReschedule;
  final void Function(BuildContext context, String appointmentId)
  onFillQuestionnaire;
  final void Function(BuildContext context) onFindClinic;

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

  /// Pull-to-refresh: `/me` (a link or a request the clinic confirmed
  /// since), the requests, both lists from their first page; done when the
  /// shown one answered.
  Future<void> _refresh() async {
    ref
      ..invalidate(meProvider)
      ..invalidate(appointmentRequestsProvider)
      ..invalidate(appointmentListProvider);
    try {
      await ref.read(appointmentListProvider(_scope).future);
    } on Object {
      // The page shows the failure.
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // No plus button once it is known there is no clinic to book in.
    final noClinic = switch (ref.watch(activeClinicProvider)) {
      AsyncData(value: null) => true,
      _ => false,
    };
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
                      trailing: noClinic
                          ? null
                          : KivetoIconButton.fab(
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
              ..._requests(l10n),
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
        if (clinicId == null) return [fill(_noClinic(l10n))];
        if (value.items.isEmpty && value.nextCursor == null) {
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
                  return MoreFooter(
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
                  onAddToCalendar: (origin) => unawaited(
                    shareAppointmentCalendar(
                      context,
                      ref,
                      clinicId: clinicId,
                      appointment: appointment,
                      origin: origin,
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

  /// The requests of the tab shown (« Demandes de rendez-vous »), before the
  /// appointments: none while they load; their failure in their place, the
  /// appointments unaffected.
  List<Widget> _requests(AppLocalizations l10n) {
    Widget section(List<Widget> children) => SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        KivetoSpace.gutter,
        0,
        KivetoSpace.gutter,
        KivetoSpace.xl2,
      ),
      sliver: SliverList.list(children: children),
    );
    switch (ref.watch(appointmentRequestsProvider)) {
      case AsyncValue(isLoading: true, hasError: true):
        return const [];
      case AsyncData(:final value):
        // A confirmed request of the active clinic shows as its appointment.
        final active = switch (ref.watch(activeClinicProvider)) {
          AsyncData(:final value) => value?.name,
          _ => null,
        };
        final shown = requestsFor(
          _scope,
          value,
          ref.watch(clockProvider).now(),
          activeClinicName: active,
        );
        if (shown.isEmpty) return const [];
        return [
          section([
            KivetoSectionHeader(l10n.appointmentRequestsTitle),
            for (final request in shown) ...[
              const SizedBox(height: KivetoSpace.m),
              AppointmentRequestCard(
                key: ValueKey((_scope, request.id)),
                request: request,
              ),
            ],
          ]),
        ];
      case AsyncError():
        return [
          section([
            KivetoCallout.danger(
              body: l10n.appointmentRequestsError,
              actionLabel: l10n.commonRetry,
              onAction: () => ref.invalidate(appointmentRequestsProvider),
            ),
          ]),
        ];
      default:
        return const [];
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

  Widget _noClinic(AppLocalizations l10n) => EmptyState(
    glyph: LucideGlyph.calendar,
    title: l10n.noClinicTitle,
    body: l10n.noClinicAppointmentsBody,
    action: KivetoButton.primary(
      label: l10n.screenClinicsTitle,
      size: KivetoButtonSize.small,
      onPressed: () => widget.onFindClinic(context),
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
