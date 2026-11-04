import 'package:kiveto_mobile/features/identity_access/presentation/resend_countdown.dart';
import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/kit/forms.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_layout.dart';
import 'package:material_ui/material_ui.dart';

/// The SMS code of an account change (the e-mail change, the deletion), as
/// on screen 8: the six boxes (« Code de confirmation », « Valable 10
/// minutes. », [errorText] in place of the help), then « Renvoyer le code »
/// once the countdown of [resendAvailableAt] is over (disabled while
/// [busy]).
class AccountCodeBlock extends StatelessWidget {
  const new({
    required this.controller,
    required this.resendAvailableAt,
    required this.onResend,
    super.key,
    this.errorText,
    this.busy = false,
    this.resendable = true,
    this.onChanged,
    this.onCompleted,
  });

  final TextEditingController controller;
  final DateTime resendAvailableAt;
  final VoidCallback onResend;
  final String? errorText;

  /// A request runs (a check, a resend): no resend.
  final bool busy;

  /// False hides « Renvoyer le code » (the caller offers another way on).
  final bool resendable;
  final ValueChanged<String>? onChanged;

  /// Called with the code once the 6 digits are typed.
  final ValueChanged<String>? onCompleted;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        KivetoOtpField(
          legend: l10n.identityAccountCodeLegend,
          helpText: l10n.identityCodeHelp,
          errorText: errorText,
          controller: controller,
          autofocus: true,
          onChanged: onChanged,
          onCompleted: onCompleted,
        ),
        if (resendable) ...[
          const SizedBox(height: KivetoSpace.sm),
          ResendCountdown(
            availableAt: resendAvailableAt,
            builder: (context, remaining) {
              final waiting = remaining > Duration.zero;
              return KivetoTextButton(
                label: waiting
                    ? l10n.identityAccountResendIn(
                        ResendCountdown.format(remaining),
                      )
                    : l10n.identityAccountResend,
                onPressed: waiting || busy ? null : onResend,
              );
            },
          ),
        ],
      ],
    );
  }
}
