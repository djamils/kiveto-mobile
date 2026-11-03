import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiveto_mobile/core/di/core_providers.dart';
import 'package:kiveto_mobile/features/home/domain/home_repository.dart';
import 'package:kiveto_mobile/features/home/infrastructure/portal_home_repository.dart';

// The bindings of home: its contract on the Portal API. Read-only screen:
// the presentation reads the repository directly (no pass-through use
// case).

final homeRepositoryProvider = Provider<HomeRepository>(
  (ref) => PortalHomeRepository(
    ref.watch(portalServerProvider),
    ref.watch(apiFailureMapperProvider),
  ),
);
