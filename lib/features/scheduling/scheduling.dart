// The public API of scheduling: the domain, the booking wizard's four
// pages (12, 13, 3, 14), the appointments screen (4, with the cancellation
// sheet 16 and the account's booking requests), the reschedule page, the
// questionnaire (15), the new-client booking of a clinic of the directory
// (the « Motif » block of 11, then its two steps; their exits are
// callbacks: the feature never imports app/), the phone dialer seam (a
// clinic's « Appeler »), and the revision of the appointments the home
// watches to reload after a booking, a reschedule, a cancellation or a
// questionnaire sent.

export 'package:kiveto_mobile/features/scheduling/domain/appointment.dart';
export 'package:kiveto_mobile/features/scheduling/domain/appointment_request.dart';
export 'package:kiveto_mobile/features/scheduling/domain/booking.dart';
export 'package:kiveto_mobile/features/scheduling/domain/booking_draft.dart';
export 'package:kiveto_mobile/features/scheduling/domain/booking_venue.dart';
export 'package:kiveto_mobile/features/scheduling/presentation/appointments_page.dart'
    show AppointmentsPage;
export 'package:kiveto_mobile/features/scheduling/presentation/booking_confirm_page.dart'
    show BookingConfirmPage;
export 'package:kiveto_mobile/features/scheduling/presentation/booking_motif_page.dart'
    show BookingMotifPage;
export 'package:kiveto_mobile/features/scheduling/presentation/booking_pet_page.dart'
    show BookingPetPage;
export 'package:kiveto_mobile/features/scheduling/presentation/booking_slot_page.dart'
    show BookingSlotPage;
export 'package:kiveto_mobile/features/scheduling/presentation/listing_confirm_page.dart'
    show ListingConfirmPage;
export 'package:kiveto_mobile/features/scheduling/presentation/listing_motif_section.dart'
    show ListingMotifSection, callClinic;
export 'package:kiveto_mobile/features/scheduling/presentation/listing_slot_page.dart'
    show ListingSlotPage;
export 'package:kiveto_mobile/features/scheduling/presentation/questionnaire_page.dart'
    show QuestionnairePage;
export 'package:kiveto_mobile/features/scheduling/presentation/reschedule_page.dart'
    show ReschedulePage;
export 'package:kiveto_mobile/features/scheduling/presentation/scheduling_providers.dart'
    show appointmentsRevisionProvider, phoneDialerProvider;
