import 'package:kiveto_mobile/shared/presentation/icons/kiveto_icon.dart';
import 'package:kiveto_mobile/shared/presentation/icons/lucide_glyph.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_colors.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_layout.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_text.dart';
import 'package:material_ui/material_ui.dart';

/// The tones of a [StatusPill] (C-12).
enum StatusTone { success, warning, neutral, brand, onBrand, danger }

/// C-12: a status pill, 11/700 (12/600 on the brand hero card).
class StatusPill extends StatelessWidget {
  const new(this.label, {required this.tone, super.key, this.compact = false});

  final String label;
  final StatusTone tone;

  /// Padding 3 8 instead of 4 8 (motif cards).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final (fill, foreground) = switch (tone) {
      StatusTone.success => (KivetoColors.successSoft, KivetoColors.success),
      StatusTone.warning => (KivetoColors.warningSoft, KivetoColors.warning),
      StatusTone.neutral => (
        KivetoColors.neutralSoft,
        KivetoColors.inkSecondary,
      ),
      StatusTone.brand => (KivetoColors.brandSoft, KivetoColors.brand),
      StatusTone.onBrand => (KivetoColors.brandRaised, KivetoColors.surface),
      // Extrapolated: not in the mockup.
      StatusTone.danger => (KivetoColors.dangerSoft, KivetoColors.danger),
    };
    final onBrand = tone == StatusTone.onBrand;
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: compact ? 3 : 4,
        horizontal: onBrand ? 10 : 8,
      ),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(KivetoRadius.pill),
      ),
      child: Text(
        label,
        softWrap: false,
        style: (onBrand ? KivetoText.captionStrong : KivetoText.pill).copyWith(
          color: foreground,
        ),
      ),
    );
  }
}

/// C-12b: a tag, 12/700, padding 6 10; brand, or success with a check.
class KivetoTag extends StatelessWidget {
  const new brand(this.label, {super.key}) : success = false;

  const new success(this.label, {super.key}) : success = true;

  final String label;
  final bool success;

  @override
  Widget build(BuildContext context) {
    final colors = success ? KivetoColorSets.green : KivetoColorSets.indigo;
    return Align(
      alignment: AlignmentDirectional.centerStart,
      widthFactor: 1,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        decoration: BoxDecoration(
          color: colors.fill,
          borderRadius: BorderRadius.circular(KivetoRadius.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (success) ...[
              KivetoIcon(
                LucideGlyph.check,
                size: 14,
                strokeWidth: 2.4,
                color: colors.foreground,
              ),
              const SizedBox(width: KivetoSpace.s),
            ],
            Flexible(
              child: Text(
                label,
                style: KivetoText.tag.copyWith(color: colors.foreground),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A stadium (or rounded) chip on a [TextButton]: Material's padded 48-px
/// tap target, the drawn size of the mockup.
class _Chip extends StatelessWidget {
  const new({
    required this.child,
    required this.onPressed,
    required this.height,
    required this.padding,
    required this.fill,
    required this.foreground,
    required this.border,
    required this.textStyle,
    this.radius = KivetoRadius.pill,
    this.selected,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final double height;
  final double padding;
  final Color fill;
  final Color foreground;
  final Color border;
  final TextStyle textStyle;
  final double radius;
  final bool? selected;

  @override
  Widget build(BuildContext context) => Semantics(
    selected: selected,
    child: TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
        minimumSize: WidgetStatePropertyAll(Size(0, height)),
        padding: WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: padding),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
        ),
        side: WidgetStatePropertyAll(BorderSide(color: border)),
        backgroundColor: WidgetStatePropertyAll(fill),
        foregroundColor: WidgetStatePropertyAll(foreground),
        overlayColor: const WidgetStatePropertyAll(KivetoColors.inkPressed),
        textStyle: WidgetStatePropertyAll(textStyle),
        splashFactory: NoSplash.splashFactory,
        tapTargetSize: MaterialTapTargetSize.padded,
        visualDensity: VisualDensity.standard,
      ),
      child: child,
    ),
  );
}

/// C-13a: a single-select filter chip, 36; ink when selected.
class KivetoFilterChip extends StatelessWidget {
  const new({
    required this.label,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback? onSelected;

  @override
  Widget build(BuildContext context) => _Chip(
    onPressed: onSelected,
    selected: selected,
    height: 36,
    padding: 14,
    fill: selected ? KivetoColors.ink : KivetoColors.surface,
    foreground: selected ? KivetoColors.surface : KivetoColors.inkSecondary,
    border: selected ? KivetoColors.ink : KivetoColors.border,
    textStyle: KivetoText.labelSmall,
    child: Text(label),
  );
}

/// C-13b: a choice chip, 40; brand-soft when selected.
class KivetoChoiceChip extends StatelessWidget {
  const new({
    required this.label,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback? onSelected;

  @override
  Widget build(BuildContext context) => _Chip(
    onPressed: onSelected,
    selected: selected,
    height: 40,
    padding: 14,
    fill: selected ? KivetoColors.brandSoft : KivetoColors.surface,
    foreground: selected ? KivetoColors.onBrandSoft : KivetoColors.ink,
    border: selected ? KivetoColors.brand : KivetoColors.borderChip,
    textStyle: selected ? KivetoText.labelStrong : KivetoText.label,
    child: Text(label),
  );
}

/// C-13c: a summary chip on canvas with a trailing icon (edit a step,
/// switch clinic); C-13d ([KivetoSummaryChip.action]): white with a
/// leading icon (and an optional trailing one: « Autour de moi ✕ »).
class KivetoSummaryChip extends StatelessWidget {
  const new({
    required this.label,
    required this.onPressed,
    super.key,
    this.trailingGlyph = LucideGlyph.penLine,
  }) : leadingGlyph = null;

  const new action({
    required this.label,
    required this.onPressed,
    required LucideGlyph this.leadingGlyph,
    super.key,
    this.trailingGlyph,
  });

  final String label;
  final VoidCallback? onPressed;
  final LucideGlyph? trailingGlyph;
  final LucideGlyph? leadingGlyph;

  @override
  Widget build(BuildContext context) {
    final leading = leadingGlyph;
    final trailing = trailingGlyph;
    return _Chip(
      onPressed: onPressed,
      height: 36,
      padding: 12,
      fill: leading == null ? KivetoColors.canvas : KivetoColors.surface,
      foreground: KivetoColors.ink,
      border: KivetoColors.border,
      textStyle: KivetoText.labelSmall,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[
            KivetoIcon(leading, size: 14, color: KivetoColors.ink),
            const SizedBox(width: KivetoSpace.s),
          ],
          Flexible(child: Text(label)),
          if (trailing != null) ...[
            const SizedBox(width: KivetoSpace.s),
            KivetoIcon(trailing, size: 14, color: KivetoColors.ink),
          ],
        ],
      ),
    );
  }
}

/// C-13e: a document chip, 32, radius 8.
class KivetoDocumentChip extends StatelessWidget {
  const new({required this.label, required this.onPressed, super.key});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => _Chip(
    onPressed: onPressed,
    height: 32,
    padding: 10,
    radius: KivetoRadius.s,
    fill: KivetoColors.surface,
    foreground: KivetoColors.ink,
    border: KivetoColors.border,
    textStyle: KivetoText.labelSmall,
    child: Text(label),
  );
}

/// The colour of an [InitialsAvatar] (C-14).
enum AvatarTone {
  indigo,
  orange,
  green,
  neutral,
  ink,
  brand;

  /// The pet colours cycle indigo → orange → green → neutral, keyed on the
  /// pet's position in its clinic's list, so a pet keeps its colour.
  static AvatarTone forPetIndex(int index) =>
      const [indigo, orange, green, neutral][index % 4];

  KivetoColorSet get colors => switch (this) {
    indigo => KivetoColorSets.indigo,
    orange => KivetoColorSets.orange,
    green => KivetoColorSets.green,
    neutral => KivetoColorSets.neutral,
    ink => KivetoColorSets.ink,
    brand => KivetoColorSets.onBrand,
  };
}

/// C-14: a circle with initials: 24 (nav), 44, 48 (account; [pet] for the
/// pet choice), 64 (pet header).
class InitialsAvatar extends StatelessWidget {
  const new(
    this.initials, {
    super.key,
    this.size = 44,
    this.tone = AvatarTone.indigo,
    this.pet = false,
  });

  final String initials;
  final double size;
  final AvatarTone tone;
  final bool pet;

  @override
  Widget build(BuildContext context) {
    final colors = tone.colors;
    final fontSize = switch (size) {
      <= 24 => 10.0,
      <= 44 => 16.0,
      <= 48 => pet ? 18.0 : 17.0,
      _ => 24.0,
    };
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: colors.fill, shape: BoxShape.circle),
      child: Text(
        initials,
        maxLines: 1,
        style: kivetoTextStyle(
          fontSize,
          FontWeight.w700,
          color: colors.foreground,
        ),
      ),
    );
  }
}

/// C-42: a 10 px dot, brand (the current clinic) or grey.
class StatusDot extends StatelessWidget {
  const new({super.key, this.active = true});

  final bool active;

  @override
  Widget build(BuildContext context) => Container(
    width: 10,
    height: 10,
    decoration: BoxDecoration(
      color: active ? KivetoColors.brand : KivetoColors.borderStrong,
      shape: BoxShape.circle,
    ),
  );
}
