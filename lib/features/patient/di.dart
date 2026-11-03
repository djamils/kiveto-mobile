import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiveto_mobile/core/di/core_providers.dart';
import 'package:kiveto_mobile/features/patient/domain/pet_repository.dart';
import 'package:kiveto_mobile/features/patient/infrastructure/portal_pet_repository.dart';

// The bindings of patient: its contract on the Portal API. Read-only
// screen: the presentation reads the repository directly (no pass-through
// use case).

final petRepositoryProvider = Provider<PetRepository>(
  (ref) => PortalPetRepository(
    ref.watch(portalServerProvider),
    ref.watch(portalFileDownloaderProvider),
    ref.watch(apiFailureMapperProvider),
  ),
);
