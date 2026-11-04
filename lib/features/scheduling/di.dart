import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiveto_mobile/core/di/core_providers.dart';
import 'package:kiveto_mobile/features/scheduling/domain/questionnaire_repository.dart';
import 'package:kiveto_mobile/features/scheduling/domain/scheduling_repository.dart';
import 'package:kiveto_mobile/features/scheduling/infrastructure/portal_questionnaire_repository.dart';
import 'package:kiveto_mobile/features/scheduling/infrastructure/portal_scheduling_repository.dart';

// The bindings of scheduling: its contracts on the Portal API. The
// presentation calls the repositories directly (no pass-through use case):
// the booking wizard's notifier holds the intent and its key, the
// questionnaire page its form.

final schedulingRepositoryProvider = Provider<SchedulingRepository>(
  (ref) => PortalSchedulingRepository(
    ref.watch(portalServerProvider),
    ref.watch(apiFailureMapperProvider),
  ),
);

final questionnaireRepositoryProvider = Provider<QuestionnaireRepository>(
  (ref) => PortalQuestionnaireRepository(
    ref.watch(portalServerProvider),
    ref.watch(apiFailureMapperProvider),
  ),
);
