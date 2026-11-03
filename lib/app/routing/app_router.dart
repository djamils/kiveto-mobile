import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kiveto_mobile/app/routing/app_routes.dart';
import 'package:kiveto_mobile/app/routing/app_shell.dart';
import 'package:kiveto_mobile/app/routing/home_placeholder_page.dart';
import 'package:kiveto_mobile/app/routing/kit_gallery_page.dart';
import 'package:kiveto_mobile/app/routing/placeholder_page.dart';
import 'package:kiveto_mobile/app/routing/shell_seams.dart';
import 'package:kiveto_mobile/core/di/core_providers.dart';
import 'package:kiveto_mobile/features/document/document.dart';
import 'package:kiveto_mobile/features/identity_access/identity_access.dart';
import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

/// The router: the public screens, the 5-tab shell, the full-screen flows
/// over it, the debug kit gallery; redirected by the session and the
/// clinic seam ([redirectFor]). Placeholder pages until the slices.
final routerProvider = Provider<GoRouter>((ref) {
  final session = ref.watch(sessionManagerProvider);
  final hasConfirmedClinic = ValueNotifier<bool?>(null);
  ref.listen<bool?>(
    hasConfirmedClinicProvider,
    (_, next) => hasConfirmedClinic.value = next,
    fireImmediately: true,
  );
  final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.home,
    refreshListenable: Listenable.merge([session, hasConfirmedClinic]),
    redirect: (context, state) => redirectFor(
      location: state.uri,
      signedIn: session.status == SessionStatus.signedIn,
      hasConfirmedClinic: hasConfirmedClinic.value,
    ),
    errorBuilder: (context, state) => PlaceholderPage(
      title: AppLocalizations.of(context).routeNotFoundTitle,
      kind: PlaceholderKind.notFound,
    ),
    routes: _routes(rootNavigatorKey),
  );
  ref.onDispose(() {
    router.dispose();
    hasConfirmedClinic.dispose();
  });
  return router;
});

/// A placeholder route whose title comes from the ARB.
GoRoute _page(
  String path,
  String Function(AppLocalizations l10n) title, {
  PlaceholderKind kind = PlaceholderKind.tab,
  GlobalKey<NavigatorState>? parentNavigatorKey,
  List<RouteBase> routes = const [],
}) => GoRoute(
  path: path,
  parentNavigatorKey: parentNavigatorKey,
  routes: routes,
  builder: (context, state) =>
      PlaceholderPage(title: title(AppLocalizations.of(context)), kind: kind),
);

// The exits of the feature pages, on the paths of the app (features never
// import app/).
void _goWelcome(BuildContext context) => context.go(AppRoutes.welcome);
void _goHome(BuildContext context) => context.go(AppRoutes.home);

List<RouteBase> _routes(GlobalKey<NavigatorState> root) {
  GoRoute fullScreen(String path, String Function(AppLocalizations) title) =>
      _page(
        path,
        title,
        kind: PlaceholderKind.fullScreen,
        parentNavigatorKey: root,
      );

  return [
    GoRoute(
      path: AppRoutes.welcome,
      builder: (context, state) => WelcomePage(
        // A `go`, not a push: a code page pushed on /welcome would be
        // unmounted by the redirect of /welcome as soon as the session
        // opens, before it reaches the destination of its branch.
        onCodeSent: (context) => context.go(AppRoutes.signInCode),
        onInvitationLink: (context, token) =>
            context.go(AppRoutes.invitationLink(token)),
        onKitGallery: kDebugMode
            ? (context) => unawaited(context.push(AppRoutes.kitGallery))
            : null,
      ),
    ),
    GoRoute(
      path: AppRoutes.signInCode,
      parentNavigatorKey: root,
      builder: (context, state) => CodePage(
        onSignedIn: _goHome,
        onInvitations: (context) => context.go(AppRoutes.onboardingInvitations),
        onRegister: (context) => context.go(AppRoutes.register),
        onRestart: _goWelcome,
      ),
    ),
    GoRoute(
      path: AppRoutes.register,
      parentNavigatorKey: root,
      builder: (context, state) => const RegisterPage(onRestart: _goWelcome),
    ),
    GoRoute(
      path: AppRoutes.onboardingInvitations,
      parentNavigatorKey: root,
      builder: (context, state) => const OnboardingInvitationsPage(
        onDone: _goHome,
        onRestart: _goWelcome,
      ),
    ),
    GoRoute(
      path: AppRoutes.invitation,
      parentNavigatorKey: root,
      builder: (context, state) => InvitationPage(
        token: invitationTokenFrom(state.uri),
        onDone: _goHome,
        onSignIn: _goWelcome,
      ),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const HomePlaceholderPage(),
            ),
            _page(AppRoutes.clinics, (l10n) => l10n.screenClinicsTitle),
          ],
        ),
        StatefulShellBranch(
          routes: [
            _page(
              AppRoutes.pets,
              (l10n) => l10n.screenPetsTitle,
              routes: [
                _page(
                  ':petId',
                  (l10n) => l10n.screenPetTitle,
                  kind: PlaceholderKind.pushed,
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            _page(
              AppRoutes.appointments,
              (l10n) => l10n.screenAppointmentsTitle,
              routes: [
                fullScreen(
                  ':appointmentId/questionnaire',
                  (l10n) => l10n.screenQuestionnaireTitle,
                ),
                fullScreen(
                  ':appointmentId/cancel',
                  (l10n) => l10n.screenCancelAppointmentTitle,
                ),
                fullScreen(
                  ':appointmentId/reschedule',
                  (l10n) => l10n.screenRescheduleTitle,
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.documents,
              builder: (context, state) => DocumentsPage(
                onRequestRenewal: (context, prescriptionId) => unawaited(
                  context.push(AppRoutes.prescriptionRenewal(prescriptionId)),
                ),
              ),
              routes: [
                fullScreen(
                  'prescriptions/:prescriptionId/renewal',
                  (l10n) => l10n.screenPrescriptionRenewalTitle,
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            _page(
              AppRoutes.account,
              (l10n) => l10n.screenAccountTitle,
              kind: PlaceholderKind.account,
            ),
          ],
        ),
      ],
    ),
    fullScreen(AppRoutes.bookingPet, (l10n) => l10n.screenBookingPetTitle),
    fullScreen(AppRoutes.bookingMotif, (l10n) => l10n.screenBookingMotifTitle),
    fullScreen(AppRoutes.bookingSlot, (l10n) => l10n.screenBookingSlotTitle),
    fullScreen(
      AppRoutes.bookingConfirm,
      (l10n) => l10n.screenBookingConfirmTitle,
    ),
    fullScreen(
      '/clinic-listings/:listingId',
      (l10n) => l10n.screenClinicListingTitle,
    ),
    // Debug builds only: the page is tree-shaken from release builds.
    if (kDebugMode)
      GoRoute(
        path: AppRoutes.kitGallery,
        parentNavigatorKey: root,
        builder: (context, state) => const KitGalleryPage(),
      ),
  ];
}
