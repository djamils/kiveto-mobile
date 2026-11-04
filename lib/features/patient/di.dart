import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiveto_mobile/core/di/core_providers.dart';
import 'package:kiveto_mobile/features/patient/domain/pet_change.dart';
import 'package:kiveto_mobile/features/patient/domain/pet_repository.dart';
import 'package:kiveto_mobile/features/patient/infrastructure/portal_pet_change_repository.dart';
import 'package:kiveto_mobile/features/patient/infrastructure/portal_pet_repository.dart';

// The bindings of patient: its contracts on the Portal API. The
// presentation calls the repositories directly (no pass-through use case):
// the change request sheet holds its form and the key of its intent.

final petRepositoryProvider = Provider<PetRepository>(
  (ref) => PortalPetRepository(
    ref.watch(portalServerProvider),
    ref.watch(portalFileDownloaderProvider),
    ref.watch(apiFailureMapperProvider),
  ),
);

final petChangeRepositoryProvider = Provider<PetChangeRepository>(
  (ref) => PortalPetChangeRepository(
    ref.watch(portalServerProvider),
    ref.watch(apiFailureMapperProvider),
  ),
);
