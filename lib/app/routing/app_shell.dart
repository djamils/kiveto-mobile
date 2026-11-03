import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kiveto_mobile/app/routing/shell_seams.dart';
import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/presentation/icons/lucide_glyph.dart';
import 'package:kiveto_mobile/shared/presentation/kit/navigation.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_colors.dart';
import 'package:material_ui/material_ui.dart';

/// The signed-in shell: the tab's page over the bottom navigation of the
/// mockup (Accueil, Animaux, Rendez-vous, Documents with its badge, Compte
/// with its initials). Each tab keeps its own stack; tapping the active
/// tab goes back to its root.
class AppShell extends ConsumerWidget {
  const new({required this.navigationShell, super.key});

  static const documentsTab = 3;

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final index = navigationShell.currentIndex;
    final unread = index == documentsTab
        ? 0
        : ref.watch(unreadDocumentsCountProvider);
    return Scaffold(
      backgroundColor: KivetoColors.canvas,
      body: navigationShell,
      bottomNavigationBar: KivetoBottomNav(
        currentIndex: index,
        onTap: (tab) =>
            navigationShell.goBranch(tab, initialLocation: tab == index),
        items: [
          KivetoNavItem(label: l10n.navHome, glyph: LucideGlyph.house),
          KivetoNavItem(label: l10n.navPets, glyph: LucideGlyph.pawPrint),
          KivetoNavItem(
            label: l10n.navAppointments,
            glyph: LucideGlyph.calendar,
          ),
          KivetoNavItem(
            label: l10n.navDocuments,
            glyph: LucideGlyph.fileText,
            badgeCount: unread,
            semanticLabel: unread > 0 ? l10n.navDocumentsUnread(unread) : null,
          ),
          KivetoNavItem(
            label: l10n.navAccount,
            avatar: true,
            initials: ref.watch(accountInitialsProvider),
          ),
        ],
      ),
    );
  }
}
