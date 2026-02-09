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
      safePrint(
        '🔄 [ApiResponse] Processing response - Type: ${clientResponse.runtimeType}',
      );

      if (clientResponse is ApiResponse) {
        safePrint(
          '📦 [ApiResponse] Received ApiResponse wrapper - success: ${clientResponse.success}',
        );
        safePrint('📦 [ApiResponse] Has data: ${clientResponse.data != null}');
        safePrint(
          '📦 [ApiResponse] Data type: ${clientResponse.data?.runtimeType}',
        );
        safePrint('📦 [ApiResponse] Data: ${clientResponse.data}');

        // If it's already an ApiResponse, check if it's successful
        if (clientResponse.success && clientResponse.data != null) {
          safePrint('✅ [ApiResponse] Already wrapped ApiResponse with data');
          try {
            safePrint('🔄 [ApiResponse] Parsing data: ${clientResponse.data}');
            final parsedData = parser(clientResponse.data as dynamic);
            safePrint('✅ [ApiResponse] Successfully parsed data');
            return ApiResponse.success(
              parsedData,
              statusCode: clientResponse.statusCode,
            );
          } catch (e, stackTrace) {
            safePrint('❌ [ApiResponse] Failed to parse data: $e');
            safePrint('❌ [ApiResponse] Stack trace: $stackTrace');
            return ApiResponse.error(
              errorMessage ?? 'Failed to parse response: ${e.toString()}',
              statusCode: clientResponse.statusCode,
            );
          }
        } else {
          safePrint(
            '❌ [ApiResponse] ApiResponse indicates failure: ${clientResponse.message}',
          );
          return ApiResponse.error(
            clientResponse.message ?? errorMessage ?? 'Request failed',
            statusCode: clientResponse.statusCode,
          );
        }
      }

      if (clientResponse is Map<String, dynamic>) {
        safePrint(
          '📋 [ApiResponse] Response is Map, checking for wrapped format',
        );
        final success = clientResponse['success'] as bool? ?? false;
        final data = clientResponse['data'];
        final message = clientResponse['message'] as String?;

        safePrint(
          '📋 [ApiResponse] Wrapped format - success: $success, hasData: ${data != null}',
        );

        if (!success || data == null) {
          safePrint('❌ [ApiResponse] Wrapped format indicates failure');
          return ApiResponse.error(
            message ?? errorMessage ?? 'Request failed',
            statusCode: clientResponse['statusCode'] as int?,
          );
        }

        safePrint('✅ [ApiResponse] Parsing wrapped data');
        final parsedData = parser(data);
        return ApiResponse.success(parsedData, message: message);
      }

      // Fallback: treat as direct data
      safePrint('📦 [ApiResponse] Treating as direct data');
      final parsedData = parser(clientResponse);
      safePrint('✅ [ApiResponse] Successfully parsed direct data');
      return ApiResponse.success(parsedData);
    } catch (e, stackTrace) {
      safePrint('❌ [ApiResponse] Exception during processing: $e');
      safePrint('❌ [ApiResponse] Stack trace: $stackTrace');
      return ApiResponse.error(
        errorMessage ?? 'Failed to process response: ${e.toString()}',
      );
    }
  }
}
