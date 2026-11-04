import 'package:kiveto_mobile/core/errors/api_failure_mapper.dart';
import 'package:kiveto_mobile/core/network/portal_results.dart';
import 'package:kiveto_mobile/features/client/domain/link_suggestion.dart';
import 'package:kiveto_mobile/features/client/domain/link_suggestion_repository.dart';
import 'package:kiveto_mobile/features/client/domain/me.dart';
import 'package:kiveto_portal_api/kiveto_portal_api.dart' as api;
import 'package:tonik_util/tonik_util.dart';

/// [LinkSuggestionRepository] on the generated `AccountApi`.
final class PortalLinkSuggestionRepository implements LinkSuggestionRepository {
  new(api.Server server, this._failures) : _api = api.AccountApi(server);

  final api.AccountApi _api;
  final ApiFailureMapper _failures;

  @override
  Future<List<LinkSuggestion>> suggestions() async => switch (await _api
      .listLinkSuggestions()) {
    TonikSuccess(value: api.ListLinkSuggestionsResponse200(:final body)) => [
      for (final view in body)
        LinkSuggestion(
          id: view.id,
          clinicName: view.clinic.name,
          clinicCity: view.clinic.city,
          matchedOn: _named(
            LinkMatch.values,
            view.matchedOn,
            LinkMatch.unknown,
          ),
        ),
    ],
    final other => throw apiFailureOf(other, _failures),
  };

  @override
  Future<LinkStatus> accept(String id) async =>
      switch (await _api.acceptLinkSuggestion(suggestionId: id)) {
        TonikSuccess(value: api.AcceptLinkSuggestionResponse202(:final body)) =>
          _named(LinkStatus.values, body.linkStatus, LinkStatus.unknown),
        final other => throw apiFailureOf(other, _failures),
      };

  /// The value of [values] named like the wire's [value] (the generated
  /// enums name theirs like the domain's); [unknown] for any other — never
  /// the generated `toJson` of `unknown`, which throws.
  static T _named<T extends Enum>(List<T> values, Enum value, T unknown) =>
      values.asNameMap()[value.name] ?? unknown;
}
