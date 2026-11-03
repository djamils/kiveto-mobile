// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Kiveto';

  @override
  String get navHome => 'Accueil';

  @override
  String get navPets => 'Animaux';

  @override
  String get navAppointments => 'Rendez-vous';

  @override
  String get navDocuments => 'Documents';

  @override
  String get navAccount => 'Compte';

  @override
  String navDocumentsUnread(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Documents, $count nouveaux',
      one: 'Documents, 1 nouveau',
    );
    return '$_temp0';
  }

  @override
  String get screenWelcomeTitle => 'Bienvenue';

  @override
  String get screenSignInCodeTitle => 'Entrez le code reçu';

  @override
  String get screenRegisterTitle => 'Créez votre compte';

  @override
  String get screenOnboardingInvitationsTitle => 'Vos invitations';

  @override
  String get screenInvitationTitle => 'Activez votre espace';

  @override
  String get screenHomeTitle => 'Accueil';

  @override
  String get screenClinicsTitle => 'Trouver une clinique';

  @override
  String get screenPetsTitle => 'Mes animaux';

  @override
  String get screenPetTitle => 'Fiche animal';

  @override
  String get screenAppointmentsTitle => 'Rendez-vous';

  @override
  String get screenDocumentsTitle => 'Documents';

  @override
  String get screenAccountTitle => 'Compte';

  @override
  String get screenBookingPetTitle => 'Pour quel animal ?';

  @override
  String get screenBookingMotifTitle => 'Quel est le motif ?';

  @override
  String get screenBookingSlotTitle => 'Choisissez un créneau';

  @override
  String get screenBookingConfirmTitle => 'Vérifiez et confirmez';

  @override
  String get screenQuestionnaireTitle => 'Avant la consultation';

  @override
  String get screenCancelAppointmentTitle => 'Annuler le rendez-vous';

  @override
  String get screenRescheduleTitle => 'Reporter le rendez-vous';

  @override
  String get screenPrescriptionRenewalTitle => 'Demander un renouvellement';

  @override
  String get screenClinicListingTitle => 'Fiche clinique';

  @override
  String get screenKitGalleryTitle => 'Kit d\'interface';

  @override
  String get placeholderBody => 'Cet écran arrive dans une prochaine version.';

  @override
  String get welcomeKitGalleryLink => 'Ouvrir le kit d\'interface';

  @override
  String get invitationLinkReceived => 'Lien d\'invitation reçu.';

  @override
  String get invitationLinkMissing => 'Aucun lien d\'invitation.';

  @override
  String get routeNotFoundTitle => 'Page introuvable';

  @override
  String get routeNotFoundAction => 'Revenir à l\'accueil';

  @override
  String get accountSignOut => 'Se déconnecter';

  @override
  String get commonRetry => 'Réessayer';

  @override
  String get commonBack => 'Retour';

  @override
  String get commonClose => 'Fermer';

  @override
  String get commonLoading => 'Chargement…';

  @override
  String get commonContinue => 'Continuer';

  @override
  String get commonOptional => '(facultatif)';

  @override
  String get phoneCountryCode => 'Indicatif pays';

  @override
  String get errorNetworkTitle => 'Pas de connexion';

  @override
  String get errorNetworkBody =>
      'Vérifiez votre connexion Internet, puis réessayez.';

  @override
  String get errorUnauthorizedTitle => 'Session expirée';

  @override
  String get errorUnauthorizedBody => 'Reconnectez-vous pour continuer.';

  @override
  String get errorValidationTitle => 'Informations à corriger';

  @override
  String get errorValidationBody =>
      'Certaines informations ne sont pas valides. Corrigez-les, puis réessayez.';

  @override
  String get errorRateLimitedTitle => 'Trop de tentatives';

  @override
  String errorRateLimitedBody(int minutes) {
    return 'Réessayez dans $minutes min.';
  }

  @override
  String get errorRateLimitedBodyUnknown => 'Réessayez dans quelques minutes.';

  @override
  String get errorNotFoundTitle => 'Introuvable';

  @override
  String get errorNotFoundBody =>
      'Cet élément n\'existe pas ou n\'est plus disponible.';

  @override
  String get errorConflictTitle => 'Action déjà traitée';

  @override
  String get errorConflictBody =>
      'La situation a changé entre-temps. Actualisez, puis réessayez.';

  @override
  String get errorServerTitle => 'Service indisponible';

  @override
  String get errorServerBody =>
      'Le service rencontre un problème. Réessayez dans un instant.';

  @override
  String get errorBusinessTitle => 'Action impossible';

  @override
  String get errorBusinessBody => 'Cette action n\'a pas pu aboutir.';

  @override
  String get errorUnknownTitle => 'Une erreur est survenue';

  @override
  String get errorUnknownBody => 'Réessayez dans un instant.';
}
