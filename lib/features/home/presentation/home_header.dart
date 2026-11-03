import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiveto_mobile/features/client/client.dart';
import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/presentation/icons/kiveto_icon.dart';
import 'package:kiveto_mobile/shared/presentation/icons/lucide_glyph.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_colors.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_layout.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_text.dart';
import 'package:material_ui/material_ui.dart';

/// C-37b, the home header (mockup 01): the active clinic over « Bonjour
/// {prénom} ». With several confirmed clinics the clinic's name and its
/// chevron open the clinic switcher; with one it is plain text. No bell
/// (notifications come later). Built from `GET /me` alone: it shows even
/// when the home itself failed.
class HomeHeader extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final me = switch (ref.watch(meProvider)) {
      AsyncData(:final value) => value,
      _ => null,
    };
    if (me == null) return const SizedBox.shrink();
    final clinic = switch (ref.watch(activeClinicProvider)) {
      AsyncData(:final value) => value,
      _ => null,
    };
    final firstName = me.account.firstName?.trim();
    final switchable = me.confirmedClinics.length > 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (clinic != null) ...[
          if (switchable)
            _ClinicSwitcherButton(
              name: clinic.name,
              semanticLabel: l10n.homeClinicSwitcherLabel(clinic.name),
              onPressed: () => unawaited(showClinicSwitcherSheet(context)),
            )
          else
            Text(clinic.name, style: _clinicStyle),
          const SizedBox(height: KivetoSpace.xs),
        ],
        Semantics(
          header: true,
          child: Text(
            firstName == null || firstName.isEmpty
                ? l10n.homeGreetingNoName
                : l10n.homeGreeting(firstName),
            style: KivetoText.pageTitle,
          ),
        ),
      ],
    );
  }
}

final TextStyle _clinicStyle = KivetoText.labelSmall.copyWith(
  color: KivetoColors.inkMuted,
);

/// The clinic's name and a chevron, no padding (13/600 grey), read as one
/// button.
class _ClinicSwitcherButton extends StatelessWidget {
  const new({
    required this.name,
    required this.semanticLabel,
    required this.onPressed,
  });

  final String name;
  final String semanticLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: semanticLabel,
    onTap: onPressed,
    excludeSemantics: true,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(child: Text(name, style: _clinicStyle)),
          const SizedBox(width: KivetoSpace.xs),
          const KivetoIcon(
            LucideGlyph.chevronDown,
            size: 16,
            color: KivetoColors.inkMuted,
          ),
        ],
      ),
    ),
  );
}
