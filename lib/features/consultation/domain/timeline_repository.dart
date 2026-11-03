import 'package:kiveto_mobile/features/consultation/domain/timeline.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';

/// The visit history of a pet; throws an `ApiFailure` (shared/domain).
abstract interface class TimelineRepository {
  /// `GET /clinics/{c}/pets/{id}/timeline`: the first page, or the one of
  /// [cursor]. The pet id is the patient's (a plain string: a domain never
  /// imports another feature).
  Future<TimelinePage> timeline(
    ClinicId clinicId,
    String petId, {
    String? cursor,
  });
}
