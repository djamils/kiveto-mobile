import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiveto_mobile/features/client/client.dart';
import 'package:kiveto_mobile/shared/presentation/async/async_views.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_colors.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_layout.dart';
import 'package:material_ui/material_ui.dart';

/// A page of the booking flows on white (mockups 12, 13, 3, 14 and the
/// reschedule): a scrolling body (padding 16 20 16, blocks [gap] apart),
/// and a [bar] kept at the bottom.
class FlowScaffold extends StatelessWidget {
  const new({
    required this.children,
    super.key,
    this.bar,
    this.gap = KivetoSpace.xl3,
  });

  final List<Widget> children;
  final Widget? bar;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final bar = this.bar;
    return Scaffold(
      backgroundColor: KivetoColors.surface,
      body: SafeArea(
        // The bars keep the bottom inset themselves.
        bottom: bar == null,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  KivetoSpace.gutter,
                  KivetoSpace.xl,
                  KivetoSpace.gutter,
                  KivetoSpace.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < children.length; i++) ...[
                      if (i > 0) SizedBox(height: gap),
                      children[i],
                    ],
                  ],
                ),
              ),
            ),
            ?bar,
          ],
        ),
      ),
    );
  }
}

/// Where a step's content waits for the active clinic: a spinner while
/// `/me` loads, its failure with a retry.
class BookingClinicPending extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      switch (ref.watch(activeClinicProvider)) {
        AsyncError(:final error, isLoading: false) => ErrorView(
          error: error,
          onRetry: () => ref.invalidate(meProvider),
        ),
        _ => const SizedBox(height: 160, child: LoadingView()),
      };
}
