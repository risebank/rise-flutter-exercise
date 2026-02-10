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
      // Check if user is signed in
      final session = await Amplify.Auth.fetchAuthSession();

      if (session.isSignedIn) {
        // Fetch tokens with proper type casting
        final cognitoSession = await Amplify.Auth.fetchAuthSession(
          options: FetchAuthSessionOptions(forceRefresh: false),
        ) as CognitoAuthSession;

        final tokens = cognitoSession.userPoolTokensResult.value;
        final token = tokens.accessToken.raw;

        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (e) {
      safePrint('❌ [AuthInterceptor] Error attaching token: $e');
      // Log error but continue with request - let API handle auth errors
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 || err.response?.statusCode == 403) {
      // Token might be expired, try to refresh
      try {
        final refreshedSession = await Amplify.Auth.fetchAuthSession(
          options: FetchAuthSessionOptions(forceRefresh: true),
        ) as CognitoAuthSession;

        final tokens = refreshedSession.userPoolTokensResult.value;
        final newToken = tokens.accessToken.raw;

        // Update the original request with new token
        err.requestOptions.headers['Authorization'] = 'Bearer $newToken';

        // Retry the original request with new token
        final dio = Dio();
        dio.options.baseUrl = err.requestOptions.baseUrl;
        dio.options.connectTimeout = err.requestOptions.connectTimeout;
        dio.options.receiveTimeout = err.requestOptions.receiveTimeout;
        dio.options.headers = err.requestOptions.headers;

        // Add interceptors to the retry dio instance
        dio.interceptors.addAll([AuthInterceptor(), ErrorInterceptor()]);

        final response = await dio.fetch(err.requestOptions);
        return handler.resolve(response);
      } catch (refreshError) {
        safePrint('❌ [AuthInterceptor] Token refresh failed: $refreshError');
        // If refresh fails, continue with error
        return handler.next(err);
      }
    }
    return handler.next(err);
  }
}

class ErrorInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Check for CORS issues
    try {
      if (response.data == null) {
        safePrint(
          '⚠️ [ErrorInterceptor] Response data is null - possible CORS issue',
        );
      }
    } catch (e) {
      safePrint('❌ [ErrorInterceptor] Error accessing response data: $e');
      safePrint('⚠️ [ErrorInterceptor] This may indicate a CORS issue');
    }

    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Check for CORS-related errors
    final isCorsError = err.type == DioExceptionType.unknown ||
        (err.response == null && err.type != DioExceptionType.cancel) ||
        err.message?.toLowerCase().contains('cors') == true ||
        err.message?.toLowerCase().contains('access-control') == true;

    if (isCorsError) {
      safePrint('⚠️ [ErrorInterceptor] CORS error detected');
      safePrint(
        '⚠️ [ErrorInterceptor] This may be due to missing or incorrect '
        'Access-Control-Allow-Headers in the backend response. '
        'The Authorization header must be explicitly listed.',
      );
    }

    // Log error details for debugging
    safePrint(
      '❌ [ErrorInterceptor] Request failed: ${err.requestOptions.method} '
      '${err.requestOptions.path} - ${err.response?.statusCode ?? err.type}',
    );

    return handler.next(err);
  }
}
