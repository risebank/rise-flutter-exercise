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

      safePrint(
        '🔍 [AuthInterceptor] Session check - isSignedIn: ${session.isSignedIn}',
      );

      if (session.isSignedIn) {
        // Fetch tokens with proper type casting
        final cognitoSession =
            await Amplify.Auth.fetchAuthSession(
                  options: FetchAuthSessionOptions(forceRefresh: false),
                )
                as CognitoAuthSession;

        final tokens = cognitoSession.userPoolTokensResult.value;
        final token = tokens.accessToken.raw;

        safePrint(
          '✅ [AuthInterceptor] Token attached to request: ${options.path}',
        );
        options.headers['Authorization'] = 'Bearer $token';
      } else {
        safePrint(
          '⚠️ [AuthInterceptor] User not signed in, skipping token attachment',
        );
      }
    } catch (e) {
      safePrint('❌ [AuthInterceptor] Error attaching token: $e');
      // Log error but continue with request - let API handle auth errors
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    safePrint(
      '❌ [AuthInterceptor] Error: ${err.response?.statusCode} - ${err.requestOptions.path}',
    );

    if (err.response?.statusCode == 401 || err.response?.statusCode == 403) {
      safePrint(
        '🔄 [AuthInterceptor] Attempting token refresh for 401/403 error',
      );

      // Token might be expired, try to refresh
      try {
        final refreshedSession =
            await Amplify.Auth.fetchAuthSession(
                  options: FetchAuthSessionOptions(forceRefresh: true),
                )
                as CognitoAuthSession;

        final tokens = refreshedSession.userPoolTokensResult.value;
        final newToken = tokens.accessToken.raw;

        safePrint('✅ [AuthInterceptor] Token refreshed, retrying request');

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
        safePrint('✅ [AuthInterceptor] Retry successful');
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
    safePrint('📤 [ErrorInterceptor] Request initiated');
    safePrint('📤 [ErrorInterceptor] Method: ${options.method}');
    safePrint('📤 [ErrorInterceptor] Path: ${options.path}');
    safePrint('📤 [ErrorInterceptor] Full URL: ${options.uri}');
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    safePrint('✅ [ErrorInterceptor] Response received');
    safePrint('✅ [ErrorInterceptor] Status: ${response.statusCode}');
    safePrint('✅ [ErrorInterceptor] Path: ${response.requestOptions.path}');
    
    // Check for CORS headers
    final corsHeader = response.headers.value('access-control-allow-origin');
    safePrint('✅ [ErrorInterceptor] CORS header: $corsHeader');
    
    try {
      safePrint('✅ [ErrorInterceptor] Data type: ${response.data.runtimeType}');
      if (response.data == null) {
        safePrint('⚠️ [ErrorInterceptor] Response data is null - possible CORS issue');
      }
    } catch (e) {
      safePrint('❌ [ErrorInterceptor] Error accessing response data: $e');
      safePrint('⚠️ [ErrorInterceptor] This may indicate a CORS issue');
    }
    
    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    safePrint('❌ [ErrorInterceptor] Request failed');
    safePrint('❌ [ErrorInterceptor] Path: ${err.requestOptions.path}');
    safePrint('❌ [ErrorInterceptor] Method: ${err.requestOptions.method}');
    safePrint('❌ [ErrorInterceptor] Status Code: ${err.response?.statusCode}');
    safePrint('❌ [ErrorInterceptor] Error Type: ${err.type}');
    safePrint('❌ [ErrorInterceptor] Error Message: ${err.message}');

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

    if (err.response != null) {
      safePrint('❌ [ErrorInterceptor] Response Data: ${err.response!.data}');
      safePrint(
        '❌ [ErrorInterceptor] Response Headers: ${err.response!.headers}',
      );
      
      // Check for CORS headers in response
      final corsHeaders = {
        'access-control-allow-origin': err.response!.headers.value('access-control-allow-origin'),
        'access-control-allow-headers': err.response!.headers.value('access-control-allow-headers'),
        'access-control-allow-methods': err.response!.headers.value('access-control-allow-methods'),
      };
      
      if (corsHeaders.values.any((h) => h != null)) {
        safePrint('📋 [ErrorInterceptor] CORS headers present: $corsHeaders');
        
        // Check if Authorization header is explicitly allowed
        final allowHeaders = corsHeaders['access-control-allow-headers']?.toLowerCase() ?? '';
        if (allowHeaders == '*' || allowHeaders.contains('authorization')) {
          safePrint('✅ [ErrorInterceptor] Authorization header is allowed');
        } else {
          safePrint(
            '⚠️ [ErrorInterceptor] Authorization header may not be explicitly allowed. '
            'Backend should include "Authorization" in Access-Control-Allow-Headers.',
          );
        }
      } else {
        safePrint('⚠️ [ErrorInterceptor] No CORS headers found in response');
      }
    } else {
      safePrint('❌ [ErrorInterceptor] No response received (network error?)');
    }

    return handler.next(err);
  }
}
