import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/kit/forms.dart';
import 'package:kiveto_mobile/shared/presentation/kit/navigation.dart';
import 'package:material_ui/material_ui.dart';

/// The token of a pasted invitation link (`https://<host>/invitation#t=…`),
/// or null when [link] is not one. The token is never shown or logged.
String? invitationTokenOfLink(String link) {
  final uri = Uri.tryParse(link.trim());
  if (uri == null ||
      !(uri.isScheme('https') || uri.isScheme('http')) ||
      !(uri.path == '/invitation' || uri.path.endsWith('/invitation'))) {
    return null;
  }
  try {
    final token = Uri.splitQueryString(uri.fragment)['t'];
    return token == null || token.isEmpty ? null : token;
  } on Object {
    // A malformed percent-encoding: not a link the app sent.
    return null;
  }
}

/// The sheet of "J'ai un lien d'invitation": the link opens the app by
/// itself; a link pasted here opens the invitation too. Resolves to its
/// token, or null when dismissed.
Future<String?> showInvitationLinkSheet(BuildContext context) =>
    showKivetoSheet<String>(
      context: context,
      builder: (context) => const _InvitationLinkSheet(),
    );

class _InvitationLinkSheet extends StatefulWidget {
  const new();

  @override
  State<_InvitationLinkSheet> createState() => _InvitationLinkSheetState();
}

class _InvitationLinkSheetState extends State<_InvitationLinkSheet> {
  final _link = TextEditingController();
  bool _invalid = false;

  @override
  void dispose() {
    _link.dispose();
    super.dispose();
  }

  void _open() {
    final token = invitationTokenOfLink(_link.text);
    if (token == null) {
      setState(() => _invalid = true);
      return;
    }
    Navigator.of(context).pop(token);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return KivetoSheet(
      title: l10n.identityInvitationBoxAction,
      subtitle: l10n.identityInvitationSheetBody,
      children: [
        KivetoTextField(
          label: l10n.identityInvitationSheetLabel,
          controller: _link,
          hintText: l10n.identityInvitationSheetHint,
          errorText: _invalid ? l10n.identityInvitationSheetError : null,
          keyboardType: TextInputType.url,
          textInputAction: TextInputAction.go,
          onChanged: (_) {
            if (_invalid) setState(() => _invalid = false);
          },
          onSubmitted: (_) => _open(),
        ),
        const SizedBox(height: 8),
        KivetoButton.primary(
          label: l10n.identityInvitationSheetAction,
          onPressed: _open,
        ),
      ],
    );
  }
}
