import 'package:kiveto_mobile/core/errors/api_failure_mapper.dart';
import 'package:kiveto_mobile/core/network/portal_results.dart';
import 'package:kiveto_mobile/features/client/domain/me.dart';
import 'package:kiveto_mobile/features/client/domain/me_repository.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';
import 'package:kiveto_portal_api/kiveto_portal_api.dart' as api;
import 'package:tonik_util/tonik_util.dart';

/// [MeRepository] on the generated `AccountApi`.
final class PortalMeRepository implements MeRepository {
  new(api.Server server, this._failures) : _api = api.AccountApi(server);

  final api.AccountApi _api;
  final ApiFailureMapper _failures;

  @override
  Future<Me> me() async => switch (await _api.getMe()) {
    TonikSuccess(value: api.GetMeResponse200(:final body)) => Me(
      account: _account(body.account),
      clinics: [for (final clinic in body.clinics) _clinic(clinic)],
    ),
    final other => throw apiFailureOf(other, _failures),
  };

  static Account _account(api.AccountView view) => Account(
    id: view.id,
    firstName: view.firstName,
    lastName: view.lastName,
    email: view.email,
    emailVerified: view.emailVerified,
    maskedPhone: view.maskedPhone,
    address: switch (view.address?.addressView) {
      final api.AddressView address => PostalAddress(
        line1: address.line1,
        line2: address.line2,
        postalCode: address.postalCode,
        city: address.city,
        country: address.country,
      ),
      null => null,
    },
  );

  static ClinicLink _clinic(api.ClinicLinkView view) => ClinicLink(
    clinicId: ClinicId(view.clinicId),
    name: view.name,
    city: view.city,
    phone: view.phone,
    address: switch (view.address?.clinicAddressView) {
      final api.ClinicAddressView address => ClinicAddress(
        line: address.line,
        postalCode: address.postalCode,
        city: address.city,
      ),
      null => null,
    },
    timezone: view.timezone,
    linkStatus: switch (view.linkStatus) {
      api.ClinicLinkViewLinkStatusModel.confirmed => LinkStatus.confirmed,
      api.ClinicLinkViewLinkStatusModel.pending => LinkStatus.pending,
      api.ClinicLinkViewLinkStatusModel.unknown => LinkStatus.unknown,
    },
    linkedAt: view.linkedAt?.toUtc(),
    petNames: view.petNames,
    tags: view.tags,
    unreadDocuments: view.unreadDocuments,
  );
}
