import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiveto_mobile/core/di/core_providers.dart';
import 'package:kiveto_mobile/features/scheduling/domain/scheduling_repository.dart';
import 'package:kiveto_mobile/features/scheduling/infrastructure/portal_scheduling_repository.dart';

// The bindings of scheduling: its contract on the Portal API. The
// presentation calls the repository directly (no pass-through use case):
// the booking wizard's notifier holds the intent and its key.

final schedulingRepositoryProvider = Provider<SchedulingRepository>(
  (ref) => PortalSchedulingRepository(
    ref.watch(portalServerProvider),
    ref.watch(apiFailureMapperProvider),
  ),
);
