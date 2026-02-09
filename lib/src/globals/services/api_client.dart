import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:rise_flutter_exercise/src/globals/services/endpoints.dart';
import 'package:rise_flutter_exercise/src/globals/services/interceptors.dart';
import 'package:rise_flutter_exercise/src/globals/services/api_response.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  final Dio _dio = Dio();

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal() {
    _dio.options.baseUrl = Endpoints.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 60);
    _dio.options.receiveTimeout = const Duration(seconds: 60);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    // Configure response type for web to handle CORS properly
    _dio.options.responseType = ResponseType.json;

    safePrint('🌐 [ApiClient] Initialized with base URL: ${Endpoints.baseUrl}');

    _dio.interceptors.addAll([AuthInterceptor(), ErrorInterceptor()]);
  }

  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    BuildContext? context,
  }) async {
    try {
      safePrint('🌐 [ApiClient] GET request starting');
      safePrint('🌐 [ApiClient] Path: $path');
      safePrint('🌐 [ApiClient] Base URL: ${_dio.options.baseUrl}');
      safePrint('🌐 [ApiClient] Full URL: ${_dio.options.baseUrl}$path');
      safePrint('🌐 [ApiClient] Query params: $queryParameters');

      safePrint('🌐 [ApiClient] Calling _dio.get()...');

      Response response;
      try {
        response = await _dio.get(
          path,
          queryParameters: queryParameters,
          options: Options(
            responseType: ResponseType.json,
            validateStatus: (status) => status != null && status < 500,
          ),
        );
      } catch (e) {
        safePrint('❌ [ApiClient] Exception during dio.get(): $e');
        rethrow;
      }

      safePrint('🌐 [ApiClient] Request completed successfully');
      safePrint('🌐 [ApiClient] Response status: ${response.statusCode}');
      safePrint('🌐 [ApiClient] Response headers: ${response.headers}');

      safePrint(
        '✅ [ApiClient] Response received - Status: ${response.statusCode}',
      );

      // Check if response data is accessible (CORS check)
      dynamic responseData;
      try {
        responseData = response.data;
        safePrint(
          '📦 [ApiClient] Response data type: ${responseData.runtimeType}',
        );

        if (responseData == null) {
          safePrint(
            '⚠️ [ApiClient] Response data is null - possible CORS issue',
          );
          // Try to get raw response as fallback
          try {
            final rawResponse = response.data as String?;
            if (rawResponse != null && rawResponse.isNotEmpty) {
              safePrint('📦 [ApiClient] Attempting to parse raw response');
              responseData = jsonDecode(rawResponse);
            }
          } catch (e) {
            safePrint('❌ [ApiClient] Failed to parse raw response: $e');
          }
        }
      } catch (e) {
        safePrint('❌ [ApiClient] Error accessing response.data: $e');
        safePrint('⚠️ [ApiClient] This may indicate a CORS issue');
        return ApiResponse.error(
          'Response data is not accessible. This may be a CORS issue. '
          'Please ensure the backend includes Access-Control-Allow-Origin header '
          'in the response headers.',
          statusCode: response.statusCode,
        );
      }

      if (responseData == null) {
        return ApiResponse.error(
          'Response data is null. This may be a CORS issue. '
          'Please check that the backend includes Access-Control-Allow-Origin header.',
          statusCode: response.statusCode,
        );
      }

      safePrint('📦 [ApiClient] Response data: $responseData');

      return ApiResponse.success(
        responseData as T,
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      safePrint(
        '❌ [ApiClient] DioException - Status: ${e.response?.statusCode}',
      );
      safePrint('❌ [ApiClient] Error type: ${e.type}');
      safePrint('❌ [ApiClient] Error message: ${e.message}');
      safePrint('❌ [ApiClient] Error response: ${e.response?.data}');

      // Check for CORS-related errors
      if (e.type == DioExceptionType.unknown ||
          e.type == DioExceptionType.badResponse) {
        if (e.message?.contains('CORS') == true ||
            e.message?.contains('Access-Control') == true ||
            e.response?.statusCode == null) {
          safePrint('⚠️ [ApiClient] Possible CORS issue detected');
          return ApiResponse.error(
            'CORS error: The response was received but cannot be accessed. '
            'Please ensure the backend includes Access-Control-Allow-Origin header.',
            statusCode: e.response?.statusCode,
          );
        }
      }

      String errorMessage = 'Request failed';

      if (e.response != null) {
        final responseData = e.response!.data;

        // Handle different error response formats
        if (responseData is Map<String, dynamic>) {
          // Try 'error' field first (common in API responses)
          errorMessage =
              responseData['error'] as String? ??
              responseData['message'] as String? ??
              responseData['debug'] as String? ??
              e.message ??
              'Request failed';
        } else if (responseData is String) {
          errorMessage = responseData;
        } else {
          errorMessage = e.message ?? 'Request failed';
        }
      } else {
        errorMessage = e.message ?? 'Request failed';
      }

      return ApiResponse.error(
        errorMessage,
        statusCode: e.response?.statusCode,
      );
    } catch (e, stackTrace) {
      safePrint('❌ [ApiClient] Unexpected error: $e');
      safePrint('❌ [ApiClient] Stack trace: $stackTrace');
      return ApiResponse.error('Unexpected error: ${e.toString()}');
    }
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    BuildContext? context,
  }) async {
    try {
      final response = await _dio.post(path, data: data);

      return ApiResponse.success(
        response.data as T,
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      String errorMessage = 'Request failed';

      if (e.response != null) {
        final responseData = e.response!.data;

        if (responseData is Map<String, dynamic>) {
          errorMessage =
              responseData['error'] as String? ??
              responseData['message'] as String? ??
              responseData['debug'] as String? ??
              e.message ??
              'Request failed';
        } else if (responseData is String) {
          errorMessage = responseData;
        } else {
          errorMessage = e.message ?? 'Request failed';
        }
      } else {
        errorMessage = e.message ?? 'Request failed';
      }

      return ApiResponse.error(
        errorMessage,
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Unexpected error: ${e.toString()}');
    }
  }

  Future<ApiResponse<T>> patch<T>(
    String path, {
    dynamic data,
    BuildContext? context,
  }) async {
    try {
      final response = await _dio.patch(path, data: data);

      return ApiResponse.success(
        response.data as T,
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      String errorMessage = 'Request failed';

      if (e.response != null) {
        final responseData = e.response!.data;

        if (responseData is Map<String, dynamic>) {
          errorMessage =
              responseData['error'] as String? ??
              responseData['message'] as String? ??
              responseData['debug'] as String? ??
              e.message ??
              'Request failed';
        } else if (responseData is String) {
          errorMessage = responseData;
        } else {
          errorMessage = e.message ?? 'Request failed';
        }
      } else {
        errorMessage = e.message ?? 'Request failed';
      }

      return ApiResponse.error(
        errorMessage,
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Unexpected error: ${e.toString()}');
    }
  }

  Future<ApiResponse<T>> delete<T>(String path, {BuildContext? context}) async {
    try {
      final response = await _dio.delete(path);

      return ApiResponse.success(
        response.data as T,
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      String errorMessage = 'Request failed';

      if (e.response != null) {
        final responseData = e.response!.data;

        // Handle different error response formats
        if (responseData is Map<String, dynamic>) {
          errorMessage =
              responseData['error'] as String? ??
              responseData['message'] as String? ??
              responseData['debug'] as String? ??
              e.message ??
              'Request failed';
        } else if (responseData is String) {
          errorMessage = responseData;
        } else {
          errorMessage = e.message ?? 'Request failed';
        }
      } else {
        errorMessage = e.message ?? 'Request failed';
      }

      return ApiResponse.error(
        errorMessage,
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Unexpected error: ${e.toString()}');
    }
  }
}
