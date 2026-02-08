import 'package:flutter/widgets.dart';

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
      return ApiResponse.error(
        errorMessage ?? 'Failed to process response: ${e.toString()}',
      );
    }
  }
}
