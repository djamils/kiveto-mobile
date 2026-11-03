import 'package:kiveto_mobile/features/home/domain/home_overview.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';

/// The home of the owner in a clinic; throws an `ApiFailure`
/// (shared/domain).
abstract interface class HomeRepository {
  /// `GET /clinics/{c}/home`.
  Future<HomeOverview> overview(ClinicId clinicId);
}
