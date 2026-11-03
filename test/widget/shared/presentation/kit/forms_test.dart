import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/kit/forms.dart';
import 'package:kiveto_mobile/shared/presentation/kit/pills.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_colors.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../support/fakes.dart';

BoxDecoration _boxDecoration(WidgetTester tester, Finder finder) =>
    tester.widget<AnimatedContainer>(finder).decoration! as BoxDecoration;

void main() {
  group('KivetoOtpField', () {
    testWidgets('digits only, 6 at most; filled, current and empty boxes; '
        'completion', (tester) async {
      final changes = <String>[];
      String? completed;
      await pumpKit(
        tester,
        KivetoOtpField(
          legend: 'Code de vérification',
          helpText: 'Valable 10 minutes.',
          onChanged: changes.add,
          onCompleted: (code) => completed = code,
        ),
      );
      expect(find.text('Valable 10 minutes.'), findsOneWidget);

      await tester.tap(find.byType(TextField));
      await tester.enterText(find.byType(TextField), '4a8 1');
      await tester.pump();

      final boxes = find.byType(AnimatedContainer);
      expect(boxes, findsNWidgets(6));
      expect(find.text('4'), findsOneWidget);
      expect(find.widgetWithText(AnimatedContainer, '8'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      final filled = _boxDecoration(tester, boxes.at(0));
      final current = _boxDecoration(tester, boxes.at(3));
      final empty = _boxDecoration(tester, boxes.at(4));
      expect((filled.border! as Border).top.color, KivetoColors.brand);
      expect((filled.border! as Border).top.width, 1);
      expect((current.border! as Border).top.width, 2);
      expect(current.color, KivetoColors.brandSubtle);
      expect((empty.border! as Border).top.color, KivetoColors.borderStrong);
      expect(completed, isNull);

      await tester.enterText(find.byType(TextField), '4812345');
      await tester.pump();
      expect(completed, '481234');
      expect(changes.last, '481234');
    });

    testWidgets('an external controller is used as is', (tester) async {
      final controller = TextEditingController(text: '12');
      addTearDown(controller.dispose);
      await pumpKit(
        tester,
        KivetoOtpField(legend: 'Code', controller: controller, autofocus: true),
      );

      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);

      // A programmatic clear (after otp_invalid) empties the boxes.
      controller.clear();
      await tester.pump();
      expect(find.text('1'), findsNothing);
      final boxes = find.byType(AnimatedContainer);
      // No filled box: the first is the current one (focused), the others
      // empty.
      final first = _boxDecoration(tester, boxes.at(0));
      expect((first.border! as Border).top.width, 2);
      expect(first.color, KivetoColors.brandSubtle);
      for (var i = 1; i < 6; i++) {
        final border = _boxDecoration(tester, boxes.at(i)).border! as Border;
        expect(border.top.color, KivetoColors.borderStrong, reason: 'box $i');
      }

      // Another controller replaces it.
      final other = TextEditingController(text: '9');
      addTearDown(other.dispose);
      await pumpKit(tester, KivetoOtpField(legend: 'Code', controller: other));
      expect(find.widgetWithText(AnimatedContainer, '9'), findsOneWidget);
      other.text = '98';
      await tester.pump();
      expect(find.widgetWithText(AnimatedContainer, '8'), findsOneWidget);
      controller.text = '777';
      await tester.pump();
      expect(find.widgetWithText(AnimatedContainer, '7'), findsNothing);
    });

    testWidgets('the hidden field is labelled with the legend', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpKit(
        tester,
        const KivetoOtpField(legend: 'Code de vérification'),
      );

      expect(
        tester.getSemantics(find.byType(EditableText)).label,
        contains('Code de vérification'),
      );
      handle.dispose();
    });
  });

  testWidgets('each input is labelled with its visible label, read once', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpKit(
      tester,
      const Column(
        children: [
          KivetoTextField(label: 'Prénom', hintText: 'Sarah'),
          KivetoTextField.multiline(label: 'Précisions', optional: true),
          KivetoPhoneField(label: 'Numéro de mobile'),
          KivetoCodeField(label: 'Code reçu'),
          KivetoSearchField(semanticLabel: 'Rechercher une clinique'),
        ],
      ),
    );

    final labels = [
      for (final input in find.byType(EditableText).evaluate())
        tester.getSemantics(find.byWidget(input.widget)).label,
    ];
    expect(labels[0], contains('Prénom'));
    expect(labels[1], contains('Précisions (facultatif)'));
    expect(labels[2], contains('Numéro de mobile'));
    expect(labels[3], contains('Code reçu'));
    expect(labels[4], contains('Rechercher une clinique'));
    // The visible label is not a second node.
    expect(find.bySemanticsLabel(RegExp(r'^Prénom$')), findsNothing);
    handle.dispose();
  });

  testWidgets('the consent: a tap on the sentence toggles it, a tap on a link '
      'only follows the link', (tester) async {
    var consent = false;
    var linkTaps = 0;
    await pumpKit(
      tester,
      StatefulBuilder(
        builder: (context, setState) => KivetoConsentCheckbox(
          value: consent,
          onChanged: (next) => setState(() => consent = next),
          label: [
            const InlinePart.text("J'accepte les "),
            InlinePart.link('conditions', onTap: () => linkTaps++),
            const InlinePart.text(' et la politique.'),
          ],
        ),
      ),
    );

    await tester.tapOnText(find.textRange.ofSubstring("J'accepte"));
    await tester.pump();
    expect((consent, linkTaps), (true, 0));

    await tester.tapOnText(find.textRange.ofSubstring('conditions'));
    await tester.pump();
    expect((consent, linkTaps), (true, 1));

    await tester.tapOnText(find.textRange.ofSubstring('politique'));
    await tester.pump();
    expect((consent, linkTaps), (false, 1));
  });

  testWidgets('KivetoSwitch: toggles, disabled at .55, focus ring', (
    tester,
  ) async {
    var value = false;
    await pumpKit(
      tester,
      StatefulBuilder(
        builder: (context, setState) => Column(
          children: [
            KivetoSwitch(
              value: value,
              semanticLabel: 'Rappels',
              onChanged: (next) => setState(() => value = next),
            ),
            const KivetoSwitch(value: true, onChanged: null),
          ],
        ),
      ),
    );

    await tester.tap(find.byType(KivetoSwitch).first);
    await tester.pumpAndSettle();
    expect(value, isTrue);
    expect(
      tester
          .widget<Opacity>(
            find.descendant(
              of: find.byType(KivetoSwitch).last,
              matching: find.byType(Opacity),
            ),
          )
          .opacity,
      0.55,
    );

    // Keyboard: focus, then activate.
    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();
    expect(value, isFalse);
    FocusManager.instance.highlightStrategy = FocusHighlightStrategy.automatic;
  });

  testWidgets('checkboxes: the box, the consent with links, the tile', (
    tester,
  ) async {
    var box = false;
    var consent = false;
    var tile = true;
    var linkTaps = 0;
    await pumpKit(
      tester,
      StatefulBuilder(
        builder: (context, setState) => Column(
          children: [
            KivetoCheckbox(
              value: box,
              onChanged: (next) => setState(() => box = next),
            ),
            KivetoConsentCheckbox(
              value: consent,
              onChanged: (next) => setState(() => consent = next),
              label: [
                const InlinePart.text("J'accepte les "),
                InlinePart.link('conditions', onTap: () => linkTaps++),
              ],
            ),
            KivetoCheckboxTile(
              label: 'SMS',
              value: tile,
              onChanged: (next) => setState(() => tile = next),
            ),
            const KivetoCheckboxTile(
              label: 'Email',
              value: false,
              onChanged: null,
            ),
            const KivetoCheckbox(value: true, onChanged: null, size: 20),
          ],
        ),
      ),
    );

    await tester.tap(find.byType(KivetoCheckbox).first);
    await tester.tap(find.byType(KivetoCheckbox).at(1));
    await tester.tap(find.text('SMS'));
    await tester.tapOnText(find.textRange.ofSubstring('conditions'));
    await tester.pumpAndSettle();

    expect((box, consent, tile, linkTaps), (true, true, false, 1));
  });

  testWidgets('text fields: label, help, read-only, error, textarea, phone, '
      'code, search', (tester) async {
    var countryTaps = 0;
    final submitted = <String>[];
    await pumpKit(
      tester,
      Column(
        children: [
          KivetoTextField(
            label: 'Prénom',
            hintText: 'Sarah',
            helpText: 'Comme sur votre dossier.',
            onSubmitted: submitted.add,
          ),
          const KivetoTextField(label: 'Email', readOnly: true),
          const KivetoTextField(label: 'Nom', errorText: 'Le nom est vide.'),
          const KivetoTextField.multiline(label: 'Précisions', optional: true),
          KivetoPhoneField(
            label: 'Numéro de mobile',
            hintText: '6 12 34 56 78',
            errorText: 'Numéro invalide.',
            onCountryTap: () => countryTaps++,
          ),
          const KivetoPhoneField(label: 'Autre numéro'),
          const KivetoCodeField(label: 'Code', hintText: '6 chiffres'),
          const KivetoSearchField(
            semanticLabel: 'Rechercher une clinique',
            hintText: 'Ville',
          ),
        ],
      ),
    );

    expect(find.text('Comme sur votre dossier.'), findsOneWidget);
    expect(find.text('Le nom est vide.'), findsOneWidget);
    expect(
      find.textContaining('(facultatif)', findRichText: true),
      findsOneWidget,
    );
    await tester.tap(find.text('+33').first);
    expect(countryTaps, 1);
    await tester.enterText(find.byType(TextField).first, 'Sarah');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    expect(submitted, ['Sarah']);
    final height = tester.getSize(find.byType(TextField).first).height;
    expect(height, greaterThanOrEqualTo(48));
  });

  testWidgets('radio cards, the radio dot, the add card, a dashed border', (
    tester,
  ) async {
    var selected = 0;
    var added = 0;
    await pumpKit(
      tester,
      StatefulBuilder(
        builder: (context, setState) => Column(
          children: [
            KivetoRadioCard(
              title: 'Moka',
              subtitle: 'Chien · 4 ans',
              leading: const InitialsAvatar('M', size: 48, pet: true),
              selected: selected == 0,
              onTap: () => setState(() => selected = 0),
            ),
            KivetoRadioCard(
              title: 'Vaccination',
              subtitle: '30 min',
              pill: const StatusPill(
                'Rappel à faire',
                tone: StatusTone.warning,
              ),
              selected: selected == 1,
              onTap: () => setState(() => selected = 1),
            ),
            KivetoAddCard(label: 'Un autre animal', onTap: () => added++),
            const KivetoDashedBorder(child: SizedBox(height: 40, width: 100)),
          ],
        ),
      ),
    );

    await tester.tap(find.text('Vaccination'));
    await tester.tap(find.text('Un autre animal'));
    await tester.pumpAndSettle();

    expect(selected, 1);
    expect(added, 1);
    final dots = tester.widgetList<RadioDot>(find.byType(RadioDot)).toList();
    expect(dots.map((dot) => dot.selected), [false, true]);
    expect(
      tester.getSize(find.byType(KivetoRadioCard).first).height,
      greaterThanOrEqualTo(76),
    );
  });

  testWidgets("the error, else the help, is the input's semantics hint", (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpKit(
      tester,
      const Column(
        children: [
          KivetoTextField(label: 'Nom', errorText: 'Le nom est vide.'),
          KivetoPhoneField(label: 'Mobile', helpText: 'Un code par SMS.'),
        ],
      ),
    );

    final inputs = find.byType(EditableText).evaluate().toList();
    final name = tester.getSemantics(find.byWidget(inputs[0].widget));
    final phone = tester.getSemantics(find.byWidget(inputs[1].widget));
    expect(name.hint, contains('Le nom est vide.'));
    expect(phone.hint, contains('Un code par SMS.'));
    // The visible note is not read a second time.
    expect(find.bySemanticsLabel('Le nom est vide.'), findsNothing);
    handle.dispose();
  });
}
