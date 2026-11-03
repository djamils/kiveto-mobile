import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiveto_mobile/core/di/core_providers.dart';
import 'package:kiveto_mobile/features/consultation/domain/timeline_repository.dart';
import 'package:kiveto_mobile/features/consultation/infrastructure/portal_timeline_repository.dart';

// The bindings of consultation: its contract on the Portal API. Read-only:
// the presentation reads the repository directly (no pass-through use
// case).

final timelineRepositoryProvider = Provider<TimelineRepository>(
  (ref) => PortalTimelineRepository(
    ref.watch(portalServerProvider),
    ref.watch(apiFailureMapperProvider),
  ),
);
