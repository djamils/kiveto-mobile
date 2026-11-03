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
  String get screenSignInCodeTitle => 'Entrez le code reçu';

  @override
  String get screenRegisterTitle => 'Créez votre compte';

  @override
  String get screenClinicsTitle => 'Trouver une clinique';

  @override
  String get screenAppointmentsTitle => 'Rendez-vous';

  @override
  String get screenDocumentsTitle => 'Documents';

  @override
  String get screenAccountTitle => 'Compte';

  @override
  String get screenBookingPetTitle => 'Pour quel animal ?';

  @override
  String get screenBookingMotifTitle => 'Quel est le motif ?';

  @override
  String get screenBookingSlotTitle => 'Choisissez un créneau';

  @override
  String get screenBookingConfirmTitle => 'Vérifiez et confirmez';

  @override
  String get screenQuestionnaireTitle => 'Avant la consultation';

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

  @override
  String homeClinicSwitcherLabel(String name) {
    return 'Changer de clinique, actuellement $name';
  }

  @override
  String get homeNextAppointmentTitle => 'Prochain rendez-vous';

  @override
  String get homeAppointmentConfirmed => 'Confirmé';

  @override
  String get homeAppointmentPending => 'En attente';

  @override
  String homeAppointmentPetMotif(String pet, String motif) {
    return '$pet — $motif';
  }

  @override
  String get homeFillQuestionnaire => 'Remplir le questionnaire';

  @override
  String get homeManageAppointments => 'Gérer';

  @override
  String get homePetsTitle => 'Mes animaux';

  @override
  String get homeCareTitle => 'À prévoir';

  @override
  String get homeCareCaption => 'Échéances de soins';

  @override
  String homeCareItemTitle(String pet, String label) {
    return '$pet — $label';
  }

  @override
  String homeCareDue(String date) {
    return 'Avant le $date';
  }

  @override
  String get homeBook => 'Prendre rendez-vous';

  @override
  String get homeDocumentsTitle => 'Derniers documents';

  @override
  String get homeDocumentsSeeAll => 'Tout voir';

  @override
  String get homeClinicGoneTitle => 'Clinique indisponible';

  @override
  String get homeClinicGoneBody =>
      'Votre accès à cette clinique n\'est plus actif.';

  @override
  String get clientClinicSwitcherTitle => 'Changer de clinique';

  @override
  String get clientClinicActive => 'Active';

  @override
  String get petSwitcherLabel => 'Animal';

  @override
  String get petSpeciesDog => 'Chien';

  @override
  String get petSpeciesCat => 'Chat';

  @override
  String get petSpeciesNac => 'NAC';

  @override
  String get petSpeciesOther => 'Autre';

  @override
  String get petSexMale => 'Mâle';

  @override
  String get petSexFemale => 'Femelle';

  @override
  String get petSexMaleNeutered => 'Mâle castré';

  @override
  String get petSexFemaleNeutered => 'Femelle stérilisée';

  @override
  String get petSexUnknownNeutered => 'Stérilisé';

  @override
  String get petDeceasedMale => 'Décédé';

  @override
  String get petDeceasedFemale => 'Décédée';

  @override
  String get petMissingMale => 'Disparu';

  @override
  String get petMissingFemale => 'Disparue';

  @override
  String petAgeYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ans',
      one: '1 an',
    );
    return '$_temp0';
  }

  @override
  String petAgeMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mois',
      one: '1 mois',
    );
    return '$_temp0';
  }

  @override
  String get petAgeUnderOneMonth => 'Moins d\'un mois';

  @override
  String get petBornMale => 'Né le';

  @override
  String get petBornFemale => 'Née le';

  @override
  String get petWeight => 'Poids';

  @override
  String petWeightValue(String value) {
    return '$value kg';
  }

  @override
  String get petChip => 'Puce';

  @override
  String get petReferentVet => 'Suivi par';

  @override
  String get petNone => '—';

  @override
  String get petReportChange => 'Signaler une modification';

  @override
  String get petReportChangeCaption =>
      'Vérifiée par la clinique avant mise à jour de la fiche.';

  @override
  String get petCareTitle => 'Vaccins et préventions';

  @override
  String get petBooklet => 'Carnet PDF';

  @override
  String petBookletTitle(String name) {
    return 'Carnet de vaccination · $name';
  }

  @override
  String get petCareEmpty => 'Aucun soin préventif à suivre.';

  @override
  String get petEmptyTitle => 'Aucun animal';

  @override
  String petEmptyBody(String clinic) {
    return 'Les animaux suivis par $clinic apparaîtront ici.';
  }

  @override
  String get careBooked => 'RDV pris';

  @override
  String get careOverdue => 'En retard';

  @override
  String get careUpToDate => 'À jour';

  @override
  String get careToday => 'Aujourd\'hui';

  @override
  String get careTomorrow => 'Demain';

  @override
  String careInDays(int count) {
    return 'Dans $count j';
  }

  @override
  String careInWeeks(int count) {
    return 'Dans $count sem.';
  }

  @override
  String careDoneAndDue(String done, String due) {
    return 'Fait le $done · prochain avant le $due';
  }

  @override
  String careOverdueSince(String due) {
    return 'À faire depuis le $due';
  }

  @override
  String careDueBefore(String due) {
    return 'Prochain avant le $due';
  }

  @override
  String careValidUntil(String due) {
    return 'Valide jusqu\'au $due';
  }

  @override
  String get timelineTitle => 'Historique';

  @override
  String get timelineNoDocument => 'Aucun document partagé';

  @override
  String get timelineEmpty => 'Aucune consultation partagée pour le moment.';

  @override
  String get timelineMoreError => 'Impossible de charger la suite.';

  @override
  String documentsSubtitle(String clinic) {
    return 'Partagés par $clinic';
  }

  @override
  String get documentsFilterGroup => 'Filtrer par type';

  @override
  String get documentsFilterAll => 'Tous';

  @override
  String get documentsFilterReports => 'Comptes-rendus';

  @override
  String get documentsFilterPrescriptions => 'Ordonnances';

  @override
  String get documentsFilterInvoices => 'Factures';

  @override
  String get documentsFilterLabResults => 'Résultats';

  @override
  String get documentsGlyphReport => 'CR';

  @override
  String get documentsGlyphPrescription => 'Rx';

  @override
  String get documentsGlyphInvoice => '€';

  @override
  String get documentsGlyphLabResult => 'Lab';

  @override
  String get documentsGlyphCertificate => 'Cert';

  @override
  String documentsValidUntil(String date) {
    return 'valable jusqu\'au $date';
  }

  @override
  String get documentsPaymentPaid => 'Payée';

  @override
  String get documentsPaymentUnpaid => 'Non payée';

  @override
  String get documentsPaymentPartiallyPaid => 'Partiellement payée';

  @override
  String get documentsPaymentCredited => 'Avoir émis';

  @override
  String documentsOpen(String title) {
    return 'Ouvrir $title';
  }

  @override
  String get documentsUnread => 'Nouveau';

  @override
  String get documentsRequestRenewal => 'Demander un renouvellement';

  @override
  String get documentsRenewalRequested => 'Renouvellement demandé';

  @override
  String get documentsRenewalDone => 'Renouvellement traité';

  @override
  String get documentsEmptyAllTitle => 'Aucun document';

  @override
  String get documentsEmptyReportsTitle => 'Aucun compte-rendu';

  @override
  String get documentsEmptyPrescriptionsTitle => 'Aucune ordonnance';

  @override
  String get documentsEmptyInvoicesTitle => 'Aucune facture';

  @override
  String get documentsEmptyLabResultsTitle => 'Aucun résultat d\'analyse';

  @override
  String documentsEmptyBody(String clinic) {
    return 'Les documents partagés par $clinic apparaîtront ici.';
  }

  @override
  String get documentsMoreError => 'Impossible de charger la suite.';

  @override
  String get documentsLinkGoneTitle => 'Documents indisponibles';

  @override
  String get documentsLinkGoneBody =>
      'Votre accès aux documents de cette clinique n\'est plus actif.';

  @override
  String get documentsFileGoneTitle => 'Document indisponible';

  @override
  String get documentsFileGoneBody =>
      'Ce document a été retiré ou n\'est pas encore prêt. Réessayez plus tard.';

  @override
  String get documentsFileRenderError => 'Impossible d\'afficher ce document.';

  @override
  String documentsPrescriptionTitle(String date) {
    return 'Ordonnance du $date';
  }

  @override
  String documentsPrescriptionLine(String quantity, String posology) {
    return 'Qté $quantity · $posology';
  }

  @override
  String get documentsPrescriptionOpen => 'Voir l\'ordonnance';

  @override
  String get documentsPrescriptionGoneTitle => 'Ordonnance indisponible';

  @override
  String get documentsPrescriptionGoneBody =>
      'Cette ordonnance n\'est plus disponible.';

  @override
  String get documentsKindReport => 'Compte-rendu';

  @override
  String get documentsKindPrescription => 'Ordonnance';

  @override
  String get documentsKindInvoice => 'Facture';

  @override
  String get documentsKindLabResult => 'Résultats';

  @override
  String get documentsKindCertificate => 'Certificat';

  @override
  String get documentsKindUnknown => 'Document';

  @override
  String documentsNamesAnd(String head, String last) {
    return '$head et $last';
  }

  @override
  String bookingStepLabel(int step) {
    return 'Étape $step sur 4';
  }

  @override
  String get bookingPetLabel => 'Animal';

  @override
  String bookingClinicSwitcherLabel(String name) {
    return 'Changer de clinique, actuellement $name';
  }

  @override
  String get bookingNewPet => 'Un autre animal';

  @override
  String get bookingNewPetName => 'Nom de l\'animal';

  @override
  String get bookingNewPetSpecies => 'Espèce';

  @override
  String get bookingPetFootnote =>
      'Un nouvel animal est ajouté à votre dossier dès la réservation ; la clinique complète sa fiche lors de la visite.';

  @override
  String get bookingPetBarLabel => 'Rendez-vous pour';

  @override
  String get bookingNewPetBarValue => 'Nouvel animal';

  @override
  String get bookingMotifLabel => 'Motif';

  @override
  String bookingMotifSubtitle(String pet, String clinic) {
    return 'Pour $pet · $clinic';
  }

  @override
  String get bookingMotifSuggested => 'Rappel à faire';

  @override
  String bookingMotifDuration(int minutes) {
    return '$minutes min';
  }

  @override
  String get bookingMotifEmpty => 'Choisissez un motif';

  @override
  String get bookingMotifsEmptyTitle => 'Aucun motif en ligne';

  @override
  String get bookingMotifsEmptyBody =>
      'Cette clinique ne propose pas de rendez-vous en ligne pour le moment.';

  @override
  String get bookingNotOpenTitle => 'Réservation en ligne indisponible';

  @override
  String get bookingNotOpenBody =>
      'Cette clinique ne prend pas de rendez-vous en ligne pour le moment. Contactez-la directement.';

  @override
  String get bookingEmergency =>
      'Urgence ? Ne réservez pas en ligne, appelez la clinique.';

  @override
  String get bookingEmergencyNoPhone =>
      'Urgence ? Ne réservez pas en ligne, appelez directement la clinique.';

  @override
  String get bookingCall => 'Appeler';

  @override
  String get bookingCallError => 'Impossible de lancer l\'appel.';

  @override
  String get bookingSlotLabel => 'Votre créneau';

  @override
  String get bookingSlotEmpty => 'Choisissez un créneau';

  @override
  String bookingDateAtTime(String date, String time) {
    return '$date à $time';
  }

  @override
  String get bookingVetLabel => 'Vétérinaire';

  @override
  String get bookingPreviousWeek => 'Semaine précédente';

  @override
  String get bookingNextWeek => 'Semaine suivante';

  @override
  String get bookingMorning => 'Matin';

  @override
  String get bookingAfternoon => 'Après-midi';

  @override
  String get bookingNoSlotDay => 'Aucun créneau disponible ce jour-là.';

  @override
  String get bookingNoSlotWeek => 'Aucun créneau cette semaine.';

  @override
  String get bookingNoPractitioner =>
      'Aucun vétérinaire ne prend de rendez-vous en ligne pour ce motif.';

  @override
  String get bookingSlotFootnote =>
      'Seuls les créneaux ouverts à la réservation en ligne par la clinique sont affichés.';

  @override
  String get bookingSlotTaken =>
      'Ce créneau vient d\'être pris. Choisissez-en un autre.';

  @override
  String bookingSlotTakenLabel(String time) {
    return '$time, déjà pris';
  }

  @override
  String get bookingRecapDate => 'Date';

  @override
  String get bookingRecapClinic => 'Clinique';

  @override
  String get bookingEdit => 'Modifier';

  @override
  String bookingNewPetSecondary(String species) {
    return 'Nouvel animal · $species';
  }

  @override
  String get bookingReassuranceCancel =>
      'Annulation et report en ligne jusqu\'au délai fixé par la clinique';

  @override
  String get bookingReassuranceQuestionnaire =>
      'Questionnaire de 2 min avant la visite';

  @override
  String get bookingConfirm => 'Confirmer le rendez-vous';

  @override
  String get bookingConfirmedTitle => 'Rendez-vous confirmé';

  @override
  String get bookingPendingTitle => 'Demande envoyée';

  @override
  String get bookingSmsSent => 'Une confirmation vous a été envoyée.';

  @override
  String get bookingPendingNote =>
      'La clinique doit confirmer ce rendez-vous. Vous le retrouverez dans vos rendez-vous.';

  @override
  String get bookingFillQuestionnaire => 'Remplir le questionnaire maintenant';

  @override
  String get bookingLater => 'Plus tard';

  @override
  String get bookingBackHome => 'Retour à l\'accueil';

  @override
  String get bookingErrorPetNotBookable =>
      'Cet animal ne peut plus prendre rendez-vous en ligne.';

  @override
  String get bookingErrorNotOpen =>
      'La réservation en ligne n\'est pas ouverte pour ce motif. Contactez la clinique.';

  @override
  String get bookingErrorNotFound =>
      'Ce choix n\'est plus disponible. Recommencez la réservation.';

  @override
  String get appointmentsNew => 'Nouveau rendez-vous';

  @override
  String get appointmentsUpcoming => 'À venir';

  @override
  String get appointmentsPast => 'Passés';

  @override
  String get appointmentsStatusConfirmed => 'Confirmé';

  @override
  String get appointmentsStatusPending => 'En attente';

  @override
  String get appointmentsStatusCancelled => 'Annulé';

  @override
  String get appointmentsStatusCancelledByClinic => 'Annulé par la clinique';

  @override
  String get appointmentsStatusDeclined => 'Refusé';

  @override
  String get appointmentsStatusCompleted => 'Terminé';

  @override
  String get appointmentsStatusNoShow => 'Non honoré';

  @override
  String appointmentsTimePet(String time, String pet) {
    return '$time · $pet';
  }

  @override
  String get appointmentsPendingLine =>
      'En attente de confirmation par la clinique';

  @override
  String get appointmentsQuestionnaireTitle => 'Questionnaire à compléter';

  @override
  String get appointmentsQuestionnaireBody =>
      '2 min · motif, symptômes, traitements en cours';

  @override
  String get appointmentsReschedule => 'Reporter';

  @override
  String get appointmentsCancel => 'Annuler';

  @override
  String appointmentsCancellableUntil(String date, String time) {
    return 'Annulation en ligne possible jusqu\'au $date à $time.';
  }

  @override
  String get appointmentsWindowClosed =>
      'Le délai d\'annulation en ligne est dépassé : contactez la clinique.';

  @override
  String get appointmentsAddToCalendar => 'Ajouter à mon calendrier';

  @override
  String get appointmentsCalendarError =>
      'Impossible d\'ajouter ce rendez-vous à votre calendrier.';

  @override
  String get appointmentsEmptyUpcomingTitle => 'Aucun rendez-vous à venir';

  @override
  String get appointmentsBook => 'Prendre rendez-vous';

  @override
  String get appointmentsEmptyPastTitle => 'Aucun rendez-vous passé';

  @override
  String get appointmentsClinicGoneTitle => 'Clinique indisponible';

  @override
  String get appointmentsClinicGoneBody =>
      'Votre accès à cette clinique n\'est plus actif.';

  @override
  String get appointmentsMoreError => 'Impossible de charger la suite.';

  @override
  String get appointmentsBackToList => 'Retour à mes rendez-vous';

  @override
  String get appointmentCancelTitle => 'Annuler ce rendez-vous ?';

  @override
  String appointmentCancelSubtitle(String date, String pet, String motif) {
    return '$date · $pet — $motif';
  }

  @override
  String appointmentCancelSubtitleNoPet(String date, String motif) {
    return '$date — $motif';
  }

  @override
  String appointmentCancelCareVaccination(
    String label,
    String pet,
    String date,
  ) {
    return 'Le rappel $label est à faire avant le $date pour $pet. Reporter évite un retard de vaccination.';
  }

  @override
  String appointmentCancelCareInternalParasite(
    String label,
    String pet,
    String date,
  ) {
    return 'Le traitement $label est à faire avant le $date pour $pet. Reporter évite un retard de vermifugation.';
  }

  @override
  String appointmentCancelCareExternalParasite(
    String label,
    String pet,
    String date,
  ) {
    return 'Le traitement $label est à faire avant le $date pour $pet. Reporter évite un retard de traitement antiparasitaire.';
  }

  @override
  String appointmentCancelCareOther(String label, String pet, String date) {
    return 'Le soin $label est à faire avant le $date pour $pet. Reporter évite un retard de soin.';
  }

  @override
  String get appointmentCancelReasonLegend => 'Raison de l\'annulation';

  @override
  String get appointmentCancelReasonUnavailable => 'Empêchement';

  @override
  String get appointmentCancelReasonNoLongerNeeded => 'Plus nécessaire';

  @override
  String get appointmentCancelReasonSeenElsewhere => 'Vu ailleurs';

  @override
  String get appointmentCancelReasonOther => 'Autre';

  @override
  String get appointmentCancelConfirm => 'Annuler le rendez-vous';

  @override
  String get appointmentCancelReschedule => 'Reporter plutôt';

  @override
  String get appointmentCancelKeep => 'Garder mon rendez-vous';

  @override
  String get appointmentCancelDoneTitle => 'Rendez-vous annulé';

  @override
  String get appointmentCancelDoneBody => 'La clinique a été prévenue.';

  @override
  String get appointmentCancelDoneSms => 'Une confirmation vous est envoyée.';

  @override
  String get appointmentCancelNotModifiable =>
      'Ce rendez-vous ne peut plus être modifié.';

  @override
  String rescheduleSubtitle(String pet, String motif, String date) {
    return '$pet · $motif · actuellement $date';
  }

  @override
  String rescheduleSubtitleNoPet(String motif, String date) {
    return '$motif · actuellement $date';
  }

  @override
  String get rescheduleSlotLabel => 'Nouveau créneau';

  @override
  String get rescheduleConfirm => 'Confirmer';

  @override
  String get rescheduleDoneTitle => 'Rendez-vous reporté';

  @override
  String get rescheduleNotAllowed =>
      'Ce rendez-vous ne peut pas être reporté en ligne.';

  @override
  String get rescheduleNotFoundTitle => 'Rendez-vous introuvable';

  @override
  String bookingNewPetNameTooLong(int max) {
    return '$max caractères au plus.';
  }

  @override
  String get appointmentGone => 'Ce rendez-vous n\'est plus disponible.';

  @override
  String get rescheduleStillPending =>
      'La clinique doit confirmer le nouveau créneau.';

  @override
  String get rescheduleSlotGone =>
      'Ce créneau n\'est plus proposé pour ce rendez-vous. Choisissez-en un autre.';
}
