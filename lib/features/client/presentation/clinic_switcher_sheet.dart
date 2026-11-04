import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiveto_mobile/features/client/domain/me.dart';
import 'package:kiveto_mobile/features/client/presentation/client_providers.dart';
import 'package:kiveto_mobile/features/client/presentation/clinic_row.dart';
import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/presentation/kit/navigation.dart';
import 'package:kiveto_mobile/shared/presentation/kit/surfaces.dart';
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
              ClinicRow(
                name: clinic.name,
                meta: clinic.city,
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
