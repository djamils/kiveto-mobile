import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiveto_mobile/features/client/domain/me.dart';
import 'package:kiveto_mobile/features/client/presentation/client_providers.dart';
import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/presentation/icons/kiveto_icon.dart';
import 'package:kiveto_mobile/shared/presentation/icons/lucide_glyph.dart';
import 'package:kiveto_mobile/shared/presentation/kit/navigation.dart';
import 'package:kiveto_mobile/shared/presentation/kit/pills.dart';
import 'package:kiveto_mobile/shared/presentation/kit/surfaces.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_colors.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_text.dart';
import 'package:material_ui/material_ui.dart';

/// The clinic switcher: a sheet listing the confirmed clinics of the
/// account (C-11j), the active one marked; choosing another makes it the
/// active clinic (kept on this device) and closes the sheet. Every
/// clinic-scoped screen follows the active clinic.
Future<void> showClinicSwitcherSheet(BuildContext context) =>
    showKivetoSheet<void>(
      context: context,
      builder: (context) => const _ClinicSwitcherSheet(),
    );

class _ClinicSwitcherSheet extends ConsumerWidget {
  const new();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final clinics = switch (ref.watch(meProvider)) {
      AsyncData(:final value) => value.confirmedClinics,
      _ => const <ClinicLink>[],
    };
    final active = switch (ref.watch(activeClinicProvider)) {
      AsyncData(value: final clinic?) => clinic.clinicId,
      _ => null,
    };
    return KivetoSheet(
      title: l10n.clientClinicSwitcherTitle,
      children: [
        KivetoCard.list(
          children: [
            for (final clinic in clinics)
              _ClinicRow(
                clinic: clinic,
                active: clinic.clinicId == active,
                onTap: () {
                  final notifier = ref.read(activeClinicProvider.notifier);
                  Navigator.of(context).pop();
                  if (clinic.clinicId != active) {
                    unawaited(notifier.select(clinic.clinicId));
                  }
                },
              ),
          ],
        ),
      ],
    );
  }
}

/// C-11j: a clinic row: its dot (brand when active), its name and city,
/// the « Active » pill or a chevron.
class _ClinicRow extends StatelessWidget {
  const new({required this.clinic, required this.active, required this.onTap});

  final ClinicLink clinic;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final city = clinic.city;
    return Semantics(
      button: true,
      selected: active,
      child: InkWell(
        onTap: onTap,
        splashFactory: NoSplash.splashFactory,
        overlayColor: const WidgetStatePropertyAll(KivetoColors.inkPressed),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          child: Row(
            children: [
              StatusDot(active: active),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(clinic.name, style: KivetoText.labelStrong),
                    if (city != null && city.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(city, style: KivetoText.caption),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              if (active)
                StatusPill(
                  AppLocalizations.of(context).clientClinicActive,
                  tone: StatusTone.brand,
                )
              else
                const KivetoIcon(
                  LucideGlyph.chevronRight,
                  size: 18,
                  color: KivetoColors.inkMuted,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
