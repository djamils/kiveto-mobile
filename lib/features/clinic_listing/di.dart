import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiveto_mobile/core/di/core_providers.dart';
import 'package:kiveto_mobile/features/clinic_listing/domain/clinic_listing_repository.dart';
import 'package:kiveto_mobile/features/clinic_listing/infrastructure/portal_clinic_listing_repository.dart';

// The bindings of clinic_listing: the directory on the Portal API. The
// presentation reads the repository directly (no pass-through use case).

final clinicListingRepositoryProvider = Provider<ClinicListingRepository>(
  (ref) => PortalClinicListingRepository(
    ref.watch(portalServerProvider),
    ref.watch(apiFailureMapperProvider),
  ),
);
