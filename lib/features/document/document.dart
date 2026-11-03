// The public API of document: the documents screen (its exit is a
// callback: the feature never imports app/), the in-app PDF viewer
// (`openDocumentFile` for a document, `openPdfFile` for another file of the
// Portal API) and the prescription read (`prescriptionProvider`).

export 'package:kiveto_mobile/features/document/domain/document.dart';
export 'package:kiveto_mobile/features/document/domain/prescription.dart';
export 'package:kiveto_mobile/features/document/presentation/documents_page.dart'
    show DocumentsPage;
export 'package:kiveto_mobile/features/document/presentation/documents_providers.dart'
    show prescriptionProvider;
export 'package:kiveto_mobile/features/document/presentation/pdf_file_page.dart'
    show openDocumentFile, openPdfFile;
