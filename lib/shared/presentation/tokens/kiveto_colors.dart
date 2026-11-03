import 'package:material_ui/material_ui.dart';

/// The 42 colour tokens of the mockup (design-system §2.1), light only
/// (dark mode is not designed), as constants.
abstract final class KivetoColors {
  /// Brand indigo: primary buttons, links, active nav, progress, selection.
  static const brand = Color(0xFF4338CA);

  /// Pressed state of brand fills and links (the mockup's `a:hover`).
  static const brandPressed = Color(0xFF3730A3);

  /// Tinted brand surface: nav pill, tags, tonal buttons, selected chips.
  static const brandSoft = Color(0xFFEEF0FF);

  /// Selected card fill, focused OTP box.
  static const brandSubtle = Color(0xFFF7F7FF);
  static const brandBorderSoft = Color(0xFFD9DBFB);
  static const onBrandSoft = Color(0xFF312E81);
  static const onBrandSoftMuted = Color(0xFF3F3F6A);
  static const brandDisabled = Color(0xFFDCDCF5);
  static const onBrandMuted = Color(0xFFE0E1FF);
  static const brandRaised = Color(0xFF5B51E0);
  static const onBrandOutline = Color(0xFF8B84F0);

  /// Primary text, dark button, account avatar; base of scrim and shadow.
  static const ink = Color(0xFF18181B);
  static const inkSecondary = Color(0xFF3F3F50);
  static const inkMuted = Color(0xFF5F5F73);
  static const inkDisabled = Color(0xFF6B6B7B);
  static const inkUnavailable = Color(0xFF8A8A9A);

  /// Cards, sheets, white screens, text on brand.
  static const surface = Color(0xFFFFFFFF);

  /// Background of the tabbed screens; muted fills on white screens.
  static const canvas = Color(0xFFF6F6FA);
  static const track = Color(0xFFEBEBF2);
  static const neutralSoft = Color(0xFFF0F0F5);
  static const border = Color(0xFFE6E6EF);
  static const divider = Color(0xFFEFEFF5);
  static const borderStrong = Color(0xFFC9C9D8);
  static const borderChip = Color(0xFFD6D6E2);
  static const timelineLine = Color(0xFFE0E0EA);
  static const timelineDot = Color(0xFFB8B8C8);

  static const success = Color(0xFF166534);
  static const successSoft = Color(0xFFECFDF3);
  static const warning = Color(0xFF92400E);
  static const warningSoft = Color(0xFFFFF4E5);
  static const onWarningSoft = Color(0xFF7C2D12);
  static const accentOrange = Color(0xFF9A3412);
  static const accentOrangeSoft = Color(0xFFFDF2E9);
  static const danger = Color(0xFFB42318);
  static const dangerSoft = Color(0xFFFEF2F2);
  static const onDangerSoft = Color(0xFF7F1D1D);
  static const dangerBorderSoft = Color(0xFFF1C4C4);
  static const dangerDisabled = Color(0xFFF3D6D3);
  static const onDangerDisabled = Color(0xFF7A2C24);

  /// The unread-count badge of the bottom navigation.
  static const badge = Color(0xFFDC2626);

  /// Modal barrier behind a sheet: ink at 50 %.
  static const scrim = Color(0x8018181B);

  /// Bottom-nav shadow: ink at 8 %.
  static const shadow = Color(0x1418181B);

  /// Switch thumb shadow: black at 20 % (not one of the 42).
  static const switchThumbShadow = Color(0x33000000);

  /// The pressed overlay of the surfaces that are not brand-filled.
  static const inkPressed = Color(0x1218181B);
}

/// A foreground on a fill, with an optional border (design-system §2.2).
@immutable
final class KivetoColorSet {
  const new({required this.fill, required this.foreground, this.border});

  final Color fill;
  final Color foreground;
  final Color? border;
}

/// The colour pairs used as sets (avatars, tiles, pills, callouts).
abstract final class KivetoColorSets {
  static const indigo = KivetoColorSet(
    fill: KivetoColors.brandSoft,
    foreground: KivetoColors.brand,
  );
  static const indigoSelected = KivetoColorSet(
    fill: KivetoColors.brandSoft,
    foreground: KivetoColors.onBrandSoft,
    border: KivetoColors.brand,
  );
  static const orange = KivetoColorSet(
    fill: KivetoColors.accentOrangeSoft,
    foreground: KivetoColors.accentOrange,
  );
  static const green = KivetoColorSet(
    fill: KivetoColors.successSoft,
    foreground: KivetoColors.success,
  );
  static const amber = KivetoColorSet(
    fill: KivetoColors.warningSoft,
    foreground: KivetoColors.warning,
  );
  static const neutral = KivetoColorSet(
    fill: KivetoColors.neutralSoft,
    foreground: KivetoColors.inkSecondary,
  );
  static const ink = KivetoColorSet(
    fill: KivetoColors.ink,
    foreground: KivetoColors.surface,
  );
  static const red = KivetoColorSet(
    fill: KivetoColors.dangerSoft,
    foreground: KivetoColors.onDangerSoft,
  );
  static const onBrand = KivetoColorSet(
    fill: KivetoColors.brand,
    foreground: KivetoColors.surface,
  );
}
