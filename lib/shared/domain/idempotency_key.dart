// The domain imports no package (rule 1), so package:meta's @immutable is
// out of reach: the value objects below have only final fields.
// ignore_for_file: avoid_equals_and_hash_code_on_mutable_classes

import 'dart:math';

import 'package:kiveto_mobile/shared/domain/uuid_v4.dart';

/// The `Idempotency-Key` of one user intent (a booking, a request).
///
/// One key per intent: the state of the intent (a wizard, a form notifier)
/// holds it, sends it with every retry of that intent, and generates a new
/// one when the content of the intent changes — the backend answers
/// `422 idempotency_key_reused` to the same key with another body.
final class IdempotencyKey {
  const new(this.value);

  /// A new key, a UUID v4 drawn from [random] (default: [Random.secure]).
  factory generate([Random? random]) => IdempotencyKey(uuidV4(random));

  final String value;

  @override
  bool operator ==(Object other) =>
      other is IdempotencyKey && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}
