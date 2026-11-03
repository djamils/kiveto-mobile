import 'package:flutter_riverpod/flutter_riverpod.dart';

// The seams of the shell, filled by the slices: app/bootstrap overrides
// each with a provider that watches its feature (ProviderScope overrides).

/// The Documents badge (hidden at 0); slice 2 (document).
final unreadDocumentsCountProvider = Provider<int>((ref) => 0);

/// The initials of the account tab's avatar (null: a plain ink avatar);
/// slice 1 (identity_access) or 5 (client).
final accountInitialsProvider = Provider<String?>((ref) => null);

/// Whether the account has a confirmed clinic (null: not known yet);
/// slice 1 fills it from `GET /me`. False sends the clinic-scoped tabs to
/// `/clinics`.
final hasConfirmedClinicProvider = Provider<bool?>((ref) => null);
