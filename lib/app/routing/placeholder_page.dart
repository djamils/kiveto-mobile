import 'package:go_router/go_router.dart';
import 'package:kiveto_mobile/app/routing/app_routes.dart';
import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_colors.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_layout.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_text.dart';
import 'package:material_ui/material_ui.dart';

/// The page of an unknown location (the router's `errorBuilder`): its
/// [title] and a way back home.
class PlaceholderPage extends StatelessWidget {
  const new({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: KivetoColors.surface,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            KivetoSpace.gutter,
            KivetoSpace.xl3,
            KivetoSpace.gutter,
            KivetoSpace.xl,
          ),
          children: [
            Semantics(
              header: true,
              child: Text(title, style: KivetoText.pageTitle),
            ),
            const SizedBox(height: KivetoSpace.xl5),
            KivetoButton.primary(
              label: l10n.routeNotFoundAction,
              onPressed: () => context.go(AppRoutes.home),
            ),
          ],
        ),
      ),
    );
  }
}
