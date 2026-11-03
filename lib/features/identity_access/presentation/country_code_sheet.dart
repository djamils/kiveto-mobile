import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/presentation/kit/forms.dart';
import 'package:kiveto_mobile/shared/presentation/kit/navigation.dart';
import 'package:material_ui/material_ui.dart';

/// A dialling prefix of the sign-in screen: France and the French overseas
/// territories the Portal serves. Which numbers it covers is the server's
/// answer (`422 phone_not_supported`), not this list's.
final class PhoneCountry {
  const new(this.code, this._name, {this.tenDigitPlan = false});

  /// `+33`.
  final String code;
  final String Function(AppLocalizations l10n) _name;

  /// A 10-digit national plan, `0` + 9 digits (France and its overseas
  /// departments); the others use their own lengths.
  final bool tenDigitPlan;

  String name(AppLocalizations l10n) => _name(l10n);

  /// Whether [national] holds a whole number for this prefix, to enable the
  /// button: 9 digits after the trunk `0` on a 10-digit plan, at least 6
  /// elsewhere.
  bool isComplete(String national) {
    var digits = national.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('0')) digits = digits.substring(1);
    return tenDigitPlan ? digits.length == 9 : digits.length >= 6;
  }

  static String _france(AppLocalizations l10n) => l10n.identityCountryFrance;
  static String _reunion(AppLocalizations l10n) =>
      l10n.identityCountryReunionMayotte;
  static String _guadeloupe(AppLocalizations l10n) =>
      l10n.identityCountryGuadeloupe;
  static String _guyane(AppLocalizations l10n) => l10n.identityCountryGuyane;
  static String _martinique(AppLocalizations l10n) =>
      l10n.identityCountryMartinique;
  static String _saintPierre(AppLocalizations l10n) =>
      l10n.identityCountrySaintPierre;
  static String _wallis(AppLocalizations l10n) => l10n.identityCountryWallis;
  static String _newCaledonia(AppLocalizations l10n) =>
      l10n.identityCountryNewCaledonia;
  static String _polynesia(AppLocalizations l10n) =>
      l10n.identityCountryPolynesia;

  static const france = PhoneCountry('+33', _france, tenDigitPlan: true);

  /// In the order of the sheet.
  static const List<PhoneCountry> all = [
    france,
    PhoneCountry('+262', _reunion, tenDigitPlan: true),
    PhoneCountry('+590', _guadeloupe, tenDigitPlan: true),
    PhoneCountry('+594', _guyane, tenDigitPlan: true),
    PhoneCountry('+596', _martinique, tenDigitPlan: true),
    PhoneCountry('+508', _saintPierre),
    PhoneCountry('+681', _wallis),
    PhoneCountry('+687', _newCaledonia),
    PhoneCountry('+689', _polynesia),
  ];
}

/// The sheet of the "+33" button: one card per prefix; resolves to the
/// prefix picked, or null when dismissed.
Future<PhoneCountry?> showCountryCodeSheet(
  BuildContext context, {
  required PhoneCountry selected,
}) => showKivetoSheet<PhoneCountry>(
  context: context,
  builder: (context) {
    final l10n = AppLocalizations.of(context);
    return KivetoSheet(
      title: l10n.identityCountrySheetTitle,
      children: [
        for (final country in PhoneCountry.all)
          KivetoRadioCard(
            title: '${country.code} ${country.name(l10n)}',
            selected: country.code == selected.code,
            onTap: () => Navigator.of(context).pop(country),
          ),
      ],
    );
  },
);
