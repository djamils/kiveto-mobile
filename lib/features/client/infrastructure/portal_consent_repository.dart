import 'package:kiveto_mobile/core/errors/api_failure_mapper.dart';
import 'package:kiveto_mobile/core/network/portal_results.dart';
import 'package:kiveto_mobile/features/client/domain/consent.dart';
import 'package:kiveto_mobile/features/client/domain/consent_repository.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';
import 'package:kiveto_portal_api/kiveto_portal_api.dart' as api;
import 'package:tonik_util/tonik_util.dart';

/// [ConsentRepository] on the generated `ConsentsApi`.
///
/// The generated enums are mapped by name (`asNameMap()`): their `unknown`
/// stays this app's `unknown` (the generated `toJson` of `unknown` throws).
/// A channel this app does not know is dropped (the consent covers the
/// others); so is a history change on such a channel. `preferredChannel`
/// is not used.
final class PortalConsentRepository implements ConsentRepository {
  new(api.Server server, this._failures) : _api = api.ConsentsApi(server);

  final api.ConsentsApi _api;
  final ApiFailureMapper _failures;

  @override
  Future<ClinicConsents> consents(ClinicId clinicId) async =>
      switch (await _api.getConsents(clinicId: clinicId.value)) {
        TonikSuccess(value: api.GetConsentsResponse200(:final body)) =>
          _consents(body.consents),
        final other => throw apiFailureOf(other, _failures),
      };

  /// The channels are sent in the order sms, email.
  @override
  Future<ClinicConsents> update(
    ClinicId clinicId,
    ConsentKind kind,
    Set<ConsentChannel> channels,
  ) async {
    final wireKind = switch (kind) {
      ConsentKind.appointmentReminders => 'appointment_reminders',
      ConsentKind.vaccinationReminders => 'vaccination_reminders',
      ConsentKind.marketing => 'marketing',
      ConsentKind.clinicalDocuments => 'clinical_documents',
      ConsentKind.billing => 'billing',
      ConsentKind.unknown => throw ArgumentError.value(
        kind,
        'kind',
        'a consent kind of the API',
      ),
    };
    final body = api.ConsentUpdate(
      channels: [
        for (final channel in ConsentChannel.values)
          if (channels.contains(channel))
            switch (channel) {
              ConsentChannel.sms => api.ConsentUpdateChannelsArrayModel.sms,
              ConsentChannel.email => api.ConsentUpdateChannelsArrayModel.email,
            },
      ],
    );
    return switch (await _api.updateConsent(
      body: body,
      clinicId: clinicId.value,
      kind: wireKind,
    )) {
      TonikSuccess(value: api.UpdateConsentResponse200(:final body)) =>
        _consents(body.consents),
      final other => throw apiFailureOf(other, _failures),
    };
  }

  @override
  Future<ConsentHistoryPage> history(
    ClinicId clinicId, {
    String? cursor,
  }) async => switch (await _api.getConsentHistory(
    clinicId: clinicId.value,
    cursor: cursor,
  )) {
    TonikSuccess(value: api.GetConsentHistoryResponse200(:final body)) =>
      ConsentHistoryPage(
        items: [
          for (final item in body.items)
            if (_channel(item.channel) case final channel?)
              ConsentHistoryEntry(
                kind: _sameName(ConsentKind.values, item.kind),
                channel: channel,
                action: _sameName(ConsentAction.values, item.action),
                at: item.at.toUtc(),
                source: _sameName(ConsentSource.values, item.source),
                author: item.author,
                approximate: item.approximate,
              ),
        ],
        nextCursor: body.nextCursor,
      ),
    final other => throw apiFailureOf(other, _failures),
  };

  static ClinicConsents _consents(List<api.ConsentView> views) =>
      ClinicConsents([
        for (final view in views)
          Consent(
            kind: _sameName(ConsentKind.values, view.kind),
            channels: {for (final channel in view.channels) ?_channel(channel)},
            grantedAt: view.grantedAt?.toUtc(),
            effect: _sameName(ConsentEffect.values, view.effect),
          ),
      ]);

  /// The channel of the same name; null for one this app does not know.
  static ConsentChannel? _channel(Enum wire) =>
      ConsentChannel.values.asNameMap()[wire.name];

  /// The value of [values] named like [wire]; the last of [values] (their
  /// `unknown`) for a name this app does not know.
  static T _sameName<T extends Enum>(List<T> values, Enum wire) =>
      values.asNameMap()[wire.name] ?? values.last;
}
