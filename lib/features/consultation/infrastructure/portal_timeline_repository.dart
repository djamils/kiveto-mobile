import 'package:kiveto_mobile/core/errors/api_failure_mapper.dart';
import 'package:kiveto_mobile/core/network/portal_results.dart';
import 'package:kiveto_mobile/features/consultation/domain/timeline.dart';
import 'package:kiveto_mobile/features/consultation/domain/timeline_repository.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';
import 'package:kiveto_mobile/shared/domain/document_kind.dart';
import 'package:kiveto_portal_api/kiveto_portal_api.dart' as api;
import 'package:tonik_util/tonik_util.dart';

/// [TimelineRepository] on the generated `PetsApi.getPetTimeline` (the
/// server's page size: no `limit` sent).
final class PortalTimelineRepository implements TimelineRepository {
  new(api.Server server, this._failures) : _api = api.PetsApi(server);

  final api.PetsApi _api;
  final ApiFailureMapper _failures;

  @override
  Future<TimelinePage> timeline(
    ClinicId clinicId,
    String petId, {
    String? cursor,
  }) async => switch (await _api.getPetTimeline(
    clinicId: clinicId.value,
    petId: petId,
    cursor: cursor,
  )) {
    TonikSuccess(value: api.GetPetTimelineResponse200(:final body)) =>
      TimelinePage(
        items: [
          for (final entry in body.items)
            TimelineEntry(
              visitId: entry.visitId,
              date: clinicInstantOf(entry.date),
              vet: entry.vet,
              title: entry.title,
              documents: [
                for (final document in entry.documents)
                  TimelineDocument(id: document.id, kind: _kind(document.kind)),
              ],
            ),
        ],
        nextCursor: body.nextCursor,
      ),
    final other => throw apiFailureOf(other, _failures),
  };

  static DocumentKind _kind(
    api.TimelineDocumentViewTypeModel kind,
  ) => switch (kind) {
    api.TimelineDocumentViewTypeModel.report => DocumentKind.report,
    api.TimelineDocumentViewTypeModel.prescription => DocumentKind.prescription,
    api.TimelineDocumentViewTypeModel.invoice => DocumentKind.invoice,
    api.TimelineDocumentViewTypeModel.labResult => DocumentKind.labResult,
    api.TimelineDocumentViewTypeModel.certificate => DocumentKind.certificate,
    api.TimelineDocumentViewTypeModel.unknown => DocumentKind.unknown,
  };
}
