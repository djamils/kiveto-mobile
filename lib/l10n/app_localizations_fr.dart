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

  @override
  String get identityWelcomeTitle =>
      'La santé de vos animaux, avec votre clinique';

  @override
  String get identityWelcomeIntro =>
      'Rendez-vous en ligne, documents, rappels de vaccins.';

  @override
  String get identityPhoneLabel => 'Numéro de mobile';

  @override
  String get identityPhoneHint => '6 12 34 56 78';

  @override
  String get identityPhoneHelp =>
      'Vous recevrez un code par SMS. Pas de mot de passe.';

  @override
  String get identityRequestCode => 'Recevoir mon code';

  @override
  String get identityInvitationBoxTitle =>
      'Votre clinique vous a envoyé une invitation ?';

  @override
  String get identityInvitationBoxBody =>
      'Ouvrez le lien reçu par SMS ou email : vos animaux et votre historique seront déjà là.';

  @override
  String get identityInvitationBoxAction => 'J\'ai un lien d\'invitation';

  @override
  String get identityCountrySheetTitle => 'Indicatif du numéro';

  @override
  String get identityCountryFrance => 'France';

  @override
  String get identityCountryReunionMayotte => 'La Réunion · Mayotte';

  @override
  String get identityCountryGuadeloupe => 'Guadeloupe';

  @override
  String get identityCountryGuyane => 'Guyane';

  @override
  String get identityCountryMartinique => 'Martinique';

  @override
  String get identityCountrySaintPierre => 'Saint-Pierre-et-Miquelon';

  @override
  String get identityCountryWallis => 'Wallis-et-Futuna';

  @override
  String get identityCountryNewCaledonia => 'Nouvelle-Calédonie';

  @override
  String get identityCountryPolynesia => 'Polynésie française';

  @override
  String get identityInvitationSheetBody =>
      'Le lien reçu par SMS ou email ouvre directement l\'application. Vous pouvez aussi le coller ici.';

  @override
  String get identityInvitationSheetLabel => 'Lien d\'invitation';

  @override
  String get identityInvitationSheetHint => 'https://…/invitation#t=…';

  @override
  String get identityInvitationSheetAction => 'Ouvrir l\'invitation';

  @override
  String get identityInvitationSheetError =>
      'Ce lien n\'est pas un lien d\'invitation. Copiez le lien complet reçu par SMS ou email.';

  @override
  String identityCodeSentTo(String phone) {
    return 'Envoyé par SMS au $phone.';
  }

  @override
  String get identityCodeEdit => 'Modifier';

  @override
  String get identityCodeLegend => 'Code de vérification';

  @override
  String get identityCodeHelp => 'Valable 10 minutes.';

  @override
  String identityCodeResendSmsIn(String time) {
    return 'Renvoyer le SMS dans $time';
  }

  @override
  String get identityCodeResendSms => 'Renvoyer le SMS';

  @override
  String get identityCodeResendEmail => 'Recevoir le code par email';

  @override
  String get identityCodeResentEmail =>
      'Si un email vérifié est associé à votre compte, le code vous y a été envoyé.';

  @override
  String get identityCodeResentSms => 'Nouveau code envoyé par SMS.';

  @override
  String get identityCodeNotReceived =>
      'Vous n\'avez pas reçu de code ? Réessayez dans quelques minutes.';

  @override
  String get identityCodeSubmit => 'Valider';

  @override
  String get identityRestart => 'Recommencer';

  @override
  String get identityReconnect => 'Se reconnecter';

  @override
  String get identityBackHome => 'Revenir à l\'accueil';

  @override
  String identityRegisterVerified(String phone) {
    return '$phone vérifié';
  }

  @override
  String get identityFirstNameLabel => 'Prénom';

  @override
  String get identityLastNameLabel => 'Nom';

  @override
  String get identityEmailLabel => 'Email';

  @override
  String get identityRegisterEmailHelp =>
      'Pour recevoir vos documents et confirmations.';

  @override
  String get identityRegisterNote =>
      'Vos animaux seront ajoutés lors de votre premier rendez-vous, ou retrouvés si votre clinique utilise déjà Kiveto.';

  @override
  String get identityRegisterSubmit => 'Créer mon compte';

  @override
  String identityTermsConsent(String terms, String privacy) {
    return 'J\'accepte les $terms et la $privacy.';
  }

  @override
  String get identityTermsLink => 'conditions d\'utilisation';

  @override
  String get identityPrivacyLink => 'politique de confidentialité';

  @override
  String get identityTermsOpenError =>
      'Impossible d\'ouvrir les conditions d\'utilisation.';

  @override
  String get identityTermsLoadError =>
      'Impossible de charger les conditions d\'utilisation.';

  @override
  String identityInvitationTag(String clinic) {
    return 'Invitation : $clinic';
  }

  @override
  String identityInvitationTitle(String pets) {
    return 'Activez votre espace pour suivre $pets';
  }

  @override
  String get identityInvitationTitleNoPet => 'Activez votre espace';

  @override
  String identityNamesAnd(String head, String last) {
    return '$head et $last';
  }

  @override
  String get identityInvitationIntro =>
      'Rendez-vous, documents et rappels de soins, au même endroit.';

  @override
  String get identityInvitationEmailHelp => 'Renseigné par la clinique.';

  @override
  String identityInvitationCodeLabel(String maskedPhone) {
    return 'Code reçu par SMS au $maskedPhone';
  }

  @override
  String get identityInvitationCodeHint => '6 chiffres';

  @override
  String identityInvitationResendIn(String time) {
    return 'Renvoyer le code dans $time';
  }

  @override
  String get identityInvitationResend => 'Renvoyer le code';

  @override
  String get identityInvitationSubmit => 'Activer mon espace';

  @override
  String identityInvitationExistingAccount(String action) {
    return 'Déjà un compte Kiveto ? $action';
  }

  @override
  String get identityInvitationAttach => 'Rattacher cette clinique';

  @override
  String get identityInvitationExpiredTitle => 'Invitation expirée';

  @override
  String get identityInvitationExpiredBody =>
      'Ce lien n\'est plus valable. Demandez à votre clinique de vous renvoyer une invitation.';

  @override
  String get identityInvitationInvalidTitle => 'Lien d\'invitation invalide';

  @override
  String get identityInvitationInvalidBody =>
      'Ce lien est incomplet ou a été remplacé par un envoi plus récent. Utilisez le dernier lien reçu, ou connectez-vous avec votre numéro.';

  @override
  String get identityInvitationUsedTitle => 'Invitation déjà utilisée';

  @override
  String get identityInvitationUsedBody =>
      'Cette invitation a déjà été acceptée. Connectez-vous avec votre numéro pour retrouver votre espace.';

  @override
  String get identityInvitationSignIn => 'Se connecter avec mon numéro';

  @override
  String identityOnboardingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count invitations',
      one: '1 invitation',
    );
    return '$_temp0';
  }

  @override
  String get identityOnboardingBody =>
      'Votre clinique vous invite à retrouver vos animaux sur Kiveto : rendez-vous, documents et rappels de soins, au même endroit.';

  @override
  String get identityOnboardingAcceptSelected => 'Accepter cette invitation';

  @override
  String identityOnboardingAccepted(String clinic) {
    return 'Invitation acceptée : $clinic.';
  }

  @override
  String get identityOnboardingLater => 'Plus tard';

  @override
  String identityOnboardingNotNow(String action) {
    return 'Pas maintenant ? $action';
  }

  @override
  String get identityOnboardingNone => 'Aucune invitation en attente.';

  @override
  String get identityErrorPhoneNotSupported =>
      'Ce numéro de mobile n\'est pas encore pris en charge par Kiveto.';

  @override
  String get identityErrorPhoneInvalid => 'Vérifiez votre numéro de mobile.';

  @override
  String get identityErrorOtpInvalid =>
      'Code incorrect. Vérifiez-le, puis réessayez.';

  @override
  String get identityErrorOtpExpired =>
      'Ce code a expiré. Demandez-en un nouveau.';

  @override
  String get identityErrorOtpAttemptsExceeded =>
      'Trop d\'essais. Demandez un nouveau code.';

  @override
  String identityErrorOtpRateLimited(int minutes) {
    return 'Trop de demandes de code. Réessayez dans $minutes min.';
  }

  @override
  String get identityErrorOtpRateLimitedUnknown =>
      'Trop de demandes de code. Réessayez dans quelques minutes.';

  @override
  String get identityErrorOtpChallengeNotFound =>
      'Cette demande de code n\'est plus valable. Recommencez.';

  @override
  String get identityErrorAccountDisabled =>
      'Ce compte est désactivé. Contactez votre clinique.';

  @override
  String get identityErrorOnboardingInvalid =>
      'Votre vérification a expiré. Reconnectez-vous avec votre numéro.';

  @override
  String get identityErrorAccountExists =>
      'Un compte existe déjà pour ce numéro. Connectez-vous avec votre numéro.';

  @override
  String get identityErrorTermsOutdated =>
      'Les conditions d\'utilisation ont changé : relisez-les, puis acceptez-les à nouveau.';

  @override
  String get identityErrorInvitationInvalid =>
      'Cette invitation n\'est plus disponible.';

  @override
  String homeGreeting(String firstName) {
    return 'Bonjour $firstName';
  }

  @override
  String get homeGreetingNoName => 'Bonjour';
}
