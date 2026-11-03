import 'dart:math';

/// A random RFC 4122 version 4 UUID, lower case
/// (`xxxxxxxx-xxxx-4xxx-[89ab]xxx-xxxxxxxxxxxx`), drawn from [random]
/// (default: [Random.secure]).
String uuidV4([Random? random]) {
  final source = random ?? Random.secure();
  final bytes = List<int>.generate(16, (_) => source.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  final text = bytes
      .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
      .join();
  return '${text.substring(0, 8)}-${text.substring(8, 12)}-'
      '${text.substring(12, 16)}-${text.substring(16, 20)}-'
      '${text.substring(20)}';
}
