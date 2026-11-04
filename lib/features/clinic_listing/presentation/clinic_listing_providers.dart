import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart'
    show AsyncNotifierProviderFamily, FutureProviderFamily;
import 'package:geolocator/geolocator.dart' as geo;
import 'package:kiveto_mobile/features/clinic_listing/di.dart';
import 'package:kiveto_mobile/features/clinic_listing/domain/clinic_listing.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';
import 'package:kiveto_mobile/shared/domain/listing_id.dart';

// The state of the directory's screens (10, 11). The directory is public:
// nothing here belongs to the account.

/// The clinics of one search, page after page; each search keeps its own
/// list, dropped once no screen shows it.
final AsyncNotifierProviderFamily<
  ClinicSearchNotifier,
  ClinicSearchState,
  ListingQuery
>
clinicSearchProvider = AsyncNotifierProvider.autoDispose
    .family<ClinicSearchNotifier, ClinicSearchState, ListingQuery>(
      ClinicSearchNotifier.new,
    );

/// The pages of a search read so far.
@immutable
final class ClinicSearchState {
  const new({
    this.items = const [],
    this.nextCursor,
    this.loadingMore = false,
    this.moreError,
  });

  final List<ClinicListingSummary> items;

  /// Reads the next page; null after the last one.
  final String? nextCursor;

  /// A next page is on its way.
  final bool loadingMore;

  /// Why the last next page failed (the items read so far stay).
  final Object? moreError;
}

final class ClinicSearchNotifier extends AsyncNotifier<ClinicSearchState> {
  new(this.query);

  final ListingQuery query;

  @override
  Future<ClinicSearchState> build() async {
    final page = await ref.watch(clinicListingRepositoryProvider).search(query);
    return ClinicSearchState(items: page.items, nextCursor: page.nextCursor);
  }

  /// Reads the next page of the same search (nothing on the last page,
  /// while a page loads, or while the list reloads). A failure keeps the
  /// items and sets `moreError`; a `400 cursor_invalid` reloads the search
  /// from its first page.
  Future<void> loadMore() async {
    final current = switch (state) {
      AsyncData(:final value, isLoading: false) => value,
      _ => null,
    };
    final cursor = current?.nextCursor;
    if (current == null || cursor == null || current.loadingMore) return;
    final built = ref;
    state = AsyncData(
      ClinicSearchState(
        items: current.items,
        nextCursor: cursor,
        loadingMore: true,
      ),
    );
    try {
      final page = await ref
          .read(clinicListingRepositoryProvider)
          .search(query, cursor: cursor);
      if (!built.mounted) return;
      if (state case AsyncData(:final value)) {
        state = AsyncData(
          ClinicSearchState(
            items: [...value.items, ...page.items],
            nextCursor: page.nextCursor,
          ),
        );
      }
    } on Object catch (error) {
      if (!built.mounted) return;
      if (error case BusinessFailure(code: 'cursor_invalid')) {
        ref.invalidateSelf();
        return;
      }
      if (state case AsyncData(:final value)) {
        state = AsyncData(
          ClinicSearchState(
            items: value.items,
            nextCursor: cursor,
            moreError: error,
          ),
        );
      }
    }
  }
}

/// The sheet of a clinic of the directory (11).
final FutureProviderFamily<ClinicListingDetail, ListingId>
clinicListingProvider = FutureProvider.autoDispose
    .family<ClinicListingDetail, ListingId>(
      (ref, id) => ref.watch(clinicListingRepositoryProvider).listing(id),
    );

/// Why the device's position could not be read.
enum LocationProblem {
  /// The owner refused the permission.
  denied,

  /// The permission is refused for good: the system no longer asks, only
  /// its settings can grant it.
  deniedForever,

  /// The location service of the phone is off.
  disabled,

  /// No position in time, or another failure of the platform.
  failed,
}

/// The device's position could not be read, for [problem].
final class LocationFailure implements Exception {
  const new(this.problem);

  final LocationProblem problem;

  @override
  String toString() => 'LocationFailure($problem)';
}

/// Reads the device's position once; throws a [LocationFailure].
typedef DeviceLocator = Future<GeoPoint> Function();

/// The device's position, coarse (a seam for the tests: geolocator talks
/// to the platform). Asks the permission when it was not decided yet.
final deviceLocationProvider = Provider<DeviceLocator>((ref) => _locateDevice);

/// A coordinate rounded to 3 decimals (about 100 m, the precision of the
/// distances the cards print): the same search for two taps nearby.
double _coarse(double degrees) => (degrees * 1000).round() / 1000;

/// One coarse position (low accuracy, 15 s at most), rounded.
Future<GeoPoint> _locateDevice() async {
  try {
    if (!await geo.Geolocator.isLocationServiceEnabled()) {
      throw const LocationFailure(LocationProblem.disabled);
    }
    var permission = await geo.Geolocator.checkPermission();
    if (permission == geo.LocationPermission.denied) {
      permission = await geo.Geolocator.requestPermission();
    }
    switch (permission) {
      case geo.LocationPermission.whileInUse || geo.LocationPermission.always:
        break;
      case geo.LocationPermission.deniedForever:
        throw const LocationFailure(LocationProblem.deniedForever);
      case geo.LocationPermission.denied ||
          geo.LocationPermission.unableToDetermine:
        throw const LocationFailure(LocationProblem.denied);
    }
    const accuracy = geo.LocationAccuracy.low;
    const timeLimit = Duration(seconds: 15);
    final position = await geo.Geolocator.getCurrentPosition(
      // Android: the platform's location manager, not Google Play
      // services, whose settings check asks the owner to turn on Google's
      // « Location Accuracy » (a data-collection consent) before any fix,
      // even for a coarse position. iOS keeps the plain settings:
      // geolocator_apple's one-time position reads only the accuracy and
      // never allows background updates, so `AppleSettings` (whose
      // `allowBackgroundLocationUpdates` defaults to true, for streams)
      // would add nothing.
      locationSettings: defaultTargetPlatform == TargetPlatform.android
          ? geo.AndroidSettings(
              accuracy: accuracy,
              timeLimit: timeLimit,
              forceLocationManager: true,
            )
          : const geo.LocationSettings(
              accuracy: accuracy,
              timeLimit: timeLimit,
            ),
    );
    return GeoPoint(_coarse(position.latitude), _coarse(position.longitude));
  } on LocationFailure {
    rethrow;
  } on geo.LocationServiceDisabledException {
    throw const LocationFailure(LocationProblem.disabled);
  } on geo.PermissionDeniedException {
    throw const LocationFailure(LocationProblem.denied);
  } on Object catch (error) {
    debugPrint('Position not read (${error.runtimeType})');
    throw const LocationFailure(LocationProblem.failed);
  }
}
