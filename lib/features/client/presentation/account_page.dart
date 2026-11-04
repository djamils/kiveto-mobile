import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiveto_mobile/features/client/domain/me.dart';
import 'package:kiveto_mobile/features/client/presentation/account_messages.dart';
import 'package:kiveto_mobile/features/client/presentation/account_providers.dart';
import 'package:kiveto_mobile/features/client/presentation/client_providers.dart';
import 'package:kiveto_mobile/features/client/presentation/clinic_row.dart';
import 'package:kiveto_mobile/features/client/presentation/consents_section.dart';
import 'package:kiveto_mobile/features/client/presentation/data_export_sheet.dart';
import 'package:kiveto_mobile/features/client/presentation/profile_card.dart';
import 'package:kiveto_mobile/features/client/presentation/profile_edit_sheet.dart';
import 'package:kiveto_mobile/features/identity_access/identity_access.dart';
import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';
import 'package:kiveto_mobile/shared/presentation/async/async_views.dart';
import 'package:kiveto_mobile/shared/presentation/icons/lucide_glyph.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/kit/feedback.dart';
import 'package:kiveto_mobile/shared/presentation/kit/surfaces.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_colors.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_layout.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_text.dart';
import 'package:material_ui/material_ui.dart';

/// Screen 6, « Compte » (mockup 06): the profile (name, e-mail, phone,
/// address), the clinics of the account (a tap makes a confirmed one the
/// active clinic), the consents of the active clinic, the data (export,
/// deletion) and « Se déconnecter ». Pull-to-refresh reloads `/me` and the
/// consents. The e-mail change and the deletion are identity_access's
/// sheets; the server decides every rule.
///
/// Exit: [onAddClinic] (the clinic search).
class AccountPage extends ConsumerWidget {
  const new({required this.onAddClinic, super.key});

  final void Function(BuildContext context) onAddClinic;

  Future<void> _refresh(WidgetRef ref) async {
    ref
      ..invalidate(meProvider)
      ..invalidate(consentsProvider);
    try {
      await ref.read(meProvider.future);
    } on Object {
      // The page shows the failure.
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final me = ref.watch(meProvider);
    final account = switch (me) {
      AsyncValue(isLoading: true, hasError: true) => const KivetoSkeleton(),
      AsyncData(:final value) => _AccountSections(
        me: value,
        onAddClinic: onAddClinic,
      ),
      AsyncError(:final error) => ErrorView(
        error: error,
        onRetry: () => ref.invalidate(meProvider),
      ),
      _ => const KivetoSkeleton(),
    };
    return Scaffold(
      backgroundColor: KivetoColors.canvas,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: KivetoColors.brand,
          onRefresh: () => _refresh(ref),
          child: ListView(
            // A short page can be pulled too.
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(KivetoSpace.gutter),
            children: [
              KivetoPageHeader(l10n.screenAccountTitle),
              const SizedBox(height: KivetoSpace.xl4),
              account,
              const SizedBox(height: KivetoSpace.xl4),
              const _SignOutButton(),
            ],
          ),
        ),
      ),
    );
  }
}

/// The sections of a loaded account, 22 apart.
class _AccountSections extends ConsumerWidget {
  const new({required this.me, required this.onAddClinic});

  final Me me;
  final void Function(BuildContext context) onAddClinic;

  /// The profile sheet; once saved (the sheet reloaded `/me`), « Profil
  /// enregistré. ».
  Future<void> _editProfile(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final saved = AppLocalizations.of(context).accountProfileSaved;
    if (await showProfileEditSheet(context, me.account)) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(saved)));
    }
  }

  /// identity_access's e-mail sheet; a verified address reloads `/me`, also
  /// when the sheet was closed while the server verified it.
  Future<void> _changeEmail(BuildContext context) {
    final container = ProviderScope.containerOf(context, listen: false);
    final account = me.account;
    return showEmailChangeSheet(
      context,
      currentEmail: account.email,
      verified: account.emailVerified,
      maskedPhone: account.maskedPhone,
      onVerified: () => container.invalidate(meProvider),
    );
  }

  /// Makes [clinicId] the active clinic, then reloads `/me`.
  Future<void> _switchTo(BuildContext context, ClinicId clinicId) async {
    final container = ProviderScope.containerOf(context, listen: false);
    await container.read(activeClinicProvider.notifier).select(clinicId);
    container.invalidate(meProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final active = switch (ref.watch(activeClinicProvider)) {
      AsyncData(value: final clinic?) => clinic.clinicId,
      _ => null,
    };
    final consents = ref.watch(consentsProvider);
    // The clinic the consents are of: the active one (also while /me
    // reloads after a change, when the active clinic reloads too).
    final consentsClinic = switch (consents) {
      AsyncData(value: final state?) => state.clinicId,
      _ => active,
    };
    final consentsClinicName = [
      for (final clinic in me.clinics)
        if (clinic.clinicId == consentsClinic) clinic.name,
    ].firstOrNull;
    final showConsents = switch (consents) {
      AsyncData(value: null) => false,
      _ => true,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProfileCard(
          account: me.account,
          onEdit: () => unawaited(_editProfile(context)),
          onEmail: () => unawaited(_changeEmail(context)),
        ),
        const SizedBox(height: KivetoSpace.xl4),
        KivetoSectionHeader(
          l10n.accountClinicsTitle,
          actionLabel: l10n.accountClinicsAdd,
          onAction: () => onAddClinic(context),
        ),
        const SizedBox(height: KivetoSpace.m),
        if (me.clinics.isEmpty)
          KivetoCard(
            padding: const EdgeInsets.all(KivetoSpace.xl),
            child: Text(l10n.accountClinicsEmpty, style: KivetoText.bodySmall),
          )
        else
          KivetoCard.list(
            children: [
              for (final clinic in me.clinics)
                _clinicRow(context, l10n, clinic, activeClinicId: active),
            ],
          ),
        if (showConsents) ...[
          const SizedBox(height: KivetoSpace.xl4),
          ConsentsSection(clinicName: consentsClinicName),
        ],
        const SizedBox(height: KivetoSpace.xl4),
        KivetoSectionHeader(l10n.accountDataTitle),
        const SizedBox(height: KivetoSpace.m),
        KivetoCard.list(
          children: [
            KivetoActionRow(
              glyph: LucideGlyph.download,
              label: l10n.accountDataExport,
              onTap: () => unawaited(showDataExportSheet(context)),
            ),
            KivetoActionRow(
              glyph: LucideGlyph.trash,
              label: l10n.accountDataDelete,
              danger: true,
              onTap: () => unawaited(
                showAccountDeletionSheet(
                  context,
                  maskedPhone: me.account.maskedPhone,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: KivetoSpace.m),
        KivetoFootnote(l10n.accountDataInvoicesNote, small: true),
      ],
    );
  }

  /// A clinic of the account: the active one marked; a confirmed other one
  /// becomes the active clinic on a tap; a pending one waits for the
  /// clinic (not tappable).
  Widget _clinicRow(
    BuildContext context,
    AppLocalizations l10n,
    ClinicLink clinic, {
    required ClinicId? activeClinicId,
  }) {
    final isActive = clinic.clinicId == activeClinicId;
    final confirmed = clinic.linkStatus == LinkStatus.confirmed;
    return ClinicRow(
      name: clinic.name,
      meta: clinicMeta(l10n, clinic),
      active: isActive,
      pending: clinic.linkStatus == LinkStatus.pending,
      onTap: confirmed && !isActive
          ? () => unawaited(_switchTo(context, clinic.clinicId))
          : null,
    );
  }
}

/// « Se déconnecter »: the logout of identity_access (the server revokes
/// the session, the app signs out whatever it answers; the router then
/// goes to the welcome screen). Loading while it runs.
class _SignOutButton extends ConsumerStatefulWidget {
  const new();

  @override
  ConsumerState<_SignOutButton> createState() => _SignOutButtonState();
}

class _SignOutButtonState extends ConsumerState<_SignOutButton> {
  bool _running = false;

  Future<void> _signOut() async {
    setState(() => _running = true);
    try {
      await ref.read(signOutProvider)();
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }

  @override
  Widget build(BuildContext context) => KivetoButton.outline(
    label: AppLocalizations.of(context).accountSignOut,
    size: KivetoButtonSize.large,
    expand: true,
    loading: _running,
    onPressed: () => unawaited(_signOut()),
  );
}
