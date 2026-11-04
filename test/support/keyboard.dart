// iOS phone, number and multiline pads have no key that closes them: the
// pages and sheets that host such a field close the keyboard on a drag of
// their own scroll view (KeyboardDismissOnDrag), not on a drag that scrolls
// a field's text.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Shows the keyboard on [field] (a widget holding one text input), takes
/// [inset] logical pixels at the bottom of the view as the keyboard does,
/// runs [beforeDrag] (e.g. an assertion on the page's scroll extent), drags
/// upwards from the centre of [from] (not a text field: its own gestures
/// would take the drag), and expects the field to lose the focus and the
/// keyboard to hide. Run it under an iOS platform override
/// (`variant: TargetPlatformVariant.only(TargetPlatform.iOS)`).
Future<void> expectDragClosesKeyboard(
  WidgetTester tester, {
  required Finder field,
  required Finder from,
  double inset = 336,
  void Function()? beforeDrag,
}) async {
  await tester.showKeyboard(field);
  _takeKeyboardInset(tester, inset);
  await tester.pumpAndSettle();
  final focus = tester.binding.focusManager.primaryFocus;
  expect(focus?.hasFocus, isTrue, reason: 'the field has the focus');
  expect(tester.testTextInput.isVisible, isTrue, reason: 'the keyboard shows');
  beforeDrag?.call();

  await tester.dragFrom(tester.getCenter(from), const Offset(0, -120));
  await tester.pumpAndSettle();

  expect(focus?.hasFocus, isFalse, reason: 'a drag closes the keyboard');
  expect(tester.testTextInput.isVisible, isFalse);
}

/// Types more lines than the multiline [field] shows, with the keyboard
/// taking [inset] logical pixels: a drag inside the field scrolls its text
/// and keeps the keyboard; then a drag on the page from [from] closes it.
/// Run it under an iOS platform override.
Future<void> expectTextScrollKeepsKeyboard(
  WidgetTester tester, {
  required Finder field,
  required Finder from,
  double inset = 336,
}) async {
  await tester.enterText(
    field,
    [for (var line = 1; line <= 8; line++) 'Ligne $line'].join('\n'),
  );
  _takeKeyboardInset(tester, inset);
  await tester.pumpAndSettle();
  final focus = tester.binding.focusManager.primaryFocus;
  expect(focus?.hasFocus, isTrue, reason: 'the field has the focus');
  final text = tester.state<ScrollableState>(
    find.descendant(of: field, matching: find.byType(Scrollable)),
  );
  expect(
    text.position.maxScrollExtent,
    greaterThan(0),
    reason: 'the field holds more lines than it shows',
  );
  final scrolled = text.position.pixels;

  // Down, towards the first lines (the caret keeps the last ones in view).
  await tester.dragFrom(
    tester.getCenter(
      find.descendant(of: field, matching: find.byType(EditableText)),
    ),
    const Offset(0, 40),
  );
  await tester.pumpAndSettle();

  expect(
    text.position.pixels,
    isNot(scrolled),
    reason: 'the drag scrolled the text',
  );
  expect(focus?.hasFocus, isTrue, reason: "scrolling the field's text");
  expect(tester.testTextInput.isVisible, isTrue);

  await tester.dragFrom(tester.getCenter(from), const Offset(0, -120));
  await tester.pumpAndSettle();

  expect(focus?.hasFocus, isFalse, reason: 'a drag on the page');
  expect(tester.testTextInput.isVisible, isFalse);
}

void _takeKeyboardInset(WidgetTester tester, double inset) {
  tester.view.viewInsets = FakeViewPadding(
    bottom: inset * tester.view.devicePixelRatio,
  );
  addTearDown(tester.view.resetViewInsets);
}
