// The public API of client: the account and its clinics, `meProvider`, the
// active clinic (`activeClinicProvider`, whose notifier's `select` is the
// clinic switcher's API), the switcher sheet itself, and the account
// screen (6).

export 'package:kiveto_mobile/features/client/domain/me.dart';
export 'package:kiveto_mobile/features/client/presentation/account_page.dart'
    show AccountPage;
export 'package:kiveto_mobile/features/client/presentation/client_providers.dart'
    show ActiveClinicNotifier, activeClinicProvider, meProvider;
export 'package:kiveto_mobile/features/client/presentation/clinic_switcher_sheet.dart'
    show showClinicSwitcherSheet;
