import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiveto_mobile/core/di/core_providers.dart';
import 'package:kiveto_mobile/features/client/domain/active_clinic_store.dart';
import 'package:kiveto_mobile/features/client/domain/consent_repository.dart';
import 'package:kiveto_mobile/features/client/domain/data_export_repository.dart';
import 'package:kiveto_mobile/features/client/domain/link_suggestion_repository.dart';
import 'package:kiveto_mobile/features/client/domain/me_repository.dart';
import 'package:kiveto_mobile/features/client/infrastructure/portal_consent_repository.dart';
import 'package:kiveto_mobile/features/client/infrastructure/portal_data_export_repository.dart';
import 'package:kiveto_mobile/features/client/infrastructure/portal_link_suggestion_repository.dart';
import 'package:kiveto_mobile/features/client/infrastructure/portal_me_repository.dart';
import 'package:kiveto_mobile/features/client/infrastructure/preferences_active_clinic_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

// The bindings of client: the account, its consents, its data exports and
// the clinics' records at its phone number on the Portal API, the active
// clinic in the platform preferences. The presentation reads the
// repositories directly (no pass-through use case).

final meRepositoryProvider = Provider<MeRepository>(
  (ref) => PortalMeRepository(
    ref.watch(portalServerProvider),
    ref.watch(apiFailureMapperProvider),
  ),
);

final consentRepositoryProvider = Provider<ConsentRepository>(
  (ref) => PortalConsentRepository(
    ref.watch(portalServerProvider),
    ref.watch(apiFailureMapperProvider),
  ),
);

final dataExportRepositoryProvider = Provider<DataExportRepository>(
  (ref) => PortalDataExportRepository(
    ref.watch(portalServerProvider),
    ref.watch(portalFileDownloaderProvider),
    ref.watch(apiFailureMapperProvider),
  ),
);

final linkSuggestionRepositoryProvider = Provider<LinkSuggestionRepository>(
  (ref) => PortalLinkSuggestionRepository(
    ref.watch(portalServerProvider),
    ref.watch(apiFailureMapperProvider),
  ),
);

final activeClinicStoreProvider = Provider<ActiveClinicStore>(
  (ref) => PreferencesActiveClinicStore(SharedPreferencesAsync.new),
);
