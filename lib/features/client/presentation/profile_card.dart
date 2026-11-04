import 'package:kiveto_mobile/features/client/domain/me.dart';
import 'package:kiveto_mobile/features/client/presentation/account_messages.dart';
import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/presentation/icons/lucide_glyph.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/kit/pills.dart';
import 'package:kiveto_mobile/shared/presentation/kit/surfaces.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_colors.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_text.dart';
import 'package:material_ui/material_ui.dart';

/// The profile card of the account screen (6, C-10): the initials, the
/// name, the e-mail and phone (« À vérifier » for an e-mail not verified);
/// the address and « Modifier » ([onEdit]); the e-mail row ([onEmail]):
/// add, verify or change the address.
class ProfileCard extends StatelessWidget {
  const new({
    required this.account,
    required this.onEdit,
    required this.onEmail,
    super.key,
  });

  final Account account;
  final VoidCallback onEdit;
  final VoidCallback onEmail;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final email = account.email;
    final unverified = email != null && !account.emailVerified;
    final address = accountAddressLine(account.address);
    return KivetoCard.list(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              InitialsAvatar(
                account.initials ?? '?',
                size: 48,
                tone: AvatarTone.ink,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      accountDisplayName(account),
                      style: KivetoText.sectionTitle,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      // The masked phone stays on one line.
                      [
                        ?email,
                        account.maskedPhone.replaceAll(' ', '\u00a0'),
                      ].join(' · '),
                      style: KivetoText.bodySmall,
                    ),
                    if (unverified) ...[
                      const SizedBox(height: 6),
                      StatusPill(
                        l10n.accountEmailUnverified,
                        tone: StatusTone.warning,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  address ?? l10n.accountProfileNoAddress,
                  style: address == null
                      ? KivetoText.bodySmall
                      : KivetoText.bodySmall.copyWith(
                          color: KivetoColors.inkSecondary,
                        ),
                ),
              ),
              const SizedBox(width: 12),
              KivetoButton.outline(
                label: l10n.accountProfileEdit,
                size: KivetoButtonSize.small,
                onPressed: onEdit,
              ),
            ],
          ),
        ),
        KivetoActionRow(
          glyph: LucideGlyph.mail,
          label: switch ((email, account.emailVerified)) {
            (null, _) => l10n.accountEmailAdd,
            (_, false) => l10n.accountEmailVerify,
            _ => l10n.accountEmailChange,
          },
          onTap: onEmail,
        ),
      ],
    );
  }
}
