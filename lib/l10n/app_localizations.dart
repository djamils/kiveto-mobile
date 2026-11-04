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

  /// Title of the debug-only gallery of the UI kit.
  ///
  /// In fr, this message translates to:
  /// **'Kit d\'interface'**
  String get screenKitGalleryTitle;

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

  /// E-mail change sheet: 422 email_taken, another account verified this address.
  ///
  /// In fr, this message translates to:
  /// **'Cette adresse e-mail est déjà utilisée par un autre compte.'**
  String get identityErrorEmailTaken;

  /// E-mail change sheet: 422 validation_failed on the e-mail, shown on the address field.
  ///
  /// In fr, this message translates to:
  /// **'Vérifiez l\'adresse e-mail saisie.'**
  String get identityErrorEmailInvalid;

  /// E-mail change sheet: its title when the account has no e-mail.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une adresse e-mail'**
  String get identityEmailAddTitle;

  /// E-mail change sheet: its title when the account's e-mail is not verified.
  ///
  /// In fr, this message translates to:
  /// **'Vérifier mon adresse e-mail'**
  String get identityEmailVerifyTitle;

  /// E-mail change sheet: its title when the account's e-mail is verified.
  ///
  /// In fr, this message translates to:
  /// **'Changer d\'adresse e-mail'**
  String get identityEmailChangeTitle;

  /// E-mail change sheet, step 1: label of the address field.
  ///
  /// In fr, this message translates to:
  /// **'Adresse e-mail'**
  String get identityEmailFieldLabel;

  /// E-mail change sheet, step 1: the SMS code confirming the change goes to the account's phone (masked as the server sends it).
  ///
  /// In fr, this message translates to:
  /// **'Pour confirmer, un code va être envoyé au {phone}.'**
  String identityEmailCodeWillBeSent(String phone);

  /// E-mail change and account deletion sheets: asks for the SMS code.
  ///
  /// In fr, this message translates to:
  /// **'Recevoir un code'**
  String get identityAccountRequestCode;

  /// E-mail change and account deletion sheets: the SMS code went to the account's phone (masked as the server sends it).
  ///
  /// In fr, this message translates to:
  /// **'Saisissez le code envoyé au {phone}.'**
  String identityAccountCodeSentTo(String phone);

  /// E-mail change and account deletion sheets: legend of the code boxes.
  ///
  /// In fr, this message translates to:
  /// **'Code de confirmation'**
  String get identityAccountCodeLegend;

  /// E-mail change and account deletion sheets: sends a new SMS code.
  ///
  /// In fr, this message translates to:
  /// **'Renvoyer le code'**
  String get identityAccountResend;

  /// Account deletion and e-mail change sheets, SMS code step: the code expired, had too many attempts or is unknown; asks for a new code by SMS (a new challenge).
  ///
  /// In fr, this message translates to:
  /// **'Recevoir un nouveau code'**
  String get identityAccountNewCode;

  /// E-mail change and account deletion sheets: the disabled resend button during the countdown (m:ss).
  ///
  /// In fr, this message translates to:
  /// **'Renvoyer le code dans {time}'**
  String identityAccountResendIn(String time);

  /// E-mail change sheet, step 3: the code went to the new address.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez le code envoyé à {email}.'**
  String identityEmailCodeSentTo(String email);

  /// E-mail change sheet, step 3: checks the code received at the new address.
  ///
  /// In fr, this message translates to:
  /// **'Vérifier l\'adresse'**
  String get identityEmailVerifySubmit;

  /// E-mail change sheet: back to the address field; from the SMS code step the code already sent is kept (no new SMS), from the e-mail code step a new SMS code is needed.
  ///
  /// In fr, this message translates to:
  /// **'Modifier l\'adresse'**
  String get identityEmailEdit;

  /// E-mail change sheet: title of the success state.
  ///
  /// In fr, this message translates to:
  /// **'Adresse e-mail vérifiée'**
  String get identityEmailDoneTitle;

  /// E-mail change sheet: body of the success state.
  ///
  /// In fr, this message translates to:
  /// **'{email} est vérifiée : vous pourrez y recevoir vos codes de connexion.'**
  String identityEmailDoneBody(String email);

  /// E-mail change sheet: closes the success state.
  ///
  /// In fr, this message translates to:
  /// **'Terminer'**
  String get identityEmailDone;

  /// Account deletion sheet: its title.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer mon compte ?'**
  String get identityDeletionTitle;

  /// Account deletion sheet: first line of the danger callout.
  ///
  /// In fr, this message translates to:
  /// **'Votre compte est désactivé dès la confirmation : vous ne pourrez plus vous connecter.'**
  String get identityDeletionWarningDisabled;

  /// Account deletion sheet: second line of the danger callout.
  ///
  /// In fr, this message translates to:
  /// **'Vos informations de compte et vos exports sont effacés.'**
  String get identityDeletionWarningErased;

  /// Account deletion sheet: third line of the danger callout.
  ///
  /// In fr, this message translates to:
  /// **'Vos cliniques conservent votre dossier, vos factures et vos ordonnances.'**
  String get identityDeletionWarningClinics;

  /// Account deletion sheet, step 1: the SMS code confirming the deletion goes to the account's phone (masked as the server sends it).
  ///
  /// In fr, this message translates to:
  /// **'Un code de confirmation va être envoyé au {phone}.'**
  String identityDeletionCodeWillBeSent(String phone);

  /// Account deletion sheet: closes the sheet, nothing deleted.
  ///
  /// In fr, this message translates to:
  /// **'Garder mon compte'**
  String get identityDeletionKeep;

  /// Account deletion sheet, step 2: sends the deletion (enabled once the 6 digits are typed).
  ///
  /// In fr, this message translates to:
  /// **'Supprimer mon compte'**
  String get identityDeletionConfirm;

  /// After the account deletion: the SnackBar shown on the welcome screen.
  ///
  /// In fr, this message translates to:
  /// **'Votre demande de suppression est enregistrée : votre compte est désactivé.'**
  String get identityDeletionDone;

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

  /// Clinic switcher sheet and account screen (6): the pill of the active clinic.
  ///
  /// In fr, this message translates to:
  /// **'Active'**
  String get clientClinicActive;

  /// Account screen (6), profile card: the account has no postal address.
  ///
  /// In fr, this message translates to:
  /// **'Aucune adresse renseignée'**
  String get accountProfileNoAddress;

  /// Account screen (6), profile card: opens the profile form.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get accountProfileEdit;

  /// Account screen (6), profile card: the e-mail row when the account has none.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une adresse e-mail'**
  String get accountEmailAdd;

  /// Account screen (6), profile card: the e-mail row when the e-mail is not verified.
  ///
  /// In fr, this message translates to:
  /// **'Vérifier mon adresse e-mail'**
  String get accountEmailVerify;

  /// Account screen (6), profile card: the e-mail row when the e-mail is verified.
  ///
  /// In fr, this message translates to:
  /// **'Changer d\'adresse e-mail'**
  String get accountEmailChange;

  /// Account screen (6), profile card: the pill of an e-mail not verified yet.
  ///
  /// In fr, this message translates to:
  /// **'À vérifier'**
  String get accountEmailUnverified;

  /// Account screen (6): title of the clinics section.
  ///
  /// In fr, this message translates to:
  /// **'Mes cliniques'**
  String get accountClinicsTitle;

  /// Account screen (6): link of the clinics section to the clinic search.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une clinique'**
  String get accountClinicsAdd;

  /// Account screen (6): the account has no clinic.
  ///
  /// In fr, this message translates to:
  /// **'Aucune clinique rattachée pour l\'instant.'**
  String get accountClinicsEmpty;

  /// Account screen (6), a clinic row: when the link was made (day and short month), the last part of the meta line.
  ///
  /// In fr, this message translates to:
  /// **'rattachée le {date}'**
  String accountClinicLinkedOn(String date);

  /// Account screen (6), a clinic row: meta line of a link the clinic has not confirmed yet.
  ///
  /// In fr, this message translates to:
  /// **'En attente de confirmation par la clinique'**
  String get accountClinicPendingMeta;

  /// Account screen (6), a clinic row: the pill of a link the clinic has not confirmed yet.
  ///
  /// In fr, this message translates to:
  /// **'En attente'**
  String get accountClinicPending;

  /// Account screen (6): title of the consents section.
  ///
  /// In fr, this message translates to:
  /// **'Consentements'**
  String get accountConsentsTitle;

  /// Account screen (6): the consents are those of the active clinic.
  ///
  /// In fr, this message translates to:
  /// **'Pour {clinic}. Modifiable à tout moment.'**
  String accountConsentsDescription(String clinic);

  /// Account screen (6), a consent: appended to its description when it is granted.
  ///
  /// In fr, this message translates to:
  /// **'Accordé le {date}.'**
  String accountConsentGrantedOn(String date);

  /// Account screen (6): the consent of kind appointment_reminders.
  ///
  /// In fr, this message translates to:
  /// **'Confirmations et rappels de RDV'**
  String get accountConsentAppointmentRemindersTitle;

  /// Account screen (6): description of the consent of kind appointment_reminders.
  ///
  /// In fr, this message translates to:
  /// **'Confirmations, rappels et changements de vos rendez-vous.'**
  String get accountConsentAppointmentRemindersBody;

  /// Account screen (6): the consent of kind vaccination_reminders.
  ///
  /// In fr, this message translates to:
  /// **'Rappels de soins'**
  String get accountConsentVaccinationRemindersTitle;

  /// Account screen (6): description of the consent of kind vaccination_reminders.
  ///
  /// In fr, this message translates to:
  /// **'Vaccins, antiparasitaires, contrôles.'**
  String get accountConsentVaccinationRemindersBody;

  /// Account screen (6): the consent of kind marketing.
  ///
  /// In fr, this message translates to:
  /// **'Actualités de la clinique'**
  String get accountConsentMarketingTitle;

  /// Account screen (6): description of the consent of kind marketing.
  ///
  /// In fr, this message translates to:
  /// **'Conseils saisonniers, horaires, nouveautés.'**
  String get accountConsentMarketingBody;

  /// Account screen (6): the consent of kind clinical_documents.
  ///
  /// In fr, this message translates to:
  /// **'Documents médicaux'**
  String get accountConsentClinicalDocumentsTitle;

  /// Account screen (6): description of the consent of kind clinical_documents (sent anyway: the consent picks the channels).
  ///
  /// In fr, this message translates to:
  /// **'Avis de nouveaux comptes rendus, ordonnances et résultats. Toujours envoyés : choisissez au moins un canal.'**
  String get accountConsentClinicalDocumentsBody;

  /// Account screen (6): the consent of kind billing.
  ///
  /// In fr, this message translates to:
  /// **'Factures'**
  String get accountConsentBillingTitle;

  /// Account screen (6): description of the consent of kind billing (sent anyway: the consent picks the channels).
  ///
  /// In fr, this message translates to:
  /// **'Avis de factures et de paiements. Toujours envoyés : choisissez au moins un canal.'**
  String get accountConsentBillingBody;

  /// Account screen (6) and consent history: the SMS channel.
  ///
  /// In fr, this message translates to:
  /// **'SMS'**
  String get accountConsentChannelSms;

  /// Account screen (6) and consent history: the e-mail channel.
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get accountConsentChannelEmail;

  /// Account screen (6): opens the consent history of the active clinic.
  ///
  /// In fr, this message translates to:
  /// **'Historique de mes consentements'**
  String get accountConsentsHistoryLink;

  /// Account screen (6): 404 on the consents of the active clinic.
  ///
  /// In fr, this message translates to:
  /// **'Consentements indisponibles'**
  String get accountConsentsUnavailableTitle;

  /// Account screen (6): body of the 404 on the consents.
  ///
  /// In fr, this message translates to:
  /// **'Les consentements de cette clinique ne sont pas disponibles pour l\'instant.'**
  String get accountConsentsUnavailableBody;

  /// Account screen (6): SnackBar when the server refused to withdraw the last channel of a consent sent anyway (422).
  ///
  /// In fr, this message translates to:
  /// **'Ces messages sont envoyés dans tous les cas : gardez au moins un canal.'**
  String get accountConsentKeepOneChannel;

  /// Account screen (6): SnackBar of a 409 conflict on a consent change (the consents were reloaded).
  ///
  /// In fr, this message translates to:
  /// **'Vos consentements ont changé entre-temps : vérifiez-les, puis réessayez.'**
  String get accountConsentConflict;

  /// Consent history sheet: its title (its subtitle is the clinic's name).
  ///
  /// In fr, this message translates to:
  /// **'Historique de mes consentements'**
  String get accountHistoryTitle;

  /// Consent history sheet: a change, its consent and channel.
  ///
  /// In fr, this message translates to:
  /// **'{kind} · {channel}'**
  String accountHistoryRow(String kind, String channel);

  /// Consent history sheet: a channel granted, when and by whom.
  ///
  /// In fr, this message translates to:
  /// **'Accordé le {date} · {author}'**
  String accountHistoryGranted(String date, String author);

  /// Consent history sheet: a channel withdrawn, when and by whom.
  ///
  /// In fr, this message translates to:
  /// **'Retiré le {date} · {author}'**
  String accountHistoryWithdrawn(String date, String author);

  /// Consent history sheet: a channel granted at an approximate date (the consents taken over when the clinic joined).
  ///
  /// In fr, this message translates to:
  /// **'Accordé au plus tard le {date} · {author}'**
  String accountHistoryGrantedApproximate(String date, String author);

  /// Consent history sheet: a channel withdrawn at an approximate date.
  ///
  /// In fr, this message translates to:
  /// **'Retiré au plus tard le {date} · {author}'**
  String accountHistoryWithdrawnApproximate(String date, String author);

  /// Consent history sheet: a change whose action (neither granted nor withdrawn) this app does not know, when and by whom.
  ///
  /// In fr, this message translates to:
  /// **'{date} · {author}'**
  String accountHistoryChanged(String date, String author);

  /// Consent history sheet: no change recorded.
  ///
  /// In fr, this message translates to:
  /// **'Aucun changement enregistré.'**
  String get accountHistoryEmpty;

  /// Consent history sheet: reads the next page.
  ///
  /// In fr, this message translates to:
  /// **'Afficher plus'**
  String get accountHistoryMore;

  /// Account screen (6): title of the data section.
  ///
  /// In fr, this message translates to:
  /// **'Mes données'**
  String get accountDataTitle;

  /// Account screen (6): opens the data export sheet.
  ///
  /// In fr, this message translates to:
  /// **'Exporter mes données'**
  String get accountDataExport;

  /// Account screen (6): opens the account deletion sheet.
  ///
  /// In fr, this message translates to:
  /// **'Demander la suppression de mon compte'**
  String get accountDataDelete;

  /// Account screen (6): caption under the data section.
  ///
  /// In fr, this message translates to:
  /// **'Les factures restent conservées par la clinique selon ses obligations légales.'**
  String get accountDataInvoicesNote;

  /// Profile sheet: its title.
  ///
  /// In fr, this message translates to:
  /// **'Modifier mon profil'**
  String get accountProfileSheetTitle;

  /// Profile sheet: label of the first name field.
  ///
  /// In fr, this message translates to:
  /// **'Prénom'**
  String get accountProfileFirstName;

  /// Profile sheet: label of the last name field.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get accountProfileLastName;

  /// Profile sheet: label of the street field.
  ///
  /// In fr, this message translates to:
  /// **'Adresse'**
  String get accountProfileStreet;

  /// Profile sheet: label of the postal code field.
  ///
  /// In fr, this message translates to:
  /// **'Code postal'**
  String get accountProfilePostalCode;

  /// Profile sheet: label of the city field.
  ///
  /// In fr, this message translates to:
  /// **'Ville'**
  String get accountProfileCity;

  /// Profile sheet: footnote under the fields.
  ///
  /// In fr, this message translates to:
  /// **'Ces informations ne modifient que votre profil Kiveto, pas les dossiers de vos cliniques. L\'adresse peut être modifiée, pas supprimée.'**
  String get accountProfileFootnote;

  /// Profile sheet: sends the changes.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get accountProfileSave;

  /// Account screen (6): SnackBar once the profile is saved.
  ///
  /// In fr, this message translates to:
  /// **'Profil enregistré.'**
  String get accountProfileSaved;

  /// Profile sheet: the server refused the first name (422).
  ///
  /// In fr, this message translates to:
  /// **'Saisissez votre prénom (60 caractères au plus).'**
  String get accountProfileFirstNameError;

  /// Profile sheet: the server refused the last name (422).
  ///
  /// In fr, this message translates to:
  /// **'Saisissez votre nom (60 caractères au plus).'**
  String get accountProfileLastNameError;

  /// Profile sheet: the server refused the street (422).
  ///
  /// In fr, this message translates to:
  /// **'Saisissez la rue (255 caractères au plus).'**
  String get accountProfileStreetError;

  /// Profile sheet: the server refused the city (422).
  ///
  /// In fr, this message translates to:
  /// **'Saisissez la ville (255 caractères au plus).'**
  String get accountProfileCityError;

  /// Profile sheet: the server refused the postal code (422).
  ///
  /// In fr, this message translates to:
  /// **'Le code postal comporte 20 caractères au plus.'**
  String get accountProfilePostalCodeError;

  /// Data export sheet: its title.
  ///
  /// In fr, this message translates to:
  /// **'Exporter mes données'**
  String get accountExportTitle;

  /// Data export sheet: what an export holds.
  ///
  /// In fr, this message translates to:
  /// **'Un fichier ZIP avec votre compte, vos cliniques, vos rendez-vous et la liste de vos documents, disponible 48 h.'**
  String get accountExportSubtitle;

  /// Data export sheet: an export, by the day it was asked for.
  ///
  /// In fr, this message translates to:
  /// **'Export du {date}'**
  String accountExportRow(String date);

  /// Data export sheet: the pill of an export being built.
  ///
  /// In fr, this message translates to:
  /// **'En préparation'**
  String get accountExportPending;

  /// Data export sheet: the pill of an export ready to download.
  ///
  /// In fr, this message translates to:
  /// **'Prêt'**
  String get accountExportReady;

  /// Data export sheet: the pill of an export whose build failed.
  ///
  /// In fr, this message translates to:
  /// **'Échec'**
  String get accountExportFailed;

  /// Data export sheet: the pill of an export no longer available.
  ///
  /// In fr, this message translates to:
  /// **'Expiré'**
  String get accountExportExpired;

  /// Data export sheet: until when a ready export can be downloaded.
  ///
  /// In fr, this message translates to:
  /// **'Disponible jusqu\'au {date} à {time}'**
  String accountExportAvailableUntil(String date, String time);

  /// Data export sheet: downloads a ready export and hands it to the share sheet.
  ///
  /// In fr, this message translates to:
  /// **'Télécharger'**
  String get accountExportDownload;

  /// Data export sheet: asks for a new export.
  ///
  /// In fr, this message translates to:
  /// **'Demander un export'**
  String get accountExportRequest;

  /// Data export sheet: the new export is being built.
  ///
  /// In fr, this message translates to:
  /// **'Export demandé : il sera prêt dans quelques minutes.'**
  String get accountExportRequested;

  /// Data export sheet: 429 export_rate_limited.
  ///
  /// In fr, this message translates to:
  /// **'Vous avez déjà demandé un export ces dernières 24 heures.'**
  String get accountExportRateLimited;

  /// Data export sheet: no export yet.
  ///
  /// In fr, this message translates to:
  /// **'Aucun export pour l\'instant.'**
  String get accountExportEmpty;

  /// Data export sheet: reloads the list while an export is being built.
  ///
  /// In fr, this message translates to:
  /// **'Actualiser'**
  String get accountExportRefresh;

  /// Data export sheet: the download failed.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de télécharger cet export.'**
  String get accountExportDownloadFailed;

  /// Data export sheet: the export is gone (404 on its file); the list is reloaded.
  ///
  /// In fr, this message translates to:
  /// **'Cet export n\'est plus disponible.'**
  String get accountExportGone;

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

  /// Questionnaire (15): the appointment under the title.
  ///
  /// In fr, this message translates to:
  /// **'{pet} · {motif} · {slot}'**
  String questionnaireSubtitle(String pet, String motif, String slot);

  /// Questionnaire (15): an appointment without pet under the title.
  ///
  /// In fr, this message translates to:
  /// **'{motif} · {slot}'**
  String questionnaireSubtitleNoPet(String motif, String slot);

  /// Questionnaire (15): the line under the appointment, before the answers are sent.
  ///
  /// In fr, this message translates to:
  /// **'2 minutes. Vos réponses sont transmises à l\'équipe soignante.'**
  String get questionnaireIntro;

  /// Questionnaire (15): the line under the appointment once the answers were sent and may still change (date with no-break spaces).
  ///
  /// In fr, this message translates to:
  /// **'Réponses envoyées le {date} à {time}. Vous pouvez les modifier jusqu\'au rendez-vous.'**
  String questionnaireSentOn(String date, String time);

  /// Questionnaire (15): legend of the symptoms.
  ///
  /// In fr, this message translates to:
  /// **'Depuis la dernière visite, avez-vous remarqué :'**
  String get questionnaireSymptomsLegend;

  /// Questionnaire (15): legend of the ongoing treatment.
  ///
  /// In fr, this message translates to:
  /// **'Un traitement en cours pour {pet} ?'**
  String questionnaireTreatmentLegend(String pet);

  /// Questionnaire (15): legend of the ongoing treatment, appointment without pet.
  ///
  /// In fr, this message translates to:
  /// **'Un traitement en cours ?'**
  String get questionnaireTreatmentLegendNoPet;

  /// Questionnaire (15): legend of the temperament.
  ///
  /// In fr, this message translates to:
  /// **'Comment se passent les visites pour {pet} ?'**
  String questionnaireTemperamentLegend(String pet);

  /// Questionnaire (15): legend of the temperament, appointment without pet.
  ///
  /// In fr, this message translates to:
  /// **'Comment se passent les visites ?'**
  String get questionnaireTemperamentLegendNoPet;

  /// Questionnaire (15): symptom chip, none (goes with no other).
  ///
  /// In fr, this message translates to:
  /// **'Rien de particulier'**
  String get questionnaireSymptomNone;

  /// Questionnaire (15): symptom chip.
  ///
  /// In fr, this message translates to:
  /// **'Toux'**
  String get questionnaireSymptomCough;

  /// Questionnaire (15): symptom chip.
  ///
  /// In fr, this message translates to:
  /// **'Vomissements'**
  String get questionnaireSymptomVomiting;

  /// Questionnaire (15): symptom chip.
  ///
  /// In fr, this message translates to:
  /// **'Diarrhée'**
  String get questionnaireSymptomDiarrhea;

  /// Questionnaire (15): symptom chip.
  ///
  /// In fr, this message translates to:
  /// **'Baisse d’appétit'**
  String get questionnaireSymptomAppetiteLoss;

  /// Questionnaire (15): symptom chip.
  ///
  /// In fr, this message translates to:
  /// **'Démangeaisons'**
  String get questionnaireSymptomItching;

  /// Questionnaire (15): symptom chip.
  ///
  /// In fr, this message translates to:
  /// **'Boiterie'**
  String get questionnaireSymptomLameness;

  /// Questionnaire (15): no ongoing treatment.
  ///
  /// In fr, this message translates to:
  /// **'Non'**
  String get questionnaireTreatmentNo;

  /// Questionnaire (15): an ongoing treatment.
  ///
  /// In fr, this message translates to:
  /// **'Oui'**
  String get questionnaireTreatmentYes;

  /// Questionnaire (15): label of the treatment field.
  ///
  /// In fr, this message translates to:
  /// **'Lequel ?'**
  String get questionnaireTreatmentDetails;

  /// Questionnaire (15): placeholder of the treatment field.
  ///
  /// In fr, this message translates to:
  /// **'Nom du médicament, dose'**
  String get questionnaireTreatmentDetailsHint;

  /// Questionnaire (15): temperament chip.
  ///
  /// In fr, this message translates to:
  /// **'Calme'**
  String get questionnaireTemperamentCalm;

  /// Questionnaire (15): temperament chip.
  ///
  /// In fr, this message translates to:
  /// **'Stressé(e)'**
  String get questionnaireTemperamentStressed;

  /// Questionnaire (15): temperament chip.
  ///
  /// In fr, this message translates to:
  /// **'Peut mordre ou griffer'**
  String get questionnaireTemperamentMayBite;

  /// Questionnaire (15): label of the optional notes.
  ///
  /// In fr, this message translates to:
  /// **'Autre chose à signaler'**
  String get questionnaireNotes;

  /// Questionnaire (15): sends the answers.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer à la clinique'**
  String get questionnaireSend;

  /// Questionnaire (15): message once the answers were saved.
  ///
  /// In fr, this message translates to:
  /// **'Questionnaire envoyé à la clinique.'**
  String get questionnaireSent;

  /// Questionnaire (15): title of the callout of a questionnaire that may no longer change.
  ///
  /// In fr, this message translates to:
  /// **'Questionnaire clos'**
  String get questionnaireLockedTitle;

  /// Questionnaire (15): body of the callout of a questionnaire that may no longer change (the appointment or its consultation started, or it was closed before a reschedule).
  ///
  /// In fr, this message translates to:
  /// **'Ce questionnaire ne peut plus être modifié.'**
  String get questionnaireLockedBody;

  /// Questionnaire (15): a closed questionnaire without answers.
  ///
  /// In fr, this message translates to:
  /// **'Le questionnaire n\'a pas été rempli.'**
  String get questionnaireLockedEmpty;

  /// Questionnaire (15): when the answers of a closed questionnaire were sent (date with no-break spaces).
  ///
  /// In fr, this message translates to:
  /// **'Réponses envoyées le {date} à {time}.'**
  String questionnaireLockedSentOn(String date, String time);

  /// Questionnaire (15): the appointment is gone (404).
  ///
  /// In fr, this message translates to:
  /// **'Rendez-vous introuvable'**
  String get questionnaireNotFoundTitle;

  /// Questionnaire (15): the appointment is gone (404).
  ///
  /// In fr, this message translates to:
  /// **'Ce rendez-vous a été annulé ou n\'existe plus.'**
  String get questionnaireNotFoundBody;

  /// Renewal (17): the prescription under the title.
  ///
  /// In fr, this message translates to:
  /// **'Ordonnance du {date} · {vet} · {pet}'**
  String renewalSubtitle(String date, String vet, String pet);

  /// Renewal (17): title of the lines of the prescription.
  ///
  /// In fr, this message translates to:
  /// **'Traitements à renouveler'**
  String get renewalLinesLegend;

  /// Renewal (17): the request covers every line.
  ///
  /// In fr, this message translates to:
  /// **'La demande porte sur toute l\'ordonnance.'**
  String get renewalLinesCaption;

  /// Renewal (17): legend of the pet condition.
  ///
  /// In fr, this message translates to:
  /// **'Comment va {pet} avec ce traitement ?'**
  String renewalConditionLegend(String pet);

  /// Renewal (17): pet condition chip.
  ///
  /// In fr, this message translates to:
  /// **'Ça va mieux'**
  String get renewalConditionImproved;

  /// Renewal (17): pet condition chip.
  ///
  /// In fr, this message translates to:
  /// **'Pas d’amélioration'**
  String get renewalConditionNoImprovement;

  /// Renewal (17): pet condition chip.
  ///
  /// In fr, this message translates to:
  /// **'Effets indésirables'**
  String get renewalConditionAdverseEffects;

  /// Renewal (17): warning when the treatment does not help or has adverse effects.
  ///
  /// In fr, this message translates to:
  /// **'Le vétérinaire vous proposera sans doute une consultation avant de renouveler.'**
  String get renewalConditionWarning;

  /// Renewal (17): label of the optional note.
  ///
  /// In fr, this message translates to:
  /// **'Précision pour le vétérinaire'**
  String get renewalNote;

  /// Renewal (17): footnote.
  ///
  /// In fr, this message translates to:
  /// **'Retrait à la clinique. Le vétérinaire décide si un renouvellement sans consultation est possible.'**
  String get renewalFootnote;

  /// Renewal (17): sends the request.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer la demande'**
  String get renewalSend;

  /// Renewal (17): success title.
  ///
  /// In fr, this message translates to:
  /// **'Demande envoyée'**
  String get renewalDoneTitle;

  /// Renewal (17): success paragraph.
  ///
  /// In fr, this message translates to:
  /// **'La clinique vous préviendra quand l\'ordonnance sera prête, ou si une consultation est nécessaire.'**
  String get renewalDoneBody;

  /// Renewal (17): back to the documents (5).
  ///
  /// In fr, this message translates to:
  /// **'Retour aux documents'**
  String get renewalDoneBack;

  /// Renewal (17): the server refuses the renewal (422 prescription_not_renewable).
  ///
  /// In fr, this message translates to:
  /// **'Cette ordonnance ne peut pas être renouvelée en ligne : contactez la clinique.'**
  String get renewalNotRenewable;

  /// Renewal (17) and change request: too many requests (429).
  ///
  /// In fr, this message translates to:
  /// **'Vous avez envoyé beaucoup de demandes. Réessayez plus tard ou contactez la clinique.'**
  String get requestRateLimited;

  /// Change request sheet: subtitle.
  ///
  /// In fr, this message translates to:
  /// **'Pour {pet}. La clinique vérifie chaque modification avant de mettre à jour la fiche.'**
  String petChangeSubtitle(String pet);

  /// Change request sheet: legend of the field chips.
  ///
  /// In fr, this message translates to:
  /// **'Que faut-il modifier ?'**
  String get petChangeFieldLegend;

  /// Change request: the name field (chip, pending row).
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get petChangeFieldName;

  /// Change request: the weight field (chip, pending row).
  ///
  /// In fr, this message translates to:
  /// **'Poids'**
  String get petChangeFieldWeight;

  /// Change request: the sterilization field (chip, legend, pending row).
  ///
  /// In fr, this message translates to:
  /// **'Stérilisation'**
  String get petChangeFieldSterilization;

  /// Change request: the chip number field (chip, pending row).
  ///
  /// In fr, this message translates to:
  /// **'Puce'**
  String get petChangeFieldChipNumber;

  /// Change request: another change (chip, pending row).
  ///
  /// In fr, this message translates to:
  /// **'Autre'**
  String get petChangeFieldOther;

  /// Change request sheet: label of the name field.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau nom'**
  String get petChangeNewName;

  /// Change request sheet: label of the weight field.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau poids (kg)'**
  String get petChangeNewWeight;

  /// Change request sheet: placeholder of the weight field.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : 12,4'**
  String get petChangeNewWeightHint;

  /// Change request sheet: label of the weighing date.
  ///
  /// In fr, this message translates to:
  /// **'Pesé le'**
  String get petChangeMeasuredOn;

  /// Change request sheet: the weighing date until one is picked.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui'**
  String get petChangeMeasuredToday;

  /// Change request sheet: sterilization chip, male.
  ///
  /// In fr, this message translates to:
  /// **'Castré'**
  String get petChangeNeuteredMale;

  /// Change request sheet: sterilization chip, male.
  ///
  /// In fr, this message translates to:
  /// **'Non castré'**
  String get petChangeIntactMale;

  /// Change request sheet: sterilization chip, female.
  ///
  /// In fr, this message translates to:
  /// **'Stérilisée'**
  String get petChangeNeuteredFemale;

  /// Change request sheet: sterilization chip, female.
  ///
  /// In fr, this message translates to:
  /// **'Non stérilisée'**
  String get petChangeIntactFemale;

  /// Change request sheet: sterilization chip, sex not recorded.
  ///
  /// In fr, this message translates to:
  /// **'Stérilisé(e)'**
  String get petChangeNeuteredUnknown;

  /// Change request sheet: sterilization chip, sex not recorded.
  ///
  /// In fr, this message translates to:
  /// **'Non stérilisé(e)'**
  String get petChangeIntactUnknown;

  /// Change request sheet: label of the chip number field.
  ///
  /// In fr, this message translates to:
  /// **'Numéro de puce'**
  String get petChangeChipNumber;

  /// Change request sheet: help of the chip number field.
  ///
  /// In fr, this message translates to:
  /// **'Les 15 chiffres inscrits sur la carte d\'identification.'**
  String get petChangeChipNumberHelp;

  /// Change request sheet: label of the field of another change.
  ///
  /// In fr, this message translates to:
  /// **'Ce qui a changé'**
  String get petChangeOtherValue;

  /// Change request sheet: placeholder of the field of another change.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : nouvelle allergie'**
  String get petChangeOtherValueHint;

  /// Change request sheet: label of the optional note.
  ///
  /// In fr, this message translates to:
  /// **'Précision pour la clinique'**
  String get petChangeNote;

  /// Change request sheet: label of the note of another change.
  ///
  /// In fr, this message translates to:
  /// **'Précisions pour la clinique'**
  String get petChangeNoteOther;

  /// Change request sheet: help of the note of another change.
  ///
  /// In fr, this message translates to:
  /// **'Expliquez la modification à la clinique.'**
  String get petChangeNoteOtherHelp;

  /// Change request sheet: sends the request.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer la demande'**
  String get petChangeSend;

  /// Change request sheet: success title.
  ///
  /// In fr, this message translates to:
  /// **'Demande envoyée'**
  String get petChangeDoneTitle;

  /// Change request sheet: success paragraph.
  ///
  /// In fr, this message translates to:
  /// **'La clinique vérifiera la modification avant de mettre à jour la fiche.'**
  String get petChangeDoneBody;

  /// Change request sheet: closes the sheet after the success.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get petChangeDoneClose;

  /// Change request sheet: the server refuses a change for this pet (422 pet_not_eligible: deceased, missing).
  ///
  /// In fr, this message translates to:
  /// **'Cet animal ne peut plus faire l\'objet d\'une demande de modification : contactez la clinique.'**
  String get petChangeNotEligible;

  /// Change request sheet: the pet is gone (404).
  ///
  /// In fr, this message translates to:
  /// **'Cet animal n\'est plus suivi par cette clinique.'**
  String get petChangeNotFound;

  /// Pet screen (2): title of the change requests waiting for the clinic.
  ///
  /// In fr, this message translates to:
  /// **'Demandes en cours'**
  String get petChangePendingTitle;

  /// Pet screen (2): a pending change request, its field and value.
  ///
  /// In fr, this message translates to:
  /// **'{field} : {value}'**
  String petChangePendingRow(String field, String value);

  /// Pet screen (2): when a pending change request was sent (date with no-break spaces).
  ///
  /// In fr, this message translates to:
  /// **'Envoyée le {date}'**
  String petChangePendingSentOn(String date);

  /// Pet screen (2): pill of a pending change request.
  ///
  /// In fr, this message translates to:
  /// **'En attente'**
  String get petChangePendingStatus;

  /// Pet screen (2): the pending change requests could not be read.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d\'afficher vos demandes en cours.'**
  String get petChangePendingError;

  /// Change request: a proposed weight as the owner typed it.
  ///
  /// In fr, this message translates to:
  /// **'{value} kg'**
  String petChangeWeightValue(String value);

  /// Clinic search (10): the subtitle under the greeting.
  ///
  /// In fr, this message translates to:
  /// **'Trouvez votre clinique pour prendre rendez-vous.'**
  String get clinicSearchSubtitle;

  /// Clinic search (10): accessible name of the search field (visually hidden).
  ///
  /// In fr, this message translates to:
  /// **'Rechercher une clinique'**
  String get clinicSearchFieldLabel;

  /// Clinic search (10): hint of the search field.
  ///
  /// In fr, this message translates to:
  /// **'Nom ou ville'**
  String get clinicSearchFieldHint;

  /// Clinic search (10): the chip that searches around the device position.
  ///
  /// In fr, this message translates to:
  /// **'Autour de moi'**
  String get clinicSearchNearMe;

  /// Clinic search (10): the near-me chip, disabled while the position is read.
  ///
  /// In fr, this message translates to:
  /// **'Localisation…'**
  String get clinicSearchLocating;

  /// Clinic search (10): how many clinics are listed (by name).
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucune clinique} =1{1 clinique} other{{count} cliniques}}'**
  String clinicSearchCount(int count);

  /// Clinic search (10): how many clinics are listed around the position.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucune clinique à proximité} =1{1 clinique à proximité} other{{count} cliniques à proximité}}'**
  String clinicSearchNearCount(int count);

  /// Clinic search (10): the clinics listed so far (by name) while a next page exists.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{Plus d\'une clinique} other{Plus de {count} cliniques}}'**
  String clinicSearchMoreCount(int count);

  /// Clinic search (10): the clinics listed so far around the position while a next page exists.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{Plus d\'une clinique à proximité} other{Plus de {count} cliniques à proximité}}'**
  String clinicSearchMoreNearCount(int count);

  /// Clinic search (10): pill of a clinic that takes new clients online.
  ///
  /// In fr, this message translates to:
  /// **'RDV en ligne'**
  String get clinicSearchOnline;

  /// Clinic search (10): pill of a clinic only listed (not on Kiveto).
  ///
  /// In fr, this message translates to:
  /// **'Pas encore sur Kiveto'**
  String get clinicSearchUnlisted;

  /// Clinic search (10): the next slot open to a new client (no-break space before the colon).
  ///
  /// In fr, this message translates to:
  /// **'Prochain créneau : {slot}'**
  String clinicSearchNextSlot(String slot);

  /// Clinic search (10): no clinic matches the search.
  ///
  /// In fr, this message translates to:
  /// **'Aucune clinique trouvée'**
  String get clinicSearchEmptyTitle;

  /// Clinic search (10): body of the empty search.
  ///
  /// In fr, this message translates to:
  /// **'Essayez un autre nom ou une autre ville.'**
  String get clinicSearchEmptyBody;

  /// Clinic search (10): body of an empty search around the position (no-break spaces inside the quotes).
  ///
  /// In fr, this message translates to:
  /// **'Aucune clinique de l\'annuaire autour de vous. Touchez « Autour de moi » pour chercher par nom.'**
  String get clinicSearchEmptyNearBody;

  /// Clinic search (10): SnackBar when the location permission is refused.
  ///
  /// In fr, this message translates to:
  /// **'Autorisez l\'accès à votre position pour voir les cliniques autour de vous.'**
  String get clinicSearchLocationDenied;

  /// Clinic search (10): SnackBar when the location permission is refused for good (the system no longer asks; no-break space before the colon).
  ///
  /// In fr, this message translates to:
  /// **'L\'accès à votre position est refusé pour Kiveto : autorisez-le dans les réglages du téléphone.'**
  String get clinicSearchLocationDeniedForever;

  /// Clinic search (10): SnackBar when the location service is off.
  ///
  /// In fr, this message translates to:
  /// **'Activez la localisation de votre téléphone pour voir les cliniques autour de vous.'**
  String get clinicSearchLocationDisabled;

  /// Clinic search (10): SnackBar when no position could be read in time.
  ///
  /// In fr, this message translates to:
  /// **'Votre position n\'a pas pu être déterminée. Réessayez.'**
  String get clinicSearchLocationFailed;

  /// Clinic search (10): title of a clinic record found at the account phone number (no article before the clinic name).
  ///
  /// In fr, this message translates to:
  /// **'{clinic} a un dossier à votre numéro'**
  String linkSuggestionTitle(String clinic);

  /// Clinic search (10): body of a record found at the account phone number.
  ///
  /// In fr, this message translates to:
  /// **'Rattachez-le pour retrouver vos animaux et votre historique.'**
  String get linkSuggestionBody;

  /// Clinic search (10): asks to be linked to the record found.
  ///
  /// In fr, this message translates to:
  /// **'Rattacher ce dossier'**
  String get linkSuggestionAccept;

  /// Clinic search (10): SnackBar when the record is no longer offered (404).
  ///
  /// In fr, this message translates to:
  /// **'Ce dossier n\'est plus proposé.'**
  String get linkSuggestionGone;

  /// Clinic search (10): the records at the account phone number could not be read.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de vérifier les dossiers à votre numéro.'**
  String get linkSuggestionsError;

  /// Clinic search (10): title of a link the clinic has yet to confirm (no-break space before the colon).
  ///
  /// In fr, this message translates to:
  /// **'Rattachement demandé : {clinic}'**
  String linkPendingTitle(String clinic);

  /// Clinic search (10): body of a link the clinic has yet to confirm.
  ///
  /// In fr, this message translates to:
  /// **'La clinique doit confirmer le rattachement. Vos animaux et votre historique apparaîtront dès sa confirmation.'**
  String get linkPendingBody;

  /// Clinic sheet (11): open now (device clock), until when.
  ///
  /// In fr, this message translates to:
  /// **'Ouvert · ferme à {time}'**
  String clinicListingOpenUntil(String time);

  /// Clinic sheet (11): closed now, opening later today.
  ///
  /// In fr, this message translates to:
  /// **'Fermé · ouvre à {time}'**
  String clinicListingOpensLater(String time);

  /// Clinic sheet (11): closed until tomorrow.
  ///
  /// In fr, this message translates to:
  /// **'Fermé · ouvre demain à {time}'**
  String clinicListingOpensTomorrow(String time);

  /// Clinic sheet (11): closed until another day of the week (lower case).
  ///
  /// In fr, this message translates to:
  /// **'Fermé · ouvre {day} à {time}'**
  String clinicListingOpensOn(String day, String time);

  /// Clinic sheet (11): title of the known / new client choice.
  ///
  /// In fr, this message translates to:
  /// **'Vous êtes'**
  String get clinicListingWho;

  /// Clinic sheet (11): who card of a known client.
  ///
  /// In fr, this message translates to:
  /// **'Déjà client'**
  String get clinicListingKnownClient;

  /// Clinic sheet (11): second line of the known client card.
  ///
  /// In fr, this message translates to:
  /// **'de cette clinique'**
  String get clinicListingKnownClientSub;

  /// Clinic sheet (11): who card of a new client.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau client'**
  String get clinicListingNewClient;

  /// Clinic sheet (11): second line of the new client card.
  ///
  /// In fr, this message translates to:
  /// **'première visite'**
  String get clinicListingNewClientSub;

  /// Clinic sheet (11): hint of the new client choice.
  ///
  /// In fr, this message translates to:
  /// **'Vous décrirez votre animal à l\'étape suivante. La clinique confirme les rendez-vous des nouveaux clients.'**
  String get clinicListingNewHint;

  /// Clinic sheet (11): hint of the known client choice (no-break spaces inside the quotes, before the colon and the question mark).
  ///
  /// In fr, this message translates to:
  /// **'Si la clinique a votre numéro de mobile, votre dossier vous est proposé dans « Trouver une clinique » : rattachez-le. Déjà rattaché ? Prenez rendez-vous depuis votre espace.'**
  String get clinicListingKnownHint;

  /// Clinic sheet (11): known client, back to the clinic search (its record suggestions).
  ///
  /// In fr, this message translates to:
  /// **'Retrouver mon dossier'**
  String get clinicListingFindRecord;

  /// Clinic sheet (11): title of the opening hours.
  ///
  /// In fr, this message translates to:
  /// **'Horaires'**
  String get clinicListingHours;

  /// Clinic sheet (11): a closed day of the opening hours.
  ///
  /// In fr, this message translates to:
  /// **'Fermé'**
  String get clinicListingClosed;

  /// Clinic sheet (11): the clinic is not in the directory (404).
  ///
  /// In fr, this message translates to:
  /// **'Clinique introuvable'**
  String get clinicListingGoneTitle;

  /// Clinic sheet (11): body of the clinic not found.
  ///
  /// In fr, this message translates to:
  /// **'Cette clinique n\'est plus dans l\'annuaire.'**
  String get clinicListingGoneBody;

  /// Clinic sheet (11): emergency hint under the motifs (no-break space before the question mark; the phone kept on one line).
  ///
  /// In fr, this message translates to:
  /// **'Urgence ? Appelez directement la clinique au {phone}.'**
  String listingMotifUrgency(String phone);

  /// Clinic sheet (11): the clinic takes no online request of new clients.
  ///
  /// In fr, this message translates to:
  /// **'Cette clinique ne propose pas encore la prise de rendez-vous en ligne aux nouveaux clients.'**
  String get listingMotifNotOpen;

  /// Clinic sheet (11): the clinic takes no new client.
  ///
  /// In fr, this message translates to:
  /// **'Cette clinique n\'accepte pas de nouveaux clients pour le moment.'**
  String get listingMotifNoNewClients;

  /// Clinic sheet (11): calls the clinic.
  ///
  /// In fr, this message translates to:
  /// **'Appeler la clinique'**
  String get listingMotifCall;

  /// Clinic sheet (11): no motif open online to new clients.
  ///
  /// In fr, this message translates to:
  /// **'Aucun motif n\'est ouvert en ligne aux nouveaux clients.'**
  String get listingMotifEmpty;

  /// New-client booking: the step counter of the header.
  ///
  /// In fr, this message translates to:
  /// **'Étape {step} sur 2'**
  String listingBookingStepLabel(int step);

  /// New-client booking, step 2: title.
  ///
  /// In fr, this message translates to:
  /// **'Votre animal'**
  String get listingBookingPetTitle;

  /// New-client booking, step 1: reached without a motif chosen.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez d\'abord un motif.'**
  String get listingBookingNoMotif;

  /// New-client booking, step 2: reached without a slot chosen (the slot taken meanwhile).
  ///
  /// In fr, this message translates to:
  /// **'Choisissez d\'abord un créneau.'**
  String get listingBookingNoSlot;

  /// New-client booking, step 1: label of the bottom bar.
  ///
  /// In fr, this message translates to:
  /// **'Créneau'**
  String get listingBookingSlotLabel;

  /// New-client booking, step 1: bottom bar value before a slot is chosen.
  ///
  /// In fr, this message translates to:
  /// **'À choisir'**
  String get listingBookingSlotEmpty;

  /// New-client booking, step 2: footnote.
  ///
  /// In fr, this message translates to:
  /// **'La clinique confirme les rendez-vous des nouveaux clients. Vous suivez votre demande dans Rendez-vous.'**
  String get listingBookingFootnote;

  /// New-client booking: success message (the date with no-break spaces).
  ///
  /// In fr, this message translates to:
  /// **'La clinique doit confirmer votre rendez-vous du {date} à {time}.'**
  String listingBookingSentMessage(String date, String time);

  /// New-client booking: success note.
  ///
  /// In fr, this message translates to:
  /// **'Vous suivez votre demande dans Rendez-vous. Si la clinique ne peut pas la confirmer, vous en êtes informé.'**
  String get listingBookingSentNote;

  /// New-client booking: opens the Rendez-vous tab (success, request limit).
  ///
  /// In fr, this message translates to:
  /// **'Voir mes rendez-vous'**
  String get listingBookingSeeAppointments;

  /// New-client booking: back to the clinic search after the success.
  ///
  /// In fr, this message translates to:
  /// **'Retour à l\'annuaire'**
  String get listingBookingBackToDirectory;

  /// New-client booking: refused, the account is already a client of the clinic (422 already_linked).
  ///
  /// In fr, this message translates to:
  /// **'Vous êtes déjà client de cette clinique : prenez rendez-vous depuis votre espace.'**
  String get listingBookingAlreadyLinked;

  /// New-client booking: refused, too many pending requests (422 booking_request_limit).
  ///
  /// In fr, this message translates to:
  /// **'Vous avez déjà des demandes de rendez-vous en attente : attendez la réponse des cliniques.'**
  String get listingBookingLimit;

  /// New-client booking: refused, online requests closed (422 booking_not_open).
  ///
  /// In fr, this message translates to:
  /// **'Cette clinique ne prend plus de demandes en ligne de nouveaux clients.'**
  String get listingBookingNotOpen;

  /// New-client booking: refused, the clinic or the choice is gone (404).
  ///
  /// In fr, this message translates to:
  /// **'Cette clinique ou ce créneau n\'est plus disponible.'**
  String get listingBookingNotFound;

  /// New-client booking: refused, too many requests (429).
  ///
  /// In fr, this message translates to:
  /// **'Trop de demandes en peu de temps : réessayez plus tard.'**
  String get listingBookingRateLimited;

  /// Appointments (4): title of the new-client booking requests.
  ///
  /// In fr, this message translates to:
  /// **'Demandes de rendez-vous'**
  String get appointmentRequestsTitle;

  /// Appointments (4): pill of a request the clinic refused.
  ///
  /// In fr, this message translates to:
  /// **'Refusée'**
  String get appointmentRequestDeclined;

  /// Appointments (4): pill of a request left without an answer.
  ///
  /// In fr, this message translates to:
  /// **'Expirée'**
  String get appointmentRequestExpired;

  /// Appointments (4): pill of a cancelled request.
  ///
  /// In fr, this message translates to:
  /// **'Annulée'**
  String get appointmentRequestCancelled;

  /// Appointments (4): pill of a request the clinic confirmed (its appointment is in that clinic's list).
  ///
  /// In fr, this message translates to:
  /// **'Confirmée'**
  String get appointmentRequestConfirmed;

  /// Appointments (4): status line of a pending request.
  ///
  /// In fr, this message translates to:
  /// **'La clinique doit confirmer votre demande.'**
  String get appointmentRequestPendingLine;

  /// Appointments (4): status line of a refused request.
  ///
  /// In fr, this message translates to:
  /// **'La clinique n\'a pas pu confirmer ce rendez-vous.'**
  String get appointmentRequestDeclinedLine;

  /// Appointments (4): status line of an expired request.
  ///
  /// In fr, this message translates to:
  /// **'Sans réponse de la clinique à temps, la demande a expiré.'**
  String get appointmentRequestExpiredLine;

  /// Appointments (4): status line of a cancelled request.
  ///
  /// In fr, this message translates to:
  /// **'La demande a été annulée.'**
  String get appointmentRequestCancelledLine;

  /// Appointments (4): status line of a confirmed request of a clinic that is not the active one.
  ///
  /// In fr, this message translates to:
  /// **'Le rendez-vous apparaît dans les rendez-vous de cette clinique.'**
  String get appointmentRequestConfirmedLine;

  /// Appointments (4): the booking requests could not be read.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger vos demandes de rendez-vous.'**
  String get appointmentRequestsError;

  /// The tabs of an account without a confirmed clinic (2, 4, 5): empty state title.
  ///
  /// In fr, this message translates to:
  /// **'Aucune clinique rattachée'**
  String get noClinicTitle;

  /// Appointments (4) without a confirmed clinic: empty state body.
  ///
  /// In fr, this message translates to:
  /// **'Trouvez une clinique pour prendre un premier rendez-vous.'**
  String get noClinicAppointmentsBody;

  /// Pets tab without a confirmed clinic: empty state body.
  ///
  /// In fr, this message translates to:
  /// **'Vos animaux apparaîtront ici dès qu\'une clinique vous aura rattaché.'**
  String get noClinicPetsBody;

  /// Documents tab without a confirmed clinic: empty state body.
  ///
  /// In fr, this message translates to:
  /// **'Les documents partagés par votre clinique apparaîtront ici.'**
  String get noClinicDocumentsBody;
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
