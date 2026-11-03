/// Where a preventive care item stands, as the server decides it from the
/// clinic's local date (`booked` when an appointment covers it); [unknown]
/// for a status this app does not know yet. The app only picks the wording
/// and the tone.
enum CareStatus { booked, overdue, dueSoon, upToDate, unknown }
