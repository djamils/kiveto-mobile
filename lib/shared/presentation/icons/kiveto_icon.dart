import 'package:kiveto_mobile/shared/presentation/icons/lucide_glyph.dart';
import 'package:material_ui/material_ui.dart';

/// A Lucide outline: the 24-grid [glyph] scaled to [size], stroked
/// [strokeWidth] grid units wide with round caps and joins, in [color]
/// (default: the ambient [IconTheme] colour). Decorative unless
/// [semanticLabel] is given.
class KivetoIcon extends StatelessWidget {
  const new(
    this.glyph, {
    super.key,
    this.size = 20,
    this.color,
    this.strokeWidth = 2,
    this.semanticLabel,
  });

  final LucideGlyph glyph;
  final double size;
  final Color? color;
  final double strokeWidth;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final icon = CustomPaint(
      size: Size.square(size),
      painter: _GlyphPainter(
        glyph,
        color ?? IconTheme.of(context).color ?? const Color(0xFF18181B),
        strokeWidth,
      ),
    );
    final label = semanticLabel;
    return label == null
        ? ExcludeSemantics(child: icon)
        : Semantics(label: label, image: true, child: icon);
  }
}

final class _GlyphPainter extends CustomPainter {
  new(this.glyph, this.color, this.strokeWidth);

  final LucideGlyph glyph;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    // Uniform scale, centred: a box forced to another shape never
    // stretches the glyph.
    final side = size.shortestSide;
    canvas
      ..save()
      ..translate((size.width - side) / 2, (size.height - side) / 2)
      ..scale(side / 24)
      ..drawPath(
        glyph.path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = color
          ..isAntiAlias = true,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_GlyphPainter old) =>
      old.glyph != glyph ||
      old.color != color ||
      old.strokeWidth != strokeWidth;
}
