import 'package:kiveto_mobile/core/errors/api_failure_mapper.dart';
import 'package:kiveto_mobile/core/network/portal_results.dart';
import 'package:kiveto_mobile/features/client/domain/me.dart';
import 'package:kiveto_mobile/features/client/domain/me_repository.dart';
import 'package:kiveto_mobile/features/client/domain/profile_update.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';
import 'package:kiveto_portal_api/kiveto_portal_api.dart' as api;
import 'package:tonik_util/tonik_util.dart';

/// [MeRepository] on the generated `AccountApi`. The `PATCH /me` answer is
/// the account itself (`UpdatedAccountView`, its own address wrapper),
/// mapped like the account of `GET /me`.
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

  /// Sent as `application/merge-patch+json`: the names always, the address
  /// only when the update carries one (an absent key stays unchanged).
  @override
  Future<Account> updateProfile(ProfileUpdate update) async {
    final address = update.address;
    final body = api.MeUpdate(
      firstName: update.firstName,
      lastName: update.lastName,
      address: address == null
          ? null
          : api.MeUpdateJsonMergePatchAddressAnyOfModel(
              profileAddress: api.ProfileAddress(
                streetLine1: address.streetLine1,
                postalCode: address.postalCode,
                city: address.city,
                countryCode: address.countryCode,
              ),
            ),
    );
    return switch (await _api.updateMe(
      body: api.ApiPortalV1MePatchBodyRequestBodyMergePatchJson(body),
    )) {
      TonikSuccess(value: api.UpdateMeResponse200(body: final view)) => Account(
        id: view.id,
        firstName: view.firstName,
        lastName: view.lastName,
        email: view.email,
        emailVerified: view.emailVerified,
        maskedPhone: view.maskedPhone,
        address: _address(view.address?.addressView),
      ),
      final other => throw apiFailureOf(other, _failures),
    };
  }

  static Account _account(api.AccountView view) => Account(
    id: view.id,
    firstName: view.firstName,
    lastName: view.lastName,
    email: view.email,
    emailVerified: view.emailVerified,
    maskedPhone: view.maskedPhone,
    address: _address(view.address?.addressView),
  );

  static PostalAddress? _address(api.AddressView? address) => switch (address) {
    final api.AddressView address => PostalAddress(
      line1: address.line1,
      line2: address.line2,
      postalCode: address.postalCode,
      city: address.city,
      country: address.country,
    ),
    null => null,
  };

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
