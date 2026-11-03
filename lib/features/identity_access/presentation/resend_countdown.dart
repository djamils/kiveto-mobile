import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiveto_mobile/core/di/core_providers.dart';
import 'package:material_ui/material_ui.dart';

/// Rebuilds [builder] with the time left until [availableAt] (the
/// `resendAvailableAt` of a code challenge, by `clockProvider`), each
/// second while it is not over; zero once it is.
class ResendCountdown extends ConsumerStatefulWidget {
  const new({required this.availableAt, required this.builder, super.key});

  final DateTime availableAt;
  final Widget Function(BuildContext context, Duration remaining) builder;

  /// `m:ss`, seconds rounded up (`0:24`).
  static String format(Duration remaining) {
    final seconds = (remaining.inMilliseconds / 1000).ceil();
    return '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  ConsumerState<ResendCountdown> createState() => _ResendCountdownState();
}

class _ResendCountdownState extends ConsumerState<ResendCountdown> {
  Timer? _ticker;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void didUpdateWidget(ResendCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.availableAt != widget.availableAt) _start();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Duration _left() {
    final left = widget.availableAt.difference(ref.read(clockProvider).now());
    return left.isNegative ? Duration.zero : left;
  }

  void _start() {
    _ticker?.cancel();
    _remaining = _left();
    if (_remaining == Duration.zero) return;
    _ticker = Timer.periodic(const Duration(seconds: 1), (ticker) {
      final left = _left();
      if (left == Duration.zero) ticker.cancel();
      // Only a visible change rebuilds.
      if (ResendCountdown.format(left) != ResendCountdown.format(_remaining)) {
        setState(() => _remaining = left);
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _remaining);
}
