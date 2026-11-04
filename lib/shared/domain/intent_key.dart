import 'package:kiveto_mobile/shared/domain/idempotency_key.dart';

/// The `Idempotency-Key` of the intent of a request form (a renewal, a
/// change request): one key per content.
///
/// [keyFor] gives a content equal (`==`) to one it was already asked for
/// the key that content first got, so every retry of the same request (a
/// network failure, a second tap, a content edited then edited back) sends
/// the same key and the server answers it once; any other content is
/// another intent, so a new key (the same key with another body is
/// `422 idempotency_key_reused`).
final class IntentKey<T extends Object> {
  /// Keys drawn from the given function (default:
  /// [IdempotencyKey.generate]).
  new([this._newKey = IdempotencyKey.generate]);

  final IdempotencyKey Function() _newKey;
  final _keys = <T, IdempotencyKey>{};

  /// The key of [content]: the one it first got, else a new one.
  IdempotencyKey keyFor(T content) => _keys.putIfAbsent(content, _newKey);
}
