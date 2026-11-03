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

  /// Title of the welcome screen (7).
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue'**
  String get screenWelcomeTitle;

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

  /// Title of the pending invitations screen, after a sign-in with pending invitations.
  ///
  /// In fr, this message translates to:
  /// **'Vos invitations'**
  String get screenOnboardingInvitationsTitle;

  /// Title of the invitation activation screen (0), opened from the invitation link.
  ///
  /// In fr, this message translates to:
  /// **'Activez votre espace'**
  String get screenInvitationTitle;

  /// Title of the home screen (1).
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get screenHomeTitle;

  /// Title of the clinic search screen (10).
  ///
  /// In fr, this message translates to:
  /// **'Trouver une clinique'**
  String get screenClinicsTitle;

  /// Title of the pets tab.
  ///
  /// In fr, this message translates to:
  /// **'Mes animaux'**
  String get screenPetsTitle;

  /// Title of the pet sheet (2).
  ///
  /// In fr, this message translates to:
  /// **'Fiche animal'**
  String get screenPetTitle;

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
  /// **'Pour quel animal ?'**
  String get screenBookingPetTitle;

  /// Title of the booking step 2, the reason (13).
  ///
  /// In fr, this message translates to:
  /// **'Quel est le motif ?'**
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

  /// Title of the appointment cancellation screen (16).
  ///
  /// In fr, this message translates to:
  /// **'Annuler le rendez-vous'**
  String get screenCancelAppointmentTitle;

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

  /// The invitation screen received a link with a token (the token is never shown).
  ///
  /// In fr, this message translates to:
  /// **'Lien d\'invitation reçu.'**
  String get invitationLinkReceived;

  /// The invitation screen was opened without a token.
  ///
  /// In fr, this message translates to:
  /// **'Aucun lien d\'invitation.'**
  String get invitationLinkMissing;

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
