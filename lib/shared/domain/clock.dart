/// The time source of the domains and applications (rule 8 forbids reading
/// the wall clock there): the app injects `SystemClock` (core/di/), tests a
/// fixed clock.
abstract interface class Clock {
  /// The current instant, in UTC.
  DateTime now();
}
