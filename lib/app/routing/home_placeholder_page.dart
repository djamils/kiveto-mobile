import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiveto_mobile/features/client/client.dart';
import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/presentation/async/async_views.dart';
import 'package:kiveto_mobile/shared/presentation/kit/surfaces.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_colors.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_layout.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_text.dart';
import 'package:material_ui/material_ui.dart';

/// The home (1) until its slice: it proves the session with the account's
/// first name and the active clinic.
class HomePlaceholderPage extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final clinic = switch (ref.watch(activeClinicProvider)) {
      AsyncData(:final value) => value?.name,
      _ => null,
    };
    return Scaffold(
      backgroundColor: KivetoColors.canvas,
      body: SafeArea(
        child: AsyncValueView<Me>(
          value: ref.watch(meProvider),
          onRetry: () => ref.invalidate(meProvider),
          data: (me) {
            final firstName = me.account.firstName?.trim();
            return ListView(
              padding: const EdgeInsets.fromLTRB(
                KivetoSpace.gutter,
                KivetoSpace.xl3,
                KivetoSpace.gutter,
                KivetoSpace.xl,
              ),
              children: [
                KivetoPageHeader(
                  firstName == null || firstName.isEmpty
                      ? l10n.homeGreetingNoName
                      : l10n.homeGreeting(firstName),
                  subtitle: clinic,
                ),
                const SizedBox(height: KivetoSpace.xl2),
                Text(l10n.placeholderBody, style: KivetoText.bodyLarge),
              ],
            );
          },
        ),
      ),
    );
  }
}
