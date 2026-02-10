import 'package:flutter/widgets.dart';

class ErrorMessages {
  // Network errors
  static String networkError(BuildContext context) =>
      'Network error. Please check your connection.';
  static String serverError(BuildContext context) =>
      'Server error. Please try again later.';

  // Auth errors
  static String authError(BuildContext context) => 'Please login again.';
  static String invalidCredentials(BuildContext context) =>
      'Invalid email or password.';

  // Generic errors
  static String fetchError(BuildContext context, String resource) =>
      'Failed to fetch $resource. Please try again.';
  static String createError(BuildContext context, String resource) =>
      'Failed to create $resource. Please try again.';
  static String updateError(BuildContext context, String resource) =>
      'Failed to update $resource. Please try again.';
  static String deleteError(BuildContext context, String resource) =>
      'Failed to delete $resource. Please try again.';

  // Success messages
  static String createSuccess(BuildContext context, String resource) =>
      '$resource created successfully.';
  static String updateSuccess(BuildContext context, String resource) =>
      '$resource updated successfully.';

  // Status code mapping
  static String fromStatusCode(int? statusCode) {
    switch (statusCode) {
      case 401:
        return 'Please login again.';
      case 404:
        return 'The requested item was not found.';
      case 500:
        return 'Server error. Please try again later.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  // User-friendly error conversion
  static String userFriendly(BuildContext context, String error) {
    final lowerError = error.toLowerCase();
    if (lowerError.contains('network') || lowerError.contains('connection')) {
      return networkError(context);
    }
    if (lowerError.contains('unauthorized') || lowerError.contains('401')) {
      return authError(context);
    }
    if (lowerError.contains('server') || lowerError.contains('500')) {
      return serverError(context);
    }
    return error;
  }
}
