import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_colors.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_layout.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_text.dart';
import 'package:material_ui/material_ui.dart';

/// The end of a list with more pages (the appointments of 4, the clinics
/// of 10): built as it nears the viewport, it reads the next page
/// ([onLoad]); a spinner while it comes, « Impossible de charger la
/// suite. » and a retry when it [failed].
class MoreFooter extends StatefulWidget {
  const new({
    required this.loading,
    required this.failed,
    required this.onLoad,
    super.key,
  });

  final bool loading;
  final bool failed;
  final VoidCallback onLoad;

  @override
  State<MoreFooter> createState() => _MoreFooterState();
}

class _MoreFooterState extends State<MoreFooter> {
  @override
  void initState() {
    super.initState();
    _loadWhenIdle();
  }

  @override
  void didUpdateWidget(MoreFooter oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Also when the list was replaced under a footer kept in place (a
    // reload from the first page after a stale cursor).
    _loadWhenIdle();
  }

  /// Built and neither loading nor failed: read the next page (after the
  /// frame: the list's state changes; the list ignores a second call).
  void _loadWhenIdle() {
    if (widget.loading || widget.failed) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onLoad();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (widget.failed && !widget.loading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: KivetoSpace.sm),
        child: Column(
          children: [
            Text(
              l10n.appointmentsMoreError,
              textAlign: TextAlign.center,
              style: KivetoText.bodySmall,
            ),
            const SizedBox(height: KivetoSpace.sm),
            KivetoButton.outline(
              label: l10n.commonRetry,
              size: KivetoButtonSize.small,
              onPressed: widget.onLoad,
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: KivetoSpace.ml),
      child: Center(
        child: SizedBox.square(
          dimension: 24,
          child: CircularProgressIndicator(
            color: KivetoColors.brand,
            strokeWidth: 2.5,
            semanticsLabel: l10n.commonLoading,
          ),
        ),
      ),
    );
  }
}
