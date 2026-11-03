import 'package:kiveto_mobile/shared/presentation/icons/kiveto_icon.dart';
import 'package:kiveto_mobile/shared/presentation/icons/lucide_glyph.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/kit/forms.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_colors.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_layout.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_text.dart';
import 'package:material_ui/material_ui.dart';

/// C-10: a flat white card, 1 px border, radius 12 (14 for the recap and
/// appointment cards).
class KivetoCard extends StatelessWidget {
  const new({
    required this.child,
    super.key,
    this.radius = KivetoRadius.l,
    this.padding = EdgeInsets.zero,
  });

  /// A grouped list: [children] separated by 1 px dividers, no inset.
  new list({
    required List<Widget> children,
    super.key,
    this.radius = KivetoRadius.l,
  }) : padding = EdgeInsets.zero,
       child = Column(
         crossAxisAlignment: CrossAxisAlignment.stretch,
         children: [
           for (var i = 0; i < children.length; i++) ...[
             if (i > 0)
               const Divider(
                 height: 1,
                 thickness: 1,
                 color: KivetoColors.divider,
               ),
             children[i],
           ],
         ],
       );

  final Widget child;
  final double radius;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: KivetoColors.surface,
      border: Border.all(color: KivetoColors.border),
      borderRadius: BorderRadius.circular(radius),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(radius - 1),
      child: Material(
        type: MaterialType.transparency,
        child: Padding(padding: padding, child: child),
      ),
    ),
  );
}

/// C-11a/b/c: a row of a card: a title, an optional meta line, an optional
/// leading tile and trailing widget.
class KivetoListRow extends StatelessWidget {
  /// C-11a: two lines and a trailing widget (a pill), padding 14.
  const new({
    required this.title,
    super.key,
    this.meta,
    this.trailing,
    this.onTap,
  }) : leading = null,
       _padding = const EdgeInsets.all(14),
       _minHeight = 0,
       _metaGap = 2;

  /// C-11b: a navigation row, min-height 52, trailing chevron.
  const new navigation({
    required this.title,
    required VoidCallback this.onTap,
    super.key,
    this.meta,
  }) : leading = null,
       trailing = const KivetoIcon(
         LucideGlyph.chevronRight,
         size: 18,
         color: KivetoColors.inkMuted,
       ),
       _padding = const EdgeInsets.symmetric(horizontal: 14),
       _minHeight = 52,
       _metaGap = 1;

  /// C-11c: a row with a leading tile, padding 12 14.
  const new tile({
    required KivetoLeadingTile this.leading,
    required this.title,
    super.key,
    this.meta,
    this.trailing,
    this.onTap,
  }) : _padding = const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
       _minHeight = 0,
       _metaGap = 2;

  final String title;
  final String? meta;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsets _padding;
  final double _minHeight;
  final double _metaGap;

  @override
  Widget build(BuildContext context) {
    final leading = this.leading;
    final trailing = this.trailing;
    final meta = this.meta;
    final row = ConstrainedBox(
      constraints: BoxConstraints(minHeight: _minHeight),
      child: Padding(
        padding: _padding,
        child: Row(
          children: [
            if (leading != null) ...[leading, const SizedBox(width: 12)],
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: KivetoText.label),
                  if (meta != null) ...[
                    SizedBox(height: _metaGap),
                    Text(meta, style: KivetoText.caption),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 12), trailing],
          ],
        ),
      ),
    );
    return onTap == null
        ? row
        : InkWell(
            onTap: onTap,
            splashFactory: NoSplash.splashFactory,
            overlayColor: const WidgetStatePropertyAll(KivetoColors.inkPressed),
            child: row,
          );
  }
}

/// C-11c / C-30: a 36 (radius 8) or 40 (radius 10) tile holding a glyph
/// or a text glyph (`€`, `CR`, `Rx`…) in a colour set.
class KivetoLeadingTile extends StatelessWidget {
  const new({
    required this.colors,
    super.key,
    this.glyph,
    this.text,
    this.size = 36,
  }) : assert(glyph != null || text != null, 'a glyph or a text');

  final KivetoColorSet colors;
  final LucideGlyph? glyph;
  final String? text;
  final double size;

  @override
  Widget build(BuildContext context) {
    final glyph = this.glyph;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.fill,
        borderRadius: BorderRadius.circular(size >= 40 ? 10 : 8),
      ),
      child: glyph != null
          ? KivetoIcon(glyph, size: 18, color: colors.foreground)
          : Text(
              text!,
              style: size >= 40
                  ? KivetoText.tag.copyWith(color: colors.foreground)
                  : kivetoTextStyle(
                      15,
                      FontWeight.w700,
                      color: colors.foreground,
                    ),
            ),
    );
  }
}

/// C-11d: an action row, min-height 52, leading icon 18; red when
/// [danger].
class KivetoActionRow extends StatelessWidget {
  const new({
    required this.glyph,
    required this.label,
    required this.onTap,
    super.key,
    this.danger = false,
  });

  final LucideGlyph glyph;
  final String label;
  final VoidCallback? onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? KivetoColors.danger : KivetoColors.ink;
    return InkWell(
      onTap: onTap,
      splashFactory: NoSplash.splashFactory,
      overlayColor: const WidgetStatePropertyAll(KivetoColors.inkPressed),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 52),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              KivetoIcon(glyph, size: 18, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: KivetoText.label.copyWith(color: color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// C-11e: a key/value row of a recap: label column 72, value 15/700, an
/// optional second line and trailing link.
class KivetoKeyValueRow extends StatelessWidget {
  const new({
    required this.label,
    required this.value,
    super.key,
    this.secondary,
    this.actionLabel,
    this.onAction,
  });

  final String label;
  final String value;
  final String? secondary;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final secondary = this.secondary;
    final actionLabel = this.actionLabel;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      child: Row(
        crossAxisAlignment: secondary == null
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Padding(
              padding: EdgeInsets.only(top: secondary == null ? 0 : 2),
              child: Text(label, style: KivetoText.caption),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: KivetoText.itemTitle),
                if (secondary != null)
                  Text(secondary, style: KivetoText.bodySmall),
              ],
            ),
          ),
          if (actionLabel != null) ...[
            const SizedBox(width: 12),
            KivetoInlineLinks([
              InlinePart.link(
                actionLabel,
                onTap: onAction ?? () {},
                underline: false,
              ),
            ]),
          ],
        ],
      ),
    );
  }
}

/// C-11h: a title, a description and a trailing switch.
class KivetoSwitchRow extends StatelessWidget {
  const new({
    required this.title,
    required this.value,
    required this.onChanged,
    super.key,
    this.description,
  });

  final String title;
  final String? description;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final description = this.description;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: KivetoText.labelStrong),
                if (description != null) ...[
                  const SizedBox(height: KivetoSpace.tight),
                  Text(
                    description,
                    style: KivetoText.caption.copyWith(height: 1.4),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 14),
          KivetoSwitch(
            value: value,
            onChanged: onChanged,
            semanticLabel: title,
          ),
        ],
      ),
    );
  }
}

/// C-11i: a checkbox row, min-height 60; the whole row toggles.
class KivetoCheckboxRow extends StatelessWidget {
  const new({
    required this.title,
    required this.value,
    required this.onChanged,
    super.key,
    this.meta,
  });

  final String title;
  final String? meta;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final meta = this.meta;
    final onChanged = this.onChanged;
    return MergeSemantics(
      child: InkWell(
        onTap: onChanged == null ? null : () => onChanged(!value),
        splashFactory: NoSplash.splashFactory,
        overlayColor: const WidgetStatePropertyAll(KivetoColors.inkPressed),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 60),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Row(
              children: [
                KivetoCheckbox(value: value, onChanged: onChanged),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: KivetoText.itemTitle),
                      if (meta != null) Text(meta, style: KivetoText.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// C-41: a section title (16/700) with an optional trailing link, caption
/// or widget, or a description under it.
class KivetoSectionHeader extends StatelessWidget {
  const new(
    this.title, {
    super.key,
    this.description,
    this.trailingCaption,
    this.actionLabel,
    this.onAction,
    this.trailing,
  });

  final String title;
  final String? description;
  final String? trailingCaption;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final description = this.description;
    final caption = trailingCaption;
    final actionLabel = this.actionLabel;
    final trailing = this.trailing;
    final heading = Semantics(
      header: true,
      child: Text(title, style: KivetoText.sectionTitle),
    );
    if (description != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          heading,
          const SizedBox(height: KivetoSpace.xxs),
          Text(description, style: KivetoText.caption),
        ],
      );
    }
    return Row(
      crossAxisAlignment: trailing == null
          ? CrossAxisAlignment.baseline
          : CrossAxisAlignment.center,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Expanded(child: heading),
        if (caption != null) Text(caption, style: KivetoText.caption),
        if (actionLabel != null)
          KivetoInlineLinks([
            InlinePart.link(
              actionLabel,
              onTap: onAction ?? () {},
              underline: false,
            ),
          ]),
        ?trailing,
      ],
    );
  }
}

/// C-37a: the title of a tab page (26/700), an optional subtitle and
/// trailing action.
class KivetoPageHeader extends StatelessWidget {
  const new(this.title, {super.key, this.subtitle, this.trailing});

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final subtitle = this.subtitle;
    final trailing = this.trailing;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(title, style: KivetoText.pageTitle),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: KivetoSpace.xs),
                Text(subtitle, style: KivetoText.body),
              ],
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

/// C-37c: a detail page header: back on its own row, then the title, a
/// subtitle and an optional extra line.
class KivetoDetailHeader extends StatelessWidget {
  const new({
    required this.title,
    super.key,
    this.subtitle,
    this.extra,
    this.extraIsPositive = false,
    this.onBack,
  });

  final String title;
  final String? subtitle;
  final String? extra;

  /// Shows [extra] in 13/600 green (an "Ouvert" status).
  final bool extraIsPositive;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final subtitle = this.subtitle;
    final extra = this.extra;
    final onBack = this.onBack;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (onBack != null) KivetoIconButton.back(onPressed: onBack),
        Semantics(
          header: true,
          child: Text(title, style: KivetoText.flowTitle),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: KivetoSpace.s),
          Text(subtitle, style: KivetoText.body),
        ],
        if (extra != null) ...[
          const SizedBox(height: KivetoSpace.s),
          Text(
            extra,
            style: extraIsPositive
                ? KivetoText.labelSmall.copyWith(color: KivetoColors.success)
                : KivetoText.bodySmall,
          ),
        ],
      ],
    );
  }
}

/// C-38: the K badge alone: 36 × 36, radius 10, brand, a white K.
class KivetoBadgeMark extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) => Container(
    width: 36,
    height: 36,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: KivetoColors.brand,
      borderRadius: BorderRadius.circular(KivetoRadius.m),
    ),
    child: ExcludeSemantics(
      child: Text(
        'K',
        style: KivetoText.titleLarge.copyWith(color: KivetoColors.surface),
      ),
    ),
  );
}

/// C-38: the brand lockup: the K badge and the "Kiveto" wordmark.
class KivetoBrandLockup extends StatelessWidget {
  const new({super.key, this.name = 'Kiveto'});

  /// The brand name (not translated).
  final String name;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      const KivetoBadgeMark(),
      const SizedBox(width: KivetoSpace.m),
      Text(name, style: KivetoText.brandWordmark),
    ],
  );
}
