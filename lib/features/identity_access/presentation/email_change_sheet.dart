import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiveto_mobile/features/identity_access/di.dart';
import 'package:kiveto_mobile/features/identity_access/domain/otp_challenge.dart';
import 'package:kiveto_mobile/features/identity_access/domain/otp_channel.dart';
import 'package:kiveto_mobile/features/identity_access/presentation/account_code_block.dart';
import 'package:kiveto_mobile/features/identity_access/presentation/identity_messages.dart';
import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/kit/feedback.dart';
import 'package:kiveto_mobile/shared/presentation/kit/forms.dart';
import 'package:kiveto_mobile/shared/presentation/kit/navigation.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_colors.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_layout.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_text.dart';
import 'package:material_ui/material_ui.dart';

/// The e-mail change of the account screen (6), in a sheet: the address
/// (prefilled with [currentEmail] when it is not [verified]) → « Recevoir un
/// code » (a code by SMS to the account's phone, [maskedPhone]) → that code,
/// checked on its 6th digit, sends a code to the address → that code,
/// checked on its 6th digit → « Adresse e-mail vérifiée ».
///
/// [onVerified] is called once the server verified the address, however
/// the sheet became meanwhile (closed during the verification included):
/// the caller then reloads the account. The server decides every rule (the
/// address, the codes and their quotas); its refusals show on the field
/// they are about, and « Modifier l'adresse » goes back to the address. An
/// SMS code not spent yet is kept (each new SMS counts in the number's
/// quota): « Recevoir un code » then goes back to it without a new SMS.
Future<void> showEmailChangeSheet(
  BuildContext context, {
  required bool verified,
  required String maskedPhone,
  required VoidCallback onVerified,
  String? currentEmail,
}) => showKivetoSheet<void>(
  context: context,
  builder: (context) => EmailChangeSheet(
    currentEmail: currentEmail,
    verified: verified,
    maskedPhone: maskedPhone,
    onVerified: onVerified,
  ),
);

/// The content of the e-mail change sheet (see [showEmailChangeSheet]).
class EmailChangeSheet extends ConsumerStatefulWidget {
  const new({
    required this.verified,
    required this.maskedPhone,
    required this.onVerified,
    super.key,
    this.currentEmail,
  });

  final String? currentEmail;
  final bool verified;
  final String maskedPhone;

  /// Called once the server verified the address.
  final VoidCallback onVerified;

  @override
  ConsumerState<EmailChangeSheet> createState() => _EmailChangeSheetState();
}

enum _Step { address, smsCode, emailCode, done }

class _EmailChangeSheetState extends ConsumerState<EmailChangeSheet> {
  late final _email = TextEditingController(
    text: widget.verified ? '' : widget.currentEmail ?? '',
  );
  final _code = TextEditingController();
  _Step _step = _Step.address;

  /// The SMS code's challenge (step 2), kept until its code is spent: the
  /// address can be changed and the same code typed again.
  OtpChallenge? _challenge;

  /// The server said the SMS code cannot be used any more (expired, too
  /// many attempts, unknown): leaving step 2 drops its challenge.
  bool _challengeSpent = false;

  /// The challenge of the code sent to [_sentTo] (step 3).
  String? _emailChallengeId;
  String _sentTo = '';
  bool _busy = false;
  bool _resending = false;
  String? _addressError;
  String? _requestError;
  String? _codeError;

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    super.dispose();
  }

  String _title(AppLocalizations l10n) =>
      switch ((widget.currentEmail, widget.verified)) {
        (null, _) => l10n.identityEmailAddTitle,
        (_, false) => l10n.identityEmailVerifyTitle,
        _ => l10n.identityEmailChangeTitle,
      };

  /// Step 1 → 2: an SMS code to the account's phone; back to the code
  /// already sent while its challenge is kept (no new SMS).
  Future<void> _requestCode() async {
    if (_busy || _email.text.trim().isEmpty) return;
    if (_challenge != null) {
      _code.clear();
      setState(() {
        _addressError = null;
        _requestError = null;
        _codeError = null;
        _step = _Step.smsCode;
      });
      return;
    }
    final l10n = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _addressError = null;
      _requestError = null;
    });
    try {
      final challenge = await ref
          .read(accountSecurityRepositoryProvider)
          .requestEmailChangeCode();
      if (!mounted) return;
      _code.clear();
      setState(() {
        _busy = false;
        _challenge = challenge;
        _challengeSpent = false;
        _codeError = null;
        _step = _Step.smsCode;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _requestError = identityErrorText(l10n, error);
      });
    }
  }

  /// Step 2 → 3: the SMS code checked, a code sent to the address; an
  /// address the server refuses goes back to its field (the code was not
  /// spent: its challenge is kept).
  Future<void> _submitSmsCode(String code) async {
    final challenge = _challenge;
    if (challenge == null || _busy || _resending || code.length != 6) return;
    final l10n = AppLocalizations.of(context);
    final email = _email.text.trim();
    setState(() {
      _busy = true;
      _codeError = null;
    });
    try {
      final emailChallengeId = await ref
          .read(accountSecurityRepositoryProvider)
          .startEmailChange(
            challengeId: challenge.id,
            code: code,
            email: email,
          );
      if (!mounted) return;
      _code.clear();
      setState(() {
        _busy = false;
        _emailChallengeId = emailChallengeId;
        _sentTo = email;
        _step = _Step.emailCode;
      });
    } on Object catch (error) {
      if (!mounted) return;
      _code.clear();
      setState(() {
        _busy = false;
        if (isEmailRefused(error)) {
          _addressError = identityErrorText(l10n, error);
          _step = _Step.address;
        } else {
          _codeError = identityErrorText(l10n, error);
          _challengeSpent = isSpentCode(error);
        }
      });
    }
  }

  /// Step 3 → done: the code received at the address.
  Future<void> _verify(String code) async {
    final challengeId = _emailChallengeId;
    if (challengeId == null || _busy || code.length != 6) return;
    final l10n = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _codeError = null;
    });
    try {
      await ref
          .read(accountSecurityRepositoryProvider)
          .verifyEmail(challengeId: challengeId, code: code);
      widget.onVerified();
      if (!mounted) return;
      setState(() {
        _busy = false;
        _step = _Step.done;
      });
    } on Object catch (error) {
      if (!mounted) return;
      _code.clear();
      setState(() {
        _busy = false;
        _codeError = identityErrorText(l10n, error);
      });
    }
  }

  /// A new SMS code (never by e-mail: the API refuses it for this code).
  Future<void> _resend() async {
    final challenge = _challenge;
    if (challenge == null || _busy || _resending) return;
    final l10n = AppLocalizations.of(context);
    setState(() {
      _resending = true;
      _codeError = null;
    });
    try {
      final next = await ref
          .read(authRepositoryProvider)
          .resendCode(challengeId: challenge.id, channel: OtpChannel.sms);
      if (!mounted) return;
      _code.clear();
      setState(() {
        _resending = false;
        _challenge = next;
        _challengeSpent = false;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _resending = false;
        _codeError = identityErrorText(l10n, error);
        _challengeSpent = isSpentCode(error);
      });
    }
  }

  /// Back to the address. The SMS code's challenge is kept while its code
  /// can still be used (step 2); from step 3 its code was spent, and so is
  /// a code the server refused for good: a new SMS is needed then.
  void _editAddress() {
    if (_busy) return;
    _code.clear();
    setState(() {
      if (_step == _Step.emailCode || _challengeSpent) {
        _challenge = null;
        _challengeSpent = false;
      }
      _step = _Step.address;
      _emailChallengeId = null;
      _codeError = null;
      _requestError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = _title(l10n);
    switch (_step) {
      case _Step.address:
        final requestError = _requestError;
        return KivetoSheet(
          title: title,
          children: [
            KivetoTextField(
              label: l10n.identityEmailFieldLabel,
              controller: _email,
              errorText: _addressError,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.email],
              onChanged: (_) => setState(() {
                _addressError = null;
                _requestError = null;
              }),
              onSubmitted: (_) => unawaited(_requestCode()),
            ),
            const SizedBox(height: KivetoSpace.xs),
            Text(
              l10n.identityEmailCodeWillBeSent(widget.maskedPhone),
              style: KivetoText.body.copyWith(color: KivetoColors.inkSecondary),
            ),
            if (requestError != null) _ErrorLine(requestError),
            const SizedBox(height: KivetoSpace.xs),
            KivetoButton.primary(
              label: l10n.identityAccountRequestCode,
              loading: _busy,
              onPressed: _email.text.trim().isEmpty
                  ? null
                  : () => unawaited(_requestCode()),
            ),
          ],
        );
      case _Step.smsCode:
        return KivetoSheet(
          title: title,
          subtitle: l10n.identityAccountCodeSentTo(widget.maskedPhone),
          children: [
            AccountCodeBlock(
              controller: _code,
              resendAvailableAt: _challenge!.resendAvailableAt,
              errorText: _codeError,
              busy: _busy || _resending,
              onResend: () => unawaited(_resend()),
              onChanged: (_) => setState(() => _codeError = null),
              onCompleted: (code) => unawaited(_submitSmsCode(code)),
            ),
            KivetoButton.primary(
              label: l10n.commonContinue,
              loading: _busy,
              onPressed: _code.text.length == 6 && !_resending
                  ? () => unawaited(_submitSmsCode(_code.text))
                  : null,
            ),
            KivetoLinkButton(
              label: l10n.identityEmailEdit,
              onPressed: _busy ? null : _editAddress,
            ),
          ],
        );
      case _Step.emailCode:
        return KivetoSheet(
          title: title,
          subtitle: l10n.identityEmailCodeSentTo(_sentTo),
          children: [
            KivetoOtpField(
              legend: l10n.identityAccountCodeLegend,
              helpText: l10n.identityCodeHelp,
              errorText: _codeError,
              controller: _code,
              autofocus: true,
              onChanged: (_) => setState(() => _codeError = null),
              onCompleted: (code) => unawaited(_verify(code)),
            ),
            const SizedBox(height: KivetoSpace.xs),
            KivetoButton.primary(
              label: l10n.identityEmailVerifySubmit,
              loading: _busy,
              onPressed: _code.text.length == 6
                  ? () => unawaited(_verify(_code.text))
                  : null,
            ),
            KivetoLinkButton(
              label: l10n.identityEmailEdit,
              onPressed: _busy ? null : _editAddress,
            ),
          ],
        );
      case _Step.done:
        return _SheetFrame(
          child: SheetSuccessView(
            title: l10n.identityEmailDoneTitle,
            message: l10n.identityEmailDoneBody(_sentTo),
            action: KivetoButton.primary(
              label: l10n.identityEmailDone,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        );
    }
  }
}

/// An error of a request, announced, in red.
class _ErrorLine extends StatelessWidget {
  const new(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: Text(
      text,
      style: KivetoText.bodySmall.copyWith(color: KivetoColors.danger),
    ),
  );
}

/// The handle and paddings of a sheet without title (its success state).
class _SheetFrame extends StatelessWidget {
  const new({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: EdgeInsets.fromLTRB(
      KivetoSpace.gutter,
      10,
      KivetoSpace.gutter,
      kivetoBottomPadding(context, 28),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: KivetoColors.borderChip,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
        const SizedBox(height: KivetoSpace.xl2),
        child,
      ],
    ),
  );
}
