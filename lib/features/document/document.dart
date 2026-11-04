// The public API of document: the documents screen and the renewal screen
// (17; their exits are callbacks: the feature never imports app/), the
// in-app PDF viewer (`openDocumentFile` for a document, `openPdfFile` for
// another file of the Portal API), the prescription read
// (`prescriptionProvider`) and the French labels other features reuse
// (kinds, payments, pet names).

export 'package:kiveto_mobile/features/document/domain/document.dart';
export 'package:kiveto_mobile/features/document/domain/prescription.dart';
export 'package:kiveto_mobile/features/document/presentation/document_messages.dart'
    show documentKindName, joinPetNames, paymentLabel;
export 'package:kiveto_mobile/features/document/presentation/documents_page.dart'
    show DocumentsPage;
export 'package:kiveto_mobile/features/document/presentation/documents_providers.dart'
    show prescriptionProvider;
export 'package:kiveto_mobile/features/document/presentation/pdf_file_page.dart'
    show openDocumentFile, openPdfFile;
export 'package:kiveto_mobile/features/document/presentation/renewal_page.dart'
    show RenewalPage;
export 'package:kiveto_mobile/shared/domain/document_kind.dart';
export 'package:kiveto_mobile/shared/domain/payment_status.dart';
