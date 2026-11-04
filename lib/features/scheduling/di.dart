import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiveto_mobile/core/di/core_providers.dart';
import 'package:kiveto_mobile/features/scheduling/domain/new_client_booking_repository.dart';
import 'package:kiveto_mobile/features/scheduling/domain/questionnaire_repository.dart';
import 'package:kiveto_mobile/features/scheduling/domain/scheduling_repository.dart';
import 'package:kiveto_mobile/features/scheduling/infrastructure/portal_new_client_booking_repository.dart';
import 'package:kiveto_mobile/features/scheduling/infrastructure/portal_questionnaire_repository.dart';
import 'package:kiveto_mobile/features/scheduling/infrastructure/portal_scheduling_repository.dart';

// The bindings of scheduling: its contracts on the Portal API. The
// presentation calls the repositories directly (no pass-through use case):
// the booking wizards' notifiers hold the intent and its key, the
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

/// The booking of a clinic of the directory as a new client, and the
/// account's booking requests.
final newClientBookingRepositoryProvider = Provider<NewClientBookingRepository>(
  (ref) => PortalNewClientBookingRepository(
    ref.watch(portalServerProvider),
    ref.watch(apiFailureMapperProvider),
  ),
);
