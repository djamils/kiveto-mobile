// The public API of scheduling: the domain, the booking wizard's four
// pages (12, 13, 3, 14), the appointments screen (4, with the cancellation
// sheet 16), the reschedule page (their exits are callbacks: the feature
// never imports app/), and the revision of the appointments the home
// watches to reload after a booking, a reschedule or a cancellation.

export 'package:kiveto_mobile/features/scheduling/domain/appointment.dart';
export 'package:kiveto_mobile/features/scheduling/domain/booking.dart';
export 'package:kiveto_mobile/features/scheduling/domain/booking_draft.dart';
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
export 'package:kiveto_mobile/features/scheduling/presentation/reschedule_page.dart'
    show ReschedulePage;
export 'package:kiveto_mobile/features/scheduling/presentation/scheduling_providers.dart'
    show appointmentsRevisionProvider;
