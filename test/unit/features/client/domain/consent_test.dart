// The consents of a clinic: the page's order of the kinds, a channel
// turned on and off, one kind replaced, the history's values.

import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/features/client/domain/consent.dart';

final _grantedAt = DateTime.utc(2026, 9, 2, 12);

Consent _consent(
  ConsentKind kind, [
  Set<ConsentChannel> channels = const {ConsentChannel.sms},
]) => Consent(
  kind: kind,
  channels: channels,
  grantedAt: channels.isEmpty ? null : _grantedAt,
  effect: ConsentEffect.sendControl,
);

void main() {
  test('the kinds the page shows, in its order, without unknown', () {
    expect(ConsentKind.known, const [
      ConsentKind.appointmentReminders,
      ConsentKind.vaccinationReminders,
      ConsentKind.marketing,
      ConsentKind.clinicalDocuments,
      ConsentKind.billing,
    ]);
  });

  group('Consent', () {
    test('granted: at least one channel', () {
      expect(_consent(ConsentKind.marketing).granted, isTrue);
      expect(_consent(ConsentKind.marketing, const {}).granted, isFalse);
    });

    test('withChannel adds or removes one channel, keeps the rest', () {
      final consent = _consent(ConsentKind.billing);

      final both = consent.withChannel(ConsentChannel.email, on: true);
      expect(both.channels, {ConsentChannel.sms, ConsentChannel.email});
      expect(both.kind, ConsentKind.billing);
      expect(both.grantedAt, _grantedAt);
      expect(both.effect, ConsentEffect.sendControl);

      final none = consent.withChannel(ConsentChannel.sms, on: false);
      expect(none.channels, isEmpty);
      // The consent itself is unchanged.
      expect(consent.channels, {ConsentChannel.sms});
      // Turning on a channel already on, off one already off: no change.
      expect(consent.withChannel(ConsentChannel.sms, on: true).channels, {
        ConsentChannel.sms,
      });
      expect(consent.withChannel(ConsentChannel.email, on: false).channels, {
        ConsentChannel.sms,
      });
    });

    test('toString names the kind and channels', () {
      expect(
        _consent(ConsentKind.marketing).toString(),
        'Consent(marketing, (sms))',
      );
    });
  });

  group('ClinicConsents', () {
    final consents = ClinicConsents([
      _consent(ConsentKind.appointmentReminders),
      _consent(ConsentKind.marketing, const {}),
    ]);

    test('of: the consent of a kind, null when the clinic sent none', () {
      expect(consents.of(ConsentKind.marketing)?.granted, isFalse);
      expect(consents.of(ConsentKind.billing), isNull);
    });

    test('replacing swaps the consent of the same kind only', () {
      final marketing = _consent(ConsentKind.marketing, const {
        ConsentChannel.email,
      });

      final replaced = consents.replacing(marketing);

      expect(replaced.consents.map((consent) => consent.kind), [
        ConsentKind.appointmentReminders,
        ConsentKind.marketing,
      ]);
      expect(replaced.of(ConsentKind.marketing), same(marketing));
      expect(
        replaced.of(ConsentKind.appointmentReminders),
        same(consents.of(ConsentKind.appointmentReminders)),
      );
      expect(consents.of(ConsentKind.marketing)?.granted, isFalse);
    });
  });

  test('a history page and its entries', () {
    final entry = ConsentHistoryEntry(
      kind: ConsentKind.billing,
      channel: ConsentChannel.sms,
      action: ConsentAction.granted,
      at: _grantedAt,
      source: ConsentSource.system,
      author: 'Reprise',
      approximate: true,
    );
    final page = ConsentHistoryPage(items: [entry], nextCursor: 'next');

    expect(page.items.single.approximate, isTrue);
    expect(page.items.single.source, ConsentSource.system);
    expect(page.nextCursor, 'next');
    expect(
      ConsentHistoryEntry(
        kind: ConsentKind.marketing,
        channel: ConsentChannel.email,
        action: ConsentAction.withdrawn,
        at: _grantedAt,
        source: ConsentSource.portal,
        author: 'Zoé Essai',
      ).approximate,
      isFalse,
    );
    expect(const ConsentHistoryPage(items: []).nextCursor, isNull);
  });
}
