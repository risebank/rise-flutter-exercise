import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final session = await Amplify.Auth.fetchAuthSession();

      if (session.isSignedIn) {
        final tokens = await Amplify.Auth.fetchAuthSession(
              options: FetchAuthSessionOptions(forceRefresh: false),
            ) as CognitoAuthSession;
        final token = tokens.userPoolTokensResult.value.accessToken.raw;
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (e) {
      // Log error but continue with request
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Token might be expired, try to refresh
      try {
        final refreshedTokens = await Amplify.Auth.fetchAuthSession(
              options: FetchAuthSessionOptions(forceRefresh: true),
            ) as CognitoAuthSession;
        final newToken = refreshedTokens.userPoolTokensResult.value.accessToken.raw;

        // Update the original request with new token
        err.requestOptions.headers['Authorization'] = 'Bearer $newToken';

        // Retry the original request with new token
        final dio = Dio();
        dio.options.baseUrl = err.requestOptions.baseUrl;
        dio.options.connectTimeout = err.requestOptions.connectTimeout;
        dio.options.receiveTimeout = err.requestOptions.receiveTimeout;
        dio.options.headers = err.requestOptions.headers;

        final response = await dio.fetch(err.requestOptions);
        return handler.resolve(response);
      } catch (refreshError) {
        // If refresh fails, continue with error
        return handler.next(err);
      }
    }
    return handler.next(err);
  }
}

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    return handler.next(err);
  }
}
