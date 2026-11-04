import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiveto_mobile/features/client/di.dart';
import 'package:kiveto_mobile/features/client/domain/data_export.dart';
import 'package:kiveto_mobile/features/client/presentation/account_messages.dart';
import 'package:kiveto_mobile/features/client/presentation/account_providers.dart';
import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';
import 'package:kiveto_mobile/shared/presentation/async/async_views.dart';
import 'package:kiveto_mobile/shared/presentation/formatters/kiveto_format.dart';
import 'package:kiveto_mobile/shared/presentation/icons/lucide_glyph.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/kit/feedback.dart';
import 'package:kiveto_mobile/shared/presentation/kit/navigation.dart';
import 'package:kiveto_mobile/shared/presentation/kit/pills.dart';
import 'package:kiveto_mobile/shared/presentation/kit/surfaces.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_colors.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_layout.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_text.dart';
import 'package:material_ui/material_ui.dart';

/// The data exports of the account, in a sheet: each export with its
/// status (a ready one until when, and « Télécharger »: its ZIP goes to the
/// share sheet), « Actualiser » while one is being built, « Demander un
/// export ». The server decides the quota (one per 24 h).
///
/// The failures show in the sheet (a SnackBar would sit behind it).
Future<void> showDataExportSheet(BuildContext context) => showKivetoSheet<void>(
  context: context,
  builder: (context) => const DataExportSheet(),
);

/// The content of the export sheet (see [showDataExportSheet]).
class DataExportSheet extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<DataExportSheet> createState() => _DataExportSheetState();
}

class _DataExportSheetState extends ConsumerState<DataExportSheet> {
  bool _requesting = false;
  String? _requested;
  String? _requestError;

  /// The export being downloaded.
  String? _downloading;
  String? _downloadError;

  Future<void> _request() async {
    if (_requesting) return;
    final l10n = AppLocalizations.of(context);
    final repository = ref.read(dataExportRepositoryProvider);
    // Every line of an earlier action goes: none stays next to this one's.
    setState(() {
      _requesting = true;
      _requested = null;
      _requestError = null;
      _downloadError = null;
    });
    try {
      await repository.request();
      if (!mounted) return;
      ref.invalidate(dataExportsProvider);
      setState(() {
        _requesting = false;
        _requested = l10n.accountExportRequested;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _requesting = false;
        _requestError = switch (error) {
          RateLimitedFailure(code: 'export_rate_limited') =>
            l10n.accountExportRateLimited,
          _ => failureMessage(l10n, error).$2,
        };
      });
    }
  }

  Future<void> _download(DataExport export) async {
    if (_downloading != null) return;
    final l10n = AppLocalizations.of(context);
    final repository = ref.read(dataExportRepositoryProvider);
    final share = ref.read(dataExportSharerProvider);
    setState(() {
      _downloading = export.id;
      _requested = null;
      _requestError = null;
      _downloadError = null;
    });
    String? failure;
    try {
      await share(await repository.download(export.id));
    } on NotFoundFailure {
      failure = l10n.accountExportGone;
      if (mounted) ref.invalidate(dataExportsProvider);
    } on Object {
      failure = l10n.accountExportDownloadFailed;
    }
    if (!mounted) return;
    setState(() {
      _downloading = null;
      _downloadError = failure;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final requested = _requested;
    final requestError = _requestError;
    final downloadError = _downloadError;
    return KivetoSheet(
      title: l10n.accountExportTitle,
      subtitle: l10n.accountExportSubtitle,
      children: [
        AsyncValueView(
          value: ref.watch(dataExportsProvider),
          onRetry: () => ref.invalidate(dataExportsProvider),
          data: (exports) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (exports.isEmpty)
                KivetoFootnote(l10n.accountExportEmpty)
              else
                KivetoCard.list(
                  children: [
                    for (final export in exports)
                      _ExportRow(
                        export: export,
                        downloading: _downloading == export.id,
                        onDownload: _downloading == null
                            ? () => unawaited(_download(export))
                            : null,
                      ),
                  ],
                ),
              if (exports.any(
                (export) => export.status == DataExportStatus.pending,
              ))
                KivetoTextButton(
                  label: l10n.accountExportRefresh,
                  onPressed: () => ref.invalidate(dataExportsProvider),
                ),
            ],
          ),
        ),
        if (downloadError != null) _Line(downloadError, error: true),
        if (requested != null) _Line(requested),
        if (requestError != null) _Line(requestError, error: true),
        const SizedBox(height: KivetoSpace.xxs),
        KivetoButton.primary(
          label: l10n.accountExportRequest,
          loading: _requesting,
          onPressed: () => unawaited(_request()),
        ),
      ],
    );
  }
}

/// One export: « Export du {date} » and its pill; a ready one, until when
/// it can be downloaded and « Télécharger ».
class _ExportRow extends StatelessWidget {
  const new({
    required this.export,
    required this.downloading,
    required this.onDownload,
  });

  final DataExport export;
  final bool downloading;
  final VoidCallback? onDownload;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pill = dataExportPill(l10n, export.status);
    final expiresAt = export.expiresAt;
    final ready = export.status == DataExportStatus.ready;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.accountExportRow(
                        KivetoFormat.dayMonthYear(
                          deviceDateOf(export.requestedAt),
                        ),
                      ),
                      style: KivetoText.label,
                    ),
                    if (ready && expiresAt != null) ...[
                      const SizedBox(height: KivetoSpace.xxs),
                      Text(
                        l10n.accountExportAvailableUntil(
                          KivetoFormat.dayMonth(deviceDateOf(expiresAt)),
                          deviceTimeOf(expiresAt),
                        ),
                        style: KivetoText.caption,
                      ),
                    ],
                  ],
                ),
              ),
              if (pill case (final label, final tone)) ...[
                const SizedBox(width: KivetoSpace.ml),
                StatusPill(label, tone: tone),
              ],
            ],
          ),
          if (ready) ...[
            const SizedBox(height: KivetoSpace.m),
            KivetoButton.tonal(
              label: l10n.accountExportDownload,
              icon: LucideGlyph.download,
              loading: downloading,
              onPressed: onDownload,
            ),
          ],
        ],
      ),
    );
  }
}

/// A line of the sheet: a notice, or an error in red; announced.
class _Line extends StatelessWidget {
  const new(this.text, {this.error = false});

  final String text;
  final bool error;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: Text(
      text,
      style: error
          ? KivetoText.bodySmall.copyWith(color: KivetoColors.danger)
          : KivetoText.body.copyWith(color: KivetoColors.inkSecondary),
    ),
  );
}
