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
import 'package:kiveto_mobile/shared/presentation/kit/navigation.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_colors.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_layout.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_text.dart';
import 'package:material_ui/material_ui.dart';

/// The account's deletion, from the account screen (6), in a sheet: what
/// the deletion does, « Recevoir un code » (a code by SMS to the account's
/// phone, [maskedPhone]), the code, then « Supprimer mon compte », enabled
/// once the 6 digits are typed and never sent without that tap. Once the
/// server took it (`DeleteAccount`), the session is closed: the router goes
/// to the welcome screen, where a SnackBar confirms the request.
/// « Garder mon compte » closes the sheet.
Future<void> showAccountDeletionSheet(
  BuildContext context, {
  required String maskedPhone,
}) => showKivetoSheet<void>(
  context: context,
  builder: (context) => AccountDeletionSheet(maskedPhone: maskedPhone),
);

/// The content of the deletion sheet (see [showAccountDeletionSheet]).
class AccountDeletionSheet extends ConsumerStatefulWidget {
  const new({required this.maskedPhone, super.key});

  final String maskedPhone;

  @override
  ConsumerState<AccountDeletionSheet> createState() =>
      _AccountDeletionSheetState();
}

class _AccountDeletionSheetState extends ConsumerState<AccountDeletionSheet> {
  final _code = TextEditingController();

  /// Null until the code was sent (step 1).
  OtpChallenge? _challenge;

  /// The server said the code cannot be used any more (expired, too many
  /// attempts, unknown): « Recevoir un nouveau code » is offered.
  bool _codeSpent = false;
  bool _busy = false;
  bool _resending = false;
  String? _requestError;
  String? _codeError;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  /// A code by SMS: the first one (step 1), or a new challenge once the
  /// last code is spent (step 2 again; a refusal then shows on the boxes).
  Future<void> _requestCode() async {
    if (_busy) return;
    final l10n = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _requestError = null;
    });
    try {
      final challenge = await ref
          .read(accountSecurityRepositoryProvider)
          .requestDeletionCode();
      if (!mounted) return;
      _code.clear();
      setState(() {
        _busy = false;
        _challenge = challenge;
        _codeSpent = false;
        _codeError = null;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        if (_challenge == null) {
          _requestError = identityErrorText(l10n, error);
        } else {
          _codeError = identityErrorText(l10n, error);
        }
      });
    }
  }

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
        _codeSpent = false;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _resending = false;
        _codeError = identityErrorText(l10n, error);
        _codeSpent = isSpentCode(error);
      });
    }
  }

  Future<void> _delete() async {
    final challenge = _challenge;
    final code = _code.text;
    if (challenge == null || _busy || _resending || code.length != 6) return;
    final l10n = AppLocalizations.of(context);
    // The app's messenger: its SnackBar shows on the welcome screen the
    // router goes to once the session is closed.
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _busy = true;
      _codeError = null;
    });
    try {
      await ref.read(deleteAccountProvider)(
        challengeId: challenge.id,
        code: code,
      );
    } on Object catch (error) {
      if (!mounted) return;
      _code.clear();
      setState(() {
        _busy = false;
        _codeError = identityErrorText(l10n, error);
        _codeSpent = isSpentCode(error);
      });
      return;
    }
    messenger.showSnackBar(SnackBar(content: Text(l10n.identityDeletionDone)));
    if (mounted && (ModalRoute.of(context)?.isCurrent ?? false)) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final challenge = _challenge;
    final requestError = _requestError;
    final keep = KivetoButton.outline(
      label: l10n.identityDeletionKeep,
      size: KivetoButtonSize.large,
      onPressed: _busy ? null : () => Navigator.of(context).pop(),
    );
    final warnings = KivetoCallout.danger(
      body: [
        l10n.identityDeletionWarningDisabled,
        l10n.identityDeletionWarningErased,
        l10n.identityDeletionWarningClinics,
      ].join('\n'),
    );
    if (challenge == null) {
      return KivetoSheet(
        title: l10n.identityDeletionTitle,
        children: [
          warnings,
          const SizedBox(height: KivetoSpace.xxs),
          Text(
            l10n.identityDeletionCodeWillBeSent(unbroken(widget.maskedPhone)),
            style: KivetoText.body.copyWith(color: KivetoColors.inkSecondary),
          ),
          if (requestError != null)
            Semantics(
              liveRegion: true,
              child: Text(
                requestError,
                style: KivetoText.bodySmall.copyWith(
                  color: KivetoColors.danger,
                ),
              ),
            ),
          const SizedBox(height: KivetoSpace.xxs),
          KivetoButton.danger(
            label: l10n.identityAccountRequestCode,
            loading: _busy,
            onPressed: () => unawaited(_requestCode()),
          ),
          keep,
        ],
      );
    }
    return KivetoSheet(
      title: l10n.identityDeletionTitle,
      subtitle: l10n.identityAccountCodeSentTo(unbroken(widget.maskedPhone)),
      children: [
        warnings,
        const SizedBox(height: KivetoSpace.xxs),
        AccountCodeBlock(
          controller: _code,
          resendAvailableAt: challenge.resendAvailableAt,
          errorText: _codeError,
          busy: _busy || _resending,
          // A spent code: « Recevoir un nouveau code » is the one way on.
          resendable: !_codeSpent,
          onResend: () => unawaited(_resend()),
          // The 6th digit only enables the button: a deletion is never
          // sent without its tap.
          onChanged: (_) => setState(() => _codeError = null),
        ),
        // A spent code: only a new challenge goes on, without leaving.
        if (_codeSpent)
          KivetoTextButton(
            label: l10n.identityAccountNewCode,
            onPressed: _busy || _resending
                ? null
                : () => unawaited(_requestCode()),
          ),
        KivetoButton.danger(
          label: l10n.identityDeletionConfirm,
          loading: _busy,
          onPressed: _code.text.length == 6 && !_resending
              ? () => unawaited(_delete())
              : null,
        ),
        keep,
      ],
    );
  }
}
