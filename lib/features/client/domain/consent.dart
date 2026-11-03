/// The kinds of messages a clinic sends, in the order of the account page
/// (screen 6); [unknown] for a kind this app does not know.
enum ConsentKind {
  appointmentReminders,
  vaccinationReminders,
  marketing,
  clinicalDocuments,
  billing,
  unknown;

  /// The kinds the app shows, in the page's order.
  static List<ConsentKind> get known => [
    for (final kind in values)
      if (kind != unknown) kind,
  ];
}

/// The channels a consent covers (the automated ones of the API).
enum ConsentChannel { sms, email }

/// What a consent decides: whether the message is sent at all
/// ([sendControl]) or only on which channels ([channelPreference]: the
/// message goes out anyway, the server asks for one channel at least).
enum ConsentEffect { sendControl, channelPreference, unknown }

/// The consent of the account for one [kind] of message of a clinic.
final class Consent {
  const new({
    required this.kind,
    required this.channels,
    required this.effect,
    this.grantedAt,
  });

  final ConsentKind kind;

  /// Empty: not consented.
  final Set<ConsentChannel> channels;

  /// The latest grant (UTC); null when not granted.
  final DateTime? grantedAt;
  final ConsentEffect effect;

  bool get granted => channels.isNotEmpty;

  /// This consent with [channel] added ([on]) or removed.
  Consent withChannel(ConsentChannel channel, {required bool on}) => Consent(
    kind: kind,
    channels: on ? {...channels, channel} : ({...channels}..remove(channel)),
    grantedAt: grantedAt,
    effect: effect,
  );

  @override
  String toString() => 'Consent(${kind.name}, ${channels.map((c) => c.name)})';
}

/// The consents of the account in one clinic, one per kind.
final class ClinicConsents {
  const new(this.consents);

  /// In the API's order.
  final List<Consent> consents;

  /// The consent of [kind], or null when the clinic sent none.
  Consent? of(ConsentKind kind) {
    for (final consent in consents) {
      if (consent.kind == kind) return consent;
    }
    return null;
  }

  /// These consents with [consent] in place of the one of its kind.
  ClinicConsents replacing(Consent consent) => ClinicConsents([
    for (final current in consents)
      if (current.kind == consent.kind) consent else current,
  ]);
}

/// A change of the consent history: a channel granted or withdrawn.
enum ConsentAction { granted, withdrawn, unknown }

/// Where a change was made: on the Portal, at the clinic, or by the system
/// (the consents taken over when the clinic joined Kiveto).
enum ConsentSource { portal, clinic, system, unknown }

/// One change of the consent history of a clinic.
final class ConsentHistoryEntry {
  const new({
    required this.kind,
    required this.channel,
    required this.action,
    required this.at,
    required this.source,
    required this.author,
    this.approximate = false,
  });

  final ConsentKind kind;
  final ConsentChannel channel;
  final ConsentAction action;

  /// When (UTC); at the latest then when [approximate].
  final DateTime at;
  final ConsentSource source;

  /// Who made it, as the server names them (« La clinique », the profile's
  /// name…).
  final String author;
  final bool approximate;
}

/// A page of the consent history, newest first.
final class ConsentHistoryPage {
  const new({required this.items, this.nextCursor});

  final List<ConsentHistoryEntry> items;

  /// Reads the next page; null after the last one.
  final String? nextCursor;
}
