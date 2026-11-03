import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiveto_mobile/core/di/core_providers.dart';
import 'package:kiveto_mobile/features/document/domain/document_repository.dart';
import 'package:kiveto_mobile/features/document/domain/pet_name_repository.dart';
import 'package:kiveto_mobile/features/document/infrastructure/portal_document_repository.dart';
import 'package:kiveto_mobile/features/document/infrastructure/portal_pet_name_repository.dart';

// The bindings of document: its contracts on the Portal API. Read-only
// screens: the presentation reads the repositories directly (no
// pass-through use case).

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
