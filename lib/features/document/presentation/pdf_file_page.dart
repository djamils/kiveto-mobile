import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiveto_mobile/features/client/client.dart';
import 'package:kiveto_mobile/features/document/di.dart';
import 'package:kiveto_mobile/features/document/domain/document.dart';
import 'package:kiveto_mobile/features/document/presentation/documents_providers.dart';
import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';
import 'package:kiveto_mobile/shared/domain/portal_file.dart';
import 'package:kiveto_mobile/shared/presentation/async/async_views.dart';
import 'package:kiveto_mobile/shared/presentation/icons/lucide_glyph.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_colors.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_layout.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_text.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pdfrx/pdfrx.dart';

/// Draws the bytes of a PDF; [sourceName] is unique per file shown.
typedef PdfViewBuilder = Widget Function(
  BuildContext context,
  Uint8List bytes,
  String sourceName,
);

/// The PDF view of [PdfFilePage]: pdfrx (PDFium) in the app; the tests
/// override it (no PDFium in `flutter test`).
final pdfViewBuilderProvider = Provider<PdfViewBuilder>((ref) => _pdfrxView);

Widget _pdfrxView(BuildContext context, Uint8List bytes, String sourceName) {
  final l10n = AppLocalizations.of(context);
  return PdfViewer.data(
    bytes,
    sourceName: sourceName,
    params: PdfViewerParams(
      backgroundColor: KivetoColors.canvas,
      // The kit's soft shadow, not pdfrx's heavy default.
      pageDropShadow: KivetoShadows.bottomNav,
      errorBannerBuilder: (context, error, stackTrace, documentRef) =>
          EmptyState(
            glyph: LucideGlyph.circleAlert,
            title: l10n.documentsFileRenderError,
          ),
    ),
  );
}

/// Opens the file of a document in the app, over the bottom navigation
/// (the root navigator), from any page (the documents screen, the home).
/// Once it shows, the server has counted the read: `GET /me` is read again
/// (the Documents badge follows) and the document loses its dot in every
/// documents list loaded.
Future<void> openDocumentFile(
  BuildContext context, {
  required ClinicId clinicId,
  required DocumentId documentId,
  required String title,
}) => _push(
  context,
  PdfFilePage(
    title: title,
    load: (ref) =>
        ref.read(documentRepositoryProvider).file(clinicId, documentId),
    onLoaded: (ref) {
      ref.invalidate(meProvider);
      for (final kind in <DocumentKind?>[null, ...DocumentKind.values]) {
        if (ref.exists(documentListProvider(kind))) {
          ref.read(documentListProvider(kind).notifier).markRead(documentId);
        }
      }
    },
  ),
);

/// Opens a PDF of the Portal API that [load] downloads (the vaccination
/// booklet…) in the app, over the bottom navigation.
Future<void> openPdfFile(
  BuildContext context, {
  required String title,
  required Future<PortalFile> Function(WidgetRef ref) load,
}) => _push(context, PdfFilePage(title: title, load: load));

Future<void> _push(BuildContext context, PdfFilePage page) => Navigator.of(
  context,
  rootNavigator: true,
).push(MaterialPageRoute<void>(builder: (context) => page));

/// A full-screen PDF: back and [title], then the file [load] downloads
/// (loading, then the PDF; a 404 says the document is not available, any
/// other failure offers a retry). [onLoaded] runs once the file arrived.
///
/// Both callbacks take this page's own [WidgetRef]: the page that opened
/// the file may be gone by then.
class PdfFilePage extends ConsumerStatefulWidget {
  const new({
    required this.title,
    required this.load,
    super.key,
    this.onLoaded,
  });

  final String title;
  final Future<PortalFile> Function(WidgetRef ref) load;
  final void Function(WidgetRef ref)? onLoaded;

  @override
  ConsumerState<PdfFilePage> createState() => _PdfFilePageState();
}

class _PdfFilePageState extends ConsumerState<PdfFilePage> {
  /// Each file shown gets its own source name (pdfrx caches by name).
  static var _sources = 0;

  AsyncValue<(Uint8List, String)> _file = const AsyncLoading();

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    if (_file is! AsyncLoading) setState(() => _file = const AsyncLoading());
    try {
      final file = await widget.load(ref);
      if (!mounted) return;
      final bytes = switch (file.bytes) {
        final Uint8List bytes => bytes,
        final bytes => Uint8List.fromList(bytes),
      };
      setState(() => _file = AsyncData((bytes, 'kiveto-file-${_sources++}')));
      widget.onLoaded?.call(ref);
    } on Object catch (error, stackTrace) {
      if (!mounted) return;
      setState(() => _file = AsyncError(error, stackTrace));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: KivetoColors.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                KivetoSpace.gutter,
                KivetoSpace.sm,
                KivetoSpace.gutter,
                KivetoSpace.sm,
              ),
              child: Row(
                children: [
                  KivetoIconButton.back(
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(
                        widget.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: KivetoText.sectionTitle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: switch (_file) {
                AsyncData(value: (final bytes, final sourceName)) => ref.watch(
                  pdfViewBuilderProvider,
                )(context, bytes, sourceName),
                AsyncError(:final NotFoundFailure error) => ErrorView(
                  error: error,
                  title: l10n.documentsFileGoneTitle,
                  message: l10n.documentsFileGoneBody,
                ),
                AsyncError(:final error) => ErrorView(
                  error: error,
                  onRetry: () => unawaited(_load()),
                ),
                _ => const LoadingView(),
              },
            ),
          ],
        ),
      ),
    );
  }
}
