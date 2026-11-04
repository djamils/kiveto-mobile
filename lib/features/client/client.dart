// The public API of client: the account and its clinics, `meProvider`, the
// active clinic (`activeClinicProvider`, whose notifier's `select` is the
// clinic switcher's API), the switcher sheet itself, the account screen
// (6), and the clinics' records at the account's phone number (the link
// suggestions of screen 10: read, accepted) with the choice of a
// confirmed clinic by its name.

export 'package:kiveto_mobile/features/client/domain/link_suggestion.dart';
export 'package:kiveto_mobile/features/client/domain/me.dart';
export 'package:kiveto_mobile/features/client/presentation/account_page.dart'
    show AccountPage;
export 'package:kiveto_mobile/features/client/presentation/client_providers.dart'
    show ActiveClinicNotifier, activeClinicProvider, meProvider;
export 'package:kiveto_mobile/features/client/presentation/clinic_switcher_sheet.dart'
    show showClinicSwitcherSheet;
export 'package:kiveto_mobile/features/client/presentation/link_suggestion_providers.dart'
    show
        acceptLinkSuggestion,
        linkSuggestionsProvider,
        selectConfirmedClinicNamed;
