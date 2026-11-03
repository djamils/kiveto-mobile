import 'package:dio/dio.dart';
import 'package:kiveto_mobile/core/errors/api_failure_mapper.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';
import 'package:kiveto_mobile/shared/domain/clinic_instant.dart';
import 'package:kiveto_mobile/shared/domain/local_date.dart';
import 'package:tonik_util/tonik_util.dart';

// The tonik-level helpers of the slices' repositories (rule 7 keeps
// tonik_util out of core/errors/). The repository pattern:
//
//   switch (await api.getMe()) {
//     TonikSuccess(value: GetMeResponse200(:final body)) => map(body),
//     final other => throw apiFailureOf(other, _failures),
//   }

/// The [ApiFailure] of a result the repository did not want: an error, or
/// a success whose variant is an error status.
ApiFailure apiFailureOf(
  TonikResult<Object?, Response<Object?>> result,
  ApiFailureMapper failures,
) => switch (result) {
  TonikError(:final DioException error) => failures.fromDio(error),
  TonikError(type: TonikErrorType.network || TonikErrorType.cancelled) =>
    const NetworkFailure(),
  TonikError(response: final response?) ||
  TonikSuccess(:final response) => failures.fromResponse(
    statusCode: response.statusCode,
    body: response.data,
    headers: response.headers.map,
  ),
  TonikError() => const ServerFailure(),
};

/// A wire `date-time` (an `OffsetDateTime`, or a UTC `DateTime` for
/// `+00:00`) with its offset kept.
ClinicInstant clinicInstantOf(DateTime wire) =>
    ClinicInstant(wire, wire.isUtc ? Duration.zero : wire.timeZoneOffset);

/// A wire `format: date`.
LocalDate localDateOf(Date date) => LocalDate(date.year, date.month, date.day);
