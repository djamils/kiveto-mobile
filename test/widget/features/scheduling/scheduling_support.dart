// What the scheduling widget tests share: the ids and routes of the
// captures, Julien's backend for Paris, a capture edited, numbered keys,
// a booking step pumped with its draft.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/core/security/session_manager.dart';
import 'package:kiveto_mobile/features/client/di.dart';
import 'package:kiveto_mobile/features/scheduling/domain/appointment.dart';
import 'package:kiveto_mobile/features/scheduling/domain/booking.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/booking_wizard.dart';
import 'package:kiveto_mobile/shared/domain/clinic_instant.dart';
import 'package:kiveto_mobile/shared/domain/clock.dart';
import 'package:kiveto_mobile/shared/domain/idempotency_key.dart';
import 'package:kiveto_mobile/shared/presentation/icons/lucide_glyph.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../support/fakes.dart';
import '../../../support/portal_api/fake_portal_backend.dart';
import '../../../support/portal_api/portal_http_harness.dart';

const parisId = '01960000-0000-7000-8000-000000000001';
const lyonId = '01960000-0000-7000-8000-000000000101';
const osloId = '01a19a0f-128f-7a54-b39c-e01a30ee66d2';
const consultationId = '01a19a10-d467-7bc2-9344-790c64b6ab03';
const vaccinationId = '01a19a10-d47d-7781-87b0-627f2e3b5819';
const dupontId = '01a19a0e-23cd-70de-a551-46681e052884';
const rousseauId = '01a19a0e-1afe-7116-ad21-672cf69c5366';
const bookedId = '01a1a297-4a0a-7093-83f7-14de2798613e';
const parisBase = '$api/clinics/$parisId';
const motifsPath = '$parisBase/booking/motifs';
const practitionersPath =
    '$parisBase/booking/practitioners?motifId=$consultationId';

/// The availability of [practitioner] for the consultation from [from] to
/// [to] (`YYYY-MM-DD`).
String availabilityPath(
  String from,
  String to, {
  String practitioner = dupontId,
}) =>
    '$parisBase/booking/availability?motifId=$consultationId'
    '&practitionerId=$practitioner&from=$from&to=$to';

const oslo = ExistingPet(osloId, 'Oslo');
const consultation = BookingMotif(
  id: MotifId(consultationId),
  label: 'Consultation',
  durationMin: 30,
);
const dupont = Practitioner(
  id: PractitionerId(dupontId),
  displayName: 'Dr Marc Dupont',
);
final monday10 = ClinicInstant.parse('2026-11-09T10:00:00+01:00');

/// The capture [fixture] with [change] applied to its JSON body.
PortalReply editedReply(
  String fixture,
  void Function(Object? body) change, {
  int status = 200,
}) {
  final body = jsonDecode(File('$portalFixtures/$fixture').readAsStringSync());
  change(body);
  return PortalReply.json(jsonEncode(body), status: status);
}

/// Julien's `/me` with [change] applied to his Paris clinic.
PortalReply meWithParis(void Function(Map<String, Object?> paris) change) =>
    editedReply('me.get.200.json', (body) {
      change(
        ((body! as Map<String, Object?>)['clinics']! as List<Object?>).first!
            as Map<String, Object?>,
      );
    });

/// Julien signed in, Paris active: `/me`, no booking request, Oslo, the
/// motifs, the practitioners and Dupont's first window from the 3rd.
FakePortalBackend julienBackend() => FakePortalBackend()
  ..on('GET', '$api/me', PortalReply.fixture('me.get.200.json'))
  ..on(
    'GET',
    '$api/me/booking-requests?limit=50',
    PortalReply.fixture('me.booking-requests.get.200.json'),
  )
  ..on(
    'GET',
    '$parisBase/pets',
    PortalReply.fixture('clinics.paris.pets.get.200.json'),
  )
  ..on(
    'GET',
    '$motifsPath?petId=$osloId',
    PortalReply.fixture('clinics.paris.booking.motifs.get.200.json'),
  )
  ..on(
    'GET',
    motifsPath,
    PortalReply.fixture('clinics.paris.booking.motifs.get.200.json'),
  )
  ..on(
    'GET',
    practitionersPath,
    PortalReply.fixture('clinics.paris.booking.practitioners.get.200.json'),
  )
  ..on(
    'GET',
    availabilityPath('2026-11-03', '2026-11-16'),
    PortalReply.fixture('clinics.paris.booking.availability.get.200.json'),
  );

/// Numbered keys: `key-1`, `key-2`…
final class Keys {
  int count = 0;

  IdempotencyKey next() => IdempotencyKey('key-${++count}');
}

/// The icon button drawing [glyph].
Finder iconButton(LucideGlyph glyph) => find.byWidgetPredicate(
  (widget) => widget is KivetoIconButton && widget.glyph == glyph,
);

/// The [KivetoButton] labelled [label].
Finder button(String label) => find.widgetWithText(KivetoButton, label);

/// Whether the [KivetoButton] labelled [label] can be pressed.
bool enabled(WidgetTester tester, String label) =>
    tester.widget<KivetoButton>(button(label)).onPressed != null;

/// Pumps a booking step on [backend] (Julien signed in), then fills the
/// draft once the active clinic is known: [pet], [motif], [practitioner]
/// with [slot]. Keys come from [keys]. Returns the container.
Future<ProviderContainer> pumpStep(
  WidgetTester tester,
  Widget page, {
  required FakePortalBackend backend,
  BookingPet? pet,
  BookingMotif? motif,
  Practitioner? practitioner,
  ClinicInstant? slot,
  Keys? keys,
  Clock? clock,
  SessionManager? session,
  List<Override> overrides = const [],
}) async {
  final container = await pumpPage(
    tester,
    page,
    backend: backend,
    clock: clock,
    session: session ?? await memorySession(pair('A')),
    overrides: [
      activeClinicStoreProvider.overrideWithValue(InMemoryActiveClinicStore()),
      bookingKeyFactoryProvider.overrideWithValue((keys ?? Keys()).next),
      ...overrides,
    ],
  );
  final wizard = container.read(bookingWizardProvider.notifier);
  if (pet != null) wizard.choosePet(pet);
  if (motif != null) wizard.chooseMotif(motif);
  if (practitioner != null) {
    if (slot != null) {
      wizard.chooseSlot(practitioner, slot);
    } else {
      wizard.choosePractitioner(practitioner);
    }
  }
  await tester.pumpAndSettle();
  return container;
}

/// Taps [finder] once it is scrolled into view.
Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}
