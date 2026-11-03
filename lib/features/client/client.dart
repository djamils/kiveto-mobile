// The public API of client: the account and its clinics, `meProvider` and
// the active clinic (`activeClinicProvider`, whose notifier's `select` is
// the clinic switcher's API).

export 'package:kiveto_mobile/features/client/domain/me.dart';
export 'package:kiveto_mobile/features/client/presentation/client_providers.dart'
    show ActiveClinicNotifier, activeClinicProvider, meProvider;
