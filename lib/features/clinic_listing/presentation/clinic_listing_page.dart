import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiveto_mobile/core/di/core_providers.dart';
import 'package:kiveto_mobile/features/client/client.dart';
import 'package:kiveto_mobile/features/clinic_listing/domain/clinic_listing.dart';
import 'package:kiveto_mobile/features/clinic_listing/domain/opening_schedule.dart';
import 'package:kiveto_mobile/features/clinic_listing/presentation/clinic_listing_messages.dart';
import 'package:kiveto_mobile/features/clinic_listing/presentation/clinic_listing_providers.dart';
import 'package:kiveto_mobile/features/clinic_listing/presentation/opening_hours_grid.dart';
import 'package:kiveto_mobile/features/clinic_listing/presentation/who_cards.dart';
import 'package:kiveto_mobile/features/scheduling/scheduling.dart'
    show ListingMotifSection;
import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';
import 'package:kiveto_mobile/shared/domain/listing_id.dart';
import 'package:kiveto_mobile/shared/presentation/async/async_views.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/kit/feedback.dart';
import 'package:kiveto_mobile/shared/presentation/kit/surfaces.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_colors.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_layout.dart';
import 'package:material_ui/material_ui.dart';

/// Screen 11, « Fiche clinique » (mockup 11): the clinic's name, address
/// and whether it is open now (the device's clock), « Vous êtes » (a new
/// client by default), then for a new client the motifs open online
/// (scheduling's [ListingMotifSection]) and for a known one how to find
/// their record or book from their space; the opening hours.
///
/// Exits: [onBack], [onChooseMotif] (a motif chosen: the new-client
/// booking's first step), [onBookAsClient] (the booking of a known client,
/// the confirmed clinic of the same name made active first),
/// [onFindRecord] (the clinic search and its record suggestions).
class ClinicListingPage extends ConsumerStatefulWidget {
  const new({
    required this.listingId,
    required this.onBack,
    required this.onChooseMotif,
    required this.onBookAsClient,
    required this.onFindRecord,
    super.key,
  });

  final String listingId;
  final void Function(BuildContext context) onBack;
  final void Function(BuildContext context) onChooseMotif;
  final void Function(BuildContext context) onBookAsClient;
  final void Function(BuildContext context) onFindRecord;

  @override
  ConsumerState<ClinicListingPage> createState() => _ClinicListingPageState();
}

class _ClinicListingPageState extends ConsumerState<ClinicListingPage> {
  ClinicVisitor _visitor = ClinicVisitor.newClient;

  ListingId get _id => ListingId(widget.listingId);

  /// A known client books from their space: the confirmed clinic of the
  /// same name becomes the active one (else the active one stays: the
  /// wizard's chip switches it).
  Future<void> _bookAsClient(String clinicName) async {
    final container = ProviderScope.containerOf(context, listen: false);
    await selectConfirmedClinicNamed(container, clinicName);
    if (mounted) widget.onBookAsClient(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = clinicListingProvider(_id);
    void back() => widget.onBack(context);
    return switch (ref.watch(provider)) {
      AsyncValue(isLoading: true, hasError: true) => _Plain(
        onBack: back,
        child: const LoadingView(),
      ),
      AsyncData(:final value) => _sheet(context, l10n, value),
      AsyncError(:final error) when error is NotFoundFailure => _Plain(
        onBack: back,
        child: ErrorView(
          error: error,
          title: l10n.clinicListingGoneTitle,
          message: l10n.clinicListingGoneBody,
        ),
      ),
      AsyncError(:final error) => _Plain(
        onBack: back,
        child: ErrorView(error: error, onRetry: () => ref.invalidate(provider)),
      ),
      _ => _Plain(onBack: back, child: const LoadingView()),
    };
  }

  Widget _sheet(
    BuildContext context,
    AppLocalizations l10n,
    ClinicListingDetail clinic,
  ) {
    // The device's clock: the app has no zone database for the clinic's.
    final now = ref.watch(clockProvider).now().toLocal();
    final status = openingStatusLine(
      l10n,
      openingStatusAt(
        clinic.openingHours,
        weekday: now.weekday,
        time: ClockTime(now.hour, now.minute),
      ),
    );
    final rows = weeklyRows(clinic.openingHours);
    final address = clinic.address;
    final known = _visitor == ClinicVisitor.known;
    return Scaffold(
      backgroundColor: KivetoColors.canvas,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            KivetoSpace.gutter,
            KivetoSpace.xl,
            KivetoSpace.gutter,
            KivetoSpace.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              KivetoDetailHeader(
                onBack: () => widget.onBack(context),
                title: clinic.name,
                large: true,
                subtitle: address == null ? null : listingAddressLine(address),
                extra: status?.$1,
                extraIsPositive: status?.$2 ?? false,
              ),
              const SizedBox(height: KivetoSpace.xl2),
              KivetoSectionHeader(l10n.clinicListingWho),
              const SizedBox(height: KivetoSpace.m),
              WhoCards(
                selected: _visitor,
                onSelected: (visitor) => setState(() => _visitor = visitor),
              ),
              // The new-client hint announces the next step: none when the
              // clinic takes no new client online (its block says why).
              if (known || clinic.onlineBooking) ...[
                const SizedBox(height: KivetoSpace.m),
                KivetoFootnote(
                  known
                      ? l10n.clinicListingKnownHint
                      : l10n.clinicListingNewHint,
                  small: true,
                ),
              ],
              const SizedBox(height: KivetoSpace.xl2),
              if (known)
                _KnownClient(
                  onBook: () => unawaited(_bookAsClient(clinic.name)),
                  onFindRecord: () => widget.onFindRecord(context),
                )
              else
                ListingMotifSection(
                  listingId: clinic.id,
                  clinicName: clinic.name,
                  phone: clinic.phone,
                  onlineBooking: clinic.onlineBooking,
                  acceptsNewClients: clinic.acceptsNewClients,
                  onChooseMotif: widget.onChooseMotif,
                ),
              if (rows.isNotEmpty) ...[
                const SizedBox(height: KivetoSpace.xl2),
                KivetoSectionHeader(l10n.clinicListingHours),
                const SizedBox(height: KivetoSpace.m),
                OpeningHoursGrid(rows: rows),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// « Déjà client »: « Prendre rendez-vous » from the account's space (only
/// with a confirmed clinic), « Retrouver mon dossier » (the clinic search).
class _KnownClient extends ConsumerWidget {
  const new({required this.onBook, required this.onFindRecord});

  final VoidCallback onBook;
  final VoidCallback onFindRecord;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final linked = switch (ref.watch(meProvider)) {
      AsyncData(:final value) => value.hasConfirmedClinic,
      _ => false,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (linked) ...[
          KivetoButton.primary(label: l10n.appointmentsBook, onPressed: onBook),
          const SizedBox(height: KivetoSpace.m),
        ],
        KivetoButton.outline(
          label: l10n.clinicListingFindRecord,
          size: KivetoButtonSize.large,
          onPressed: onFindRecord,
        ),
      ],
    );
  }
}

/// The sheet while it loads or failed: back, then [child].
class _Plain extends StatelessWidget {
  const new({required this.onBack, required this.child});

  final VoidCallback onBack;
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: KivetoColors.canvas,
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          KivetoSpace.gutter,
          KivetoSpace.xl,
          KivetoSpace.gutter,
          KivetoSpace.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            KivetoIconButton.back(onPressed: onBack),
            Expanded(child: child),
          ],
        ),
      ),
    ),
  );
}
