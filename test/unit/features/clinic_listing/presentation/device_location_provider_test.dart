// The default deviceLocationProvider on a fake geolocator platform: the
// location service off, the permission asked when not decided yet, refused
// (then or for good), granted (a coarse position, rounded to 3 decimals,
// low accuracy within 15 s), and the platform's failures.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kiveto_mobile/features/clinic_listing/domain/clinic_listing.dart';
import 'package:kiveto_mobile/features/clinic_listing/presentation/clinic_listing_providers.dart';

/// A platform answering what the test sets, recording what was asked.
final class _FakeGeolocator extends GeolocatorPlatform {
  bool serviceEnabled = true;
  LocationPermission checked = LocationPermission.whileInUse;
  LocationPermission requested = LocationPermission.whileInUse;
  Exception? positionError;
  int requests = 0;
  LocationSettings? settings;

  @override
  Future<bool> isLocationServiceEnabled() async => serviceEnabled;

  @override
  Future<LocationPermission> checkPermission() async => checked;

  @override
  Future<LocationPermission> requestPermission() async {
    requests++;
    return requested;
  }

  @override
  Future<Position> getCurrentPosition({
    LocationSettings? locationSettings,
  }) async {
    settings = locationSettings;
    if (positionError case final Exception error) throw error;
    return Position(
      latitude: 48.88449,
      longitude: 2.33651,
      timestamp: DateTime.utc(2026, 11, 4),
      accuracy: 1200,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );
  }
}

void main() {
  late GeolocatorPlatform original;
  late _FakeGeolocator platform;

  setUp(() {
    original = GeolocatorPlatform.instance;
    platform = _FakeGeolocator();
    GeolocatorPlatform.instance = platform;
  });

  tearDown(() => GeolocatorPlatform.instance = original);

  Future<GeoPoint> locate() {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    return container.read(deviceLocationProvider)();
  }

  Matcher failsWith(LocationProblem problem) => throwsA(
    isA<LocationFailure>().having(
      (failure) => failure.problem,
      'problem',
      problem,
    ),
  );

  test('granted: a coarse position, rounded to 3 decimals, low accuracy '
      'within 15 s; nothing asked', () async {
    expect(await locate(), const GeoPoint(48.884, 2.337));
    expect(platform.requests, 0);
    expect(platform.settings?.accuracy, LocationAccuracy.low);
    expect(platform.settings?.timeLimit, const Duration(seconds: 15));
    // Android (the tests' default platform): the platform's location
    // manager, never Google Play services' settings check.
    expect(
      platform.settings,
      isA<AndroidSettings>().having(
        (settings) => settings.forceLocationManager,
        'forceLocationManager',
        isTrue,
      ),
    );
  });

  test('elsewhere: the plain settings', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    expect(await locate(), const GeoPoint(48.884, 2.337));
    expect(platform.settings, isNot(isA<AndroidSettings>()));
    expect(platform.settings?.accuracy, LocationAccuracy.low);
  });

  test('not decided yet: asked, then granted', () async {
    platform.checked = LocationPermission.denied;

    expect(await locate(), const GeoPoint(48.884, 2.337));
    expect(platform.requests, 1);
  });

  test('the location service off: disabled, nothing asked', () async {
    platform.serviceEnabled = false;

    await expectLater(locate(), failsWith(LocationProblem.disabled));
    expect(platform.requests, 0);
  });

  test('refused when asked: denied', () async {
    platform
      ..checked = LocationPermission.denied
      ..requested = LocationPermission.denied;

    await expectLater(locate(), failsWith(LocationProblem.denied));
  });

  test('refused for good, before or after asking: deniedForever', () async {
    platform.checked = LocationPermission.deniedForever;
    await expectLater(locate(), failsWith(LocationProblem.deniedForever));
    expect(platform.requests, 0);

    platform
      ..checked = LocationPermission.denied
      ..requested = LocationPermission.deniedForever;
    await expectLater(locate(), failsWith(LocationProblem.deniedForever));
  });

  test('a permission that cannot be determined: denied', () async {
    platform.checked = LocationPermission.unableToDetermine;

    await expectLater(locate(), failsWith(LocationProblem.denied));
  });

  test("the platform's failures while reading the position", () async {
    for (final (error, problem) in [
      (const LocationServiceDisabledException(), LocationProblem.disabled),
      (const PermissionDeniedException('no'), LocationProblem.denied),
      (TimeoutException('no fix'), LocationProblem.failed),
      (Exception('platform'), LocationProblem.failed),
    ]) {
      platform.positionError = error;
      await expectLater(locate(), failsWith(problem), reason: '$error');
    }
  });

  test('a LocationFailure prints its problem', () {
    expect(
      '${const LocationFailure(LocationProblem.failed)}',
      'LocationFailure(LocationProblem.failed)',
    );
  });
}
