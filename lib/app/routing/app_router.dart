import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kiveto_mobile/app/routing/app_routes.dart';
import 'package:kiveto_mobile/app/routing/app_shell.dart';
import 'package:kiveto_mobile/app/routing/kit_gallery_page.dart';
import 'package:kiveto_mobile/app/routing/placeholder_page.dart';
import 'package:kiveto_mobile/app/routing/shell_seams.dart';
import 'package:kiveto_mobile/core/di/core_providers.dart';
import 'package:kiveto_mobile/features/document/document.dart';
import 'package:kiveto_mobile/features/home/home.dart';
import 'package:kiveto_mobile/features/identity_access/identity_access.dart';
import 'package:kiveto_mobile/features/patient/patient.dart';
import 'package:kiveto_mobile/features/scheduling/scheduling.dart';
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

/// The navigations to a pet's sheet so far.
var _petVisits = 0;

/// A new navigation to a pet's sheet, the same pet included: a fresh
/// `extra` (a serialisable count) drops the choice the sheet's switcher
/// kept.
void _goPet(BuildContext context, String petId) =>
    context.go(AppRoutes.pet(petId), extra: ++_petVisits);
void _goAppointments(BuildContext context) =>
    context.go(AppRoutes.appointments);
void _goDocuments(BuildContext context) => context.go(AppRoutes.documents);
void _pushQuestionnaire(BuildContext context, String appointmentId) =>
    unawaited(context.push(AppRoutes.questionnaire(appointmentId)));
void _pushBooking(BuildContext context) =>
    unawaited(context.push(AppRoutes.bookingPet));

/// The names of the booking wizard's routes (go_router names a page
/// after its route): the pages popped when the wizard closes.
const _bookingPet = 'bookingPet';
const _bookingMotif = 'bookingMotif';
const _bookingSlot = 'bookingSlot';
const _bookingConfirm = 'bookingConfirm';
const Set<String> _bookingRoutes = {
  _bookingPet,
  _bookingMotif,
  _bookingSlot,
  _bookingConfirm,
};

/// Closes the booking wizard: every booking page is popped, back where it
/// was opened (the home, the Rendez-vous tab); reached directly (nothing
/// under it), the home.
void _closeBooking(BuildContext context) {
  final router = GoRouter.of(context);
  var opened = true;
  Navigator.of(context, rootNavigator: true).popUntil((route) {
    if (!_bookingRoutes.contains(route.settings.name)) return true;
    if (route.isFirst) opened = false;
    return route.isFirst;
  });
  if (!opened) router.go(AppRoutes.home);
}

/// Back to the booking step [name]: the steps above it are popped.
void _backToBookingStep(BuildContext context, String name) =>
    Navigator.of(context, rootNavigator: true).popUntil(
      (route) =>
          route.settings.name == name ||
          route.isFirst ||
          !_bookingRoutes.contains(route.settings.name),
    );

void _pushReschedule(BuildContext context, String appointmentId) =>
    unawaited(context.push(AppRoutes.reschedule(appointmentId)));

/// Back from a page of a tab: pops what was pushed on it, else the home.
void _backOrHome(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(AppRoutes.home);
  }
}

/// Back from a page over the Rendez-vous tab: pops it, else the tab.
void _backOrAppointments(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(AppRoutes.appointments);
  }
}

/// The change request of a pet is slice 6's: a placeholder sheet until
/// then.
void _reportPetChange(BuildContext context, String petId) => unawaited(
  showPlaceholderSheet(context, AppLocalizations.of(context).petReportChange),
);

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
              builder: (context, state) => const HomePage(
                onOpenPet: _goPet,
                onManageAppointments: _goAppointments,
                onFillQuestionnaire: _pushQuestionnaire,
                onBook: _pushBooking,
                onSeeAllDocuments: _goDocuments,
              ),
            ),
            _page(AppRoutes.clinics, (l10n) => l10n.screenClinicsTitle),
          ],
        ),
        StatefulShellBranch(
          // Two siblings, not a sub-route: a `go` from the home to a pet
          // does not stack the first pet's sheet under it.
          routes: [
            GoRoute(
              path: AppRoutes.pets,
              builder: (context, state) => const PetPage(
                onBack: _backOrHome,
                onReportChange: _reportPetChange,
              ),
            ),
            GoRoute(
              path: '${AppRoutes.pets}/:petId',
              builder: (context, state) => PetPage(
                petId: state.pathParameters['petId'],
                request: state.extra,
                onBack: _backOrHome,
                onReportChange: _reportPetChange,
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.appointments,
              builder: (context, state) => const AppointmentsPage(
                onBook: _pushBooking,
                onReschedule: _pushReschedule,
                onFillQuestionnaire: _pushQuestionnaire,
              ),
              routes: [
                fullScreen(
                  ':appointmentId/questionnaire',
                  (l10n) => l10n.screenQuestionnaireTitle,
                ),
                GoRoute(
                  path: ':appointmentId/reschedule',
                  parentNavigatorKey: root,
                  builder: (context, state) => ReschedulePage(
                    appointmentId: state.pathParameters['appointmentId']!,
                    onBack: _backOrAppointments,
                    onDone: _goAppointments,
                  ),
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
    // The booking wizard (12 → 13 → 3 → 14), over the shell; its pages
    // share one draft (scheduling's wizard notifier).
    GoRoute(
      name: _bookingPet,
      path: AppRoutes.bookingPet,
      parentNavigatorKey: root,
      builder: (context, state) => BookingPetPage(
        onContinue: (context) =>
            unawaited(context.push(AppRoutes.bookingMotif)),
        onClose: _closeBooking,
      ),
    ),
    GoRoute(
      name: _bookingMotif,
      path: AppRoutes.bookingMotif,
      parentNavigatorKey: root,
      builder: (context, state) => BookingMotifPage(
        onContinue: (context) => unawaited(context.push(AppRoutes.bookingSlot)),
        onBack: (context) => _backToBookingStep(context, _bookingPet),
        onClose: _closeBooking,
      ),
    ),
    GoRoute(
      name: _bookingSlot,
      path: AppRoutes.bookingSlot,
      parentNavigatorKey: root,
      builder: (context, state) => BookingSlotPage(
        onContinue: (context) =>
            unawaited(context.push(AppRoutes.bookingConfirm)),
        onEditPet: (context) => _backToBookingStep(context, _bookingPet),
        onEditMotif: (context) => _backToBookingStep(context, _bookingMotif),
        onBack: (context) => _backToBookingStep(context, _bookingMotif),
        onClose: _closeBooking,
      ),
    ),
    GoRoute(
      name: _bookingConfirm,
      path: AppRoutes.bookingConfirm,
      parentNavigatorKey: root,
      builder: (context, state) => BookingConfirmPage(
        onDone: _goHome,
        onFillQuestionnaire: (context, appointmentId) =>
            context.go(AppRoutes.questionnaire(appointmentId)),
        onEditSlot: (context) => _backToBookingStep(context, _bookingSlot),
        onSlotTaken: (context) => _backToBookingStep(context, _bookingSlot),
        onEditPet: (context) => _backToBookingStep(context, _bookingPet),
        onBack: (context) => _backToBookingStep(context, _bookingSlot),
        onClose: _closeBooking,
      ),
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
