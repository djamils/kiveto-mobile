import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/presentation/icons/kiveto_icon.dart';
import 'package:kiveto_mobile/shared/presentation/icons/lucide_glyph.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_colors.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_layout.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_text.dart';
import 'package:material_ui/material_ui.dart';

enum _CalloutKind { info, brand, warning, danger }

/// C-33: the boxes of information: neutral info (a), brand with an action
/// (b), warning (c), danger with an action (e).
class KivetoCallout extends StatelessWidget {
  /// C-33a: on canvas, a title, a body and an optional brand link.
  const new info({
    required String this.title,
    required this.body,
    super.key,
    this.actionLabel,
    this.onAction,
  }) : _kind = _CalloutKind.info;

  /// C-33b: brand-soft with a border, a title, a body and a small primary
  /// button.
  const new brand({
    required String this.title,
    required this.body,
    super.key,
    this.actionLabel,
    this.onAction,
  }) : _kind = _CalloutKind.brand;

  /// C-33c: an amber text box.
  const new warning({required this.body, super.key})
    : title = null,
      actionLabel = null,
      onAction = null,
      _kind = _CalloutKind.warning;

  /// C-33e: a red text box with a small danger button.
  const new danger({
    required this.body,
    super.key,
    this.actionLabel,
    this.onAction,
  }) : title = null,
       _kind = _CalloutKind.danger;

  final String? title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;
  final _CalloutKind _kind;

  @override
  Widget build(BuildContext context) {
    final title = this.title;
    final action = actionLabel;
    switch (_kind) {
      case _CalloutKind.info || _CalloutKind.brand:
        final brand = _kind == _CalloutKind.brand;
        return _box(
          fill: brand ? KivetoColors.brandSoft : KivetoColors.canvas,
          border: brand ? KivetoColors.brandBorderSoft : null,
          padding: EdgeInsets.all(brand ? 14 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title!,
                style: KivetoText.labelStrong.copyWith(
                  color: brand ? KivetoColors.onBrandSoft : KivetoColors.ink,
                ),
              ),
              SizedBox(height: brand ? KivetoSpace.m : KivetoSpace.ml),
              Text(
                body,
                style: KivetoText.bodySmall.copyWith(
                  height: brand ? 1.4 : 1.45,
                  color: brand
                      ? KivetoColors.onBrandSoftMuted
                      : KivetoColors.inkMuted,
                ),
              ),
              if (action != null) ...[
                SizedBox(height: brand ? KivetoSpace.m : KivetoSpace.ml),
                if (brand)
                  KivetoButton.primary(
                    label: action,
                    onPressed: onAction,
                    size: KivetoButtonSize.small,
                  )
                else
                  KivetoInlineLinks([
                    InlinePart.link(
                      action,
                      onTap: onAction ?? () {},
                      underline: false,
                      strong: true,
                    ),
                  ]),
              ],
            ],
          ),
        );
      case _CalloutKind.warning:
        return _box(
          fill: KivetoColors.warningSoft,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          child: Text(
            body,
            style: KivetoText.bodySmall.copyWith(
              height: 1.45,
              color: KivetoColors.onWarningSoft,
            ),
          ),
        );
      case _CalloutKind.danger:
        return _box(
          fill: KivetoColors.dangerSoft,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  body,
                  style: KivetoText.bodySmall.copyWith(
                    height: 1.4,
                    color: KivetoColors.onDangerSoft,
                  ),
                ),
              ),
              if (action != null) ...[
                const SizedBox(width: KivetoSpace.ml),
                KivetoButton.danger(
                  label: action,
                  onPressed: onAction,
                  size: KivetoButtonSize.small,
                ),
              ],
            ],
          ),
        );
    }
  }

  static Widget _box({
    required Color fill,
    required EdgeInsets padding,
    required Widget child,
    Color? border,
  }) => Container(
    width: double.infinity,
    padding: padding,
    decoration: BoxDecoration(
      color: fill,
      border: border == null ? null : Border.all(color: border),
      borderRadius: BorderRadius.circular(KivetoRadius.l),
    ),
    child: child,
  );
}

/// C-33f: a footnote or hint: 13/1.45 grey, or 12/1.4 ([small]).
class KivetoFootnote extends StatelessWidget {
  const new(this.text, {super.key, this.small = false, this.centered = false});

  final String text;
  final bool small;
  final bool centered;

  @override
  Widget build(BuildContext context) => Text(
    text,
    textAlign: centered ? TextAlign.center : null,
    style: small
        ? KivetoText.caption.copyWith(height: 1.4)
        : KivetoText.bodySmall.copyWith(height: 1.45),
  );
}

/// C-40: green checks and short reassuring lines.
class ReassuranceList extends StatelessWidget {
  const new(this.items, {super.key});

  final List<String> items;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (var i = 0; i < items.length; i++) ...[
        if (i > 0) const SizedBox(height: KivetoSpace.m),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const KivetoIcon(
              LucideGlyph.check,
              size: 18,
              strokeWidth: 2.2,
              color: KivetoColors.success,
            ),
            const SizedBox(width: KivetoSpace.m),
            Expanded(
              child: Text(
                items[i],
                style: KivetoText.body.copyWith(
                  color: KivetoColors.inkSecondary,
                ),
              ),
            ),
          ],
        ),
      ],
    ],
  );
}

/// The check in a circle of the success states: 72 with a 36 check
/// (C-34a), 64 with a 30 check (C-34b).
class _SuccessMark extends StatelessWidget {
  const new({
    required this.size,
    required this.checkSize,
    required this.colors,
  });

  final double size;
  final double checkSize;
  final KivetoColorSet colors;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(color: colors.fill, shape: BoxShape.circle),
    child: KivetoIcon(
      LucideGlyph.check,
      size: checkSize,
      strokeWidth: 2.4,
      color: colors.foreground,
    ),
  );
}

/// C-34a: the full-screen success state (the body of the screen; its
/// bottom area is a `BottomCtaArea`).
class SuccessView extends StatelessWidget {
  const new({
    required this.title,
    required this.message,
    super.key,
    this.note,
    this.action,
  });

  final String title;
  final String message;
  final String? note;

  /// An inline outline button ("Ajouter à mon calendrier").
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final note = this.note;
    final action = this.action;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const _SuccessMark(
            size: 72,
            checkSize: 36,
            colors: KivetoColorSets.green,
          ),
          const SizedBox(height: KivetoSpace.xl),
          Semantics(
            header: true,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: KivetoText.pageTitle,
            ),
          ),
          const SizedBox(height: KivetoSpace.xl),
          Text(
            message,
            textAlign: TextAlign.center,
            style: KivetoText.bodyLarge.copyWith(
              color: KivetoColors.inkSecondary,
            ),
          ),
          if (note != null) ...[
            const SizedBox(height: KivetoSpace.xl),
            KivetoFootnote(note, centered: true),
          ],
          if (action != null) ...[
            const SizedBox(height: KivetoSpace.xl),
            action,
          ],
        ],
      ),
    );
  }
}

/// C-34b: the neutral success state inside a sheet ("Rendez-vous annulé").
class SheetSuccessView extends StatelessWidget {
  const new({
    required this.title,
    required this.message,
    required this.action,
    super.key,
  });

  final String title;
  final String message;

  /// A large primary button, stretched.
  final Widget action;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _SuccessMark(
          size: 64,
          checkSize: 30,
          colors: KivetoColorSets.neutral,
        ),
        const SizedBox(height: KivetoSpace.l),
        Semantics(
          header: true,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: KivetoText.headline,
          ),
        ),
        const SizedBox(height: KivetoSpace.l),
        Text(
          message,
          textAlign: TextAlign.center,
          style: KivetoText.body.copyWith(
            height: 1.5,
            color: KivetoColors.inkSecondary,
          ),
        ),
        const SizedBox(height: KivetoSpace.l),
        SizedBox(width: double.infinity, child: action),
      ],
    ),
  );
}

/// C-43: a page-shaped loading placeholder: a title line, a 48 block and
/// two white cards (220 and 96).
class KivetoSkeleton extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) => Semantics(
    label: AppLocalizations.of(context).commonLoading,
    container: true,
    child: ExcludeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _block(width: 180, height: 26, radius: KivetoRadius.s),
          const SizedBox(height: KivetoSpace.xl2),
          _block(height: 48, radius: KivetoRadius.l),
          const SizedBox(height: KivetoSpace.xl2),
          _card(220),
          const SizedBox(height: KivetoSpace.m),
          _card(96),
        ],
      ),
    ),
  );

  static Widget _block({
    required double height,
    required double radius,
    double? width,
  }) => Container(
    width: width ?? double.infinity,
    height: height,
    decoration: BoxDecoration(
      color: KivetoColors.track,
      borderRadius: BorderRadius.circular(radius),
    ),
  );

  static Widget _card(double height) => Container(
    width: double.infinity,
    height: height,
    decoration: BoxDecoration(
      color: KivetoColors.surface,
      border: Border.all(color: KivetoColors.border),
      borderRadius: BorderRadius.circular(KivetoRadius.xl),
    ),
  );
}
