// C-30, the document card: the unread dot stays on the line of the title's
// last word, whatever the width (the final walk saw it alone on a second
// line under a long title).

import 'package:flutter/rendering.dart' show RenderParagraph;
import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/features/document/document.dart';
import 'package:kiveto_mobile/features/document/presentation/document_card.dart';
import 'package:kiveto_mobile/shared/domain/clinic_instant.dart';
import 'package:material_ui/material_ui.dart';

import '../../../support/fakes.dart';

const _title = 'Ordonnance ORD-2026-000036';

Document _document({bool unread = false}) => Document(
  id: const DocumentId('doc'),
  kind: DocumentKind.prescription,
  title: _title,
  issuedAt: ClinicInstant(DateTime.utc(2026, 10, 14, 8), Duration.zero),
  unread: unread,
);

Future<void> _pumpCard(
  WidgetTester tester, {
  required double width,
  bool unread = false,
}) => pumpKit(
  tester,
  SizedBox(
    width: width,
    child: DocumentCard(
      document: _document(unread: unread),
      meta: 'Oslo · 14 oct. 2026',
      onTap: () {},
      onOpen: () {},
      onRequestRenewal: () {},
    ),
  ),
);

void main() {
  testWidgets('the unread dot never sits alone on a line: it stays on the '
      "title's first line, right of the title, inside the card", (
    tester,
  ) async {
    // One width after the other: one line, two lines, and the widths
    // where the title's last line ends a few pixels short of the edge
    // (where an inline dot went alone to the next line).
    var wrapped = false;
    var oneLine = false;
    for (var width = 200.0; width <= 600; width += 2) {
      await _pumpCard(tester, width: width, unread: true);

      final paragraph = tester
          .renderObjectList<RenderParagraph>(find.byType(RichText))
          .firstWhere((p) => p.text.toPlainText() == _title);
      final origin = paragraph.localToGlobal(Offset.zero);
      final first = paragraph
          .getBoxesForSelection(
            const TextSelection(baseOffset: 0, extentOffset: 1),
          )
          .single
          .toRect()
          .shift(origin);
      final title = origin & paragraph.size;
      final dot = tester.getRect(find.byType(UnreadDot));
      wrapped |= title.height > first.height * 1.5;
      oneLine |= title.height < first.height * 1.5;

      expect(
        dot.center.dy,
        inExclusiveRange(first.top, first.bottom),
        reason: "at $width px the dot left the title's first line",
      );
      expect(dot.left, greaterThan(title.right), reason: 'at $width px');
      expect(
        dot.right,
        lessThanOrEqualTo(tester.getRect(find.byType(DocumentCard)).right),
        reason: 'at $width px',
      );
    }
    // Both layouts were seen.
    expect((wrapped, oneLine), (true, true));
  });

  testWidgets('a read document: no dot, the title as given', (tester) async {
    await _pumpCard(tester, width: 320);

    expect(find.byType(UnreadDot), findsNothing);
    expect(find.text(_title), findsOneWidget);
  });
}
