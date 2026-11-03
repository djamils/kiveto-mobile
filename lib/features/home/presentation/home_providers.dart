import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiveto_mobile/core/di/core_providers.dart';
import 'package:kiveto_mobile/features/client/client.dart';
import 'package:kiveto_mobile/features/home/di.dart';
import 'package:kiveto_mobile/features/home/domain/home_overview.dart';
import 'package:kiveto_mobile/features/scheduling/scheduling.dart'
    show appointmentsRevisionProvider;
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';

/// The home of the active clinic, with the clinic it belongs to (its
/// documents open there).
@immutable
final class ClinicHome {
  const new({this.clinicId, this.overview = const HomeOverview()});

  /// Null: no active clinic, an empty home.
  final ClinicId? clinicId;
  final HomeOverview overview;
}

/// The home of the active clinic (`GET /clinics/{c}/home`); empty without
/// an active clinic. It belongs to the account: it watches the session and
/// only the id of the active clinic (`selectAsync` notifies neither while
/// `/me` reloads nor for the same id). Read it through `AsyncData`
/// patterns or `AsyncValueView`, never `.value`. It reloads after every
/// booking, reschedule or cancellation (the next appointment, the « RDV
/// pris » pills).
final homeOverviewProvider = FutureProvider<ClinicHome>((ref) async {
  ref
    ..watch(sessionStatusProvider)
    ..watch(appointmentsRevisionProvider);
  final repository = ref.watch(homeRepositoryProvider);
  final clinicId = await ref.watch(
    activeClinicProvider.selectAsync((clinic) => clinic?.clinicId),
  );
  if (clinicId == null) return const ClinicHome();
  return ClinicHome(
    clinicId: clinicId,
    overview: await repository.overview(clinicId),
  );
});
