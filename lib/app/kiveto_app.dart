import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiveto_mobile/app/routing/app_router.dart';
import 'package:kiveto_mobile/app/theme/kiveto_theme.dart';
import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

/// The root widget: one `MaterialApp` (material_ui), the Kiveto theme, the
/// French localisations (the app's and Material's), the router.
class KivetoApp extends ConsumerWidget {
  const new({super.key});

  static final ThemeData _theme = kivetoTheme();

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
    onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
    theme: _theme,
    locale: const Locale('fr', 'FR'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      ...GlobalMaterialLocalizations.delegates,
    ],
    routerConfig: ref.watch(routerProvider),
    debugShowCheckedModeBanner: false,
  );
}
