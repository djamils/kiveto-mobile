import 'package:kiveto_mobile/core/errors/api_failure_mapper.dart';
import 'package:kiveto_mobile/core/network/portal_results.dart';
import 'package:kiveto_mobile/features/identity_access/domain/terms.dart';
import 'package:kiveto_mobile/features/identity_access/domain/terms_repository.dart';
import 'package:kiveto_portal_api/kiveto_portal_api.dart' as api;
import 'package:tonik_util/tonik_util.dart';

/// [TermsRepository] on the generated `TermsApi` (a public route).
final class PortalTermsRepository implements TermsRepository {
  new(api.Server server, this._failures) : _api = api.TermsApi(server);

  final api.TermsApi _api;
  final ApiFailureMapper _failures;

  @override
  Future<Terms> current() async => switch (await _api.getCurrentTerms()) {
    TonikSuccess(value: api.GetCurrentTermsResponse200(:final body)) => Terms(
      version: body.version,
      url: body.url,
    ),
    final other => throw apiFailureOf(other, _failures),
  };
}
