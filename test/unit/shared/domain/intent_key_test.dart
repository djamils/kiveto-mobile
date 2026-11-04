// IntentKey: one Idempotency-Key per content of a request form — the same
// key for an equal content, a new one for another content; a content edited
// back gets the key it first got.

import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/shared/domain/idempotency_key.dart';
import 'package:kiveto_mobile/shared/domain/intent_key.dart';

void main() {
  var count = 0;
  IdempotencyKey next() => IdempotencyKey('key-${++count}');

  setUp(() => count = 0);

  test('the same content keeps its key; equal content is the same', () {
    final intent = IntentKey<String>(next);

    final first = intent.keyFor('poids 12,4');

    expect(first, const IdempotencyKey('key-1'));
    expect(intent.keyFor('poids 12,4'), first);
    // Equal, not identical.
    expect(intent.keyFor(['poids', '12,4'].join(' ')), first);
    expect(count, 1);
  });

  test('another content is another intent: a new key, then kept; back to '
      'the first content: its first key', () {
    final intent = IntentKey<String>(next)..keyFor('a');
    final second = intent.keyFor('b');

    expect(second, const IdempotencyKey('key-2'));
    expect(intent.keyFor('b'), second);
    // Back to the first content (sent before, perhaps recorded): its key.
    expect(intent.keyFor('a'), const IdempotencyKey('key-1'));
    expect(intent.keyFor('c'), const IdempotencyKey('key-3'));
    expect(count, 3);
  });

  test('by default, generated keys (UUID v4)', () {
    final intent = IntentKey<int>();

    final key = intent.keyFor(1);

    expect(
      key.value,
      matches(RegExp('^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab]')),
    );
    expect(intent.keyFor(1), key);
    expect(intent.keyFor(2), isNot(key));
  });
}
