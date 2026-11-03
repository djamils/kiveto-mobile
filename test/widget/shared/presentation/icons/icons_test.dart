import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/shared/presentation/icons/kiveto_icon.dart';
import 'package:kiveto_mobile/shared/presentation/icons/lucide_glyph.dart';
import 'package:kiveto_mobile/shared/presentation/icons/svg_path_parser.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../support/fakes.dart';

Rect _bounds(String data) => parseSvgPath(data).getBounds();

void main() {
  group('parseSvgPath', () {
    test('absolute M L H V Z', () {
      expect(_bounds('M2 3L10 3H12V9Z'), const Rect.fromLTRB(2, 3, 12, 9));
    });

    test('relative commands from the current point', () {
      expect(_bounds('m2 3 l8 0 h2 v6 z'), const Rect.fromLTRB(2, 3, 12, 9));
    });

    test('implicit repeats: a moveto repeats as a lineto', () {
      expect(_bounds('M0 0 10 0 10 10'), const Rect.fromLTRB(0, 0, 10, 10));
      expect(_bounds('m0 0 10 0 0 10'), const Rect.fromLTRB(0, 0, 10, 10));
    });

    test('compact numbers: .5.5, signs as separators, exponents', () {
      expect(_bounds('M.5.5L4-2'), const Rect.fromLTRB(0.5, -2, 4, 0.5));
      expect(
        _bounds('M19 12.859a10 10 0 0 0-2.007-1.523').left,
        closeTo(16.993, 0.001),
      );
      final exponents = _bounds('M1e1,0 L2E1 1e-1');
      expect(exponents.left, 10);
      expect(exponents.right, 20);
      expect(exponents.bottom, closeTo(0.1, 1e-6));
    });

    test('cubic curves; S reflects the previous control point', () {
      final reflected = _bounds('M0 0C0 10 10 10 10 0S20-10 20 0');
      expect(reflected.top, lessThan(-5));
      expect(reflected.bottom, greaterThan(5));
      // Without a previous C, S uses the current point as first control.
      expect(_bounds('M0 0S10 10 20 0').top, 0);
      expect(_bounds('m0 0c0 10 10 10 10 0s10-10 10 0').top, lessThan(-5));
    });

    test('quadratic curves; T reflects the previous control point', () {
      final reflected = _bounds('M0 0Q5 10 10 0T20 0');
      expect(reflected.top, lessThan(-2));
      expect(reflected.bottom, greaterThan(2));
      expect(_bounds('M0 0T10 0').height, 0);
      expect(_bounds('m0 0q5 10 10 0t10 0').top, lessThan(-2));
    });

    test('arcs, absolute and relative, with compact flags', () {
      final circle = _bounds('M2 12a10 10 0 1 1 20 0A10 10 0 1 1 2 12');
      expect(circle.left, closeTo(2, 0.01));
      expect(circle.right, closeTo(22, 0.01));
      expect(circle.top, closeTo(2, 0.01));
      expect(circle.bottom, closeTo(22, 0.01));
      expect(_bounds('M0 0a1 1 0 011 1').right, closeTo(1, 0.01));
      // The sweep flag picks the side: 1 is clockwise on screen (above the
      // chord, y down), 0 counter-clockwise (below).
      final clockwise = _bounds('M0 0A1 1 0 0 1 2 0');
      expect(clockwise.top, closeTo(-1, 0.01));
      expect(clockwise.bottom, closeTo(0, 0.01));
      final counterClockwise = _bounds('m0 0a1 1 0 0 0 2 0');
      expect(counterClockwise.bottom, closeTo(1, 0.01));
      expect(counterClockwise.top, closeTo(0, 0.01));
    });

    for (final data in ['L0 0', '5 5', 'M0', 'M0 0A1 1 0 2 0 5 5', 'M0 0Z 5']) {
      test('refuses "$data"', () {
        expect(() => parseSvgPath(data), throwsFormatException);
      });
    }

    test('empty data is an empty path', () {
      expect(parseSvgPath(' ').getBounds(), Rect.zero);
    });
  });

  test('every glyph parses within the 24 grid', () {
    for (final glyph in LucideGlyph.values) {
      final bounds = glyph.path.getBounds();
      expect(bounds.isEmpty, isFalse, reason: glyph.name);
      expect(
        const Rect.fromLTWH(-0.5, -0.5, 25, 25).contains(bounds.topLeft) &&
            const Rect.fromLTWH(
              -0.5,
              -0.5,
              25,
              25,
            ).contains(bounds.bottomRight),
        isTrue,
        reason: '${glyph.name}: $bounds',
      );
      expect(identical(glyph.path, glyph.path), isTrue);
    }
  });

  testWidgets('KivetoIcon draws every glyph at its size; decorative unless '
      'labelled', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpKit(
      tester,
      Wrap(
        children: [
          for (final glyph in LucideGlyph.values) KivetoIcon(glyph, size: 18),
          const KivetoIcon(
            LucideGlyph.bell,
            semanticLabel: 'Notifications',
            color: Color(0xFF4338CA),
            strokeWidth: 2.2,
          ),
        ],
      ),
    );

    expect(
      find.byType(KivetoIcon),
      findsNWidgets(LucideGlyph.values.length + 1),
    );
    expect(
      tester.getSize(find.byType(KivetoIcon).first),
      const Size.square(18),
    );
    expect(find.bySemanticsLabel('Notifications'), findsOneWidget);

    await pumpKit(tester, const KivetoIcon(LucideGlyph.bell, size: 24));
    expect(tester.getSize(find.byType(KivetoIcon)), const Size.square(24));
    handle.dispose();
  });
}
