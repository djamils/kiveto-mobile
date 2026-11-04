import 'dart:math' as math;

import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_colors.dart';
import 'package:material_ui/material_ui.dart';

/// The spacing scale of the mockup (design-system §4).
abstract final class KivetoSpace {
  static const double xxs = 2;

  /// Only between a nav icon pill and its label, and inside consent rows
  /// and motif cards.
  static const double tight = 3;
  static const double xs = 4;
  static const double s = 6;
  static const double sm = 8;
  static const double m = 10;
  static const double ml = 12;
  static const double l = 14;
  static const double xl = 16;
  static const double xl2 = 18;
  static const double xl3 = 20;
  static const double xl4 = 22;
  static const double xl5 = 24;
  static const double xl6 = 28;
  static const double xl7 = 32;

  /// Horizontal page gutter of the app screens.
  static const double gutter = 20;

  /// Horizontal page gutter of the auth screens.
  static const double authGutter = 24;
}

/// The corner radii (design-system §5).
abstract final class KivetoRadius {
  static const double pill = 999;
  static const double sheet = 22;
  static const double nav = 20;
  static const double xl = 14;
  static const double l = 12;
  static const double m = 10;
  static const double segment = 9;
  static const double s = 8;
  static const double xs = 6;
  static const double bar = 2;
}

/// The only two shadows of the mockup (design-system §6).
abstract final class KivetoShadows {
  static const bottomNav = BoxShadow(
    color: KivetoColors.shadow,
    offset: Offset(0, 6),
    blurRadius: 20,
  );
  static const switchThumb = BoxShadow(
    color: KivetoColors.switchThumbShadow,
    offset: Offset(0, 1),
    blurRadius: 2,
  );
}

/// State toggles: 150 ms, `ease` (the mockup's switch).
abstract final class KivetoMotion {
  static const duration = Duration(milliseconds: 150);
  static const Curve curve = Curves.ease;
}

/// The bottom padding of a bottom area (nav, sticky bar, auth CTA): the
/// mockup's [mockup] value, or the system inset + 8 when that is larger,
/// so nothing sits under the system navigation.
double kivetoBottomPadding(BuildContext context, double mockup) =>
    math.max(mockup, MediaQuery.viewPaddingOf(context).bottom + 8);

/// The global (window) rect of [context]'s laid-out render box, e.g. the
/// control that was tapped: the anchor of the share sheet's popover on
/// iPad (`sharePositionOrigin`). [Rect.zero] when the context has no
/// laid-out box (share_plus then centres the popover).
Rect globalRectOf(BuildContext context) {
  final box = context.findRenderObject();
  if (box is! RenderBox || !box.attached || !box.hasSize) return Rect.zero;
  return box.localToGlobal(Offset.zero) & box.size;
}
