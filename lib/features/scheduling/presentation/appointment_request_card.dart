import 'package:kiveto_mobile/features/scheduling/domain/appointment_request.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/appointment_card.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/scheduling_messages.dart';
import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/presentation/formatters/kiveto_format.dart';
import 'package:kiveto_mobile/shared/presentation/kit/pills.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_colors.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_layout.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_text.dart';
import 'package:material_ui/material_ui.dart';

/// C-28 without actions, a booking request of the account as a new client
/// (screen 4): the neutral date tile, « 14:00 · {pet} » and its pill
/// (« En attente », or why it was declined), the motif, the clinic, and
/// what the request's status means. A request has no cancellation in the
/// API: no action.
class AppointmentRequestCard extends StatelessWidget {
  const new({required this.request, super.key});

  final AppointmentRequest request;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final request = this.request;
    final (label, tone) = appointmentRequestPill(l10n, request);
    final time = KivetoFormat.time(request.startAt);
    final pet = request.petName;
    final line = appointmentRequestLine(l10n, request);
    return Semantics(
      container: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: KivetoColors.surface,
          border: Border.all(color: KivetoColors.border),
          borderRadius: BorderRadius.circular(KivetoRadius.xl),
        ),
        child: Padding(
          padding: const EdgeInsets.all(KivetoSpace.xl),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppointmentDateTile(date: request.startAt.date, brand: false),
              const SizedBox(width: KivetoSpace.l),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: KivetoSpace.sm,
                        runSpacing: KivetoSpace.xs,
                        children: [
                          Text(
                            pet == null || pet.trim().isEmpty
                                ? time
                                : l10n.appointmentsTimePet(time, pet),
                            style: KivetoText.sectionTitle,
                          ),
                          StatusPill(label, tone: tone),
                        ],
                      ),
                    ),
                    const SizedBox(height: KivetoSpace.xs),
                    Text(
                      request.motifLabel,
                      style: KivetoText.body.copyWith(
                        color: KivetoColors.inkSecondary,
                      ),
                    ),
                    const SizedBox(height: KivetoSpace.xs),
                    Text(request.clinicName, style: KivetoText.bodySmall),
                    if (line != null) ...[
                      const SizedBox(height: KivetoSpace.xs),
                      Text(line, style: KivetoText.caption),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
