import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';
import 'package:kiveto_mobile/shared/presentation/async/async_views.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';

/// The French message of a failure of the sign-in screens, by its problem
/// `type`; the generic body of [failureMessage] for anything else (network,
/// server, unknown codes).
String identityErrorText(
  AppLocalizations l10n,
  Object error,
) => switch (error) {
  ApiFailure(code: 'phone_not_supported') =>
    l10n.identityErrorPhoneNotSupported,
  ApiFailure(code: 'otp_invalid') => l10n.identityErrorOtpInvalid,
  ApiFailure(code: 'otp_expired') => l10n.identityErrorOtpExpired,
  ApiFailure(code: 'otp_attempts_exceeded') =>
    l10n.identityErrorOtpAttemptsExceeded,
  RateLimitedFailure(code: 'otp_rate_limited', :final retryAfter) =>
    retryAfter == null
        ? l10n.identityErrorOtpRateLimitedUnknown
        : l10n.identityErrorOtpRateLimited(
            (retryAfter.inSeconds / 60).ceil().clamp(1, 1 << 20),
          ),
  ApiFailure(code: 'otp_challenge_not_found') =>
    l10n.identityErrorOtpChallengeNotFound,
  ApiFailure(code: 'account_disabled') => l10n.identityErrorAccountDisabled,
  ApiFailure(code: 'onboarding_invalid') => l10n.identityErrorOnboardingInvalid,
  ApiFailure(code: 'account_exists') => l10n.identityErrorAccountExists,
  ApiFailure(code: 'terms_outdated') => l10n.identityErrorTermsOutdated,
  ApiFailure(code: 'invitation_invalid') => l10n.identityErrorInvitationInvalid,
  _ => failureMessage(l10n, error).$2,
};

/// Whether [error] means the grant or the request of the flow is gone and
/// the user must start again from the welcome screen.
bool isRestartFailure(Object error) => switch (error) {
  ApiFailure(
    code: 'onboarding_invalid' || 'account_exists' || 'otp_challenge_not_found',
  ) =>
    true,
  _ => false,
};

/// "A, B et C" (nothing for no name).
String joinNames(AppLocalizations l10n, List<String> names) => switch (names) {
  [] => '',
  [final single] => single,
  _ => l10n.identityNamesAnd(
    names.sublist(0, names.length - 1).join(', '),
    names.last,
  ),
};

/// The parts of [sentence] with each of [links] (a text of the sentence
/// and its action) as a link, in the order they appear; a link text the
/// sentence does not hold is left out.
List<InlinePart> linkParts(
  String sentence,
  List<(String text, void Function() onTap)> links, {
  bool underline = true,
}) {
  final parts = <InlinePart>[];
  var rest = 0;
  for (final (text, onTap) in links) {
    final at = sentence.indexOf(text, rest);
    if (at < 0) continue;
    if (at > rest) parts.add(InlinePart.text(sentence.substring(rest, at)));
    parts.add(InlinePart.link(text, onTap: onTap, underline: underline));
    rest = at + text.length;
  }
  if (rest < sentence.length) {
    parts.add(InlinePart.text(sentence.substring(rest)));
  }
  return parts;
}
