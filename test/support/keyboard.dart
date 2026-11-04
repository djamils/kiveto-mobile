// iOS phone, number and multiline pads have no key that closes them: the
// pages and sheets that host such a field close the keyboard on a drag
// (ScrollViewKeyboardDismissBehavior.onDrag).

import 'package:flutter_test/flutter_test.dart';

/// Shows the keyboard on [field] (a widget holding one text input), takes
/// [inset] logical pixels at the bottom of the view as the keyboard does,
/// drags upwards from the centre of [from] (not a text field: its own
/// gestures would take the drag), and expects the field to lose the focus
/// and the keyboard to hide. Run it under an iOS platform override
/// (`variant: TargetPlatformVariant.only(TargetPlatform.iOS)`).
Future<void> expectDragClosesKeyboard(
  WidgetTester tester, {
  required Finder field,
  required Finder from,
  double inset = 336,
}) async {
  await tester.showKeyboard(field);
  tester.view.viewInsets = FakeViewPadding(
    bottom: inset * tester.view.devicePixelRatio,
  );
  addTearDown(tester.view.resetViewInsets);
  await tester.pumpAndSettle();
  final focus = tester.binding.focusManager.primaryFocus;
  expect(focus?.hasFocus, isTrue, reason: 'the field has the focus');
  expect(tester.testTextInput.isVisible, isTrue, reason: 'the keyboard shows');

  await tester.dragFrom(tester.getCenter(from), const Offset(0, -120));
  await tester.pumpAndSettle();

  expect(focus?.hasFocus, isFalse, reason: 'a drag closes the keyboard');
  expect(tester.testTextInput.isVisible, isFalse);
}
