import 'package:kiveto_mobile/shared/domain/clock.dart';

/// The wall clock, in UTC: the only [Clock] that reads the device time.
final class SystemClock implements Clock {
  const new();

  @override
  DateTime now() => DateTime.now().toUtc();
}
