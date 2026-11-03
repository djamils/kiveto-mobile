import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiveto_mobile/features/identity_access/presentation/flows.dart';
import 'package:kiveto_mobile/features/identity_access/presentation/identity_messages.dart';
import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/kit/forms.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_colors.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_text.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens a link outside the app; true when a browser took it. A seam for
/// the tests (url_launcher talks to the platform).
final linkLauncherProvider = Provider<Future<bool> Function(Uri url)>(
  (ref) =>
      (url) => launchUrl(url, mode: LaunchMode.externalApplication),
);

/// C-22a bound to the current terms: "J'accepte les conditions
/// d'utilisation et la politique de confidentialité.", both links opening
/// the terms page (`Terms.url`). Disabled until the terms are loaded; a
/// failed load says so with a retry link.
class TermsConsent extends ConsumerWidget {
  const new({required this.value, required this.onChanged, super.key});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final terms = ref.watch(currentTermsProvider);
    final url = switch (terms) {
      AsyncData(:final value) => value.url,
      _ => null,
    };
    void open() => unawaited(_open(context, ref, url));
    final consent = KivetoConsentCheckbox(
      value: value,
      onChanged: url == null ? null : onChanged,
      label: linkParts(
        l10n.identityTermsConsent(
          l10n.identityTermsLink,
          l10n.identityPrivacyLink,
        ),
        [(l10n.identityTermsLink, open), (l10n.identityPrivacyLink, open)],
      ),
    );
    if (terms is! AsyncError || terms.isLoading) return consent;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        consent,
        const SizedBox(height: 6),
        KivetoInlineLinks([
          InlinePart.text('${l10n.identityTermsLoadError} '),
          InlinePart.link(
            l10n.commonRetry,
            onTap: () => ref.invalidate(currentTermsProvider),
          ),
        ], style: KivetoText.caption.copyWith(color: KivetoColors.danger)),
      ],
    );
  }

  static Future<void> _open(
    BuildContext context,
    WidgetRef ref,
    String? url,
  ) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final failed = AppLocalizations.of(context).identityTermsOpenError;
    final uri = url == null ? null : Uri.tryParse(url);
    var opened = false;
    if (uri != null) {
      try {
        opened = await ref.read(linkLauncherProvider)(uri);
      } on Object catch (error) {
        debugPrint('TermsConsent: link not opened (${error.runtimeType})');
      }
    }
    if (!opened) messenger?.showSnackBar(SnackBar(content: Text(failed)));
  }
}
