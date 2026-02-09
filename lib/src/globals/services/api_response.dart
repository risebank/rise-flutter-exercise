import 'package:flutter/widgets.dart';
import 'package:amplify_flutter/amplify_flutter.dart';

class ApiResponse<T> {
  final T? data;
  final String? message;
  final bool success;
  final int? statusCode;

  ApiResponse({this.data, this.message, this.success = true, this.statusCode});

  factory ApiResponse.success(T data, {String? message, int? statusCode}) {
    return ApiResponse(
      data: data,
      message: message,
      success: true,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.error(String message, {int? statusCode}) {
    return ApiResponse(
      message: message,
      success: false,
      statusCode: statusCode,
    );
  }

  /// Factory method to handle common API response pattern
  static ApiResponse<T> fromApiClientResponse<T>(
    BuildContext context,
    dynamic clientResponse, {
    required T Function(dynamic json) parser,
    String? errorMessage,
  }) {
    try {
      if (clientResponse is ApiResponse) {
        // If it's already an ApiResponse, check if it's successful
        if (clientResponse.success && clientResponse.data != null) {
          try {
            final parsedData = parser(clientResponse.data as dynamic);
            return ApiResponse.success(
              parsedData,
              statusCode: clientResponse.statusCode,
            );
          } catch (e) {
            safePrint('❌ [ApiResponse] Failed to parse data: $e');
            return ApiResponse.error(
              errorMessage ?? 'Failed to parse response: ${e.toString()}',
              statusCode: clientResponse.statusCode,
            );
          }
        } else {
          return ApiResponse.error(
            clientResponse.message ?? errorMessage ?? 'Request failed',
            statusCode: clientResponse.statusCode,
          );
        }
      }

      if (clientResponse is Map<String, dynamic>) {
        final success = clientResponse['success'] as bool? ?? false;
        final data = clientResponse['data'];
        final message = clientResponse['message'] as String?;

        if (!success || data == null) {
          return ApiResponse.error(
            message ?? errorMessage ?? 'Request failed',
            statusCode: clientResponse['statusCode'] as int?,
          );
        }

        final parsedData = parser(data);
        return ApiResponse.success(parsedData, message: message);
      }

      // Fallback: treat as direct data
      final parsedData = parser(clientResponse);
      return ApiResponse.success(parsedData);
    } catch (e) {
      safePrint('❌ [ApiResponse] Exception during processing: $e');
      return ApiResponse.error(
        errorMessage ?? 'Failed to process response: ${e.toString()}',
      );
    }
  }
}
