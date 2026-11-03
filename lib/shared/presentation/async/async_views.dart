import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';
import 'package:kiveto_mobile/shared/presentation/icons/kiveto_icon.dart';
import 'package:kiveto_mobile/shared/presentation/icons/lucide_glyph.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_colors.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_layout.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_text.dart';
import 'package:material_ui/material_ui.dart';

/// The three states of an [AsyncValue]: [loading] (default: a
/// [LoadingView]; also while retrying after an error), an [ErrorView] with
/// [onRetry], or [data].
class AsyncValueView<T> extends StatelessWidget {
  const new({
    required this.value,
    required this.data,
    super.key,
    this.onRetry,
    this.loading,
  });

  final AsyncValue<T> value;
  final Widget Function(T value) data;
  final VoidCallback? onRetry;
  final Widget? loading;

  @override
  Widget build(BuildContext context) => switch (value) {
    // A retry in progress after an error: loading, not the error again
    // (its retry button would resend).
    AsyncValue(isLoading: true, hasError: true) =>
      loading ?? const LoadingView(),
    AsyncData(:final value) => data(value),
    AsyncError(:final error) => ErrorView(error: error, onRetry: onRetry),
    _ => loading ?? const LoadingView(),
  };
}

/// A centred brand spinner, announced as loading.
class LoadingView extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: CircularProgressIndicator(
      color: KivetoColors.brand,
      semanticsLabel: AppLocalizations.of(context).commonLoading,
    ),
  );
}

/// The title and body of an error, in French: one pair per [ApiFailure]
/// subtype, a generic one for any other error.
(String title, String body) failureMessage(
  AppLocalizations l10n,
  Object error,
) => switch (error) {
  NetworkFailure() => (l10n.errorNetworkTitle, l10n.errorNetworkBody),
  UnauthorizedFailure() => (
    l10n.errorUnauthorizedTitle,
    l10n.errorUnauthorizedBody,
  ),
  ValidationFailure() => (l10n.errorValidationTitle, l10n.errorValidationBody),
  RateLimitedFailure(:final retryAfter) => (
    l10n.errorRateLimitedTitle,
    retryAfter == null
        ? l10n.errorRateLimitedBodyUnknown
        : l10n.errorRateLimitedBody(
            (retryAfter.inSeconds / 60).ceil().clamp(1, 1 << 20),
          ),
  ),
  NotFoundFailure() => (l10n.errorNotFoundTitle, l10n.errorNotFoundBody),
  ConflictFailure() => (l10n.errorConflictTitle, l10n.errorConflictBody),
  ServerFailure() => (l10n.errorServerTitle, l10n.errorServerBody),
  BusinessFailure() => (l10n.errorBusinessTitle, l10n.errorBusinessBody),
  _ => (l10n.errorUnknownTitle, l10n.errorUnknownBody),
};

/// An error in the empty-state layout (C-36): a glyph per kind, the
/// French title and body of [failureMessage] ([message] replaces the body:
/// a slice maps its business codes), a retry button when [onRetry] is set.
class ErrorView extends StatelessWidget {
  const new({required this.error, super.key, this.onRetry, this.message});

  final Object error;
  final VoidCallback? onRetry;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (title, body) = failureMessage(l10n, error);
    final onRetry = this.onRetry;
    return EmptyState(
      glyph: switch (error) {
        NetworkFailure() => LucideGlyph.wifiOff,
        RateLimitedFailure() => LucideGlyph.clock,
        _ => LucideGlyph.circleAlert,
      },
      title: title,
      body: message ?? body,
      action: onRetry == null
          ? null
          : KivetoButton.outline(label: l10n.commonRetry, onPressed: onRetry),
    );
  }
}

/// C-36 (extrapolated): a centred grey circle with a glyph, a title, a
/// body and an optional action.
class EmptyState extends StatelessWidget {
  const new({
    required this.glyph,
    required this.title,
    super.key,
    this.body,
    this.action,
  });

  final LucideGlyph glyph;
  final String title;
  final String? body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final body = this.body;
    final action = this.action;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(KivetoSpace.xl5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: KivetoColors.neutralSoft,
                shape: BoxShape.circle,
              ),
              child: KivetoIcon(glyph, size: 28, color: KivetoColors.inkMuted),
            ),
            const SizedBox(height: KivetoSpace.m),
            Text(
              title,
              textAlign: TextAlign.center,
              style: KivetoText.sectionTitle,
            ),
            if (body != null) ...[
              const SizedBox(height: KivetoSpace.m),
              Text(
                body,
                textAlign: TextAlign.center,
                style: KivetoText.bodySmall.copyWith(height: 1.45),
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: KivetoSpace.m),
              action,
            ],
          ],
        ),
      ),
    );
  }
}
