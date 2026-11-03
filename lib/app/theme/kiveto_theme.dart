import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_colors.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_layout.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_text.dart';
import 'package:material_ui/material_ui.dart';

/// The Material theme of the app, from the mockup (design-system §2.3, §3,
/// §9): light only, flat (elevation 0, no surface tint), DM Sans with its
/// optical size on every text role. The UI kit draws its components from
/// the tokens; this theme makes the Material widgets around them agree.
ThemeData kivetoTheme() {
  const transparent = Color(0x00000000);
  const colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: KivetoColors.brand,
    onPrimary: KivetoColors.surface,
    primaryContainer: KivetoColors.brandSoft,
    onPrimaryContainer: KivetoColors.onBrandSoft,
    secondary: KivetoColors.ink,
    onSecondary: KivetoColors.surface,
    secondaryContainer: KivetoColors.neutralSoft,
    onSecondaryContainer: KivetoColors.inkSecondary,
    tertiary: KivetoColors.accentOrange,
    onTertiary: KivetoColors.surface,
    tertiaryContainer: KivetoColors.accentOrangeSoft,
    onTertiaryContainer: KivetoColors.accentOrange,
    error: KivetoColors.danger,
    onError: KivetoColors.surface,
    errorContainer: KivetoColors.dangerSoft,
    onErrorContainer: KivetoColors.onDangerSoft,
    surface: KivetoColors.surface,
    onSurface: KivetoColors.ink,
    onSurfaceVariant: KivetoColors.inkMuted,
    surfaceContainerLowest: KivetoColors.surface,
    surfaceContainerLow: KivetoColors.canvas,
    surfaceContainer: KivetoColors.neutralSoft,
    surfaceContainerHigh: KivetoColors.track,
    surfaceContainerHighest: KivetoColors.border,
    outline: KivetoColors.borderStrong,
    outlineVariant: KivetoColors.border,
    shadow: KivetoColors.ink,
    scrim: KivetoColors.ink,
    inverseSurface: KivetoColors.ink,
    onInverseSurface: KivetoColors.surface,
    inversePrimary: KivetoColors.brandSoft,
    surfaceTint: transparent,
  );

  TextStyle ink(double size, FontWeight weight, {double letterSpacing = 0}) =>
      kivetoTextStyle(
        size,
        weight,
        letterSpacingEm: letterSpacing,
        color: KivetoColors.ink,
      );

  final textTheme = TextTheme(
    displayLarge: KivetoText.display,
    displayMedium: KivetoText.display,
    displaySmall: KivetoText.displaySmall,
    headlineLarge: KivetoText.pageTitle,
    headlineMedium: KivetoText.flowTitle,
    headlineSmall: KivetoText.headline,
    titleLarge: KivetoText.titleLarge,
    titleMedium: KivetoText.sectionTitle,
    titleSmall: KivetoText.itemTitle,
    bodyLarge: KivetoText.input,
    bodyMedium: ink(14, FontWeight.w400),
    bodySmall: ink(13, FontWeight.w400),
    labelLarge: KivetoText.label,
    labelMedium: KivetoText.labelSmall,
    labelSmall: ink(11, FontWeight.w700),
  );

  OutlineInputBorder outline(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(KivetoRadius.m),
        borderSide: BorderSide(color: color, width: width),
      );

  RoundedRectangleBorder rounded(double radius) =>
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius));

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    fontFamily: KivetoText.family,
    textTheme: textTheme,
    scaffoldBackgroundColor: KivetoColors.canvas,
    canvasColor: KivetoColors.canvas,
    materialTapTargetSize: MaterialTapTargetSize.padded,
    splashFactory: NoSplash.splashFactory,
    dividerTheme: const DividerThemeData(
      thickness: 1,
      space: 1,
      color: KivetoColors.divider,
      indent: 0,
      endIndent: 0,
    ),
    // C-18a (label and help are drawn by the kit), C-18e error, C-18f focus.
    inputDecorationTheme: InputDecorationThemeData(
      filled: true,
      fillColor: KivetoColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      constraints: const BoxConstraints(minHeight: 48),
      hintStyle: KivetoText.input.copyWith(color: KivetoColors.inkMuted),
      helperStyle: KivetoText.caption,
      errorStyle: KivetoText.caption.copyWith(color: KivetoColors.danger),
      border: outline(KivetoColors.borderStrong),
      enabledBorder: outline(KivetoColors.borderStrong),
      disabledBorder: outline(KivetoColors.border),
      focusedBorder: outline(KivetoColors.brand, 2),
      errorBorder: outline(KivetoColors.danger),
      focusedErrorBorder: outline(KivetoColors.danger, 2),
    ),
    // C-1a.
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size.fromHeight(52)),
        shape: WidgetStatePropertyAll(rounded(KivetoRadius.l)),
        textStyle: WidgetStatePropertyAll(KivetoText.sectionTitle),
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.disabled)
              ? KivetoColors.brandDisabled
              : states.contains(WidgetState.pressed)
              ? KivetoColors.brandPressed
              : KivetoColors.brand,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.disabled)
              ? KivetoColors.onBrandSoftMuted
              : KivetoColors.surface,
        ),
        overlayColor: const WidgetStatePropertyAll(transparent),
        elevation: const WidgetStatePropertyAll(0),
      ),
    ),
    // C-4b.
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size(0, 44)),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 16),
        ),
        shape: WidgetStatePropertyAll(rounded(KivetoRadius.m)),
        side: const WidgetStatePropertyAll(
          BorderSide(color: KivetoColors.borderStrong),
        ),
        backgroundColor: const WidgetStatePropertyAll(KivetoColors.surface),
        foregroundColor: const WidgetStatePropertyAll(KivetoColors.ink),
        overlayColor: const WidgetStatePropertyAll(KivetoColors.inkPressed),
        textStyle: WidgetStatePropertyAll(KivetoText.label),
      ),
    ),
    // C-8.
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size(0, 44)),
        padding: const WidgetStatePropertyAll(EdgeInsets.zero),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.disabled)
              ? KivetoColors.inkDisabled
              : states.contains(WidgetState.pressed)
              ? KivetoColors.brandPressed
              : KivetoColors.brand,
        ),
        overlayColor: const WidgetStatePropertyAll(transparent),
        textStyle: WidgetStatePropertyAll(KivetoText.labelStrong),
      ),
    ),
    appBarTheme: const AppBarThemeData(
      backgroundColor: KivetoColors.canvas,
      foregroundColor: KivetoColors.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: transparent,
    ),
    cardTheme: CardThemeData(
      color: KivetoColors.surface,
      elevation: 0,
      surfaceTintColor: transparent,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(KivetoRadius.l),
        side: const BorderSide(color: KivetoColors.border),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: KivetoColors.surface,
      elevation: 0,
      surfaceTintColor: transparent,
      barrierColor: KivetoColors.scrim,
      shape: rounded(KivetoRadius.xl),
    ),
    // C-35.
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: KivetoColors.surface,
      modalBackgroundColor: KivetoColors.surface,
      surfaceTintColor: transparent,
      elevation: 0,
      modalElevation: 0,
      modalBarrierColor: KivetoColors.scrim,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(KivetoRadius.sheet),
        ),
      ),
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: KivetoColors.brand,
      selectionColor: Color(0x404338CA),
      selectionHandleColor: KivetoColors.brand,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: KivetoColors.brand,
      linearTrackColor: KivetoColors.track,
    ),
    iconTheme: const IconThemeData(color: KivetoColors.ink, size: 20),
  );
}
