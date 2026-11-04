import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiveto_mobile/app/routing/app_router.dart';
import 'package:kiveto_mobile/app/theme/kiveto_theme.dart';
import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

/// The root widget: one `MaterialApp` (material_ui), the Kiveto theme, the
/// French localisations (the app's and Material's), the router, and dark
/// status-bar content.
class KivetoApp extends ConsumerWidget {
  const new({super.key});

  static final ThemeData _theme = kivetoTheme();

  /// Dark status-bar content: every screen's top is white or canvas, and no
  /// `AppBar` sets the style, so the platform default would draw light
  /// content under the system dark mode (iOS; Android's `values-night`
  /// theme too), unreadable there. The navigation bar is left to the
  /// platform (null fields).
  static const statusBarStyle = SystemUiOverlayStyle(
    // iOS: a light status bar background, so dark content.
    statusBarBrightness: Brightness.light,
    // Android: dark icons.
    statusBarIconBrightness: Brightness.dark,
  );

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
    builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
      value: statusBarStyle,
      child: child ?? const SizedBox.shrink(),
    ),
  );
}
