import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show FutureProviderFamily;
import 'package:kiveto_mobile/core/di/core_providers.dart';
import 'package:kiveto_mobile/features/client/client.dart';
import 'package:kiveto_mobile/features/patient/di.dart';
import 'package:kiveto_mobile/features/patient/domain/care_item.dart';
import 'package:kiveto_mobile/features/patient/domain/pet.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';

// The state of the pet sheet. Every provider belongs to the account: each
// watches the session and only the id of the active clinic (`selectAsync`
// notifies neither while the clinic reloads nor for the same id). Read
// them through `AsyncData` patterns or `AsyncValueView`, never `.value`.

/// The id of the active clinic, for the account of the session.
Future<ClinicId?> _activeClinicId(Ref ref) {
  ref.watch(sessionStatusProvider);
  return ref.watch(
    activeClinicProvider.selectAsync((clinic) => clinic?.clinicId),
  );
}

/// The pets of the owner in the active clinic, alive first then by name
/// (empty without an active clinic).
final petsProvider = FutureProvider<List<PetSummary>>((ref) async {
  final repository = ref.watch(petRepositoryProvider);
  final clinicId = await _activeClinicId(ref);
  if (clinicId == null) return const [];
  return await repository.pets(clinicId);
});

/// The sheet of a pet of the active clinic (a [NotFoundFailure] without an
/// active clinic: no pet to show).
final FutureProviderFamily<Pet, PetId> petDetailProvider =
    FutureProvider.family<Pet, PetId>((ref, petId) async {
      final repository = ref.watch(petRepositoryProvider);
      final clinicId = await _activeClinicId(ref);
      if (clinicId == null) throw const NotFoundFailure();
      return await repository.pet(clinicId, petId);
    });

/// The preventive care items of a pet of the active clinic, by due date.
final FutureProviderFamily<List<CareItem>, PetId> careItemsProvider =
    FutureProvider.family<List<CareItem>, PetId>((ref, petId) async {
      final repository = ref.watch(petRepositoryProvider);
      final clinicId = await _activeClinicId(ref);
      if (clinicId == null) return const [];
      return await repository.careItems(clinicId, petId);
    });
