// The domain imports no package (rule 1), so package:meta's @immutable is
// out of reach: the value objects below have only final fields.
// ignore_for_file: avoid_equals_and_hash_code_on_mutable_classes

/// An amount in minor units (cents) of an ISO 4217 currency, as the Portal
/// API sends it (`{amount: 6800, currency: "EUR"}`). Formatting belongs to
/// the presentation (`KivetoFormat.money`).
final class Money {
  /// [currency] is three upper-case letters (`EUR`), else [ArgumentError].
  new(this.minorUnits, this.currency) {
    if (!_currencyCode.hasMatch(currency)) {
      throw ArgumentError.value(
        currency,
        'currency',
        'expected an ISO 4217 code such as EUR',
      );
    }
  }

  static final _currencyCode = RegExp(r'^[A-Z]{3}$');

  final int minorUnits;
  final String currency;

  @override
  bool operator ==(Object other) =>
      other is Money &&
      other.minorUnits == minorUnits &&
      other.currency == currency;

  @override
  int get hashCode => Object.hash(minorUnits, currency);

  @override
  String toString() => '$minorUnits $currency';
}
