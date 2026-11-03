import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';
import 'package:kiveto_mobile/shared/domain/clock.dart';
import 'package:kiveto_mobile/shared/domain/idempotency_key.dart';
import 'package:kiveto_mobile/shared/domain/money.dart';
import 'package:kiveto_mobile/shared/domain/uuid_v4.dart';

final _uuidV4 = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
);

final class _FixedClock implements Clock {
  @override
  DateTime now() => DateTime.utc(2026, 11, 3);
}

void main() {
  group('Money', () {
    test('keeps minor units and an ISO 4217 code', () {
      final money = Money(6800, 'EUR');

      expect(money.minorUnits, 6800);
      expect(money.currency, 'EUR');
      expect('$money', '6800 EUR');
      expect(money, Money(6800, 'EUR'));
      expect(money.hashCode, Money(6800, 'EUR').hashCode);
      expect(money, isNot(Money(6801, 'EUR')));
      expect(money == Object(), isFalse);
    });

    test('refuses a currency that is not three upper-case letters', () {
      expect(() => Money(6800, 'eur'), throwsArgumentError);
      expect(() => Money(6800, 'EURO'), throwsArgumentError);
      expect(() => Money(6800, ''), throwsArgumentError);
    });
  });

  group('uuidV4', () {
    test('is an RFC 4122 version 4 UUID, lower case, random', () {
      final first = uuidV4();
      final second = uuidV4();

      expect(first, matches(_uuidV4));
      expect(second, matches(_uuidV4));
      expect(first, isNot(second));
    });

    test('is deterministic with a seeded Random', () {
      expect(uuidV4(Random(42)), uuidV4(Random(42)));
      expect(uuidV4(Random(42)), matches(_uuidV4));
    });
  });

  group('IdempotencyKey', () {
    test('generate gives two different v4 keys', () {
      final first = IdempotencyKey.generate();
      final second = IdempotencyKey.generate();

      expect(first.value, matches(_uuidV4));
      expect(second.value, matches(_uuidV4));
      expect(first, isNot(second));
    });

    test('a seeded Random gives a deterministic key; equality by value', () {
      final key = IdempotencyKey.generate(Random(7));

      expect(key, IdempotencyKey.generate(Random(7)));
      expect(key.hashCode, IdempotencyKey(key.value).hashCode);
      expect('$key', key.value);
      expect(const IdempotencyKey('k') == Object(), isFalse);
    });
  });

  test('ClinicId wraps the wire string; Clock is an interface', () {
    // Built at run time, like the infrastructure does from a DTO.
    final wire = ['01960000-0000-7000-8000-000000000001'].single;
    final id = ClinicId(wire);

    expect(id.value, '01960000-0000-7000-8000-000000000001');
    expect(_FixedClock().now(), DateTime.utc(2026, 11, 3));
  });
}
