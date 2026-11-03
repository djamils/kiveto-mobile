import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('fr')];

  /// The app name: recents screen, task switcher.
  ///
  /// In fr, this message translates to:
  /// **'Kiveto'**
  String get appTitle;

  /// Bottom navigation: the home tab.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get navHome;

  /// Bottom navigation: the pets tab.
  ///
  /// In fr, this message translates to:
  /// **'Animaux'**
  String get navPets;

  /// Bottom navigation: the appointments tab.
  ///
  /// In fr, this message translates to:
  /// **'Rendez-vous'**
  String get navAppointments;

  /// Bottom navigation: the documents tab.
  ///
  /// In fr, this message translates to:
  /// **'Documents'**
  String get navDocuments;

  /// Bottom navigation: the account tab.
  ///
  /// In fr, this message translates to:
  /// **'Compte'**
  String get navAccount;

  /// Screen reader label of the documents tab when unread documents exist.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{Documents, 1 nouveau} other{Documents, {count} nouveaux}}'**
  String navDocumentsUnread(int count);

  /// Title of the code entry screen (8).
  ///
  /// In fr, this message translates to:
  /// **'Entrez le code reçu'**
  String get screenSignInCodeTitle;

  /// Title of the registration screen (9).
  ///
  /// In fr, this message translates to:
  /// **'Créez votre compte'**
  String get screenRegisterTitle;

  /// Title of the clinic search screen (10).
  ///
  /// In fr, this message translates to:
  /// **'Trouver une clinique'**
  String get screenClinicsTitle;

  /// Title of the appointments screen (4).
  ///
  /// In fr, this message translates to:
  /// **'Rendez-vous'**
  String get screenAppointmentsTitle;

  /// Title of the documents screen (5).
  ///
  /// In fr, this message translates to:
  /// **'Documents'**
  String get screenDocumentsTitle;

  /// Title of the account screen (6).
  ///
  /// In fr, this message translates to:
  /// **'Compte'**
  String get screenAccountTitle;

  /// Title of the booking step 1, the pet (12).
  ///
  /// In fr, this message translates to:
  /// **'Pour quel animal ?'**
  String get screenBookingPetTitle;

  /// Title of the booking step 2, the reason (13).
  ///
  /// In fr, this message translates to:
  /// **'Quel est le motif ?'**
  String get screenBookingMotifTitle;

  /// Title of the booking step 3, the slot (3).
  ///
  /// In fr, this message translates to:
  /// **'Choisissez un créneau'**
  String get screenBookingSlotTitle;

  /// Title of the booking step 4, the summary (14).
  ///
  /// In fr, this message translates to:
  /// **'Vérifiez et confirmez'**
  String get screenBookingConfirmTitle;

  /// Title of the pre-consultation questionnaire (15).
  ///
  /// In fr, this message translates to:
  /// **'Avant la consultation'**
  String get screenQuestionnaireTitle;

  /// Title of the reschedule screen (the slot picker of 3, reused).
  ///
  /// In fr, this message translates to:
  /// **'Reporter le rendez-vous'**
  String get screenRescheduleTitle;

  /// Title of the prescription renewal screen (17).
  ///
  /// In fr, this message translates to:
  /// **'Demander un renouvellement'**
  String get screenPrescriptionRenewalTitle;

  /// Title of the clinic sheet of the directory (11).
  ///
  /// In fr, this message translates to:
  /// **'Fiche clinique'**
  String get screenClinicListingTitle;

  /// Title of the debug-only gallery of the UI kit.
  ///
  /// In fr, this message translates to:
  /// **'Kit d\'interface'**
  String get screenKitGalleryTitle;

  /// Body of a screen not built yet.
  ///
  /// In fr, this message translates to:
  /// **'Cet écran arrive dans une prochaine version.'**
  String get placeholderBody;

  /// Debug builds only: the link from the welcome screen to the UI kit gallery.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir le kit d\'interface'**
  String get welcomeKitGalleryLink;

  /// Title shown for an unknown link or route.
  ///
  /// In fr, this message translates to:
  /// **'Page introuvable'**
  String get routeNotFoundTitle;

  /// Button of the unknown route page, back to the home screen.
  ///
  /// In fr, this message translates to:
  /// **'Revenir à l\'accueil'**
  String get routeNotFoundAction;

  /// Account screen: the sign-out button.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get accountSignOut;

  /// Retry button of the error views.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get commonRetry;

  /// Screen reader label of the back button.
  ///
  /// In fr, this message translates to:
  /// **'Retour'**
  String get commonBack;

  /// Screen reader label of the close button.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get commonClose;

  /// Screen reader label of the loading indicators.
  ///
  /// In fr, this message translates to:
  /// **'Chargement…'**
  String get commonLoading;

  /// Generic continue button.
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get commonContinue;

  /// Suffix of the label of an optional field.
  ///
  /// In fr, this message translates to:
  /// **'(facultatif)'**
  String get commonOptional;

  /// Screen reader label of the country code button of the phone field.
  ///
  /// In fr, this message translates to:
  /// **'Indicatif pays'**
  String get phoneCountryCode;

  /// Error view title: no usable answer (offline, timeout, cancelled).
  ///
  /// In fr, this message translates to:
  /// **'Pas de connexion'**
  String get errorNetworkTitle;

  /// Error view body: no usable answer.
  ///
  /// In fr, this message translates to:
  /// **'Vérifiez votre connexion Internet, puis réessayez.'**
  String get errorNetworkBody;

  /// Error view title: the server refused the session (401).
  ///
  /// In fr, this message translates to:
  /// **'Session expirée'**
  String get errorUnauthorizedTitle;

  /// Error view body: the server refused the session.
  ///
  /// In fr, this message translates to:
  /// **'Reconnectez-vous pour continuer.'**
  String get errorUnauthorizedBody;

  /// Error view title: the server refused the data sent (422 validation_failed).
  ///
  /// In fr, this message translates to:
  /// **'Informations à corriger'**
  String get errorValidationTitle;

  /// Error view body: the server refused the data sent.
  ///
  /// In fr, this message translates to:
  /// **'Certaines informations ne sont pas valides. Corrigez-les, puis réessayez.'**
  String get errorValidationBody;

  /// Error view title: too many requests (429).
  ///
  /// In fr, this message translates to:
  /// **'Trop de tentatives'**
  String get errorRateLimitedTitle;

  /// Error view body: too many requests, with the wait announced by the server, rounded up to the minute.
  ///
  /// In fr, this message translates to:
  /// **'Réessayez dans {minutes} min.'**
  String errorRateLimitedBody(int minutes);

  /// Error view body: too many requests, without a wait announced by the server.
  ///
  /// In fr, this message translates to:
  /// **'Réessayez dans quelques minutes.'**
  String get errorRateLimitedBodyUnknown;

  /// Error view title: the resource does not exist (404).
  ///
  /// In fr, this message translates to:
  /// **'Introuvable'**
  String get errorNotFoundTitle;

  /// Error view body: the resource does not exist.
  ///
  /// In fr, this message translates to:
  /// **'Cet élément n\'existe pas ou n\'est plus disponible.'**
  String get errorNotFoundBody;

  /// Error view title: the action conflicts with the current state (409).
  ///
  /// In fr, this message translates to:
  /// **'Action déjà traitée'**
  String get errorConflictTitle;

  /// Error view body: the action conflicts with the current state.
  ///
  /// In fr, this message translates to:
  /// **'La situation a changé entre-temps. Actualisez, puis réessayez.'**
  String get errorConflictBody;

  /// Error view title: server error (5xx) or unexpected answer.
  ///
  /// In fr, this message translates to:
  /// **'Service indisponible'**
  String get errorServerTitle;

  /// Error view body: server error or unexpected answer.
  ///
  /// In fr, this message translates to:
  /// **'Le service rencontre un problème. Réessayez dans un instant.'**
  String get errorServerBody;

  /// Error view title: the server refused the action (another 4xx).
  ///
  /// In fr, this message translates to:
  /// **'Action impossible'**
  String get errorBusinessTitle;

  /// Error view body: the server refused the action.
  ///
  /// In fr, this message translates to:
  /// **'Cette action n\'a pas pu aboutir.'**
  String get errorBusinessBody;

  /// Error view title: an error that is not an API failure.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue'**
  String get errorUnknownTitle;

  /// Error view body: an error that is not an API failure.
  ///
  /// In fr, this message translates to:
  /// **'Réessayez dans un instant.'**
  String get errorUnknownBody;

  /// Welcome screen (7): the title.
  ///
  /// In fr, this message translates to:
  /// **'La santé de vos animaux, avec votre clinique'**
  String get identityWelcomeTitle;

  /// Welcome screen (7): the line under the title.
  ///
  /// In fr, this message translates to:
  /// **'Rendez-vous en ligne, documents, rappels de vaccins.'**
  String get identityWelcomeIntro;

  /// Welcome screen (7): label of the mobile number field.
  ///
  /// In fr, this message translates to:
  /// **'Numéro de mobile'**
  String get identityPhoneLabel;

  /// Welcome screen (7): placeholder of the mobile number field (a French number without its leading 0).
  ///
  /// In fr, this message translates to:
  /// **'6 12 34 56 78'**
  String get identityPhoneHint;

  /// Welcome screen (7): help text under the mobile number field.
  ///
  /// In fr, this message translates to:
  /// **'Vous recevrez un code par SMS. Pas de mot de passe.'**
  String get identityPhoneHelp;

  /// Welcome screen (7): the button that sends the sign-in code by SMS.
  ///
  /// In fr, this message translates to:
  /// **'Recevoir mon code'**
  String get identityRequestCode;

  /// Welcome screen (7): title of the invitation box at the bottom.
  ///
  /// In fr, this message translates to:
  /// **'Votre clinique vous a envoyé une invitation ?'**
  String get identityInvitationBoxTitle;

  /// Welcome screen (7): body of the invitation box.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrez le lien reçu par SMS ou email : vos animaux et votre historique seront déjà là.'**
  String get identityInvitationBoxBody;

  /// Welcome screen (7): link of the invitation box, opens the invitation link sheet.
  ///
  /// In fr, this message translates to:
  /// **'J\'ai un lien d\'invitation'**
  String get identityInvitationBoxAction;

  /// Country code sheet of the welcome screen: its title.
  ///
  /// In fr, this message translates to:
  /// **'Indicatif du numéro'**
  String get identityCountrySheetTitle;

  /// Country code sheet: +33.
  ///
  /// In fr, this message translates to:
  /// **'France'**
  String get identityCountryFrance;

  /// Country code sheet: +262.
  ///
  /// In fr, this message translates to:
  /// **'La Réunion · Mayotte'**
  String get identityCountryReunionMayotte;

  /// Country code sheet: +590.
  ///
  /// In fr, this message translates to:
  /// **'Guadeloupe'**
  String get identityCountryGuadeloupe;

  /// Country code sheet: +594.
  ///
  /// In fr, this message translates to:
  /// **'Guyane'**
  String get identityCountryGuyane;

  /// Country code sheet: +596.
  ///
  /// In fr, this message translates to:
  /// **'Martinique'**
  String get identityCountryMartinique;

  /// Country code sheet: +508.
  ///
  /// In fr, this message translates to:
  /// **'Saint-Pierre-et-Miquelon'**
  String get identityCountrySaintPierre;

  /// Country code sheet: +681.
  ///
  /// In fr, this message translates to:
  /// **'Wallis-et-Futuna'**
  String get identityCountryWallis;

  /// Country code sheet: +687.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle-Calédonie'**
  String get identityCountryNewCaledonia;

  /// Country code sheet: +689.
  ///
  /// In fr, this message translates to:
  /// **'Polynésie française'**
  String get identityCountryPolynesia;

  /// Invitation link sheet of the welcome screen: the explanation (its title is identityInvitationBoxAction).
  ///
  /// In fr, this message translates to:
  /// **'Le lien reçu par SMS ou email ouvre directement l\'application. Vous pouvez aussi le coller ici.'**
  String get identityInvitationSheetBody;

  /// Invitation link sheet: label of the field where the link is pasted.
  ///
  /// In fr, this message translates to:
  /// **'Lien d\'invitation'**
  String get identityInvitationSheetLabel;

  /// Invitation link sheet: placeholder of the link field.
  ///
  /// In fr, this message translates to:
  /// **'https://…/invitation#t=…'**
  String get identityInvitationSheetHint;

  /// Invitation link sheet: the button that opens the pasted invitation.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir l\'invitation'**
  String get identityInvitationSheetAction;

  /// Invitation link sheet: the pasted text is not an invitation link.
  ///
  /// In fr, this message translates to:
  /// **'Ce lien n\'est pas un lien d\'invitation. Copiez le lien complet reçu par SMS ou email.'**
  String get identityInvitationSheetError;

  /// Code screen (8): where the code was sent; the number is shown in bold.
  ///
  /// In fr, this message translates to:
  /// **'Envoyé par SMS au {phone}.'**
  String identityCodeSentTo(String phone);

  /// Code screen (8): link back to the welcome screen to change the number.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get identityCodeEdit;

  /// Code screen (8): legend of the 6 code boxes.
  ///
  /// In fr, this message translates to:
  /// **'Code de vérification'**
  String get identityCodeLegend;

  /// Code screen (8): help text under the code boxes.
  ///
  /// In fr, this message translates to:
  /// **'Valable 10 minutes.'**
  String get identityCodeHelp;

  /// Code screen (8): the disabled resend button during the countdown (m:ss).
  ///
  /// In fr, this message translates to:
  /// **'Renvoyer le SMS dans {time}'**
  String identityCodeResendSmsIn(String time);

  /// Code screen (8): sends a new code by SMS.
  ///
  /// In fr, this message translates to:
  /// **'Renvoyer le SMS'**
  String get identityCodeResendSms;

  /// Code screen (8): sends a new code by email (verified email only).
  ///
  /// In fr, this message translates to:
  /// **'Recevoir le code par email'**
  String get identityCodeResendEmail;

  /// Code screen (8): after a resend by email (the server answers the same whether an email exists or not).
  ///
  /// In fr, this message translates to:
  /// **'Si un email vérifié est associé à votre compte, le code vous y a été envoyé.'**
  String get identityCodeResentEmail;

  /// Code screen (8) and invitation screen (0): after a resend by SMS.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau code envoyé par SMS.'**
  String get identityCodeResentSms;

  /// Code screen (8): footnote once the resend countdown is over.
  ///
  /// In fr, this message translates to:
  /// **'Vous n\'avez pas reçu de code ? Réessayez dans quelques minutes.'**
  String get identityCodeNotReceived;

  /// Code screen (8): verifies the code.
  ///
  /// In fr, this message translates to:
  /// **'Valider'**
  String get identityCodeSubmit;

  /// Sign-in screens: back to the welcome screen after a request that is no longer valid.
  ///
  /// In fr, this message translates to:
  /// **'Recommencer'**
  String get identityRestart;

  /// Invitation screens: back to the welcome screen after the verification expired.
  ///
  /// In fr, this message translates to:
  /// **'Se reconnecter'**
  String get identityReconnect;

  /// Invitation screens: back to the welcome screen (signed out) or to the home (signed in).
  ///
  /// In fr, this message translates to:
  /// **'Revenir à l\'accueil'**
  String get identityBackHome;

  /// Registration screen (9): the success tag of the verified number.
  ///
  /// In fr, this message translates to:
  /// **'{phone} vérifié'**
  String identityRegisterVerified(String phone);

  /// Registration screen (9): label of the first name field.
  ///
  /// In fr, this message translates to:
  /// **'Prénom'**
  String get identityFirstNameLabel;

  /// Registration screen (9): label of the last name field.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get identityLastNameLabel;

  /// Registration (9) and invitation (0) screens: label of the email field.
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get identityEmailLabel;

  /// Registration screen (9): help text under the optional email field.
  ///
  /// In fr, this message translates to:
  /// **'Pour recevoir vos documents et confirmations.'**
  String get identityRegisterEmailHelp;

  /// Registration screen (9): the note under the form.
  ///
  /// In fr, this message translates to:
  /// **'Vos animaux seront ajoutés lors de votre premier rendez-vous, ou retrouvés si votre clinique utilise déjà Kiveto.'**
  String get identityRegisterNote;

  /// Registration screen (9): creates the account.
  ///
  /// In fr, this message translates to:
  /// **'Créer mon compte'**
  String get identityRegisterSubmit;

  /// Terms checkbox (screens 0, 9 and the pending invitations); both placeholders are links.
  ///
  /// In fr, this message translates to:
  /// **'J\'accepte les {terms} et la {privacy}.'**
  String identityTermsConsent(String terms, String privacy);

  /// Terms checkbox: the link to the terms of use.
  ///
  /// In fr, this message translates to:
  /// **'conditions d\'utilisation'**
  String get identityTermsLink;

  /// Terms checkbox: the link to the privacy policy (the terms page).
  ///
  /// In fr, this message translates to:
  /// **'politique de confidentialité'**
  String get identityPrivacyLink;

  /// Snackbar: the terms page could not be opened.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d\'ouvrir les conditions d\'utilisation.'**
  String get identityTermsOpenError;

  /// Terms checkbox: the current terms could not be loaded (a retry link follows).
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger les conditions d\'utilisation.'**
  String get identityTermsLoadError;

  /// Invitation screens: the tag naming the inviting clinic.
  ///
  /// In fr, this message translates to:
  /// **'Invitation : {clinic}'**
  String identityInvitationTag(String clinic);

  /// Invitation screen (0): the title with the pet names ("Moka et Pistache").
  ///
  /// In fr, this message translates to:
  /// **'Activez votre espace pour suivre {pets}'**
  String identityInvitationTitle(String pets);

  /// Invitation screens: the title without pet names.
  ///
  /// In fr, this message translates to:
  /// **'Activez votre espace'**
  String get identityInvitationTitleNoPet;

  /// A list of names: the first ones joined by commas, then the last one ("Moka, Oslo et Pistache").
  ///
  /// In fr, this message translates to:
  /// **'{head} et {last}'**
  String identityNamesAnd(String head, String last);

  /// Invitation screen (0): the line under the title.
  ///
  /// In fr, this message translates to:
  /// **'Rendez-vous, documents et rappels de soins, au même endroit.'**
  String get identityInvitationIntro;

  /// Invitation screen (0): help text under the read-only email.
  ///
  /// In fr, this message translates to:
  /// **'Renseigné par la clinique.'**
  String get identityInvitationEmailHelp;

  /// Invitation screen (0): label of the code field, with the masked number as the server sends it.
  ///
  /// In fr, this message translates to:
  /// **'Code reçu par SMS au {maskedPhone}'**
  String identityInvitationCodeLabel(String maskedPhone);

  /// Invitation screen (0): placeholder of the code field.
  ///
  /// In fr, this message translates to:
  /// **'6 chiffres'**
  String get identityInvitationCodeHint;

  /// Invitation screen (0): the disabled resend button during the countdown (m:ss).
  ///
  /// In fr, this message translates to:
  /// **'Renvoyer le code dans {time}'**
  String identityInvitationResendIn(String time);

  /// Invitation screen (0): sends a new invitation code by SMS.
  ///
  /// In fr, this message translates to:
  /// **'Renvoyer le code'**
  String get identityInvitationResend;

  /// Invitation screens: accepts the invitation.
  ///
  /// In fr, this message translates to:
  /// **'Activer mon espace'**
  String get identityInvitationSubmit;

  /// Invitation screen (0), signed out: the bottom line; the placeholder is a link.
  ///
  /// In fr, this message translates to:
  /// **'Déjà un compte Kiveto ? {action}'**
  String identityInvitationExistingAccount(String action);

  /// Invitation screen (0): link to the welcome screen, to sign in with an existing account.
  ///
  /// In fr, this message translates to:
  /// **'Rattacher cette clinique'**
  String get identityInvitationAttach;

  /// Invitation screen (0): title of an expired invitation.
  ///
  /// In fr, this message translates to:
  /// **'Invitation expirée'**
  String get identityInvitationExpiredTitle;

  /// Invitation screen (0): body of an expired invitation.
  ///
  /// In fr, this message translates to:
  /// **'Ce lien n\'est plus valable. Demandez à votre clinique de vous renvoyer une invitation.'**
  String get identityInvitationExpiredBody;

  /// Invitation screen (0): title of an unknown, replaced or incomplete link.
  ///
  /// In fr, this message translates to:
  /// **'Lien d\'invitation invalide'**
  String get identityInvitationInvalidTitle;

  /// Invitation screen (0): body of an unknown, replaced or incomplete link.
  ///
  /// In fr, this message translates to:
  /// **'Ce lien est incomplet ou a été remplacé par un envoi plus récent. Utilisez le dernier lien reçu, ou connectez-vous avec votre numéro.'**
  String get identityInvitationInvalidBody;

  /// Invitation screen (0): title of an invitation already accepted.
  ///
  /// In fr, this message translates to:
  /// **'Invitation déjà utilisée'**
  String get identityInvitationUsedTitle;

  /// Invitation screen (0): body of an invitation already accepted.
  ///
  /// In fr, this message translates to:
  /// **'Cette invitation a déjà été acceptée. Connectez-vous avec votre numéro pour retrouver votre espace.'**
  String get identityInvitationUsedBody;

  /// Invitation screen (0), unusable link, signed out: to the welcome screen.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter avec mon numéro'**
  String get identityInvitationSignIn;

  /// Pending invitations screen: the tag when several clinics invite.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 invitation} other{{count} invitations}}'**
  String identityOnboardingCount(int count);

  /// Pending invitations screen: the line under the title.
  ///
  /// In fr, this message translates to:
  /// **'Votre clinique vous invite à retrouver vos animaux sur Kiveto : rendez-vous, documents et rappels de soins, au même endroit.'**
  String get identityOnboardingBody;

  /// Pending invitations screen, several invitations: accepts the selected one.
  ///
  /// In fr, this message translates to:
  /// **'Accepter cette invitation'**
  String get identityOnboardingAcceptSelected;

  /// Pending invitations screen: after an acceptance, other invitations left.
  ///
  /// In fr, this message translates to:
  /// **'Invitation acceptée : {clinic}.'**
  String identityOnboardingAccepted(String clinic);

  /// Pending invitations screen, signed in: to the home, the invitations left for later.
  ///
  /// In fr, this message translates to:
  /// **'Plus tard'**
  String get identityOnboardingLater;

  /// Pending invitations screen, signed out: the bottom line; the placeholder is a link.
  ///
  /// In fr, this message translates to:
  /// **'Pas maintenant ? {action}'**
  String identityOnboardingNotNow(String action);

  /// Pending invitations screen: every invitation was removed (no longer available).
  ///
  /// In fr, this message translates to:
  /// **'Aucune invitation en attente.'**
  String get identityOnboardingNone;

  /// Welcome screen (7): 422 phone_not_supported.
  ///
  /// In fr, this message translates to:
  /// **'Ce numéro de mobile n\'est pas encore pris en charge par Kiveto.'**
  String get identityErrorPhoneNotSupported;

  /// Welcome screen (7): 422 validation_failed on the number.
  ///
  /// In fr, this message translates to:
  /// **'Vérifiez votre numéro de mobile.'**
  String get identityErrorPhoneInvalid;

  /// Code fields: 422 otp_invalid.
  ///
  /// In fr, this message translates to:
  /// **'Code incorrect. Vérifiez-le, puis réessayez.'**
  String get identityErrorOtpInvalid;

  /// Code fields: 422 otp_expired.
  ///
  /// In fr, this message translates to:
  /// **'Ce code a expiré. Demandez-en un nouveau.'**
  String get identityErrorOtpExpired;

  /// Code fields: 422 otp_attempts_exceeded.
  ///
  /// In fr, this message translates to:
  /// **'Trop d\'essais. Demandez un nouveau code.'**
  String get identityErrorOtpAttemptsExceeded;

  /// 429 otp_rate_limited, with the wait announced by the server (Retry-After), rounded up to the minute.
  ///
  /// In fr, this message translates to:
  /// **'Trop de demandes de code. Réessayez dans {minutes} min.'**
  String identityErrorOtpRateLimited(int minutes);

  /// 429 otp_rate_limited without a wait announced by the server.
  ///
  /// In fr, this message translates to:
  /// **'Trop de demandes de code. Réessayez dans quelques minutes.'**
  String get identityErrorOtpRateLimitedUnknown;

  /// Code screen (8): 404 otp_challenge_not_found on a resend.
  ///
  /// In fr, this message translates to:
  /// **'Cette demande de code n\'est plus valable. Recommencez.'**
  String get identityErrorOtpChallengeNotFound;

  /// 403 account_disabled.
  ///
  /// In fr, this message translates to:
  /// **'Ce compte est désactivé. Contactez votre clinique.'**
  String get identityErrorAccountDisabled;

  /// 401 onboarding_invalid: the onboarding or registration grant expired.
  ///
  /// In fr, this message translates to:
  /// **'Votre vérification a expiré. Reconnectez-vous avec votre numéro.'**
  String get identityErrorOnboardingInvalid;

  /// Registration screen (9): 409 account_exists.
  ///
  /// In fr, this message translates to:
  /// **'Un compte existe déjà pour ce numéro. Connectez-vous avec votre numéro.'**
  String get identityErrorAccountExists;

  /// 422 terms_outdated: the terms were reloaded and the checkbox unchecked.
  ///
  /// In fr, this message translates to:
  /// **'Les conditions d\'utilisation ont changé : relisez-les, puis acceptez-les à nouveau.'**
  String get identityErrorTermsOutdated;

  /// Pending invitations screen: 404 invitation_invalid, the invitation was removed from the list.
  ///
  /// In fr, this message translates to:
  /// **'Cette invitation n\'est plus disponible.'**
  String get identityErrorInvitationInvalid;

  /// Home screen (1): the greeting with the account's first name.
  ///
  /// In fr, this message translates to:
  /// **'Bonjour {firstName}'**
  String homeGreeting(String firstName);

  /// Home screen (1): the greeting of an account without a first name.
  ///
  /// In fr, this message translates to:
  /// **'Bonjour'**
  String get homeGreetingNoName;

  /// Home screen (1): screen reader label of the active clinic's name, which opens the clinic switcher.
  ///
  /// In fr, this message translates to:
  /// **'Changer de clinique, actuellement {name}'**
  String homeClinicSwitcherLabel(String name);

  /// Home screen (1): the overline of the next appointment card (shown in upper case).
  ///
  /// In fr, this message translates to:
  /// **'Prochain rendez-vous'**
  String get homeNextAppointmentTitle;

  /// Home screen (1): the pill of a confirmed next appointment.
  ///
  /// In fr, this message translates to:
  /// **'Confirmé'**
  String get homeAppointmentConfirmed;

  /// Home screen (1): the pill of a next appointment the clinic has not confirmed yet.
  ///
  /// In fr, this message translates to:
  /// **'En attente'**
  String get homeAppointmentPending;

  /// Home screen (1): the pet and the motif of the next appointment (the practitioner follows after " · ").
  ///
  /// In fr, this message translates to:
  /// **'{pet} — {motif}'**
  String homeAppointmentPetMotif(String pet, String motif);

  /// Home screen (1): the button of the next appointment card opening its questionnaire (screen 15).
  ///
  /// In fr, this message translates to:
  /// **'Remplir le questionnaire'**
  String get homeFillQuestionnaire;

  /// Home screen (1): the button of the next appointment card opening the appointments tab.
  ///
  /// In fr, this message translates to:
  /// **'Gérer'**
  String get homeManageAppointments;

  /// Home screen (1): the title of the pets section.
  ///
  /// In fr, this message translates to:
  /// **'Mes animaux'**
  String get homePetsTitle;

  /// Home screen (1): the title of the care due dates section.
  ///
  /// In fr, this message translates to:
  /// **'À prévoir'**
  String get homeCareTitle;

  /// Home screen (1): the caption next to the title of the care due dates section.
  ///
  /// In fr, this message translates to:
  /// **'Échéances de soins'**
  String get homeCareCaption;

  /// Home screen (1): a care due date: the pet, then the care.
  ///
  /// In fr, this message translates to:
  /// **'{pet} — {label}'**
  String homeCareItemTitle(String pet, String label);

  /// Home screen (1): the due date of a care item.
  ///
  /// In fr, this message translates to:
  /// **'Avant le {date}'**
  String homeCareDue(String date);

  /// Home screen (1): the button starting a booking (screen 12).
  ///
  /// In fr, this message translates to:
  /// **'Prendre rendez-vous'**
  String get homeBook;

  /// Home screen (1): the title of the latest documents section.
  ///
  /// In fr, this message translates to:
  /// **'Derniers documents'**
  String get homeDocumentsTitle;

  /// Home screen (1): the link opening the documents tab.
  ///
  /// In fr, this message translates to:
  /// **'Tout voir'**
  String get homeDocumentsSeeAll;

  /// Home screen (1): 404 on the home, the link with the clinic is gone.
  ///
  /// In fr, this message translates to:
  /// **'Clinique indisponible'**
  String get homeClinicGoneTitle;

  /// Home screen (1): body of the 404 on the home.
  ///
  /// In fr, this message translates to:
  /// **'Votre accès à cette clinique n\'est plus actif.'**
  String get homeClinicGoneBody;

  /// Clinic switcher sheet: its title.
  ///
  /// In fr, this message translates to:
  /// **'Changer de clinique'**
  String get clientClinicSwitcherTitle;

  /// Clinic switcher sheet: the pill of the active clinic.
  ///
  /// In fr, this message translates to:
  /// **'Active'**
  String get clientClinicActive;

  /// Pet screen (2): screen reader label of the pet switcher.
  ///
  /// In fr, this message translates to:
  /// **'Animal'**
  String get petSwitcherLabel;

  /// A species: dog.
  ///
  /// In fr, this message translates to:
  /// **'Chien'**
  String get petSpeciesDog;

  /// A species: cat.
  ///
  /// In fr, this message translates to:
  /// **'Chat'**
  String get petSpeciesCat;

  /// A species: "nouveaux animaux de compagnie" (rabbits, birds, reptiles…).
  ///
  /// In fr, this message translates to:
  /// **'NAC'**
  String get petSpeciesNac;

  /// A species: another one.
  ///
  /// In fr, this message translates to:
  /// **'Autre'**
  String get petSpeciesOther;

  /// Pet screen (2): a male, not neutered or not known.
  ///
  /// In fr, this message translates to:
  /// **'Mâle'**
  String get petSexMale;

  /// Pet screen (2): a female, not spayed or not known.
  ///
  /// In fr, this message translates to:
  /// **'Femelle'**
  String get petSexFemale;

  /// Pet screen (2): a neutered male.
  ///
  /// In fr, this message translates to:
  /// **'Mâle castré'**
  String get petSexMaleNeutered;

  /// Pet screen (2): a spayed female.
  ///
  /// In fr, this message translates to:
  /// **'Femelle stérilisée'**
  String get petSexFemaleNeutered;

  /// Pet screen (2): a neutered pet whose sex is not known.
  ///
  /// In fr, this message translates to:
  /// **'Stérilisé'**
  String get petSexUnknownNeutered;

  /// Pet screen (2): the pill of a deceased pet (male or sex not known).
  ///
  /// In fr, this message translates to:
  /// **'Décédé'**
  String get petDeceasedMale;

  /// Pet screen (2): the pill of a deceased female.
  ///
  /// In fr, this message translates to:
  /// **'Décédée'**
  String get petDeceasedFemale;

  /// Pet screen (2): the pill of a missing pet (male or sex not known).
  ///
  /// In fr, this message translates to:
  /// **'Disparu'**
  String get petMissingMale;

  /// Pet screen (2): the pill of a missing female.
  ///
  /// In fr, this message translates to:
  /// **'Disparue'**
  String get petMissingFemale;

  /// A pet's age in full years.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 an} other{{count} ans}}'**
  String petAgeYears(int count);

  /// A pet's age in full months, under one year.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 mois} other{{count} mois}}'**
  String petAgeMonths(int count);

  /// A pet's age, under one month.
  ///
  /// In fr, this message translates to:
  /// **'Moins d\'un mois'**
  String get petAgeUnderOneMonth;

  /// Pet screen (2): the label of the birth date (male or sex not known).
  ///
  /// In fr, this message translates to:
  /// **'Né le'**
  String get petBornMale;

  /// Pet screen (2): the label of the birth date of a female.
  ///
  /// In fr, this message translates to:
  /// **'Née le'**
  String get petBornFemale;

  /// Pet screen (2): the label of the last weight.
  ///
  /// In fr, this message translates to:
  /// **'Poids'**
  String get petWeight;

  /// Pet screen (2): a weight in kilograms, already formatted.
  ///
  /// In fr, this message translates to:
  /// **'{value} kg'**
  String petWeightValue(String value);

  /// Pet screen (2): the label of the masked chip number.
  ///
  /// In fr, this message translates to:
  /// **'Puce'**
  String get petChip;

  /// Pet screen (2): the label of the vet who follows the pet.
  ///
  /// In fr, this message translates to:
  /// **'Suivi par'**
  String get petReferentVet;

  /// Pet screen (2): a value the clinic did not record.
  ///
  /// In fr, this message translates to:
  /// **'—'**
  String get petNone;

  /// Pet screen (2): the button asking the clinic to change the pet's sheet.
  ///
  /// In fr, this message translates to:
  /// **'Signaler une modification'**
  String get petReportChange;

  /// Pet screen (2): the caption under the change request button.
  ///
  /// In fr, this message translates to:
  /// **'Vérifiée par la clinique avant mise à jour de la fiche.'**
  String get petReportChangeCaption;

  /// Pet screen (2): the title of the care items section.
  ///
  /// In fr, this message translates to:
  /// **'Vaccins et préventions'**
  String get petCareTitle;

  /// Pet screen (2): the button opening the vaccination booklet.
  ///
  /// In fr, this message translates to:
  /// **'Carnet PDF'**
  String get petBooklet;

  /// Pet screen (2): the title of the vaccination booklet viewer.
  ///
  /// In fr, this message translates to:
  /// **'Carnet de vaccination · {name}'**
  String petBookletTitle(String name);

  /// Pet screen (2): no care item to follow (a deceased pet, nothing recorded).
  ///
  /// In fr, this message translates to:
  /// **'Aucun soin préventif à suivre.'**
  String get petCareEmpty;

  /// Pets tab (2): the owner has no pet in the active clinic.
  ///
  /// In fr, this message translates to:
  /// **'Aucun animal'**
  String get petEmptyTitle;

  /// Pets tab (2): body of the empty state, with the active clinic's name.
  ///
  /// In fr, this message translates to:
  /// **'Les animaux suivis par {clinic} apparaîtront ici.'**
  String petEmptyBody(String clinic);

  /// Care pill: an appointment covers the care.
  ///
  /// In fr, this message translates to:
  /// **'RDV pris'**
  String get careBooked;

  /// Care pill: the care is overdue.
  ///
  /// In fr, this message translates to:
  /// **'En retard'**
  String get careOverdue;

  /// Care pill: the care is up to date, the due date is far.
  ///
  /// In fr, this message translates to:
  /// **'À jour'**
  String get careUpToDate;

  /// Care pill: due today.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui'**
  String get careToday;

  /// Care pill: due tomorrow.
  ///
  /// In fr, this message translates to:
  /// **'Demain'**
  String get careTomorrow;

  /// Care pill: due in 2 to 13 days ("j" for jours).
  ///
  /// In fr, this message translates to:
  /// **'Dans {count} j'**
  String careInDays(int count);

  /// Care pill: due in 2 weeks or more (full weeks).
  ///
  /// In fr, this message translates to:
  /// **'Dans {count} sem.'**
  String careInWeeks(int count);

  /// Pet screen (2): a care item's last act and next due date.
  ///
  /// In fr, this message translates to:
  /// **'Fait le {done} · prochain avant le {due}'**
  String careDoneAndDue(String done, String due);

  /// Pet screen (2): an overdue care item's due date.
  ///
  /// In fr, this message translates to:
  /// **'À faire depuis le {due}'**
  String careOverdueSince(String due);

  /// Pet screen (2): the next due date of a care item due soon.
  ///
  /// In fr, this message translates to:
  /// **'Prochain avant le {due}'**
  String careDueBefore(String due);

  /// Pet screen (2): an up-to-date care item's validity.
  ///
  /// In fr, this message translates to:
  /// **'Valide jusqu\'au {due}'**
  String careValidUntil(String due);

  /// Pet screen (2): the title of the visit history.
  ///
  /// In fr, this message translates to:
  /// **'Historique'**
  String get timelineTitle;

  /// Pet screen (2): a visit without a document the owner may open.
  ///
  /// In fr, this message translates to:
  /// **'Aucun document partagé'**
  String get timelineNoDocument;

  /// Pet screen (2): no visit shared with the owner yet.
  ///
  /// In fr, this message translates to:
  /// **'Aucune consultation partagée pour le moment.'**
  String get timelineEmpty;

  /// Pet screen (2): the next page of the history failed (a retry button follows).
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger la suite.'**
  String get timelineMoreError;

  /// Documents screen (5): the subtitle under the title, with the active clinic's name.
  ///
  /// In fr, this message translates to:
  /// **'Partagés par {clinic}'**
  String documentsSubtitle(String clinic);

  /// Documents screen (5): screen reader label of the group of filter chips.
  ///
  /// In fr, this message translates to:
  /// **'Filtrer par type'**
  String get documentsFilterGroup;

  /// Documents screen (5): the filter chip showing every document.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get documentsFilterAll;

  /// Documents screen (5): the filter chip of the consultation reports.
  ///
  /// In fr, this message translates to:
  /// **'Comptes-rendus'**
  String get documentsFilterReports;

  /// Documents screen (5): the filter chip of the prescriptions.
  ///
  /// In fr, this message translates to:
  /// **'Ordonnances'**
  String get documentsFilterPrescriptions;

  /// Documents screen (5): the filter chip of the invoices.
  ///
  /// In fr, this message translates to:
  /// **'Factures'**
  String get documentsFilterInvoices;

  /// Documents screen (5): the filter chip of the lab results.
  ///
  /// In fr, this message translates to:
  /// **'Résultats'**
  String get documentsFilterLabResults;

  /// Documents screen (5): the text glyph of a report's tile (compte-rendu), 2 to 4 characters.
  ///
  /// In fr, this message translates to:
  /// **'CR'**
  String get documentsGlyphReport;

  /// Documents screen (5): the text glyph of a prescription's tile, 2 to 4 characters.
  ///
  /// In fr, this message translates to:
  /// **'Rx'**
  String get documentsGlyphPrescription;

  /// Documents screen (5): the text glyph of an invoice's tile, 1 to 4 characters.
  ///
  /// In fr, this message translates to:
  /// **'€'**
  String get documentsGlyphInvoice;

  /// Documents screen (5): the text glyph of a lab result's tile, 2 to 4 characters.
  ///
  /// In fr, this message translates to:
  /// **'Lab'**
  String get documentsGlyphLabResult;

  /// Documents screen (5): the text glyph of a certificate's tile, 2 to 4 characters.
  ///
  /// In fr, this message translates to:
  /// **'Cert'**
  String get documentsGlyphCertificate;

  /// Documents screen (5): a prescription's meta, after the pet names ("Moka · valable jusqu'au 14 janv. 2027").
  ///
  /// In fr, this message translates to:
  /// **'valable jusqu\'au {date}'**
  String documentsValidUntil(String date);

  /// Documents screen (5): an invoice's payment status, paid.
  ///
  /// In fr, this message translates to:
  /// **'Payée'**
  String get documentsPaymentPaid;

  /// Documents screen (5): an invoice's payment status, unpaid.
  ///
  /// In fr, this message translates to:
  /// **'Non payée'**
  String get documentsPaymentUnpaid;

  /// Documents screen (5): an invoice's payment status, partially paid.
  ///
  /// In fr, this message translates to:
  /// **'Partiellement payée'**
  String get documentsPaymentPartiallyPaid;

  /// Documents screen (5): an invoice's payment status, credited: the clinic issued a credit note against it (the invoice itself is not the credit note).
  ///
  /// In fr, this message translates to:
  /// **'Avoir émis'**
  String get documentsPaymentCredited;

  /// Documents screen (5): screen reader label of a document's download button, which opens it in the app, with the document's title.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir {title}'**
  String documentsOpen(String title);

  /// Documents screen (5): screen reader label of the dot of a document not opened yet.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau'**
  String get documentsUnread;

  /// Documents screen (5) and prescription sheet: the button asking the clinic to renew a prescription (opens screen 17).
  ///
  /// In fr, this message translates to:
  /// **'Demander un renouvellement'**
  String get documentsRequestRenewal;

  /// Documents screen (5) and prescription sheet: the pill of a renewal request the clinic has not answered yet.
  ///
  /// In fr, this message translates to:
  /// **'Renouvellement demandé'**
  String get documentsRenewalRequested;

  /// Documents screen (5) and prescription sheet: the pill of a renewal request the clinic handled.
  ///
  /// In fr, this message translates to:
  /// **'Renouvellement traité'**
  String get documentsRenewalDone;

  /// Documents screen (5): the empty state's title, no filter.
  ///
  /// In fr, this message translates to:
  /// **'Aucun document'**
  String get documentsEmptyAllTitle;

  /// Documents screen (5): the empty state's title, reports filter.
  ///
  /// In fr, this message translates to:
  /// **'Aucun compte-rendu'**
  String get documentsEmptyReportsTitle;

  /// Documents screen (5): the empty state's title, prescriptions filter.
  ///
  /// In fr, this message translates to:
  /// **'Aucune ordonnance'**
  String get documentsEmptyPrescriptionsTitle;

  /// Documents screen (5): the empty state's title, invoices filter.
  ///
  /// In fr, this message translates to:
  /// **'Aucune facture'**
  String get documentsEmptyInvoicesTitle;

  /// Documents screen (5): the empty state's title, lab results filter.
  ///
  /// In fr, this message translates to:
  /// **'Aucun résultat d\'analyse'**
  String get documentsEmptyLabResultsTitle;

  /// Documents screen (5): the empty state's body, with the active clinic's name.
  ///
  /// In fr, this message translates to:
  /// **'Les documents partagés par {clinic} apparaîtront ici.'**
  String documentsEmptyBody(String clinic);

  /// Documents screen (5): under the list, the next page could not be loaded (a retry button follows).
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger la suite.'**
  String get documentsMoreError;

  /// Documents screen (5): 404 on the list, the link with the clinic is no longer active.
  ///
  /// In fr, this message translates to:
  /// **'Documents indisponibles'**
  String get documentsLinkGoneTitle;

  /// Documents screen (5): body of the 404 on the list.
  ///
  /// In fr, this message translates to:
  /// **'Votre accès aux documents de cette clinique n\'est plus actif.'**
  String get documentsLinkGoneBody;

  /// Document viewer: 404 on the file.
  ///
  /// In fr, this message translates to:
  /// **'Document indisponible'**
  String get documentsFileGoneTitle;

  /// Document viewer: body of the 404 on the file.
  ///
  /// In fr, this message translates to:
  /// **'Ce document a été retiré ou n\'est pas encore prêt. Réessayez plus tard.'**
  String get documentsFileGoneBody;

  /// Document viewer: the file was downloaded but cannot be shown as a PDF.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d\'afficher ce document.'**
  String get documentsFileRenderError;

  /// Prescription sheet: the title, with the issue date ("Ordonnance du 22 déc. 2025").
  ///
  /// In fr, this message translates to:
  /// **'Ordonnance du {date}'**
  String documentsPrescriptionTitle(String date);

  /// Prescription sheet: a line's quantity and posology, as the clinic wrote them.
  ///
  /// In fr, this message translates to:
  /// **'Qté {quantity} · {posology}'**
  String documentsPrescriptionLine(String quantity, String posology);

  /// Prescription sheet: the button opening the prescription's PDF.
  ///
  /// In fr, this message translates to:
  /// **'Voir l\'ordonnance'**
  String get documentsPrescriptionOpen;

  /// Prescription sheet: 404 on the prescription.
  ///
  /// In fr, this message translates to:
  /// **'Ordonnance indisponible'**
  String get documentsPrescriptionGoneTitle;

  /// Prescription sheet: body of the 404 on the prescription.
  ///
  /// In fr, this message translates to:
  /// **'Cette ordonnance n\'est plus disponible.'**
  String get documentsPrescriptionGoneBody;

  /// The name of a kind of document: a consultation report (a chip of the pet's history).
  ///
  /// In fr, this message translates to:
  /// **'Compte-rendu'**
  String get documentsKindReport;

  /// The name of a kind of document: a prescription.
  ///
  /// In fr, this message translates to:
  /// **'Ordonnance'**
  String get documentsKindPrescription;

  /// The name of a kind of document: an invoice.
  ///
  /// In fr, this message translates to:
  /// **'Facture'**
  String get documentsKindInvoice;

  /// The name of a kind of document: lab results.
  ///
  /// In fr, this message translates to:
  /// **'Résultats'**
  String get documentsKindLabResult;

  /// The name of a kind of document: a certificate.
  ///
  /// In fr, this message translates to:
  /// **'Certificat'**
  String get documentsKindCertificate;

  /// The name of a kind of document this app does not know.
  ///
  /// In fr, this message translates to:
  /// **'Document'**
  String get documentsKindUnknown;

  /// Documents screen (5): the pets of a document, the first ones joined by commas, then the last one ("Moka, Oslo et Pistache").
  ///
  /// In fr, this message translates to:
  /// **'{head} et {last}'**
  String documentsNamesAnd(String head, String last);

  /// Booking wizard (12, 13, 3, 14): the step counter of the header.
  ///
  /// In fr, this message translates to:
  /// **'Étape {step} sur 4'**
  String bookingStepLabel(int step);

  /// Booking wizard: the pet choice (12, accessible name of the group) and its row of the recap (14).
  ///
  /// In fr, this message translates to:
  /// **'Animal'**
  String get bookingPetLabel;

  /// Booking, pet step (12): accessible name of the clinic chip that opens the clinic switcher.
  ///
  /// In fr, this message translates to:
  /// **'Changer de clinique, actuellement {name}'**
  String bookingClinicSwitcherLabel(String name);

  /// Booking, pet step (12): the dashed card that opens the new pet form.
  ///
  /// In fr, this message translates to:
  /// **'Un autre animal'**
  String get bookingNewPet;

  /// Booking, pet step (12): label of the new pet name field.
  ///
  /// In fr, this message translates to:
  /// **'Nom de l\'animal'**
  String get bookingNewPetName;

  /// Booking, pet step (12): accessible name of the species chips of a new pet.
  ///
  /// In fr, this message translates to:
  /// **'Espèce'**
  String get bookingNewPetSpecies;

  /// Booking, pet step (12): the footnote under the pets (the API creates a new pet with the booking).
  ///
  /// In fr, this message translates to:
  /// **'Un nouvel animal est ajouté à votre dossier dès la réservation ; la clinique complète sa fiche lors de la visite.'**
  String get bookingPetFootnote;

  /// Booking, pet step (12): label of the sticky bar (its value is the pet name).
  ///
  /// In fr, this message translates to:
  /// **'Rendez-vous pour'**
  String get bookingPetBarLabel;

  /// Booking, pet step (12): value of the sticky bar while the new pet has no name yet.
  ///
  /// In fr, this message translates to:
  /// **'Nouvel animal'**
  String get bookingNewPetBarValue;

  /// Booking: the motif choice (13, accessible name of the group and label of the sticky bar) and its row of the recap (14).
  ///
  /// In fr, this message translates to:
  /// **'Motif'**
  String get bookingMotifLabel;

  /// Booking, motif step (13): the line under the title.
  ///
  /// In fr, this message translates to:
  /// **'Pour {pet} · {clinic}'**
  String bookingMotifSubtitle(String pet, String clinic);

  /// Booking, motif step (13): the amber pill of a motif the server suggests for the pet.
  ///
  /// In fr, this message translates to:
  /// **'Rappel à faire'**
  String get bookingMotifSuggested;

  /// Booking: the length of a motif (« 30 min »).
  ///
  /// In fr, this message translates to:
  /// **'{minutes} min'**
  String bookingMotifDuration(int minutes);

  /// Booking, motif step (13): value of the sticky bar before a motif is chosen.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez un motif'**
  String get bookingMotifEmpty;

  /// Booking, motif step (13): title of the empty state when the clinic opens no motif online.
  ///
  /// In fr, this message translates to:
  /// **'Aucun motif en ligne'**
  String get bookingMotifsEmptyTitle;

  /// Booking, motif step (13): body of the empty state when the clinic opens no motif online.
  ///
  /// In fr, this message translates to:
  /// **'Cette clinique ne propose pas de rendez-vous en ligne pour le moment.'**
  String get bookingMotifsEmptyBody;

  /// Booking, motif step (13): title of the error when the clinic closed online booking (422 booking_not_open).
  ///
  /// In fr, this message translates to:
  /// **'Réservation en ligne indisponible'**
  String get bookingNotOpenTitle;

  /// Booking, motif step (13): body of the error when the clinic closed online booking (422 booking_not_open).
  ///
  /// In fr, this message translates to:
  /// **'Cette clinique ne prend pas de rendez-vous en ligne pour le moment. Contactez-la directement.'**
  String get bookingNotOpenBody;

  /// Booking, motif step (13): the emergency callout, next to the clinic's call button.
  ///
  /// In fr, this message translates to:
  /// **'Urgence ? Ne réservez pas en ligne, appelez la clinique.'**
  String get bookingEmergency;

  /// Booking, motif step (13): the emergency callout when the clinic gave no phone number.
  ///
  /// In fr, this message translates to:
  /// **'Urgence ? Ne réservez pas en ligne, appelez directement la clinique.'**
  String get bookingEmergencyNoPhone;

  /// Booking, motif step (13): calls the clinic's phone number.
  ///
  /// In fr, this message translates to:
  /// **'Appeler'**
  String get bookingCall;

  /// Booking, motif step (13): snack bar when no app could take the call.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de lancer l\'appel.'**
  String get bookingCallError;

  /// Booking, slot step (3): label of the sticky bar.
  ///
  /// In fr, this message translates to:
  /// **'Votre créneau'**
  String get bookingSlotLabel;

  /// Booking slot step (3) and reschedule: value of the sticky bar before a slot is chosen.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez un créneau'**
  String get bookingSlotEmpty;

  /// A day and a time (« Lun. 9 nov. à 10:00 », « Lundi 9 novembre à 10:00 »).
  ///
  /// In fr, this message translates to:
  /// **'{date} à {time}'**
  String bookingDateAtTime(String date, String time);

  /// Booking: the practitioner chips (3, accessible name of the group), their label without a name, and the row of the recap (14).
  ///
  /// In fr, this message translates to:
  /// **'Vétérinaire'**
  String get bookingVetLabel;

  /// Slot picker (3, reschedule): the previous week button.
  ///
  /// In fr, this message translates to:
  /// **'Semaine précédente'**
  String get bookingPreviousWeek;

  /// Slot picker (3, reschedule): the next week button.
  ///
  /// In fr, this message translates to:
  /// **'Semaine suivante'**
  String get bookingNextWeek;

  /// Slot picker (3, reschedule): the slots before noon.
  ///
  /// In fr, this message translates to:
  /// **'Matin'**
  String get bookingMorning;

  /// Slot picker (3, reschedule): the slots from noon.
  ///
  /// In fr, this message translates to:
  /// **'Après-midi'**
  String get bookingAfternoon;

  /// Slot picker (3, reschedule): an open day without a bookable slot.
  ///
  /// In fr, this message translates to:
  /// **'Aucun créneau disponible ce jour-là.'**
  String get bookingNoSlotDay;

  /// Slot picker (3, reschedule): a week without a bookable slot.
  ///
  /// In fr, this message translates to:
  /// **'Aucun créneau cette semaine.'**
  String get bookingNoSlotWeek;

  /// Slot picker (3, reschedule): the motif has no practitioner bookable online.
  ///
  /// In fr, this message translates to:
  /// **'Aucun vétérinaire ne prend de rendez-vous en ligne pour ce motif.'**
  String get bookingNoPractitioner;

  /// Slot picker (3, reschedule): the footnote under the slots.
  ///
  /// In fr, this message translates to:
  /// **'Seuls les créneaux ouverts à la réservation en ligne par la clinique sont affichés.'**
  String get bookingSlotFootnote;

  /// Slot picker (3, reschedule): warning after another booking took the chosen slot (409 slot_taken).
  ///
  /// In fr, this message translates to:
  /// **'Ce créneau vient d\'être pris. Choisissez-en un autre.'**
  String get bookingSlotTaken;

  /// Slot picker (3, reschedule): accessible name of a slot struck through (taken).
  ///
  /// In fr, this message translates to:
  /// **'{time}, déjà pris'**
  String bookingSlotTakenLabel(String time);

  /// Booking, recap (14): label of the date row.
  ///
  /// In fr, this message translates to:
  /// **'Date'**
  String get bookingRecapDate;

  /// Booking, recap (14): label of the clinic row.
  ///
  /// In fr, this message translates to:
  /// **'Clinique'**
  String get bookingRecapClinic;

  /// Booking, recap (14): goes back to a step to change it.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get bookingEdit;

  /// Booking, recap (14): the line under the name of a new pet.
  ///
  /// In fr, this message translates to:
  /// **'Nouvel animal · {species}'**
  String bookingNewPetSecondary(String species);

  /// Booking, recap (14): a reassurance line.
  ///
  /// In fr, this message translates to:
  /// **'Annulation et report en ligne jusqu\'au délai fixé par la clinique'**
  String get bookingReassuranceCancel;

  /// Booking, recap (14): a reassurance line.
  ///
  /// In fr, this message translates to:
  /// **'Questionnaire de 2 min avant la visite'**
  String get bookingReassuranceQuestionnaire;

  /// Booking, recap (14): books the appointment.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le rendez-vous'**
  String get bookingConfirm;

  /// Booking, success (14): title when the clinic confirmed at once.
  ///
  /// In fr, this message translates to:
  /// **'Rendez-vous confirmé'**
  String get bookingConfirmedTitle;

  /// Booking, success (14): title when the clinic must confirm (pending_clinic_confirmation).
  ///
  /// In fr, this message translates to:
  /// **'Demande envoyée'**
  String get bookingPendingTitle;

  /// Booking, success (14): note of a confirmed booking.
  ///
  /// In fr, this message translates to:
  /// **'Une confirmation vous a été envoyée.'**
  String get bookingSmsSent;

  /// Booking, success (14): note of a booking the clinic must confirm (no SMS promised).
  ///
  /// In fr, this message translates to:
  /// **'La clinique doit confirmer ce rendez-vous. Vous le retrouverez dans vos rendez-vous.'**
  String get bookingPendingNote;

  /// Booking, success (14): opens the questionnaire (15).
  ///
  /// In fr, this message translates to:
  /// **'Remplir le questionnaire maintenant'**
  String get bookingFillQuestionnaire;

  /// Booking, success (14): back to the home.
  ///
  /// In fr, this message translates to:
  /// **'Plus tard'**
  String get bookingLater;

  /// Booking, success (14): back to the home when the questionnaire is already sent.
  ///
  /// In fr, this message translates to:
  /// **'Retour à l\'accueil'**
  String get bookingBackHome;

  /// Booking, recap (14): the pet may not book online (pet_not_bookable).
  ///
  /// In fr, this message translates to:
  /// **'Cet animal ne peut plus prendre rendez-vous en ligne.'**
  String get bookingErrorPetNotBookable;

  /// Booking recap (14) and reschedule: online booking is closed for this motif (booking_not_open).
  ///
  /// In fr, this message translates to:
  /// **'La réservation en ligne n\'est pas ouverte pour ce motif. Contactez la clinique.'**
  String get bookingErrorNotOpen;

  /// Booking, recap (14): a choice of the booking is gone (404 not_found).
  ///
  /// In fr, this message translates to:
  /// **'Ce choix n\'est plus disponible. Recommencez la réservation.'**
  String get bookingErrorNotFound;

  /// Appointments (4): accessible name of the round plus button that opens the booking.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau rendez-vous'**
  String get appointmentsNew;

  /// Appointments (4): the tab of the appointments to come.
  ///
  /// In fr, this message translates to:
  /// **'À venir'**
  String get appointmentsUpcoming;

  /// Appointments (4): the tab of the other appointments.
  ///
  /// In fr, this message translates to:
  /// **'Passés'**
  String get appointmentsPast;

  /// Appointments (4): pill of a confirmed appointment.
  ///
  /// In fr, this message translates to:
  /// **'Confirmé'**
  String get appointmentsStatusConfirmed;

  /// Appointments (4): pill of an appointment the clinic must confirm.
  ///
  /// In fr, this message translates to:
  /// **'En attente'**
  String get appointmentsStatusPending;

  /// Appointments (4): pill of an appointment the owner cancelled.
  ///
  /// In fr, this message translates to:
  /// **'Annulé'**
  String get appointmentsStatusCancelled;

  /// Appointments (4): pill of an appointment the clinic cancelled.
  ///
  /// In fr, this message translates to:
  /// **'Annulé par la clinique'**
  String get appointmentsStatusCancelledByClinic;

  /// Appointments (4): pill of a request the clinic declined.
  ///
  /// In fr, this message translates to:
  /// **'Refusé'**
  String get appointmentsStatusDeclined;

  /// Appointments (4): pill of an appointment that took place.
  ///
  /// In fr, this message translates to:
  /// **'Terminé'**
  String get appointmentsStatusCompleted;

  /// Appointments (4): pill of an appointment the owner missed.
  ///
  /// In fr, this message translates to:
  /// **'Non honoré'**
  String get appointmentsStatusNoShow;

  /// Appointments (4): the first line of a card.
  ///
  /// In fr, this message translates to:
  /// **'{time} · {pet}'**
  String appointmentsTimePet(String time, String pet);

  /// Appointments (4): the third line of an appointment the clinic must confirm.
  ///
  /// In fr, this message translates to:
  /// **'En attente de confirmation par la clinique'**
  String get appointmentsPendingLine;

  /// Appointments (4): title of the questionnaire banner of a card.
  ///
  /// In fr, this message translates to:
  /// **'Questionnaire à compléter'**
  String get appointmentsQuestionnaireTitle;

  /// Appointments (4): line of the questionnaire banner of a card.
  ///
  /// In fr, this message translates to:
  /// **'2 min · motif, symptômes, traitements en cours'**
  String get appointmentsQuestionnaireBody;

  /// Appointments (4): moves an appointment.
  ///
  /// In fr, this message translates to:
  /// **'Reporter'**
  String get appointmentsReschedule;

  /// Appointments (4): opens the cancellation sheet (16).
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get appointmentsCancel;

  /// Appointments (4) and booking success (14): until when the clinic lets the owner cancel online.
  ///
  /// In fr, this message translates to:
  /// **'Annulation en ligne possible jusqu\'au {date} à {time}.'**
  String appointmentsCancellableUntil(String date, String time);

  /// Appointments (4) and cancellation (16): the online cancellation window is over.
  ///
  /// In fr, this message translates to:
  /// **'Le délai d\'annulation en ligne est dépassé : contactez la clinique.'**
  String get appointmentsWindowClosed;

  /// Appointments (4), booking (14), reschedule: shares the .ics of the appointment.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter à mon calendrier'**
  String get appointmentsAddToCalendar;

  /// Snack bar when the .ics could not be read or shared.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d\'ajouter ce rendez-vous à votre calendrier.'**
  String get appointmentsCalendarError;

  /// Appointments (4): empty upcoming tab.
  ///
  /// In fr, this message translates to:
  /// **'Aucun rendez-vous à venir'**
  String get appointmentsEmptyUpcomingTitle;

  /// Appointments (4): the button of the empty upcoming tab.
  ///
  /// In fr, this message translates to:
  /// **'Prendre rendez-vous'**
  String get appointmentsBook;

  /// Appointments (4): empty past tab.
  ///
  /// In fr, this message translates to:
  /// **'Aucun rendez-vous passé'**
  String get appointmentsEmptyPastTitle;

  /// Appointments (4): the list answered 404 (the link with the clinic is gone).
  ///
  /// In fr, this message translates to:
  /// **'Clinique indisponible'**
  String get appointmentsClinicGoneTitle;

  /// Appointments (4): the list answered 404 (the link with the clinic is gone).
  ///
  /// In fr, this message translates to:
  /// **'Votre accès à cette clinique n\'est plus actif.'**
  String get appointmentsClinicGoneBody;

  /// Appointments (4): the next page failed.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger la suite.'**
  String get appointmentsMoreError;

  /// Cancellation (16) and reschedule success: back to the appointments.
  ///
  /// In fr, this message translates to:
  /// **'Retour à mes rendez-vous'**
  String get appointmentsBackToList;

  /// Cancellation sheet (16): title.
  ///
  /// In fr, this message translates to:
  /// **'Annuler ce rendez-vous ?'**
  String get appointmentCancelTitle;

  /// Cancellation sheet (16): the appointment.
  ///
  /// In fr, this message translates to:
  /// **'{date} · {pet} — {motif}'**
  String appointmentCancelSubtitle(String date, String pet, String motif);

  /// Cancellation sheet (16): an appointment without pet.
  ///
  /// In fr, this message translates to:
  /// **'{date} — {motif}'**
  String appointmentCancelSubtitleNoPet(String date, String motif);

  /// Cancellation sheet (16): warning when the motif covers a vaccination of the pet.
  ///
  /// In fr, this message translates to:
  /// **'Le rappel {label} est à faire avant le {date} pour {pet}. Reporter évite un retard de vaccination.'**
  String appointmentCancelCareVaccination(
    String label,
    String pet,
    String date,
  );

  /// Cancellation sheet (16): warning when the motif covers a deworming of the pet.
  ///
  /// In fr, this message translates to:
  /// **'Le traitement {label} est à faire avant le {date} pour {pet}. Reporter évite un retard de vermifugation.'**
  String appointmentCancelCareInternalParasite(
    String label,
    String pet,
    String date,
  );

  /// Cancellation sheet (16): warning when the motif covers a flea and tick treatment of the pet.
  ///
  /// In fr, this message translates to:
  /// **'Le traitement {label} est à faire avant le {date} pour {pet}. Reporter évite un retard de traitement antiparasitaire.'**
  String appointmentCancelCareExternalParasite(
    String label,
    String pet,
    String date,
  );

  /// Cancellation sheet (16): warning when the motif covers another care item of the pet.
  ///
  /// In fr, this message translates to:
  /// **'Le soin {label} est à faire avant le {date} pour {pet}. Reporter évite un retard de soin.'**
  String appointmentCancelCareOther(String label, String pet, String date);

  /// Cancellation sheet (16): legend of the reasons.
  ///
  /// In fr, this message translates to:
  /// **'Raison de l\'annulation'**
  String get appointmentCancelReasonLegend;

  /// Cancellation sheet (16): reason: the owner cannot come.
  ///
  /// In fr, this message translates to:
  /// **'Empêchement'**
  String get appointmentCancelReasonUnavailable;

  /// Cancellation sheet (16): reason: no longer needed.
  ///
  /// In fr, this message translates to:
  /// **'Plus nécessaire'**
  String get appointmentCancelReasonNoLongerNeeded;

  /// Cancellation sheet (16): reason: seen by another vet.
  ///
  /// In fr, this message translates to:
  /// **'Vu ailleurs'**
  String get appointmentCancelReasonSeenElsewhere;

  /// Cancellation sheet (16): reason: another one.
  ///
  /// In fr, this message translates to:
  /// **'Autre'**
  String get appointmentCancelReasonOther;

  /// Cancellation sheet (16): cancels the appointment.
  ///
  /// In fr, this message translates to:
  /// **'Annuler le rendez-vous'**
  String get appointmentCancelConfirm;

  /// Cancellation sheet (16): moves the appointment instead.
  ///
  /// In fr, this message translates to:
  /// **'Reporter plutôt'**
  String get appointmentCancelReschedule;

  /// Cancellation sheet (16): closes the sheet.
  ///
  /// In fr, this message translates to:
  /// **'Garder mon rendez-vous'**
  String get appointmentCancelKeep;

  /// Cancellation sheet (16): title once cancelled.
  ///
  /// In fr, this message translates to:
  /// **'Rendez-vous annulé'**
  String get appointmentCancelDoneTitle;

  /// Cancellation sheet (16): body once cancelled.
  ///
  /// In fr, this message translates to:
  /// **'La clinique a été prévenue.'**
  String get appointmentCancelDoneBody;

  /// Cancellation sheet (16): added to the body when the appointment was confirmed.
  ///
  /// In fr, this message translates to:
  /// **'Une confirmation vous est envoyée.'**
  String get appointmentCancelDoneSms;

  /// Cancellation (16) and reschedule: the server refused the change (appointment_not_modifiable).
  ///
  /// In fr, this message translates to:
  /// **'Ce rendez-vous ne peut plus être modifié.'**
  String get appointmentCancelNotModifiable;

  /// Reschedule: the appointment and its current slot.
  ///
  /// In fr, this message translates to:
  /// **'{pet} · {motif} · actuellement {date}'**
  String rescheduleSubtitle(String pet, String motif, String date);

  /// Reschedule: an appointment without pet and its current slot.
  ///
  /// In fr, this message translates to:
  /// **'{motif} · actuellement {date}'**
  String rescheduleSubtitleNoPet(String motif, String date);

  /// Reschedule: label of the sticky bar.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau créneau'**
  String get rescheduleSlotLabel;

  /// Reschedule: moves the appointment.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get rescheduleConfirm;

  /// Reschedule: success title.
  ///
  /// In fr, this message translates to:
  /// **'Rendez-vous reporté'**
  String get rescheduleDoneTitle;

  /// Reschedule: the appointment may not be moved online (status, booked by the clinic, no motif, window over).
  ///
  /// In fr, this message translates to:
  /// **'Ce rendez-vous ne peut pas être reporté en ligne.'**
  String get rescheduleNotAllowed;

  /// Reschedule: the appointment is gone (404).
  ///
  /// In fr, this message translates to:
  /// **'Rendez-vous introuvable'**
  String get rescheduleNotFoundTitle;

  /// Booking, pet step (12): error of the new pet name field when it is too long.
  ///
  /// In fr, this message translates to:
  /// **'{max} caractères au plus.'**
  String bookingNewPetNameTooLong(int max);

  /// Cancellation (16) and reschedule: the appointment is gone (404).
  ///
  /// In fr, this message translates to:
  /// **'Ce rendez-vous n\'est plus disponible.'**
  String get appointmentGone;

  /// Reschedule success: note when the appointment still waits for the clinic's confirmation.
  ///
  /// In fr, this message translates to:
  /// **'La clinique doit confirmer le nouveau créneau.'**
  String get rescheduleStillPending;

  /// Reschedule: the slot or the practitioner is no longer offered for the appointment (404 on the reschedule).
  ///
  /// In fr, this message translates to:
  /// **'Ce créneau n\'est plus proposé pour ce rendez-vous. Choisissez-en un autre.'**
  String get rescheduleSlotGone;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
