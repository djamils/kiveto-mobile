// globalRectOf: the window rect of a laid-out box (the iPad share popover's
// anchor), Rect.zero while the context has none.

import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_layout.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('a laid-out box: its global rect; before layout: Rect.zero', (
    tester,
  ) async {
    late BuildContext control;
    final duringBuild = <Rect>[];
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 30, top: 40),
            child: Builder(
              builder: (context) {
                control = context;
                // No render box below this context yet on the first build.
                duringBuild.add(globalRectOf(context));
                return const SizedBox(width: 100, height: 44);
              },
            ),
          ),
        ),
      ),
    );

    expect(duringBuild.first, Rect.zero);
    expect(globalRectOf(control), const Rect.fromLTWH(30, 40, 100, 44));
    expect(globalRectOf(control), tester.getRect(find.byType(SizedBox)));
  });
}
