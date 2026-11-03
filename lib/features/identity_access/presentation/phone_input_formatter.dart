import 'dart:math' as math;

import 'package:flutter/services.dart';

/// Groups a mobile number in pairs as it is typed, digits only:
/// with a leading `0`, `06 12 34 56 78` (10 digits at most); without,
/// `6 12 34 56 78` (9 at most) for the 10-digit plans of France and its
/// overseas departments ([tenDigitPlan]); `75 12 34` (12 digits at most,
/// the E.164 room) for the others. The cursor stays after the same digit.
///
/// A number pasted or autofilled in international form with the selected
/// prefix ([countryCode]: `+33 6 12 34 56 78`, `0033 6 12 34 56 78`) loses
/// that prefix first.
///
/// Formatting only: whether the number exists or is covered is the
/// server's answer.
final class PhoneInputFormatter extends TextInputFormatter {
  const new({required this.tenDigitPlan, this.countryCode = ''});

  final bool tenDigitPlan;

  /// The selected dialling prefix (`+33`).
  final String countryCode;

  static final _nonDigits = RegExp(r'\D');

  /// The national digits of [input]: its digits, without the international
  /// form of [countryCode] (`+33…`, `0033…`) when it starts with it.
  static String _nationalDigits(String input, String countryCode) {
    final trimmed = input.trimLeft();
    final digits = trimmed.replaceAll(_nonDigits, '');
    final code = countryCode.replaceAll(_nonDigits, '');
    if (code.isEmpty) return digits;
    final international = trimmed.startsWith('+') ? code : '00$code';
    return digits.startsWith(international)
        ? digits.substring(international.length)
        : digits;
  }

  /// [input] grouped as the field shows it.
  static String format(
    String input, {
    required bool tenDigitPlan,
    String countryCode = '',
  }) {
    var digits = _nationalDigits(input, countryCode);
    final trunk = digits.startsWith('0');
    final max = tenDigitPlan ? (trunk ? 10 : 9) : 12;
    if (digits.length > max) digits = digits.substring(0, max);
    final groups = <String>[];
    var start = 0;
    if (tenDigitPlan && !trunk && digits.isNotEmpty) {
      groups.add(digits.substring(0, 1));
      start = 1;
    }
    for (var i = start; i < digits.length; i += 2) {
      groups.add(digits.substring(i, math.min(i + 2, digits.length)));
    }
    return groups.join(' ');
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text;
    var cursor = newValue.selection.isValid
        ? newValue.selection.extentOffset.clamp(0, text.length)
        : text.length;
    // A deleted space: delete the digit before it too, or the edit would
    // come back at once.
    if (text.length < oldValue.text.length &&
        text.replaceAll(_nonDigits, '') ==
            oldValue.text.replaceAll(_nonDigits, '')) {
      final before = text.substring(0, cursor);
      final digit = before.lastIndexOf(RegExp(r'\d'));
      if (digit >= 0) {
        text = text.substring(0, digit) + text.substring(cursor);
        cursor = digit;
      }
    }
    // The digits of an international prefix dropped do not count.
    final dropped =
        text.replaceAll(_nonDigits, '').length -
        _nationalDigits(text, countryCode).length;
    final digitsBefore = math.max(
      0,
      text.substring(0, cursor).replaceAll(_nonDigits, '').length - dropped,
    );
    final formatted = format(
      text,
      tenDigitPlan: tenDigitPlan,
      countryCode: countryCode,
    );
    var offset = 0;
    var seen = 0;
    while (offset < formatted.length && seen < digitsBefore) {
      if (formatted.codeUnitAt(offset) != 0x20) seen++;
      offset++;
    }
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: offset),
    );
  }
}
