import 'package:dio/dio.dart';

/// The first interceptor of the chain: a 2xx-only `validateStatus` (2xx
/// and 3xx when the request does not follow redirects).
///
/// The generated client accepts every status (errors are typed values);
/// narrowing it turns a 4xx/5xx into a `DioException(badResponse)` that the
/// auth interceptor can see, and into a `TonikError` for the caller.
final class StrictStatusInterceptor extends Interceptor {
  const new();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final upper = options.followRedirects ? 300 : 400;
    options.validateStatus = (status) =>
        status != null && status >= 200 && status < upper;
    handler.next(options);
  }
}
