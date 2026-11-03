/// The paths of the app (the screen numbers of the contract in brackets).
abstract final class AppRoutes {
  // Public.
  static const welcome = '/welcome'; // 7
  static const signInCode = '/sign-in/code'; // 8
  static const register = '/register'; // 9
  static const onboardingInvitations = '/onboarding/invitations';

  /// The invitation deep link (0): `https://<portal host>/invitation#t=…`,
  /// the token in the fragment. Reachable signed out and signed in.
  static const invitation = '/invitation';

  /// The invitation page of [token], the token in the fragment as the link
  /// carries it (never in the path or the query): a link pasted on the
  /// welcome page.
  static String invitationLink(String token) =>
      '$invitation#t=${Uri.encodeQueryComponent(token)}';

  // The shell: one branch per tab.
  static const home = '/home'; // 1
  static const clinics = '/clinics'; // 10, in the home branch
  static const pets = '/pets'; // 2
  static String pet(String petId) => '/pets/${_id(petId)}';
  static const appointments = '/appointments'; // 4
  static const documents = '/documents'; // 5
  static const account = '/account'; // 6

  // Full screen, over the shell.
  static const bookingPet = '/booking/pet'; // 12
  static const bookingMotif = '/booking/motif'; // 13
  static const bookingSlot = '/booking/slot'; // 3
  static const bookingConfirm = '/booking/confirm'; // 14
  static String questionnaire(String appointmentId) =>
      '/appointments/${_id(appointmentId)}/questionnaire'; // 15
  static String cancelAppointment(String appointmentId) =>
      '/appointments/${_id(appointmentId)}/cancel'; // 16
  static String reschedule(String appointmentId) =>
      '/appointments/${_id(appointmentId)}/reschedule'; // 3, reused
  static String prescriptionRenewal(String prescriptionId) =>
      '/documents/prescriptions/${_id(prescriptionId)}/renewal'; // 17
  static String clinicListing(String listingId) =>
      '/clinic-listings/${_id(listingId)}'; // 11

  /// Debug builds only: the UI kit gallery.
  static const kitGallery = '/debug/kit';

  /// An id as one path segment (go_router decodes it back).
  static String _id(String id) => Uri.encodeComponent(id);
}

/// What a signed-out session may open.
const Set<String> _public = {
  AppRoutes.welcome,
  AppRoutes.signInCode,
  AppRoutes.register,
  AppRoutes.onboardingInvitations,
  AppRoutes.invitation,
  AppRoutes.kitGallery,
};

/// The sign-in screens a signed-in session skips. Not the code page (8): the
/// session opens while it is shown, and it navigates itself to the
/// destination of the verification's branch (the home, or the pending
/// invitations); a redirect would unmount it mid-branch.
const Set<String> _signInOnly = {AppRoutes.welcome, AppRoutes.register};

/// The locations that need a confirmed clinic.
const List<String> _clinicScoped = [
  AppRoutes.home,
  AppRoutes.pets,
  AppRoutes.appointments,
  AppRoutes.documents,
  '/booking',
];

bool _under(String path, String root) =>
    path == root || path.startsWith('$root/');

/// The redirect of the router, as a pure function of the [location], the
/// session and whether the account has a confirmed clinic (null: not known
/// yet, no redirect). Null keeps the location.
String? redirectFor({
  required Uri location,
  required bool signedIn,
  required bool? hasConfirmedClinic,
}) {
  final path = location.path;
  if (path.isEmpty || path == '/') {
    return signedIn ? AppRoutes.home : AppRoutes.welcome;
  }
  if (!signedIn) return _public.contains(path) ? null : AppRoutes.welcome;
  if (_signInOnly.contains(path)) return AppRoutes.home;
  if (hasConfirmedClinic == false &&
      _clinicScoped.any((root) => _under(path, root))) {
    return AppRoutes.clinics;
  }
  return null;
}

/// The invitation token of `/invitation#t=<token>`, or null. It is sent in
/// a request body by slice 1 and nowhere else: never logged or shown.
String? invitationTokenFrom(Uri uri) {
  try {
    final token = Uri.splitQueryString(uri.fragment)['t'];
    return token == null || token.isEmpty ? null : token;
  } on FormatException {
    // A malformed encoding (`#t=%FF`): not a link the app sent, the page
    // says the link is invalid.
    return null;
  }
}
