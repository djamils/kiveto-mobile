import 'package:kiveto_mobile/shared/presentation/icons/svg_path_parser.dart';
import 'package:material_ui/material_ui.dart';

/// One element of a Lucide icon, on the 24 × 24 grid.
sealed class LucideElement {
  const new();

  void addTo(Path path);
}

/// `<path d="…"/>`.
final class LucidePath extends LucideElement {
  const new(this.data);

  final String data;

  @override
  void addTo(Path path) => path.addPath(parseSvgPath(data), Offset.zero);
}

/// `<circle cx cy r/>`.
final class LucideCircle extends LucideElement {
  const new(this.cx, this.cy, this.r);

  final double cx;
  final double cy;
  final double r;

  @override
  void addTo(Path path) =>
      path.addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r));
}

/// `<rect x y width height rx/>`.
final class LucideRect extends LucideElement {
  const new(this.x, this.y, this.width, this.height, {this.rx = 0});

  final double x;
  final double y;
  final double width;
  final double height;
  final double rx;

  @override
  void addTo(Path path) => path.addRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, width, height),
      Radius.circular(rx),
    ),
  );
}

/// `<line x1 y1 x2 y2/>`.
final class LucideLine extends LucideElement {
  const new(this.x1, this.y1, this.x2, this.y2);

  final double x1;
  final double y1;
  final double x2;
  final double y2;

  @override
  void addTo(Path path) => path
    ..moveTo(x1, y1)
    ..lineTo(x2, y2);
}

/// `<polyline points="…"/>` (`x y` pairs).
final class LucidePolyline extends LucideElement {
  const new(this.points);

  final List<double> points;

  @override
  void addTo(Path path) {
    path.moveTo(points[0], points[1]);
    for (var i = 2; i + 1 < points.length; i += 2) {
      path.lineTo(points[i], points[i + 1]);
    }
  }
}

/// The icons of the app: the 17 Lucide outlines of the mockup (some are
/// the mockup's simplified variants, kept as drawn) and 4 more for the
/// states the mockup does not draw. Lucide is ISC-licensed
/// (`assets/licenses/lucide.txt`, registered at startup).
enum LucideGlyph {
  chevronDown([LucidePath('m6 9 6 6 6-6')]),
  bell([
    LucidePath('M6 8a6 6 0 0 1 12 0c0 7 3 9 3 9H3s3-2 3-9'),
    LucidePath('M10.3 21a1.94 1.94 0 0 0 3.4 0'),
  ]),
  plus([LucidePath('M12 5v14M5 12h14')]),
  fileText([
    LucidePath('M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z'),
    LucidePath('M14 2v6h6M16 13H8M16 17H8'),
  ]),
  house([
    LucidePath(
      'M3 10.5 12 3l9 7.5V20a1 1 0 0 1-1 1h-5v-6H9v6H4a1 1 0 0 1-1-1z',
    ),
  ]),
  pawPrint([
    LucideCircle(11, 4, 2),
    LucideCircle(18, 8, 2),
    LucideCircle(20, 16, 2),
    LucidePath(
      'M9 10a5 5 0 0 1 5 5v3.5a3.5 3.5 0 0 1-6.84 1.045Q6.52 17.48 '
      '4.46 16.84A3.5 3.5 0 0 1 5.5 10Z',
    ),
  ]),
  calendar([
    LucideRect(3, 4, 18, 18, rx: 2),
    LucidePath('M16 2v4M8 2v4M3 10h18'),
  ]),
  chevronLeft([LucidePath('m15 18-6-6 6-6')]),
  penLine([
    LucidePath('M12 20h9'),
    LucidePath('M16.5 3.5a2.12 2.12 0 0 1 3 3L7 19l-4 1 1-4Z'),
  ]),
  download([
    LucidePath('M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4'),
    LucidePath('m7 10 5 5 5-5M12 15V3'),
  ]),
  x([LucidePath('M18 6 6 18M6 6l12 12')]),
  chevronRight([LucidePath('m9 18 6-6-6-6')]),
  trash([LucidePath('M3 6h18M8 6V4h8v2M19 6l-1 14H6L5 6')]),
  check([LucidePath('M20 6 9 17l-5-5')]),
  search([LucideCircle(11, 11, 7), LucidePath('m21 21-4.3-4.3')]),
  mapPin([
    LucidePath('M12 22s7-6.2 7-12a7 7 0 0 0-14 0c0 5.8 7 12 7 12Z'),
    LucideCircle(12, 10, 2.5),
  ]),
  phone([
    LucidePath(
      'M22 16.9v3a2 2 0 0 1-2.2 2 19.8 19.8 0 0 1-8.6-3.1 19.5 19.5 0 0 '
      '1-6-6A19.8 19.8 0 0 1 2.1 4.2 2 2 0 0 1 4.1 2h3a2 2 0 0 1 2 '
      '1.7c.1.9.4 1.8.7 2.7a2 2 0 0 1-.5 2.1L8 9.8a16 16 0 0 0 6 '
      '6l1.3-1.3a2 2 0 0 1 2.1-.4c.9.3 1.8.6 2.7.7a2 2 0 0 1 1.7 2Z',
    ),
  ]),
  circleAlert([
    LucideCircle(12, 12, 10),
    LucideLine(12, 8, 12, 12),
    LucideLine(12, 16, 12.01, 16),
  ]),
  wifiOff([
    LucidePath('M12 20h.01'),
    LucidePath('M8.5 16.429a5 5 0 0 1 7 0'),
    LucidePath('M5 12.859a10 10 0 0 1 5.17-2.69'),
    LucidePath('M19 12.859a10 10 0 0 0-2.007-1.523'),
    LucidePath('M2 8.82a15 15 0 0 1 4.177-2.643'),
    LucidePath('M22 8.82a15 15 0 0 0-11.288-3.764'),
    LucidePath('m2 2 20 20'),
  ]),
  inbox([
    LucidePolyline([22, 12, 16, 12, 14, 15, 10, 15, 8, 12, 2, 12]),
    LucidePath(
      'M5.45 5.11 2 12v6a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2v-6l-3.45-6.89A2 2 0 '
      '0 0 16.76 4H7.24a2 2 0 0 0-1.79 1.11z',
    ),
  ]),
  clock([LucideCircle(12, 12, 10), LucidePath('M12 6v6l4 2')]);

  new(this.elements);

  final List<LucideElement> elements;

  static final _paths = <LucideGlyph, Path>{};

  /// The outline on the 24 grid, built once.
  Path get path => _paths[this] ??= _build();

  Path _build() {
    final path = Path();
    for (final element in elements) {
      element.addTo(path);
    }
    return path;
  }
}
