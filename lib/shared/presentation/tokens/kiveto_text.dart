import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_colors.dart';
import 'package:material_ui/material_ui.dart';

/// The one factory of every text style: DM Sans (the variable font), the
/// optical size set to the size in px (the font's default is 9, the browser
/// of the mockup used the size), letter spacing in em, CSS half-leading.
///
/// Never `copyWith(fontSize: …)` a Kiveto style: the optical size would
/// stay the old one. Build a new style with this factory instead.
TextStyle kivetoTextStyle(
  double size,
  FontWeight weight, {
  double? height,
  double letterSpacingEm = 0,
  Color? color,
}) => TextStyle(
  fontFamily: KivetoText.family,
  fontSize: size,
  fontWeight: weight,
  fontVariations: [FontVariation.opticalSize(size.clamp(9, 40).toDouble())],
  letterSpacing: letterSpacingEm * size,
  height: height,
  leadingDistribution: TextLeadingDistribution.even,
  color: color,
);

/// The type roles of the mockup (design-system §3), with their default
/// colour. `height` null is the font's own line height (CSS `normal`).
abstract final class KivetoText {
  static const family = 'DMSans';

  static final TextStyle display = kivetoTextStyle(
    30,
    FontWeight.w700,
    height: 1.12,
    letterSpacingEm: -0.02,
    color: KivetoColors.ink,
  );
  static final TextStyle displaySmall = kivetoTextStyle(
    28,
    FontWeight.w700,
    height: 1.15,
    letterSpacingEm: -0.02,
    color: KivetoColors.ink,
  );
  static final TextStyle pageTitle = kivetoTextStyle(
    26,
    FontWeight.w700,
    letterSpacingEm: -0.02,
    color: KivetoColors.ink,
  );
  static final TextStyle flowTitle = kivetoTextStyle(
    24,
    FontWeight.w700,
    letterSpacingEm: -0.02,
    color: KivetoColors.ink,
  );
  static final TextStyle headline = kivetoTextStyle(
    22,
    FontWeight.w700,
    color: KivetoColors.ink,
  );
  static final TextStyle brandWordmark = kivetoTextStyle(
    18,
    FontWeight.w700,
    letterSpacingEm: -0.01,
    color: KivetoColors.ink,
  );
  static final TextStyle titleLarge = kivetoTextStyle(
    18,
    FontWeight.w700,
    color: KivetoColors.ink,
  );
  static final TextStyle sectionTitle = kivetoTextStyle(
    16,
    FontWeight.w700,
    color: KivetoColors.ink,
  );
  static final TextStyle itemTitle = kivetoTextStyle(
    15,
    FontWeight.w700,
    color: KivetoColors.ink,
  );
  static final TextStyle itemValue = kivetoTextStyle(
    15,
    FontWeight.w600,
    color: KivetoColors.ink,
  );
  static final TextStyle bodyLarge = kivetoTextStyle(
    15,
    FontWeight.w400,
    height: 1.5,
    color: KivetoColors.inkMuted,
  );
  static final TextStyle input = kivetoTextStyle(
    15,
    FontWeight.w400,
    color: KivetoColors.ink,
  );
  static final TextStyle body = kivetoTextStyle(
    14,
    FontWeight.w400,
    color: KivetoColors.inkMuted,
  );
  static final TextStyle label = kivetoTextStyle(
    14,
    FontWeight.w600,
    color: KivetoColors.ink,
  );
  static final TextStyle labelStrong = kivetoTextStyle(
    14,
    FontWeight.w700,
    color: KivetoColors.ink,
  );
  static final TextStyle bodySmall = kivetoTextStyle(
    13,
    FontWeight.w400,
    color: KivetoColors.inkMuted,
  );
  static final TextStyle labelSmall = kivetoTextStyle(
    13,
    FontWeight.w600,
    color: KivetoColors.ink,
  );
  static final TextStyle labelSmallStrong = kivetoTextStyle(
    13,
    FontWeight.w700,
    color: KivetoColors.ink,
  );
  static final TextStyle optionalSuffix = kivetoTextStyle(
    13,
    FontWeight.w500,
    color: KivetoColors.inkMuted,
  );
  static final TextStyle caption = kivetoTextStyle(
    12,
    FontWeight.w400,
    color: KivetoColors.inkMuted,
  );
  static final TextStyle captionStrong = kivetoTextStyle(
    12,
    FontWeight.w600,
    color: KivetoColors.inkMuted,
  );
  static final TextStyle captionMedium = kivetoTextStyle(
    12,
    FontWeight.w500,
    color: KivetoColors.inkMuted,
  );

  /// Upper case is applied by the widget (`text.toUpperCase()`).
  static final TextStyle overline = kivetoTextStyle(
    12,
    FontWeight.w600,
    letterSpacingEm: 0.06,
    color: KivetoColors.onBrandMuted,
  );
  static final TextStyle tag = kivetoTextStyle(
    12,
    FontWeight.w700,
    color: KivetoColors.brand,
  );
  static final TextStyle pill = kivetoTextStyle(
    11,
    FontWeight.w700,
    color: KivetoColors.ink,
  );
  static final TextStyle navLabel = kivetoTextStyle(
    11,
    FontWeight.w600,
    color: KivetoColors.inkMuted,
  );
  static final TextStyle navLabelActive = kivetoTextStyle(
    11,
    FontWeight.w700,
    color: KivetoColors.brand,
  );
  static final TextStyle micro = kivetoTextStyle(
    10,
    FontWeight.w700,
    color: KivetoColors.surface,
  );
}
