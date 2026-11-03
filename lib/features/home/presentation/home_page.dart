import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderException;
import 'package:kiveto_mobile/core/di/core_providers.dart';
import 'package:kiveto_mobile/features/client/client.dart';
import 'package:kiveto_mobile/features/document/document.dart';
import 'package:kiveto_mobile/features/home/domain/home_overview.dart';
import 'package:kiveto_mobile/features/home/presentation/care_list.dart';
import 'package:kiveto_mobile/features/home/presentation/home_header.dart';
import 'package:kiveto_mobile/features/home/presentation/home_providers.dart';
import 'package:kiveto_mobile/features/home/presentation/latest_documents.dart';
import 'package:kiveto_mobile/features/home/presentation/next_appointment_card.dart';
import 'package:kiveto_mobile/features/home/presentation/pet_cards.dart';
import 'package:kiveto_mobile/features/patient/patient.dart';
import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';
import 'package:kiveto_mobile/shared/presentation/async/async_views.dart';
import 'package:kiveto_mobile/shared/presentation/icons/lucide_glyph.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/kit/feedback.dart';
import 'package:kiveto_mobile/shared/presentation/kit/surfaces.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_colors.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_layout.dart';
import 'package:material_ui/material_ui.dart';

/// Screen 1, « Accueil » (mockup 01): the header (the active clinic and its
/// switcher, the greeting), then the home of the active clinic as the
/// server composed it: the next appointment, the pets, the care due dates
/// and the booking button, the latest documents. An empty section is left
/// out (« À prévoir » keeps its booking button).
///
/// Exits: [onOpenPet] with a pet id, [onManageAppointments],
/// [onFillQuestionnaire] with an appointment id, [onBook],
/// [onSeeAllDocuments].
class HomePage extends ConsumerWidget {
  const new({
    required this.onOpenPet,
    required this.onManageAppointments,
    required this.onFillQuestionnaire,
    required this.onBook,
    required this.onSeeAllDocuments,
    super.key,
  });

  final void Function(BuildContext context, String petId) onOpenPet;
  final void Function(BuildContext context) onManageAppointments;
  final void Function(BuildContext context, String appointmentId)
  onFillQuestionnaire;
  final void Function(BuildContext context) onBook;
  final void Function(BuildContext context) onSeeAllDocuments;

  /// Pull-to-refresh: `/me` (the header, the badge) and the home; done
  /// when the home answered.
  static Future<void> _refresh(WidgetRef ref) async {
    ref
      ..invalidate(meProvider)
      ..invalidate(homeOverviewProvider);
    try {
      await ref.read(homeOverviewProvider.future);
    } on Object {
      // The page shows the failure.
    }
  }

  static void _retry(WidgetRef ref, Object error) {
    // A 404: the link with the clinic may be gone, /me says which clinics
    // remain. A failure of /me reaches the home through the active clinic.
    if (_cause(error) is NotFoundFailure || ref.read(meProvider).hasError) {
      ref.invalidate(meProvider);
    }
    ref.invalidate(homeOverviewProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    backgroundColor: KivetoColors.canvas,
    body: SafeArea(
      bottom: false,
      child: RefreshIndicator(
        color: KivetoColors.brand,
        onRefresh: () => _refresh(ref),
        child: CustomScrollView(
          // A short home can be pulled too.
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            const SliverPadding(
              padding: EdgeInsets.fromLTRB(
                KivetoSpace.gutter,
                KivetoSpace.xl3,
                KivetoSpace.gutter,
                0,
              ),
              sliver: SliverToBoxAdapter(child: HomeHeader()),
            ),
            ..._body(context, ref),
          ],
        ),
      ),
    ),
  );

  List<Widget> _body(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    Widget fill(Widget child) =>
        SliverFillRemaining(hasScrollBody: false, child: child);
    // The page-shaped placeholder, in the page's gutter.
    const loading = SliverPadding(
      padding: EdgeInsets.fromLTRB(
        KivetoSpace.gutter,
        KivetoSpace.xl2,
        KivetoSpace.gutter,
        KivetoSpace.sm,
      ),
      sliver: SliverToBoxAdapter(child: KivetoSkeleton()),
    );
    switch (ref.watch(homeOverviewProvider)) {
      // A retry after an error: loading, not the error again.
      case AsyncValue(isLoading: true, hasError: true):
        return [loading];
      case AsyncData(value: ClinicHome(:final clinicId, :final overview)):
        return [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              KivetoSpace.gutter,
              KivetoSpace.xl2,
              KivetoSpace.gutter,
              KivetoSpace.sm,
            ),
            sliver: SliverList.list(
              children: _sections(context, ref, l10n, clinicId, overview),
            ),
          ),
        ];
      case AsyncError(:final error):
        return [
          fill(
            _cause(error) is NotFoundFailure
                ? ErrorView(
                    error: error,
                    title: l10n.homeClinicGoneTitle,
                    message: l10n.homeClinicGoneBody,
                    onRetry: () => _retry(ref, error),
                  )
                : ErrorView(error: error, onRetry: () => _retry(ref, error)),
          ),
        ];
      default:
        return [loading];
    }
  }

  List<Widget> _sections(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    ClinicId? clinicId,
    HomeOverview overview,
  ) {
    final today = deviceToday(ref.watch(clockProvider));
    final appointment = overview.nextAppointment;
    final sections = <Widget>[
      if (appointment != null)
        NextAppointmentCard(
          appointment: appointment,
          onFillQuestionnaire: () =>
              onFillQuestionnaire(context, appointment.id),
          onManage: () => onManageAppointments(context),
        ),
      if (overview.pets.isNotEmpty)
        _Section(
          header: KivetoSectionHeader(l10n.homePetsTitle),
          child: PetCards(
            pets: overview.pets,
            today: today,
            onOpen: (pet) => onOpenPet(context, pet.id),
          ),
        ),
      _Section(
        header: KivetoSectionHeader(
          l10n.homeCareTitle,
          trailingCaption: l10n.homeCareCaption,
        ),
        children: [
          if (overview.careItems.isNotEmpty)
            HomeCareList(items: overview.careItems, today: today),
          KivetoButton.dark(
            label: l10n.homeBook,
            icon: LucideGlyph.plus,
            onPressed: () => onBook(context),
          ),
        ],
      ),
      if (clinicId != null && overview.latestDocuments.isNotEmpty)
        _Section(
          header: KivetoSectionHeader(
            l10n.homeDocumentsTitle,
            actionLabel: l10n.homeDocumentsSeeAll,
            onAction: () => onSeeAllDocuments(context),
          ),
          child: LatestDocuments(
            documents: overview.latestDocuments,
            petNames: {for (final pet in overview.pets) pet.id: pet.name},
            today: today,
            onOpen: (document) => unawaited(
              openDocumentFile(
                context,
                clinicId: clinicId,
                documentId: DocumentId(document.id),
                title: document.title,
              ),
            ),
          ),
        ),
    ];
    return [
      for (var i = 0; i < sections.length; i++) ...[
        if (i > 0) const SizedBox(height: KivetoSpace.xl2),
        sections[i],
      ],
    ];
  }
}

/// A section of the home: its header, then its content 10 apart.
class _Section extends StatelessWidget {
  const new({required this.header, this.child, this.children = const []});

  final Widget header;
  final Widget? child;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final content = [?child, ...children];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        for (final widget in content) ...[
          const SizedBox(height: KivetoSpace.m),
          widget,
        ],
      ],
    );
  }
}

/// The error a provider failed with (an error that reached it through
/// another provider arrives wrapped in [ProviderException]s).
Object _cause(Object error) =>
    error is ProviderException ? _cause(error.exception) : error;
