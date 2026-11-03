import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiveto_mobile/core/di/core_providers.dart';
import 'package:kiveto_mobile/features/client/domain/active_clinic_store.dart';
import 'package:kiveto_mobile/features/client/domain/me_repository.dart';
import 'package:kiveto_mobile/features/client/infrastructure/portal_me_repository.dart';
import 'package:kiveto_mobile/features/client/infrastructure/preferences_active_clinic_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

// The bindings of client: the account on the Portal API, the active clinic
// in the platform preferences.

final meRepositoryProvider = Provider<MeRepository>(
  (ref) => PortalMeRepository(
    ref.watch(portalServerProvider),
    ref.watch(apiFailureMapperProvider),
  ),
);

final activeClinicStoreProvider = Provider<ActiveClinicStore>(
  (ref) => PreferencesActiveClinicStore(SharedPreferencesAsync.new),
);
