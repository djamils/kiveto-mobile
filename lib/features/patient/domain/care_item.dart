import 'package:kiveto_mobile/shared/domain/care_status.dart';
import 'package:kiveto_mobile/shared/domain/local_date.dart';

/// A preventive care item of a pet (a vaccination, a deworming…): the last
/// act of a protocol and its next due date. Its [status] is the server's.
final class CareItem {
  const new({
    required this.kind,
    required this.label,
    required this.lastDoneOn,
    required this.dueOn,
    required this.status,
  });

  /// The protocol family, as the server names it (`vaccination`,
  /// `internal_parasite`…).
  final String kind;

  /// As the clinic named it (`CHPPiL`, `Vermifugation`).
  final String label;
  final LocalDate lastDoneOn;
  final LocalDate dueOn;
  final CareStatus status;
}
