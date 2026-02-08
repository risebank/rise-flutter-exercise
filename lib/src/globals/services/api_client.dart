import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
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

    _dio.interceptors.addAll([AuthInterceptor(), ErrorInterceptor()]);
  }

  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    BuildContext? context,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
      );

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
          // Try 'error' field first (common in API responses)
          errorMessage = responseData['error'] as String? ?? 
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

  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    BuildContext? context,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
      );

      return ApiResponse.success(
        response.data as T,
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      String errorMessage = 'Request failed';
      
      if (e.response != null) {
        final responseData = e.response!.data;
        
        if (responseData is Map<String, dynamic>) {
          errorMessage = responseData['error'] as String? ?? 
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
      final response = await _dio.patch(
        path,
        data: data,
      );

      return ApiResponse.success(
        response.data as T,
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      String errorMessage = 'Request failed';
      
      if (e.response != null) {
        final responseData = e.response!.data;
        
        if (responseData is Map<String, dynamic>) {
          errorMessage = responseData['error'] as String? ?? 
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

  Future<ApiResponse<T>> delete<T>(
    String path, {
    BuildContext? context,
  }) async {
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
          errorMessage = responseData['error'] as String? ?? 
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
