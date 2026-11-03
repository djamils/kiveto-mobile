import 'package:kiveto_mobile/shared/presentation/icons/kiveto_icon.dart';
import 'package:kiveto_mobile/shared/presentation/icons/lucide_glyph.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/kit/pills.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_colors.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_layout.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_text.dart';
import 'package:material_ui/material_ui.dart';

/// One segment of a [KivetoSegmentedControl].
@immutable
final class KivetoSegment<T> {
  const new(this.value, this.label);

  final T value;
  final String label;
}

/// C-15a: a full-width segmented control (two equal columns, radius 12);
/// C-15b ([compact]): stadium segments sized to their labels.
class KivetoSegmentedControl<T> extends StatelessWidget {
  const new({
    required this.segments,
    required this.selected,
    required this.onChanged,
    super.key,
    this.compact = false,
  });

  final List<KivetoSegment<T>> segments;
  final T selected;
  final ValueChanged<T>? onChanged;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final radius = compact ? KivetoRadius.pill : KivetoRadius.l;
    final children = <Widget>[];
    for (var i = 0; i < segments.length; i++) {
      if (i > 0) children.add(const SizedBox(width: KivetoSpace.xs));
      final segment = _segment(segments[i]);
      children.add(compact ? segment : Expanded(child: segment));
    }
    return Container(
      padding: const EdgeInsets.all(KivetoSpace.xs),
      decoration: BoxDecoration(
        color: KivetoColors.track,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Row(
        mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
        children: children,
      ),
    );
  }

  Widget _segment(KivetoSegment<T> segment) {
    final active = segment.value == selected;
    final onChanged = this.onChanged;
    final style = compact
        ? (active ? KivetoText.labelSmallStrong : KivetoText.labelSmall)
        : (active ? KivetoText.labelStrong : KivetoText.label);
    return Semantics(
      button: true,
      selected: active,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onChanged == null ? null : () => onChanged(segment.value),
        child: AnimatedContainer(
          duration: KivetoMotion.duration,
          curve: KivetoMotion.curve,
          constraints: BoxConstraints(minHeight: compact ? 36 : 40),
          padding: EdgeInsets.symmetric(horizontal: compact ? 16 : 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? KivetoColors.surface : const Color(0x00FFFFFF),
            borderRadius: BorderRadius.circular(
              compact ? KivetoRadius.pill : KivetoRadius.segment,
            ),
          ),
          child: Text(
            segment.label,
            textAlign: TextAlign.center,
            style: style.copyWith(
              color: active ? KivetoColors.ink : KivetoColors.inkMuted,
            ),
          ),
        ),
      ),
    );
  }
}

/// C-16: the booking wizard header: back, "Étape n sur 4", close, the
/// progress bars, the title.
class WizardHeader extends StatelessWidget {
  const new({
    required this.step,
    required this.stepLabel,
    required this.title,
    required this.onBack,
    required this.onClose,
    super.key,
    this.total = 4,
    this.overTitle,
  });

  final int step;
  final int total;

  /// "Étape 3 sur 4", from the slice's ARB.
  final String stepLabel;
  final String title;
  final VoidCallback onBack;
  final VoidCallback onClose;

  /// A widget between the progress bars and the title, 10 above the
  /// title (the clinic chip of screen 12).
  final Widget? overTitle;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          KivetoIconButton.back(onPressed: onBack),
          Text(
            stepLabel,
            style: KivetoText.labelSmall.copyWith(color: KivetoColors.inkMuted),
          ),
          KivetoIconButton.close(onPressed: onClose),
        ],
      ),
      const SizedBox(height: KivetoSpace.xl3),
      Row(
        children: [
          for (var i = 1; i <= total; i++) ...[
            if (i > 1) const SizedBox(width: KivetoSpace.s),
            Expanded(
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: i <= step ? KivetoColors.brand : KivetoColors.border,
                  borderRadius: BorderRadius.circular(KivetoRadius.bar),
                ),
              ),
            ),
          ],
        ],
      ),
      const SizedBox(height: KivetoSpace.xl3),
      if (overTitle case final overTitle?) ...[
        Align(alignment: AlignmentDirectional.centerStart, child: overTitle),
        const SizedBox(height: KivetoSpace.m),
      ],
      Semantics(header: true, child: Text(title, style: KivetoText.flowTitle)),
    ],
  );
}

/// The white bottom bar of the flows: border-top, padding 14 20 22 (the
/// bottom inset rule applied).
class _StickyBar extends StatelessWidget {
  const new({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      color: KivetoColors.surface,
      border: Border(top: BorderSide(color: KivetoColors.border)),
    ),
    child: Padding(
      padding: EdgeInsets.fromLTRB(
        KivetoSpace.gutter,
        14,
        KivetoSpace.gutter,
        kivetoBottomPadding(context, 22),
      ),
      child: child,
    ),
  );
}

/// C-17a: the sticky summary bar of the wizard: a label and a value, and
/// an action (a medium primary button).
class StickySummaryBar extends StatelessWidget {
  const new({
    required this.label,
    required this.value,
    required this.action,
    super.key,
  });

  final String label;
  final String value;
  final Widget action;

  @override
  Widget build(BuildContext context) => _StickyBar(
    child: Row(
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: KivetoText.caption),
              const SizedBox(height: KivetoSpace.xxs),
              Text(value, style: KivetoText.itemTitle),
            ],
          ),
        ),
        const SizedBox(width: KivetoSpace.ml),
        action,
      ],
    ),
  );
}

/// C-17b: a sticky bar holding one full-width button.
class StickyCtaBar extends StatelessWidget {
  const new({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => _StickyBar(child: child);
}

/// C-17c: a bottom area without border: padding 14 24 28 (auth) or
/// 14 20 22 ([success] views), children 10 apart.
class BottomCtaArea extends StatelessWidget {
  const new({required this.children, super.key, this.success = false});

  final List<Widget> children;
  final bool success;

  @override
  Widget build(BuildContext context) {
    final gutter = success ? KivetoSpace.gutter : KivetoSpace.authGutter;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        gutter,
        14,
        gutter,
        kivetoBottomPadding(context, success ? 22 : 28),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(height: KivetoSpace.m),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// A tab of the [KivetoBottomNav]: a glyph, or an initials avatar (the
/// account tab; null initials draw a plain avatar).
@immutable
final class KivetoNavItem {
  const new({
    required this.label,
    this.glyph,
    this.avatar = false,
    this.initials,
    this.badgeCount = 0,
    this.semanticLabel,
  });

  final String label;
  final LucideGlyph? glyph;

  /// Draws a 24 avatar instead of [glyph].
  final bool avatar;
  final String? initials;

  /// Hidden at 0, "99+" above 99.
  final int badgeCount;

  /// What a screen reader says instead of [label] ("Documents, 2
  /// nouveaux", from the ARB).
  final String? semanticLabel;
}

/// C-26: the bottom navigation of the tabbed screens.
class KivetoBottomNav extends StatelessWidget {
  const new({
    required this.items,
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final List<KivetoNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: KivetoColors.canvas,
    child: Padding(
      padding: EdgeInsets.fromLTRB(12, 8, 12, kivetoBottomPadding(context, 18)),
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: KivetoSpace.xs),
        decoration: BoxDecoration(
          color: KivetoColors.surface,
          border: Border.all(color: KivetoColors.border),
          borderRadius: BorderRadius.circular(KivetoRadius.nav),
          boxShadow: const [KivetoShadows.bottomNav],
        ),
        child: Row(
          children: [
            for (var i = 0; i < items.length; i++)
              Expanded(
                child: _tab(items[i], active: i == currentIndex, index: i),
              ),
          ],
        ),
      ),
    ),
  );

  Widget _tab(KivetoNavItem item, {required bool active, required int index}) {
    final color = active ? KivetoColors.brand : KivetoColors.inkMuted;
    final glyph = item.glyph;
    final icon = item.avatar
        ? InitialsAvatar(
            item.initials ?? '',
            size: 24,
            tone: active ? AvatarTone.brand : AvatarTone.ink,
          )
        : glyph == null
        ? const SizedBox.square(dimension: 20)
        : KivetoIcon(glyph, color: color);
    final count = item.badgeCount;
    return Semantics(
      button: true,
      selected: active,
      label: item.semanticLabel ?? item.label,
      onTap: () => onTap(index),
      excludeSemantics: true,
      child: InkWell(
        onTap: () => onTap(index),
        splashFactory: NoSplash.splashFactory,
        overlayColor: const WidgetStatePropertyAll(Color(0x00000000)),
        borderRadius: BorderRadius.circular(KivetoRadius.l),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 52,
              height: 28,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  AnimatedContainer(
                    duration: KivetoMotion.duration,
                    curve: KivetoMotion.curve,
                    decoration: BoxDecoration(
                      color: active
                          ? KivetoColors.brandSoft
                          : const Color(0x00EEF0FF),
                      borderRadius: BorderRadius.circular(KivetoRadius.xl),
                    ),
                  ),
                  icon,
                  if (count > 0)
                    Positioned(
                      top: -3,
                      right: 6,
                      child: _Badge(count > 99 ? '99+' : '$count'),
                    ),
                ],
              ),
            ),
            const SizedBox(height: KivetoSpace.tight),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: active ? KivetoText.navLabelActive : KivetoText.navLabel,
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const new(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Container(
    // Min 18 × 18: grows with large text instead of clipping "99+".
    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
    padding: const EdgeInsets.symmetric(horizontal: KivetoSpace.xs),
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: KivetoColors.badge,
      border: Border.all(color: KivetoColors.surface, width: 2),
      borderRadius: BorderRadius.circular(9),
    ),
    child: Text(text, style: KivetoText.micro),
  );
}

/// C-35: shows a [KivetoSheet] over the scrim, on the root navigator: the
/// scrim covers the whole screen, the bottom navigation included.
Future<T?> showKivetoSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) => showModalBottomSheet<T>(
  context: context,
  builder: builder,
  useRootNavigator: true,
  isScrollControlled: true,
  useSafeArea: true,
  barrierColor: KivetoColors.scrim,
  backgroundColor: KivetoColors.surface,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(
      top: Radius.circular(KivetoRadius.sheet),
    ),
  ),
);

/// C-35: the content of a bottom sheet: handle, title, subtitle, actions.
class KivetoSheet extends StatelessWidget {
  const new({
    required this.title,
    required this.children,
    super.key,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final subtitle = this.subtitle;
    // Above the keyboard, and scrollable when the content is taller than
    // the room left.
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          KivetoSpace.gutter,
          10,
          KivetoSpace.gutter,
          kivetoBottomPadding(context, 28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: KivetoColors.borderChip,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: KivetoSpace.xl2),
            Semantics(
              header: true,
              child: Text(
                title,
                style: kivetoTextStyle(
                  22,
                  FontWeight.w700,
                  letterSpacingEm: -0.01,
                  color: KivetoColors.ink,
                ),
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: KivetoSpace.s),
              Text(
                subtitle,
                style: KivetoText.body.copyWith(
                  color: KivetoColors.inkSecondary,
                ),
              ),
            ],
            const SizedBox(height: KivetoSpace.xl2),
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) const SizedBox(height: KivetoSpace.sm),
              children[i],
            ],
          ],
        ),
      ),
    );
  }
}
