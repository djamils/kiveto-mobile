/// How far an invoice is paid; [unknown] for a status this app does not
/// know yet.
///
/// Shared by the features that show invoices (document, home).
enum PaymentStatus { unpaid, partiallyPaid, paid, credited, unknown }
