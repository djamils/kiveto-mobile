import 'package:flutter/gestures.dart';
import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/presentation/icons/kiveto_icon.dart';
import 'package:kiveto_mobile/shared/presentation/icons/lucide_glyph.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_colors.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_layout.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_text.dart';
import 'package:material_ui/material_ui.dart';

/// The sizes of the button families (design-system §7, C-1 to C-6).
enum KivetoButtonSize { large, medium, small }

/// What one button variant looks like.
@immutable
final class _ButtonSpec {
  const new({
    required this.height,
    required this.radius,
    required this.fill,
    required this.foreground,
    required this.textStyle,
    this.padding = 16,
    this.border,
    this.pressedFill,
    this.overlay = KivetoColors.inkPressed,
    this.disabledFill,
    this.disabledForeground = KivetoColors.inkUnavailable,
    this.iconSize = 16,
    this.iconGap = 8,
  });

  final double height;
  final double radius;
  final double padding;
  final Color fill;
  final Color foreground;
  final TextStyle textStyle;
  final Color? border;
  final Color? pressedFill;
  final Color overlay;
  final Color? disabledFill;
  final Color disabledForeground;
  final double iconSize;
  final double iconGap;
}

const _onDarkPressed = Color(0x1FFFFFFF);

/// The buttons of the kit, one named constructor per family; disabled
/// when [onPressed] is null, a spinner (and not tappable) while [loading].
/// [expand] stretches the button to the available width (default: the
/// large sizes).
class KivetoButton extends StatelessWidget {
  /// C-1: brand fill (L 52, M 48, S 40); C-1d when disabled.
  new primary({
    required this.label,
    required this.onPressed,
    super.key,
    this.size = KivetoButtonSize.large,
    this.icon,
    this.loading = false,
    bool? expand,
  }) : _spec = switch (size) {
         KivetoButtonSize.large => _primary(
           52,
           12,
           16,
           KivetoText.sectionTitle,
         ),
         KivetoButtonSize.medium => _primary(48, 12, 22, KivetoText.itemTitle),
         KivetoButtonSize.small => _primary(40, 10, 14, KivetoText.labelStrong),
       },
       expand = expand ?? size == KivetoButtonSize.large;

  /// C-2: ink fill, 48, leading icon 18.
  new dark({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.loading = false,
    bool? expand,
  }) : size = KivetoButtonSize.medium,
       _spec = _ButtonSpec(
         height: 48,
         radius: KivetoRadius.l,
         fill: KivetoColors.ink,
         foreground: KivetoColors.surface,
         textStyle: KivetoText.itemTitle,
         overlay: _onDarkPressed,
         disabledFill: KivetoColors.neutralSoft,
         iconSize: 18,
       ),
       expand = expand ?? true;

  /// C-3: danger fill (L 52, S 40); disabled colours of §2.1.
  new danger({
    required this.label,
    required this.onPressed,
    super.key,
    this.size = KivetoButtonSize.large,
    this.icon,
    this.loading = false,
    bool? expand,
  }) : _spec = size == KivetoButtonSize.large
           ? _danger(52, 12, 16, KivetoText.sectionTitle)
           : _danger(40, 10, 12, KivetoText.labelSmallStrong),
       expand = expand ?? size == KivetoButtonSize.large;

  /// C-4: white with a strong border (L 48, M 44 with an optional icon,
  /// S 36).
  new outline({
    required this.label,
    required this.onPressed,
    super.key,
    this.size = KivetoButtonSize.medium,
    this.icon,
    this.loading = false,
    bool? expand,
  }) : _spec = switch (size) {
         KivetoButtonSize.large => _outline(48, 12, 16, KivetoText.label),
         KivetoButtonSize.medium => _outline(44, 10, 16, KivetoText.label),
         KivetoButtonSize.small => _outline(36, 8, 12, KivetoText.labelSmall),
       },
       expand = expand ?? size == KivetoButtonSize.large;

  /// C-4c: white, strong border, brand label, 40.
  new outlineBrand({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.loading = false,
    bool? expand,
  }) : size = KivetoButtonSize.small,
       _spec = _ButtonSpec(
         height: 40,
         radius: KivetoRadius.m,
         fill: KivetoColors.surface,
         foreground: KivetoColors.brand,
         textStyle: KivetoText.labelSmall,
         border: KivetoColors.borderStrong,
       ),
       expand = expand ?? true;

  /// C-5: white, soft danger border, danger label, 44.
  new outlineDanger({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.loading = false,
    bool? expand,
  }) : size = KivetoButtonSize.medium,
       _spec = _ButtonSpec(
         height: 44,
         radius: KivetoRadius.m,
         fill: KivetoColors.surface,
         foreground: KivetoColors.danger,
         textStyle: KivetoText.label,
         border: KivetoColors.dangerBorderSoft,
       ),
       expand = expand ?? true;

  /// C-6: brand-soft fill (S 36 with an icon, M 44).
  new tonal({
    required this.label,
    required this.onPressed,
    super.key,
    this.size = KivetoButtonSize.small,
    this.icon,
    this.loading = false,
    bool? expand,
  }) : _spec = size == KivetoButtonSize.small
           ? _ButtonSpec(
               height: 36,
               radius: KivetoRadius.s,
               padding: 10,
               fill: KivetoColors.brandSoft,
               foreground: KivetoColors.brand,
               textStyle: KivetoText.labelSmall,
               disabledFill: KivetoColors.neutralSoft,
               iconGap: 6,
             )
           : _ButtonSpec(
               height: 44,
               radius: KivetoRadius.m,
               fill: KivetoColors.brandSoft,
               foreground: KivetoColors.brand,
               textStyle: KivetoText.labelStrong,
               disabledFill: KivetoColors.neutralSoft,
             ),
       expand = expand ?? size != KivetoButtonSize.small;

  /// C-7: the white button of the brand hero card, 44.
  new onBrand({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.loading = false,
    bool? expand,
  }) : size = KivetoButtonSize.medium,
       _spec = _ButtonSpec(
         height: 44,
         radius: KivetoRadius.m,
         fill: KivetoColors.surface,
         foreground: KivetoColors.brand,
         textStyle: KivetoText.labelStrong,
         disabledFill: KivetoColors.brandDisabled,
         disabledForeground: KivetoColors.onBrandSoftMuted,
       ),
       expand = expand ?? true;

  /// C-7: the outline button of the brand hero card, 44.
  new onBrandOutline({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.loading = false,
    bool? expand,
  }) : size = KivetoButtonSize.medium,
       _spec = _ButtonSpec(
         height: 44,
         radius: KivetoRadius.m,
         fill: const Color(0x00000000),
         foreground: KivetoColors.surface,
         textStyle: KivetoText.label,
         border: KivetoColors.onBrandOutline,
         overlay: _onDarkPressed,
         disabledForeground: KivetoColors.onBrandMuted,
       ),
       expand = expand ?? false;

  static _ButtonSpec _primary(
    double height,
    double radius,
    double padding,
    TextStyle style,
  ) => _ButtonSpec(
    height: height,
    radius: radius,
    padding: padding,
    fill: KivetoColors.brand,
    foreground: KivetoColors.surface,
    textStyle: style,
    pressedFill: KivetoColors.brandPressed,
    disabledFill: KivetoColors.brandDisabled,
    disabledForeground: KivetoColors.onBrandSoftMuted,
  );

  static _ButtonSpec _danger(
    double height,
    double radius,
    double padding,
    TextStyle style,
  ) => _ButtonSpec(
    height: height,
    radius: radius,
    padding: padding,
    fill: KivetoColors.danger,
    foreground: KivetoColors.surface,
    textStyle: style,
    overlay: _onDarkPressed,
    disabledFill: KivetoColors.dangerDisabled,
    disabledForeground: KivetoColors.onDangerDisabled,
  );

  static _ButtonSpec _outline(
    double height,
    double radius,
    double padding,
    TextStyle style,
  ) => _ButtonSpec(
    height: height,
    radius: radius,
    padding: padding,
    fill: KivetoColors.surface,
    foreground: KivetoColors.ink,
    textStyle: style,
    border: KivetoColors.borderStrong,
  );

  final String label;
  final VoidCallback? onPressed;
  final KivetoButtonSize size;
  final LucideGlyph? icon;
  final bool loading;
  final bool expand;
  final _ButtonSpec _spec;

  @override
  Widget build(BuildContext context) {
    final spec = _spec;
    final disabled = onPressed == null && !loading;
    final foreground = disabled ? spec.disabledForeground : spec.foreground;
    final glyph = icon;
    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (glyph != null) ...[
          KivetoIcon(glyph, size: spec.iconSize, color: foreground),
          SizedBox(width: spec.iconGap),
        ],
        Flexible(child: Text(label, textAlign: TextAlign.center)),
      ],
    );
    if (loading) {
      content = Stack(
        alignment: Alignment.center,
        children: [
          Opacity(opacity: 0, child: content),
          SizedBox.square(
            dimension: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: spec.foreground,
              semanticsLabel: AppLocalizations.of(context).commonLoading,
            ),
          ),
        ],
      );
    }
    final button = TextButton(
      onPressed: loading ? null : onPressed,
      style: ButtonStyle(
        minimumSize: WidgetStatePropertyAll(
          Size(expand ? double.infinity : 0, spec.height),
        ),
        padding: WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: spec.padding),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(spec.radius),
          ),
        ),
        side: spec.border == null
            ? null
            : WidgetStatePropertyAll(BorderSide(color: spec.border!)),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (disabled) return spec.disabledFill ?? spec.fill;
          if (states.contains(WidgetState.pressed)) {
            return spec.pressedFill ?? spec.fill;
          }
          return spec.fill;
        }),
        foregroundColor: WidgetStatePropertyAll(foreground),
        overlayColor: WidgetStateProperty.resolveWith(
          (states) =>
              spec.pressedFill == null && states.contains(WidgetState.pressed)
              ? spec.overlay
              : const Color(0x00000000),
        ),
        textStyle: WidgetStatePropertyAll(spec.textStyle),
        elevation: const WidgetStatePropertyAll(0),
        splashFactory: NoSplash.splashFactory,
        tapTargetSize: MaterialTapTargetSize.padded,
        visualDensity: VisualDensity.standard,
      ),
      child: content,
    );
    // A button that does not stretch keeps its own width, at the start
    // (`align-self: start` in the mockup), even under tight constraints.
    return expand
        ? button
        : Align(
            alignment: AlignmentDirectional.centerStart,
            widthFactor: 1,
            heightFactor: 1,
            child: button,
          );
  }
}

/// C-8a: a text button, 44 high, left-aligned; 14/700 brand, or 14/600
/// grey when disabled (a countdown label).
class KivetoTextButton extends StatelessWidget {
  const new({required this.label, required this.onPressed, super.key});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Align(
    alignment: AlignmentDirectional.centerStart,
    child: _LinkLikeButton(
      label: label,
      onPressed: onPressed,
      style: onPressed == null
          ? KivetoText.label.copyWith(color: KivetoColors.inkDisabled)
          : KivetoText.labelStrong.copyWith(color: KivetoColors.brand),
    ),
  );
}

/// C-8b: a centred text link, 44 high, 14/600 brand.
class KivetoLinkButton extends StatelessWidget {
  const new({required this.label, required this.onPressed, super.key});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Center(
    child: _LinkLikeButton(
      label: label,
      onPressed: onPressed,
      style: KivetoText.label.copyWith(
        color: onPressed == null
            ? KivetoColors.inkDisabled
            : KivetoColors.brand,
      ),
    ),
  );
}

class _LinkLikeButton extends StatelessWidget {
  const new({
    required this.label,
    required this.onPressed,
    required this.style,
  });

  final String label;
  final VoidCallback? onPressed;
  final TextStyle style;

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: onPressed,
    style: ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size(0, 44)),
      padding: const WidgetStatePropertyAll(EdgeInsets.zero),
      textStyle: WidgetStatePropertyAll(style),
      foregroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.pressed)
            ? KivetoColors.brandPressed
            : style.color,
      ),
      overlayColor: const WidgetStatePropertyAll(Color(0x00000000)),
      splashFactory: NoSplash.splashFactory,
    ),
    child: Text(label),
  );
}

/// A part of [KivetoInlineLinks]: plain text, or a link.
@immutable
final class InlinePart {
  /// Plain text in the paragraph's style.
  const new text(this.text) : onTap = null, underline = false, strong = false;

  /// A brand link: underlined inside sentences (the default), plain and
  /// 13/600 or 13/700 ([strong]) as a standalone link.
  const new link(
    this.text, {
    required VoidCallback this.onTap,
    this.underline = true,
    this.strong = false,
  });

  final String text;
  final VoidCallback? onTap;
  final bool underline;
  final bool strong;
}

/// C-8c: a paragraph with inline brand links ("J'accepte les conditions
/// d'utilisation…", "Tout voir").
class KivetoInlineLinks extends StatefulWidget {
  const new(this.parts, {super.key, this.style, this.textAlign});

  final List<InlinePart> parts;

  /// The paragraph style (default: 13 px body, secondary ink).
  final TextStyle? style;
  final TextAlign? textAlign;

  @override
  State<KivetoInlineLinks> createState() => _KivetoInlineLinksState();
}

class _KivetoInlineLinksState extends State<KivetoInlineLinks> {
  /// One recognizer per link, kept across builds (a rebuild between the
  /// pointer down and up must not drop the tap): only their callbacks are
  /// updated; they are disposed with the state.
  final _recognizers = <TapGestureRecognizer>[];

  @override
  void initState() {
    super.initState();
    _syncRecognizers();
  }

  @override
  void didUpdateWidget(KivetoInlineLinks oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncRecognizers();
  }

  @override
  void dispose() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    super.dispose();
  }

  void _syncRecognizers() {
    final taps = [for (final part in widget.parts) ?part.onTap];
    while (_recognizers.length > taps.length) {
      _recognizers.removeLast().dispose();
    }
    while (_recognizers.length < taps.length) {
      _recognizers.add(TapGestureRecognizer());
    }
    for (var i = 0; i < taps.length; i++) {
      _recognizers[i].onTap = taps[i];
    }
  }

  @override
  Widget build(BuildContext context) {
    var link = 0;
    final base =
        widget.style ??
        KivetoText.bodySmall.copyWith(
          color: KivetoColors.inkSecondary,
          height: 1.45,
        );
    return Text.rich(
      TextSpan(
        style: base,
        children: [
          for (final part in widget.parts)
            if (part.onTap != null)
              TextSpan(
                text: part.text,
                style: TextStyle(
                  color: KivetoColors.brand,
                  fontWeight: part.strong ? FontWeight.w700 : FontWeight.w600,
                  decoration: part.underline ? TextDecoration.underline : null,
                  decorationColor: KivetoColors.brand,
                ),
                recognizer: _recognizers[link++],
              )
            else
              TextSpan(text: part.text),
        ],
      ),
      textAlign: widget.textAlign,
    );
  }
}

/// The 44 × 44 icon buttons (C-9); the semantic label is required (back
/// and close default to the kit's own labels).
class KivetoIconButton extends StatelessWidget {
  /// C-9a: chevron-left 22, shifted 10 px left so the glyph aligns with
  /// the gutter.
  const new back({
    required this.onPressed,
    super.key,
    this.semanticLabel,
    this.offset = -10,
  }) : glyph = LucideGlyph.chevronLeft,
       _kind = _IconButtonKind.plain,
       _back = true;

  /// C-9b: x 22, shifted 10 px right.
  const new close({
    required this.onPressed,
    super.key,
    this.semanticLabel,
    this.offset = 10,
  }) : glyph = LucideGlyph.x,
       _kind = _IconButtonKind.plain,
       _back = false;

  /// C-9c: a white circle with a border (the bell of the home).
  const new roundOutline({
    required this.glyph,
    required String this.semanticLabel,
    required this.onPressed,
    super.key,
  }) : _kind = _IconButtonKind.roundOutline,
       offset = 0,
       _back = null;

  /// C-9d: a brand circle with a white glyph (stroke 2.2).
  const new fab({
    required this.glyph,
    required String this.semanticLabel,
    required this.onPressed,
    super.key,
  }) : _kind = _IconButtonKind.fab,
       offset = 0,
       _back = null;

  /// C-9e: a muted square (the download button of a document).
  const new squareMuted({
    required this.glyph,
    required String this.semanticLabel,
    required this.onPressed,
    super.key,
  }) : _kind = _IconButtonKind.squareMuted,
       offset = 0,
       _back = null;

  final LucideGlyph glyph;
  final String? semanticLabel;
  final VoidCallback? onPressed;

  /// Horizontal shift of the drawn button (negative margins of the
  /// mockup), without changing the layout.
  final double offset;
  final _IconButtonKind _kind;
  final bool? _back;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label =
        semanticLabel ??
        switch (_back) {
          true => l10n.commonBack,
          _ => l10n.commonClose,
        };
    final (fill, border, color, shape, glyphSize, stroke) = switch (_kind) {
      _IconButtonKind.plain => (
        const Color(0x00000000),
        null,
        KivetoColors.ink,
        const CircleBorder(),
        22.0,
        2.0,
      ),
      _IconButtonKind.roundOutline => (
        KivetoColors.surface,
        KivetoColors.border,
        KivetoColors.ink,
        const CircleBorder(),
        20.0,
        2.0,
      ),
      _IconButtonKind.fab => (
        KivetoColors.brand,
        null,
        KivetoColors.surface,
        const CircleBorder(),
        20.0,
        2.2,
      ),
      _IconButtonKind.squareMuted => (
        KivetoColors.canvas,
        null,
        KivetoColors.ink,
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        18.0,
        2.0,
      ),
    };
    final button = Semantics(
      button: true,
      enabled: onPressed != null,
      label: label,
      // The child's tap action is excluded with its semantics: give it back.
      onTap: onPressed,
      excludeSemantics: true,
      child: Material(
        color: fill,
        shape: border == null
            ? shape
            : CircleBorder(side: BorderSide(color: border)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          splashFactory: NoSplash.splashFactory,
          overlayColor: WidgetStatePropertyAll(
            _kind == _IconButtonKind.fab
                ? KivetoColors.brandPressed
                : KivetoColors.inkPressed,
          ),
          child: SizedBox.square(
            dimension: 44,
            child: Center(
              child: KivetoIcon(
                glyph,
                size: glyphSize,
                color: color,
                strokeWidth: stroke,
              ),
            ),
          ),
        ),
      ),
    );
    // 44 × 44 even under tight constraints: back at the start, close at
    // the end.
    return Align(
      alignment: switch (_back) {
        true => AlignmentDirectional.centerStart,
        false => AlignmentDirectional.centerEnd,
        null => AlignmentDirectional.center,
      },
      widthFactor: 1,
      heightFactor: 1,
      child: offset == 0
          ? button
          : Transform.translate(offset: Offset(offset, 0), child: button),
    );
  }
}

enum _IconButtonKind { plain, roundOutline, fab, squareMuted }
