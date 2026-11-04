import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiveto_mobile/core/di/core_providers.dart';
import 'package:kiveto_mobile/features/document/domain/document_repository.dart';
import 'package:kiveto_mobile/features/document/domain/pet_name_repository.dart';
import 'package:kiveto_mobile/features/document/domain/renewal.dart';
import 'package:kiveto_mobile/features/document/infrastructure/portal_document_repository.dart';
import 'package:kiveto_mobile/features/document/infrastructure/portal_pet_name_repository.dart';
import 'package:kiveto_mobile/features/document/infrastructure/portal_renewal_repository.dart';

// The bindings of document: its contracts on the Portal API. The
// presentation calls the repositories directly (no pass-through use case):
// the renewal page holds its form and the key of its intent.

final documentRepositoryProvider = Provider<DocumentRepository>(
  (ref) => PortalDocumentRepository(
    ref.watch(portalServerProvider),
    ref.watch(portalFileDownloaderProvider),
    ref.watch(apiFailureMapperProvider),
  ),
);

final petNameRepositoryProvider = Provider<PetNameRepository>(
  (ref) => PortalPetNameRepository(
    ref.watch(portalServerProvider),
    ref.watch(apiFailureMapperProvider),
  ),
);

final renewalRepositoryProvider = Provider<RenewalRepository>(
  (ref) => PortalRenewalRepository(
    ref.watch(portalServerProvider),
    ref.watch(apiFailureMapperProvider),
  ),
);
