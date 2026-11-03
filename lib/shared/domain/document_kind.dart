/// What a document is; [unknown] for a type this app does not know yet.
///
/// Shared by the features that list or link documents (document, home,
/// consultation).
enum DocumentKind {
  report,
  prescription,
  invoice,
  labResult,
  certificate,
  unknown,
}
