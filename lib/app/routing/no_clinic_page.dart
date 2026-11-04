import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kiveto_mobile/app/routing/app_routes.dart';
import 'package:kiveto_mobile/app/routing/shell_seams.dart';
import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/presentation/async/async_views.dart';
import 'package:kiveto_mobile/shared/presentation/icons/lucide_glyph.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/kit/surfaces.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_colors.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_layout.dart';
import 'package:material_ui/material_ui.dart';

/// A clinic-scoped tab of an account without a confirmed clinic (the shell
/// seam says false): its page header ([title]), « Aucune clinique
/// rattachée » and why the tab is empty ([body]), « Trouver une clinique »;
/// otherwise (a clinic, or not known yet) the tab's page [child].
class ClinicTabGate extends ConsumerWidget {
  const new({
    required this.title,
    required this.body,
    required this.child,
    super.key,
    this.glyph = LucideGlyph.inbox,
  });

  final String title;
  final String body;
  final Widget child;
  final LucideGlyph glyph;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(hasConfirmedClinicProvider) != false) return child;
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: KivetoColors.canvas,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                KivetoSpace.gutter,
                KivetoSpace.xl3,
                KivetoSpace.gutter,
                KivetoSpace.xl2,
              ),
              sliver: SliverToBoxAdapter(child: KivetoPageHeader(title)),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                glyph: glyph,
                title: l10n.noClinicTitle,
                body: body,
                action: KivetoButton.primary(
                  label: l10n.screenClinicsTitle,
                  size: KivetoButtonSize.small,
                  onPressed: () => context.go(AppRoutes.clinics),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
