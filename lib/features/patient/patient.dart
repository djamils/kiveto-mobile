// The public API of patient: the pet sheet (screen 2; its exits are
// callbacks: the feature never imports app/), the pets of the active clinic
// and the French helpers the home reuses (species, ages, care items and
// their pills, today on the device).

export 'package:kiveto_mobile/features/patient/domain/care_item.dart';
export 'package:kiveto_mobile/features/patient/domain/pet.dart';
export 'package:kiveto_mobile/features/patient/presentation/pet_messages.dart'
    show
        CareStatusPill,
        careDate,
        careStatusPill,
        deviceToday,
        petAgeLabel,
        petCardMeta,
        speciesLabel;
export 'package:kiveto_mobile/features/patient/presentation/pet_page.dart'
    show PetPage;
export 'package:kiveto_mobile/features/patient/presentation/pet_providers.dart'
    show petsProvider;
