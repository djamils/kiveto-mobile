import 'package:kiveto_mobile/core/errors/api_failure_mapper.dart';
import 'package:kiveto_mobile/core/network/portal_results.dart';
import 'package:kiveto_mobile/features/home/domain/home_overview.dart';
import 'package:kiveto_mobile/features/home/domain/home_repository.dart';
import 'package:kiveto_mobile/shared/domain/care_status.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';
import 'package:kiveto_mobile/shared/domain/document_kind.dart';
import 'package:kiveto_mobile/shared/domain/money.dart';
import 'package:kiveto_mobile/shared/domain/payment_status.dart';
import 'package:kiveto_mobile/shared/domain/species.dart';
import 'package:kiveto_portal_api/kiveto_portal_api.dart' as api;
import 'package:tonik_util/tonik_util.dart';

/// [HomeRepository] on the generated `PetsApi.getHome`. Which appointment
/// is next, which pets, care items and documents show: the server's
/// choice, mapped as received.
final class PortalHomeRepository implements HomeRepository {
  new(api.Server server, this._failures) : _api = api.PetsApi(server);

  final api.PetsApi _api;
  final ApiFailureMapper _failures;

  @override
  Future<HomeOverview> overview(ClinicId clinicId) async => switch (await _api
      .getHome(clinicId: clinicId.value)) {
    TonikSuccess(value: api.GetHomeResponse200(:final body)) => HomeOverview(
      nextAppointment: switch (body.nextAppointment?.appointmentView) {
        final api.AppointmentView view => _appointment(view),
        null => null,
      },
      pets: [for (final pet in body.pets) _pet(pet)],
      careItems: [for (final item in body.careItems) _careItem(item)],
      latestDocuments: [
        for (final document in body.latestDocuments) _document(document),
      ],
    ),
    final other => throw apiFailureOf(other, _failures),
  };

  static NextAppointment _appointment(api.AppointmentView view) =>
      NextAppointment(
        id: view.id,
        startAt: clinicInstantOf(view.startAt),
        petName: view.pet?.petReferenceView?.name,
        motifLabel: view.motif.label,
        practitionerName: view.practitioner.displayName,
        status: switch (view.status) {
          api.AppointmentViewStatusModel.confirmed =>
            AppointmentState.confirmed,
          api.AppointmentViewStatusModel.pendingClinicConfirmation =>
            AppointmentState.pendingClinicConfirmation,
          api.AppointmentViewStatusModel.cancelledByClient ||
          api.AppointmentViewStatusModel.cancelledByClinic ||
          api.AppointmentViewStatusModel.declined ||
          api.AppointmentViewStatusModel.completed ||
          api.AppointmentViewStatusModel.noShow ||
          api.AppointmentViewStatusModel.unknown => AppointmentState.other,
        },
        questionnaire: switch (view.questionnaireStatus) {
          api.AppointmentViewQuestionnaireStatusModel.notStarted =>
            QuestionnaireState.notStarted,
          api.AppointmentViewQuestionnaireStatusModel.submitted =>
            QuestionnaireState.submitted,
          api.AppointmentViewQuestionnaireStatusModel.unknown =>
            QuestionnaireState.unknown,
        },
      );

  static HomePet _pet(api.PetSummary pet) => HomePet(
    id: pet.id,
    name: pet.name,
    initial: pet.initial,
    species: switch (pet.species) {
      api.PetSummarySpeciesModel.dog => Species.dog,
      api.PetSummarySpeciesModel.cat => Species.cat,
      api.PetSummarySpeciesModel.nac => Species.nac,
      api.PetSummarySpeciesModel.other => Species.other,
      api.PetSummarySpeciesModel.unknown => Species.unknown,
    },
    birthDate: switch (pet.birthDate) {
      final Date date => localDateOf(date),
      null => null,
    },
  );

  static HomeCareItem _careItem(api.HomeCareItemView item) => HomeCareItem(
    petId: item.pet.id,
    petName: item.pet.name,
    label: item.label,
    dueOn: localDateOf(item.dueOn),
    status: switch (item.status) {
      api.HomeCareItemViewStatusModel.booked => CareStatus.booked,
      api.HomeCareItemViewStatusModel.overdue => CareStatus.overdue,
      api.HomeCareItemViewStatusModel.dueSoon => CareStatus.dueSoon,
      api.HomeCareItemViewStatusModel.upToDate => CareStatus.upToDate,
      api.HomeCareItemViewStatusModel.unknown => CareStatus.unknown,
    },
  );

  static HomeDocument _document(api.DocumentView view) => HomeDocument(
    id: view.id,
    kind: switch (view.kind) {
      api.DocumentViewTypeModel.report => DocumentKind.report,
      api.DocumentViewTypeModel.prescription => DocumentKind.prescription,
      api.DocumentViewTypeModel.invoice => DocumentKind.invoice,
      api.DocumentViewTypeModel.labResult => DocumentKind.labResult,
      api.DocumentViewTypeModel.certificate => DocumentKind.certificate,
      api.DocumentViewTypeModel.unknown => DocumentKind.unknown,
    },
    title: view.title,
    petIds: view.petIds,
    issuedAt: clinicInstantOf(view.issuedAt),
    invoice: switch (view.invoice?.invoiceSummaryView) {
      final api.InvoiceSummaryView invoice => HomeInvoice(
        total: Money(invoice.total.amount, invoice.total.currency),
        paymentStatus: switch (invoice.paymentStatus) {
          api.InvoiceSummaryViewPaymentStatusModel.unpaid =>
            PaymentStatus.unpaid,
          api.InvoiceSummaryViewPaymentStatusModel.partiallyPaid =>
            PaymentStatus.partiallyPaid,
          api.InvoiceSummaryViewPaymentStatusModel.paid => PaymentStatus.paid,
          api.InvoiceSummaryViewPaymentStatusModel.credited =>
            PaymentStatus.credited,
          api.InvoiceSummaryViewPaymentStatusModel.unknown =>
            PaymentStatus.unknown,
        },
      ),
      null => null,
    },
  );
}
