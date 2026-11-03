// The helpers of the sign-in screens: the number formatter, the prefixes,
// the pasted invitation link, the messages by code, the countdown, the
// flows.

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/features/identity_access/domain/otp_challenge.dart';
import 'package:kiveto_mobile/features/identity_access/domain/otp_verification.dart';
import 'package:kiveto_mobile/features/identity_access/domain/phone_number.dart';
import 'package:kiveto_mobile/features/identity_access/presentation/country_code_sheet.dart';
import 'package:kiveto_mobile/features/identity_access/presentation/flows.dart';
import 'package:kiveto_mobile/features/identity_access/presentation/identity_messages.dart';
import 'package:kiveto_mobile/features/identity_access/presentation/invitation_link_sheet.dart';
import 'package:kiveto_mobile/features/identity_access/presentation/phone_input_formatter.dart';
import 'package:kiveto_mobile/features/identity_access/presentation/resend_countdown.dart';
import 'package:kiveto_mobile/l10n/app_localizations_fr.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';

final _l10n = AppLocalizationsFr();

TextEditingValue _edit(
  String old,
  String typed, {
  int? cursor,
  bool tenDigitPlan = true,
}) => PhoneInputFormatter(tenDigitPlan: tenDigitPlan).formatEditUpdate(
  TextEditingValue(
    text: old,
    selection: TextSelection.collapsed(offset: old.length),
  ),
  TextEditingValue(
    text: typed,
    selection: TextSelection.collapsed(offset: cursor ?? typed.length),
  ),
);

void main() {
  group('PhoneInputFormatter', () {
    test('a 10-digit plan: with the trunk 0 in pairs, without it 1 + '
        'pairs; digits only, capped', () {
      String format(String input) =>
          PhoneInputFormatter.format(input, tenDigitPlan: true);

      expect(format('0612345678'), '06 12 34 56 78');
      expect(format('06123456789'), '06 12 34 56 78');
      expect(format('612345678'), '6 12 34 56 78');
      expect(format('6123456789'), '6 12 34 56 78');
      expect(format('+6a1-2'), '6 12');
      expect(format(''), '');
    });

    test('another plan: pairs, 12 digits at most', () {
      String format(String input) =>
          PhoneInputFormatter.format(input, tenDigitPlan: false);

      expect(format('751234'), '75 12 34');
      expect(format('12345678901234'), '12 34 56 78 90 12');
    });

    test('the cursor stays after the same digit', () {
      final typed = _edit('6 12', '6 123');
      expect(typed.text, '6 12 3');
      expect(typed.selection.baseOffset, 6);

      // A digit typed in the middle.
      final middle = _edit('6 12 34', '6 1912 34', cursor: 4);
      expect(middle.text, '6 19 12 34');
      expect(middle.selection.baseOffset, 4);

      // No selection: at the end.
      final invalid = const PhoneInputFormatter(tenDigitPlan: false)
          .formatEditUpdate(
            TextEditingValue.empty,
            const TextEditingValue(text: '7512'),
          );
      expect(invalid.text, '75 12');
      expect(invalid.selection.baseOffset, 5);
    });

    test('a deleted space deletes the digit before it', () {
      final deleted = _edit('6 12 34', '6 1234', cursor: 4);

      expect(deleted.text, '6 13 4');
      expect(deleted.selection.baseOffset, 3);

      // A space before any digit: nothing more to delete.
      final leading = _edit(' 6', '6', cursor: 0, tenDigitPlan: false);
      expect(leading.text, '6');
    });

    test('a number pasted with the selected prefix (+33, 0033) loses it', () {
      String format(String input) => PhoneInputFormatter.format(
        input,
        tenDigitPlan: true,
        countryCode: '+33',
      );

      expect(format('+33 6 12 34 56 78'), '6 12 34 56 78');
      expect(format('0033 6 12 34 56 78'), '6 12 34 56 78');
      expect(format(' +33612345678'), '6 12 34 56 78');
      expect(format('+33 (0)6 12 34 56 78'), '06 12 34 56 78');
      // A national number, or another prefix, keeps its digits.
      expect(format('06 12 34 56 78'), '06 12 34 56 78');
      expect(format('+262 692'), '2 62 69 2');
      expect(
        PhoneInputFormatter.format(
          '00687 75 12 34',
          tenDigitPlan: false,
          countryCode: '+687',
        ),
        '75 12 34',
      );

      // Pasted in the field: the cursor at the end of the national number.
      for (final pasted in ['+33 6 12 34 56 78', '0033 6 12 34 56 78']) {
        final value =
            const PhoneInputFormatter(
              tenDigitPlan: true,
              countryCode: '+33',
            ).formatEditUpdate(
              TextEditingValue.empty,
              TextEditingValue(
                text: pasted,
                selection: TextSelection.collapsed(offset: pasted.length),
              ),
            );
        expect(value.text, '6 12 34 56 78', reason: pasted);
        expect(value.selection.baseOffset, 13, reason: pasted);
      }
    });
  });

  test('PhoneCountry: the list of the sheet, a whole number per plan', () {
    expect(PhoneCountry.all.map((country) => country.code), [
      '+33',
      '+262',
      '+590',
      '+594',
      '+596',
      '+508',
      '+681',
      '+687',
      '+689',
    ]);
    expect(PhoneCountry.all.map((country) => country.name(_l10n)), [
      'France',
      'La Réunion · Mayotte',
      'Guadeloupe',
      'Guyane',
      'Martinique',
      'Saint-Pierre-et-Miquelon',
      'Wallis-et-Futuna',
      'Nouvelle-Calédonie',
      'Polynésie française',
    ]);
    const france = PhoneCountry.france;
    expect(france.isComplete('6 12 34 56 7'), isFalse);
    expect(france.isComplete('6 12 34 56 78'), isTrue);
    expect(france.isComplete('06 12 34 56 78'), isTrue);
    final caledonia = PhoneCountry.all.firstWhere((c) => c.code == '+687');
    expect(caledonia.tenDigitPlan, isFalse);
    expect(caledonia.isComplete('75 12 3'), isFalse);
    expect(caledonia.isComplete('75 12 34'), isTrue);
  });

  test('invitationTokenOfLink: an http(s) link to /invitation with #t=', () {
    expect(
      invitationTokenOfLink('https://portal.kiveto.local/invitation#t=abc'),
      'abc',
    );
    expect(invitationTokenOfLink(' http://h/x/invitation#t=a%2Bb&y=1 '), 'a+b');
    for (final link in [
      '',
      'bonjour',
      'https://h/invitation',
      'https://h/invitation#t=',
      'https://h/other#t=abc',
      'ftp://h/invitation#t=abc',
      'https://h/invitation?t=abc',
      'https://h/invitation#t=%E0%A4%A',
      'http://[::1',
    ]) {
      expect(invitationTokenOfLink(link), isNull, reason: link);
    }
  });

  group('the messages', () {
    test('by code', () {
      for (final (failure, message) in <(Object, String)>[
        (
          const BusinessFailure(code: 'phone_not_supported', statusCode: 422),
          "Ce numéro de mobile n'est pas encore pris en charge par Kiveto.",
        ),
        (
          const BusinessFailure(code: 'otp_invalid', statusCode: 422),
          'Code incorrect. Vérifiez-le, puis réessayez.',
        ),
        (
          const BusinessFailure(code: 'otp_expired', statusCode: 422),
          'Ce code a expiré. Demandez-en un nouveau.',
        ),
        (
          const BusinessFailure(code: 'otp_attempts_exceeded', statusCode: 422),
          "Trop d'essais. Demandez un nouveau code.",
        ),
        (
          const RateLimitedFailure(
            code: 'otp_rate_limited',
            retryAfter: Duration(seconds: 61),
          ),
          'Trop de demandes de code. Réessayez dans 2 min.',
        ),
        (
          const RateLimitedFailure(
            code: 'otp_rate_limited',
            retryAfter: Duration.zero,
          ),
          'Trop de demandes de code. Réessayez dans 1 min.',
        ),
        (
          const RateLimitedFailure(code: 'otp_rate_limited'),
          'Trop de demandes de code. Réessayez dans quelques minutes.',
        ),
        (
          const NotFoundFailure(code: 'otp_challenge_not_found'),
          "Cette demande de code n'est plus valable. Recommencez.",
        ),
        (
          const BusinessFailure(code: 'account_disabled', statusCode: 403),
          'Ce compte est désactivé. Contactez votre clinique.',
        ),
        (
          const UnauthorizedFailure(code: 'onboarding_invalid'),
          'Votre vérification a expiré. Reconnectez-vous avec votre numéro.',
        ),
        (
          const ConflictFailure(code: 'account_exists'),
          'Un compte existe déjà pour ce numéro. Connectez-vous avec votre '
              'numéro.',
        ),
        (
          const BusinessFailure(code: 'terms_outdated', statusCode: 422),
          "Les conditions d'utilisation ont changé : relisez-les, puis "
              'acceptez-les à nouveau.',
        ),
        (
          const NotFoundFailure(code: 'invitation_invalid'),
          "Cette invitation n'est plus disponible.",
        ),
        (
          const NetworkFailure(),
          'Vérifiez votre connexion Internet, puis réessayez.',
        ),
        (
          const RateLimitedFailure(code: 'rate_limited'),
          'Réessayez dans quelques minutes.',
        ),
        (StateError('bug'), 'Réessayez dans un instant.'),
      ]) {
        expect(identityErrorText(_l10n, failure), message, reason: '$failure');
      }
    });

    test('the failures that restart the flow', () {
      expect(
        isRestartFailure(const UnauthorizedFailure(code: 'onboarding_invalid')),
        isTrue,
      );
      expect(
        isRestartFailure(const ConflictFailure(code: 'account_exists')),
        isTrue,
      );
      expect(
        isRestartFailure(
          const NotFoundFailure(code: 'otp_challenge_not_found'),
        ),
        isTrue,
      );
      expect(
        isRestartFailure(
          const BusinessFailure(code: 'otp_invalid', statusCode: 422),
        ),
        isFalse,
      );
      expect(isRestartFailure(StateError('bug')), isFalse);
    });

    test('joinNames', () {
      expect(joinNames(_l10n, []), '');
      expect(joinNames(_l10n, ['Moka']), 'Moka');
      expect(joinNames(_l10n, ['Moka', 'Pistache']), 'Moka et Pistache');
      expect(
        joinNames(_l10n, ['Moka', 'Oslo', 'Pistache']),
        'Moka, Oslo et Pistache',
      );
    });

    test('linkParts: the links where their text is, the rest as text', () {
      void tap() {}
      final parts = linkParts('Pas maintenant ? Revenir', [
        ('Revenir', tap),
        ('absent', tap),
      ]);

      expect(parts.map((part) => part.text), ['Pas maintenant ? ', 'Revenir']);
      expect(parts.last.onTap, tap);
      expect(parts.first.onTap, isNull);
      final tail = linkParts('a b c', [('b', tap)], underline: false);
      expect(tail.map((part) => part.text), ['a ', 'b', ' c']);
      expect(tail[1].underline, isFalse);
    });
  });

  test('ResendCountdown.format: m:ss, seconds rounded up', () {
    expect(ResendCountdown.format(Duration.zero), '0:00');
    expect(ResendCountdown.format(const Duration(milliseconds: 23400)), '0:24');
    expect(ResendCountdown.format(const Duration(seconds: 109)), '1:49');
    expect(ResendCountdown.format(const Duration(minutes: 10)), '10:00');
  });

  test('the flows: changes without a flow are ignored', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final challenge = OtpChallenge(
      id: 'c',
      expiresAt: DateTime.utc(2026),
      resendAvailableAt: DateTime.utc(2026),
    );
    const invitation = PendingInvitation(id: 'i', clinicName: 'Paris');

    container.read(signInFlowProvider.notifier).replaceChallenge(challenge);
    container.read(onboardingProvider.notifier)
      ..accepted(invitation)
      ..remove('i');

    expect(container.read(signInFlowProvider), isNull);
    expect(container.read(onboardingProvider), isNull);

    final phone = PhoneNumber.fromNational(countryCode: '+33', national: '6')!;
    container.read(signInFlowProvider.notifier).start(phone, challenge);
    expect(container.read(signInFlowProvider)?.phone, phone);
    container.read(signInFlowProvider.notifier).clear();
    expect(container.read(signInFlowProvider), isNull);
  });

  test('the onboarding: an invitation removed after an acceptance keeps the '
      'success line', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    const paris = PendingInvitation(id: 'paris', clinicName: 'Paris');
    const lyon = PendingInvitation(id: 'lyon', clinicName: 'Lyon');
    const nantes = PendingInvitation(id: 'nantes', clinicName: 'Nantes');
    final onboarding = container.read(onboardingProvider.notifier)
      ..start(
        grant: OnboardingGrant(token: 'onb', expiresAt: DateTime.utc(2026)),
        invitations: const [paris, lyon, nantes],
        signedIn: false,
      )
      ..accepted(lyon)
      ..remove('nantes');

    final state = container.read(onboardingProvider)!;
    expect(state.invitations, [paris]);
    expect(state.signedIn, isTrue);
    expect(state.acceptedClinicName, 'Lyon');
    expect(state.grant.token, 'onb');

    onboarding.clear();
    expect(container.read(onboardingProvider), isNull);
  });
}
