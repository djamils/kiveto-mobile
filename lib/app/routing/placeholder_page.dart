import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kiveto_mobile/app/routing/app_routes.dart';
import 'package:kiveto_mobile/core/di/core_providers.dart';
import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/kit/surfaces.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_colors.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_layout.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_text.dart';
import 'package:material_ui/material_ui.dart';

/// Where a placeholder sits, which sets its background and header.
enum PlaceholderKind {
  /// A tab root: canvas, page header.
  tab,

  /// A page pushed inside a tab (the pet sheet): canvas, back button.
  pushed,

  /// A full-screen flow over the shell: white, back button.
  fullScreen,

  /// The welcome screen: the brand lockup, and the kit gallery in debug.
  welcome,

  /// The invitation deep link: says whether a token arrived.
  invitation,

  /// The account tab: its sign-out button.
  account,

  /// An unknown location: a way back home.
  notFound,
}

/// The placeholder of a screen a later slice builds: its title and "Cet
/// écran arrive dans une prochaine version."
class PlaceholderPage extends ConsumerWidget {
  const new({
    required this.title,
    super.key,
    this.kind = PlaceholderKind.tab,
    this.invitationToken,
  });

  final String title;
  final PlaceholderKind kind;

  /// The token of the invitation link: only its presence is shown.
  final String? invitationToken;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final white = switch (kind) {
      PlaceholderKind.tab ||
      PlaceholderKind.pushed ||
      PlaceholderKind.account => false,
      _ => true,
    };
    final auth = switch (kind) {
      PlaceholderKind.welcome || PlaceholderKind.invitation => true,
      _ => false,
    };
    final gutter = auth ? KivetoSpace.authGutter : KivetoSpace.gutter;
    final body = Text(l10n.placeholderBody, style: KivetoText.bodyLarge);
    final children = <Widget>[
      ...switch (kind) {
        PlaceholderKind.tab || PlaceholderKind.account => [
          KivetoPageHeader(title),
          const SizedBox(height: KivetoSpace.xl2),
          body,
        ],
        PlaceholderKind.pushed || PlaceholderKind.fullScreen => [
          KivetoDetailHeader(title: title, onBack: () => _back(context)),
          const SizedBox(height: KivetoSpace.xl3),
          body,
        ],
        PlaceholderKind.welcome => [
          const KivetoBrandLockup(),
          const SizedBox(height: KivetoSpace.xl7),
          Semantics(
            header: true,
            child: Text(title, style: KivetoText.display),
          ),
          const SizedBox(height: KivetoSpace.m),
          body,
          if (kDebugMode) ...[
            const SizedBox(height: KivetoSpace.xl5),
            KivetoTextButton(
              label: l10n.welcomeKitGalleryLink,
              onPressed: () => unawaited(context.push(AppRoutes.kitGallery)),
            ),
          ],
        ],
        PlaceholderKind.invitation => [
          const KivetoBrandLockup(),
          const SizedBox(height: KivetoSpace.xl6),
          Semantics(
            header: true,
            child: Text(title, style: KivetoText.displaySmall),
          ),
          const SizedBox(height: KivetoSpace.m),
          Text(
            invitationToken == null
                ? l10n.invitationLinkMissing
                : l10n.invitationLinkReceived,
            style: KivetoText.bodyLarge.copyWith(color: KivetoColors.ink),
          ),
          const SizedBox(height: KivetoSpace.m),
          body,
        ],
        PlaceholderKind.notFound => [
          Semantics(
            header: true,
            child: Text(title, style: KivetoText.pageTitle),
          ),
          const SizedBox(height: KivetoSpace.xl5),
          KivetoButton.primary(
            label: l10n.routeNotFoundAction,
            onPressed: () => context.go(AppRoutes.home),
          ),
        ],
      },
      if (kind == PlaceholderKind.account) ...[
        const SizedBox(height: KivetoSpace.xl5),
        KivetoButton.outline(
          label: l10n.accountSignOut,
          size: KivetoButtonSize.large,
          onPressed: () =>
              unawaited(ref.read(sessionManagerProvider).signOut()),
        ),
      ],
    ];
    return Scaffold(
      backgroundColor: white ? KivetoColors.surface : KivetoColors.canvas,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            gutter,
            auth ? KivetoSpace.xl7 : KivetoSpace.xl3,
            gutter,
            KivetoSpace.xl,
          ),
          children: children,
        ),
      ),
    );
  }

  static void _back(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }
}
