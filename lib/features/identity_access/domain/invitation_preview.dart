import 'package:kiveto_mobile/shared/domain/clinic_id.dart';

/// A clinic invitation read from its link (`POST /invitations/lookup`): who
/// invites, the email the clinic filled in, the masked mobile the code goes
/// to, the pets already there, until when it is valid (UTC).
final class InvitationPreview {
  const new({
    required this.invitationId,
    required this.clinicId,
    required this.clinicName,
    required this.maskedPhone,
    required this.expiresAt,
    this.clinicCity,
    this.email,
    this.petNames = const [],
  });

  final String invitationId;
  final ClinicId clinicId;
  final String clinicName;
  final String? clinicCity;
  final String? email;

  /// As the server masks it (`+33 6 •• •• •• 55`): shown as received.
  final String maskedPhone;
  final List<String> petNames;
  final DateTime expiresAt;

  @override
  String toString() => 'InvitationPreview($invitationId, $clinicName)';
}
