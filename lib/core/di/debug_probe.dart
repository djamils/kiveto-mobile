import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiveto_mobile/core/di/core_providers.dart';
import 'package:kiveto_mobile/core/network/portal_results.dart';
import 'package:kiveto_portal_api/kiveto_portal_api.dart';
import 'package:tonik_util/tonik_util.dart';

/// Debug gallery only: `GET /legal/terms/current` through the real chain
/// (it proves the base URL and the dev `Host` header), as `200 · <version>`;
/// a failure is thrown as an `ApiFailure`. Only the status is logged.
final FutureProvider<String> termsProbeProvider =
    FutureProvider.autoDispose<String>((ref) async {
      final result = await TermsApi(ref.watch(portalServerProvider))
          .getCurrentTerms();
      switch (result) {
        case TonikSuccess(value: GetCurrentTermsResponse200(:final body)):
          debugPrint('termsProbe: 200');
          return '200 · ${body.version}';
        case final other:
          final failure = apiFailureOf(
            other,
            ref.read(apiFailureMapperProvider),
          );
          debugPrint('termsProbe: ${failure.runtimeType}');
          throw failure;
      }
    });
