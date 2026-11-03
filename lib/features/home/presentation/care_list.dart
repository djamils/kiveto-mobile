import 'package:kiveto_mobile/features/home/domain/home_overview.dart';
import 'package:kiveto_mobile/features/patient/patient.dart';
import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/domain/local_date.dart';
import 'package:kiveto_mobile/shared/presentation/kit/surfaces.dart';
import 'package:material_ui/material_ui.dart';

/// The care due dates of « À prévoir » (C-11a): « {pet} — {care} »,
/// « Avant le {date} » and the care pill, as the pet sheet shows it.
class HomeCareList extends StatelessWidget {
  const new({required this.items, required this.today, super.key});

  final List<HomeCareItem> items;
  final LocalDate today;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return KivetoCard.list(
      children: [
        for (final item in items)
          KivetoListRow(
            title: l10n.homeCareItemTitle(item.petName, item.label),
            meta: l10n.homeCareDue(careDate(item.dueOn, today)),
            trailing: CareStatusPill(
              status: item.status,
              dueOn: item.dueOn,
              today: today,
            ),
          ),
      ],
    );
  }
}
