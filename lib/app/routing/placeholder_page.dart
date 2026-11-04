import 'package:go_router/go_router.dart';
import 'package:kiveto_mobile/app/routing/app_routes.dart';
import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/kit/surfaces.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_colors.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_layout.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_text.dart';
import 'package:material_ui/material_ui.dart';

/// Where a placeholder sits, which sets its background and header.
enum PlaceholderKind {
  /// A tab root: canvas, page header.
  tab,

  /// A page pushed inside a tab: canvas, back button.
  pushed,

  /// A full-screen flow over the shell: white, back button.
  fullScreen,

  /// An unknown location: a way back home.
  notFound,
}

/// The placeholder of a screen a later slice builds: its title and "Cet
/// écran arrive dans une prochaine version."
class PlaceholderPage extends StatelessWidget {
  const new({required this.title, super.key, this.kind = PlaceholderKind.tab});

  final String title;
  final PlaceholderKind kind;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final white = switch (kind) {
      PlaceholderKind.tab || PlaceholderKind.pushed => false,
      _ => true,
    };
    final body = Text(l10n.placeholderBody, style: KivetoText.bodyLarge);
    final children = switch (kind) {
      PlaceholderKind.tab => [
        KivetoPageHeader(title),
        const SizedBox(height: KivetoSpace.xl2),
        body,
      ],
      PlaceholderKind.pushed || PlaceholderKind.fullScreen => [
        KivetoDetailHeader(title: title, onBack: () => _back(context)),
        const SizedBox(height: KivetoSpace.xl3),
        body,
      ],
      PlaceholderKind.notFound => [
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
    };
    return Scaffold(
      backgroundColor: white ? KivetoColors.surface : KivetoColors.canvas,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            KivetoSpace.gutter,
            KivetoSpace.xl3,
            KivetoSpace.gutter,
            KivetoSpace.xl,
          ),
          children: children,
        ),
      ),
    );
  }

  static void _back(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }
}
