// Screen 3 and the slot picker on the captures: Dupont's first week (the
// 8th closed, the 5th chosen, 16:30), a slot chosen, the summary chips, the
// weeks (the second from the same answer, the third asked, back without a
// request, the end of the horizon), a past `from` asked again from the next
// day, another practitioner, a day or a week without slot, the failures,
// and a slot taken meanwhile (struck, the warning).

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/features/scheduling/domain/appointment.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/booking_slot_page.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/booking_wizard.dart';
import 'package:kiveto_mobile/shared/domain/clinic_instant.dart';
import 'package:kiveto_mobile/shared/domain/local_date.dart';
import 'package:kiveto_mobile/shared/presentation/async/async_views.dart';
import 'package:kiveto_mobile/shared/presentation/icons/lucide_glyph.dart';
import 'package:kiveto_mobile/shared/presentation/kit/pills.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_colors.dart';
import 'package:material_ui/material_ui.dart';

import '../../../support/portal_api/fake_portal_backend.dart';
import '../../../support/portal_api/portal_http_harness.dart';
import 'scheduling_support.dart';

const _window1 = '2026-11-03';
const _window1End = '2026-11-16';

Finder _day(String date) => find.byKey(ValueKey('day-$date'));

Finder _slot(String startAt) => find.byKey(ValueKey('slot-$startAt'));

/// Whether the day cell of [date] is drawn selected (its number white).
bool _daySelected(WidgetTester tester, String date) =>
    tester
        .widget<Text>(
          find.descendant(
            of: _day(date),
            matching: find.text('${int.parse(date.substring(8))}'),
          ),
        )
        .style
        ?.color ==
    KivetoColors.surface;

/// The availability capture of the first window with every slot removed.
PortalReply _noSlot() =>
    editedReply('clinics.paris.booking.availability.get.200.json', (body) {
      for (final day
          in (body! as Map<String, Object?>)['days']! as List<Object?>) {
        (day! as Map<String, Object?>)['slots'] = <Object?>[];
      }
    });

/// The next window's capture with every day closed.
PortalReply _closed() =>
    editedReply('clinics.paris.booking.availability.next.get.200.json', (body) {
      for (final day
          in (body! as Map<String, Object?>)['days']! as List<Object?>) {
        (day! as Map<String, Object?>)
          ..['open'] = false
          ..['slots'] = <Object?>[];
      }
    });

/// A window of 14 days from [from], closed, but for the day [slotOn] (an
/// index) open with a slot at 09:00.
PortalReply _window(LocalDate from, {int? slotOn}) => PortalReply.json(
  jsonEncode({
    'days': [
      for (var i = 0; i < 14; i++)
        {
          'date': from.addDays(i).toIso8601String(),
          'open': i == slotOn,
          'slots': [
            if (i == slotOn)
              {
                'startAt':
                    '${from.addDays(i).toIso8601String()}T09:00:00+01:00',
              },
          ],
        },
    ],
  }),
);

void main() {
  late List<String> exits;

  setUp(() => exits = []);

  Widget page() => BookingSlotPage(
    onContinue: (context) => exits.add('continue'),
    onEditPet: (context) => exits.add('pet'),
    onEditMotif: (context) => exits.add('motif'),
    onBack: (context) => exits.add('back'),
    onClose: (context) => exits.add('close'),
  );

  testWidgets('Oslo, Consultation: step 3, the chips, Dupont chosen, the '
      'first week (the 8th closed), the 5th and its 16:30; a slot chosen '
      'fills the bar and the draft', (tester) async {
    final backend = julienBackend();
    final container = await pumpStep(
      tester,
      page(),
      backend: backend,
      pet: oslo,
      motif: consultation,
    );

    expect(find.text('Étape 3 sur 4'), findsOneWidget);
    expect(find.text('Choisissez un créneau'), findsNWidgets(2));
    expect(find.widgetWithText(KivetoSummaryChip, 'Oslo'), findsOneWidget);
    expect(
      find.widgetWithText(KivetoSummaryChip, 'Consultation · 30 min'),
      findsOneWidget,
    );
    expect(
      tester
          .widget<KivetoChoiceChip>(
            find.widgetWithText(KivetoChoiceChip, 'Dr Marc Dupont'),
          )
          .selected,
      isTrue,
    );
    expect(
      tester
          .widget<KivetoChoiceChip>(
            find.widgetWithText(KivetoChoiceChip, 'Dr Éric Rousseau'),
          )
          .selected,
      isFalse,
    );
    expect(find.text('Novembre 2026'), findsOneWidget);
    for (final (date, weekday) in [
      ('2026-11-03', 'Mar'),
      ('2026-11-04', 'Mer'),
      ('2026-11-05', 'Jeu'),
      ('2026-11-06', 'Ven'),
      ('2026-11-07', 'Sam'),
      ('2026-11-08', 'Dim'),
      ('2026-11-09', 'Lun'),
    ]) {
      expect(
        find.descendant(of: _day(date), matching: find.text(weekday)),
        findsOneWidget,
      );
    }
    expect(_day('2026-11-10'), findsNothing);
    expect(_daySelected(tester, '2026-11-05'), isTrue);
    expect(find.text('Après-midi'), findsOneWidget);
    expect(find.text('Matin'), findsNothing);
    expect(find.text('16:30'), findsOneWidget);
    expect(find.text('Votre créneau'), findsOneWidget);
    expect(enabled(tester, 'Continuer'), isFalse);
    expect(
      find.text(
        'Seuls les créneaux ouverts à la réservation en ligne par la clinique '
        'sont affichés.',
      ),
      findsOneWidget,
    );

    // The closed Sunday does not take the selection.
    await tester.tap(_day('2026-11-08'));
    await tester.pumpAndSettle();
    expect(_daySelected(tester, '2026-11-05'), isTrue);

    await tester.tap(_slot('2026-11-05T16:30:00+01:00'));
    await tester.pumpAndSettle();
    expect(find.text('Jeu. 5 nov. à 16:30'), findsOneWidget);
    final draft = container.read(bookingWizardProvider).draft;
    expect(draft.practitioner?.id, const PractitionerId(dupontId));
    expect(draft.slot, ClinicInstant.parse('2026-11-05T16:30:00+01:00'));

    await tester.tap(button('Continuer'));
    await tester.tap(find.widgetWithText(KivetoSummaryChip, 'Oslo'));
    await tester.tap(
      find.widgetWithText(KivetoSummaryChip, 'Consultation · 30 min'),
    );
    await tester.tap(iconButton(LucideGlyph.chevronLeft).first);
    await tester.tap(iconButton(LucideGlyph.x));
    expect(exits, ['continue', 'pet', 'motif', 'back', 'close']);
  });

  testWidgets('an open day without slot; the morning and the afternoon', (
    tester,
  ) async {
    await pumpStep(
      tester,
      page(),
      backend: julienBackend(),
      pet: oslo,
      motif: consultation,
    );

    await tester.tap(_day('2026-11-03'));
    await tester.pumpAndSettle();
    expect(find.text('Aucun créneau disponible ce jour-là.'), findsOneWidget);

    await tester.tap(_day('2026-11-09'));
    await tester.pumpAndSettle();
    expect(find.text('Matin'), findsOneWidget);
    expect(find.text('Après-midi'), findsOneWidget);
    expect(_slot('2026-11-09T09:00:00+01:00'), findsOneWidget);
    expect(_slot('2026-11-09T17:30:00+01:00'), findsOneWidget);
  });

  testWidgets('the weeks: the second from the same answer, the third asked '
      'from the 17th, back without a request', (tester) async {
    final backend = julienBackend()
      ..on(
        'GET',
        availabilityPath('2026-11-17', '2026-11-30'),
        PortalReply.fixture(
          'clinics.paris.booking.availability.next.get.200.json',
        ),
      );
    await pumpStep(
      tester,
      page(),
      backend: backend,
      pet: oslo,
      motif: consultation,
    );
    expect(
      tester.getSemantics(find.bySemanticsLabel('Semaine précédente')),
      isSemantics(isEnabled: false),
    );

    await tapVisible(tester, find.bySemanticsLabel('Semaine suivante'));
    expect(_day('2026-11-10'), findsOneWidget);
    expect(_day('2026-11-16'), findsOneWidget);
    expect(_daySelected(tester, '2026-11-11'), isTrue);
    expect(
      backend.requests.where(
        (request) => request.uri.path.endsWith('availability'),
      ),
      hasLength(1),
    );

    await tapVisible(tester, find.bySemanticsLabel('Semaine suivante'));
    expect(_day('2026-11-17'), findsOneWidget);
    expect(_day('2026-11-23'), findsOneWidget);
    expect(
      backend.requestsTo(availabilityPath('2026-11-17', '2026-11-30')),
      hasLength(1),
    );

    await tapVisible(tester, find.bySemanticsLabel('Semaine précédente'));
    await tapVisible(tester, find.bySemanticsLabel('Semaine précédente'));
    expect(_day('2026-11-03'), findsOneWidget);
    await tapVisible(tester, find.bySemanticsLabel('Semaine suivante'));
    await tapVisible(tester, find.bySemanticsLabel('Semaine suivante'));
    expect(_day('2026-11-17'), findsOneWidget);
    expect(
      backend.requests.where(
        (request) => request.uri.path.endsWith('availability'),
      ),
      hasLength(2),
    );
  });

  testWidgets('a closure inside the horizon: a closed window, then days '
      'open again', (tester) async {
    final backend = julienBackend()
      ..on('GET', availabilityPath('2026-11-17', '2026-11-30'), _closed())
      ..on(
        'GET',
        availabilityPath('2026-12-01', '2026-12-14'),
        _window(LocalDate(2026, 12, 1), slotOn: 0),
      );
    await pumpStep(
      tester,
      page(),
      backend: backend,
      pet: oslo,
      motif: consultation,
    );

    for (var i = 0; i < 4; i++) {
      await tapVisible(tester, find.bySemanticsLabel('Semaine suivante'));
    }

    expect(_day('2026-12-01'), findsOneWidget);
    expect(find.text('Décembre 2026'), findsOneWidget);
    expect(_slot('2026-12-01T09:00:00+01:00'), findsOneWidget);
  });

  testWidgets('beyond the horizon: two closed windows in a row (28 days) end '
      'the weeks', (tester) async {
    final backend = julienBackend()
      ..on('GET', availabilityPath('2026-11-17', '2026-11-30'), _closed())
      ..on(
        'GET',
        availabilityPath('2026-12-01', '2026-12-14'),
        _window(LocalDate(2026, 12, 1)),
      );
    await pumpStep(
      tester,
      page(),
      backend: backend,
      pet: oslo,
      motif: consultation,
    );

    for (var i = 0; i < 3; i++) {
      await tapVisible(tester, find.bySemanticsLabel('Semaine suivante'));
    }
    // One closed window: the weeks go on.
    expect(_day('2026-11-24'), findsOneWidget);
    expect(find.text('Aucun créneau cette semaine.'), findsOneWidget);
    expect(
      tester.getSemantics(find.bySemanticsLabel('Semaine suivante')),
      isSemantics(isEnabled: true),
    );

    for (var i = 0; i < 2; i++) {
      await tapVisible(tester, find.bySemanticsLabel('Semaine suivante'));
    }
    expect(_day('2026-12-08'), findsOneWidget);
    expect(
      tester.getSemantics(find.bySemanticsLabel('Semaine suivante')),
      isSemantics(isEnabled: false),
    );
  });

  testWidgets('a week without slot', (tester) async {
    final backend = julienBackend()
      ..on('GET', availabilityPath(_window1, _window1End), _noSlot());
    await pumpStep(
      tester,
      page(),
      backend: backend,
      pet: oslo,
      motif: consultation,
    );

    expect(find.text('Aucun créneau cette semaine.'), findsOneWidget);
    expect(_daySelected(tester, '2026-11-03'), isTrue);
  });

  testWidgets('the clinic still on the day before refuses `from` (capture): '
      'asked again from the next day', (tester) async {
    final backend = julienBackend()
      ..on(
        'GET',
        availabilityPath(_window1, _window1End),
        PortalReply.fixture(
          'clinics.paris.booking.availability.past.get.422.json',
          status: 422,
        ),
      )
      ..on(
        'GET',
        availabilityPath('2026-11-04', '2026-11-17'),
        PortalReply.fixture('clinics.paris.booking.availability.get.200.json'),
      );
    await pumpStep(
      tester,
      page(),
      backend: backend,
      pet: oslo,
      motif: consultation,
    );

    expect(
      backend.requestsTo(availabilityPath('2026-11-04', '2026-11-17')),
      hasLength(1),
    );
    expect(find.text('16:30'), findsOneWidget);
  });

  testWidgets("another practitioner: Rousseau's availability, the slot "
      'dropped, the day kept', (tester) async {
    final backend = julienBackend()
      ..on(
        'GET',
        availabilityPath(_window1, _window1End, practitioner: rousseauId),
        PortalReply.fixture('clinics.paris.booking.availability.get.200.json'),
      );
    final container = await pumpStep(
      tester,
      page(),
      backend: backend,
      pet: oslo,
      motif: consultation,
      practitioner: dupont,
      slot: monday10,
    );
    expect(_daySelected(tester, '2026-11-09'), isTrue);
    expect(find.text('Lun. 9 nov. à 10:00'), findsOneWidget);
    final key = container.read(bookingWizardProvider).draft.key;

    await tester.tap(find.text('Dr Éric Rousseau'));
    await tester.pumpAndSettle();

    final draft = container.read(bookingWizardProvider).draft;
    expect(draft.practitioner?.id, const PractitionerId(rousseauId));
    expect(draft.slot, isNull);
    expect(draft.key, isNot(key));
    expect(
      backend.requestsTo(
        availabilityPath(_window1, _window1End, practitioner: rousseauId),
      ),
      hasLength(1),
    );
    expect(_daySelected(tester, '2026-11-09'), isTrue);
    expect(find.text('Choisissez un créneau'), findsNWidgets(2));
  });

  testWidgets('the practitioners fail, then none: the error and its retry, '
      'then the message', (tester) async {
    final backend = julienBackend()
      ..on('GET', practitionersPath, problem('oops', 503));
    await pumpStep(
      tester,
      page(),
      backend: backend,
      pet: oslo,
      motif: consultation,
    );
    expect(find.byType(ErrorView), findsOneWidget);

    backend.on('GET', practitionersPath, PortalReply.json('[]'));
    await tapVisible(tester, find.text('Réessayer'));
    expect(
      find.text(
        'Aucun vétérinaire ne prend de rendez-vous en ligne pour ce motif.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('the availability fails: the error and its retry', (
    tester,
  ) async {
    final backend = julienBackend()
      ..on(
        'GET',
        availabilityPath(_window1, _window1End),
        problem('oops', 503),
      );
    await pumpStep(
      tester,
      page(),
      backend: backend,
      pet: oslo,
      motif: consultation,
    );
    expect(find.byType(ErrorView), findsOneWidget);

    backend.on(
      'GET',
      availabilityPath(_window1, _window1End),
      PortalReply.fixture('clinics.paris.booking.availability.get.200.json'),
    );
    await tapVisible(tester, find.text('Réessayer'));
    expect(find.text('16:30'), findsOneWidget);
  });

  testWidgets('a slot taken meanwhile (409, capture): back on the step, '
      'struck in its day, not tappable, the warning; the next choice a new '
      'key', (tester) async {
    final backend = julienBackend()
      ..on(
        'POST',
        '$parisBase/appointments',
        PortalReply.fixture(
          'clinics.paris.appointments.slot-taken.post.409.json',
          status: 409,
        ),
      );
    final container = await pumpStep(
      tester,
      page(),
      backend: backend,
      pet: oslo,
      motif: consultation,
      practitioner: dupont,
      slot: monday10,
    );
    final key = container.read(bookingWizardProvider).draft.key;
    // The fresh answer no longer has 10:00.
    backend.on(
      'GET',
      availabilityPath(_window1, _window1End),
      editedReply('clinics.paris.booking.availability.get.200.json', (body) {
        final monday =
            ((body! as Map<String, Object?>)['days']! as List<Object?>)[6]!
                as Map<String, Object?>;
        (monday['slots']! as List<Object?>).removeAt(4);
      }),
    );

    // The answer comes as the test pumps (its clock is fake).
    final confirming = container.read(bookingWizardProvider.notifier).confirm();
    await tester.pumpAndSettle();
    final outcome = await confirming;

    expect(outcome, BookingOutcome.slotTaken);
    expect(
      find.text("Ce créneau vient d'être pris. Choisissez-en un autre."),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('10:00, déjà pris'), findsOneWidget);
    expect(
      backend.requestsTo(availabilityPath(_window1, _window1End)),
      hasLength(2),
    );
    final taken = container.read(bookingWizardProvider).draft;
    expect(taken.slot, isNull);
    expect(taken.key, key);
    expect(find.text('Choisissez un créneau'), findsNWidgets(2));

    await tapVisible(tester, _slot('2026-11-09T10:00:00+01:00'));
    expect(container.read(bookingWizardProvider).draft.slot, isNull);

    await tapVisible(tester, _slot('2026-11-09T10:15:00+01:00'));
    final next = container.read(bookingWizardProvider).draft;
    expect(next.slot?.toIso8601String(), '2026-11-09T10:15:00+01:00');
    expect(next.key, isNot(key));
    expect(
      find.text("Ce créneau vient d'être pris. Choisissez-en un autre."),
      findsNothing,
    );
    expect(find.bySemanticsLabel('10:00, déjà pris'), findsOneWidget);
  });
}
