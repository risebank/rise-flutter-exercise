import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:rise_flutter_exercise/src/globals/services/api_response.dart';
import 'package:rise_flutter_exercise/src/globals/services/api_client.dart';
import 'package:rise_flutter_exercise/src/globals/services/endpoints.dart';
import 'package:rise_flutter_exercise/src/features/auth/models/who_am_i_model.dart';
import 'package:rise_flutter_exercise/src/globals/utils/error_messages.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  Future<ApiResponse<SignInResult>> login({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      final result = await Amplify.Auth.signIn(
        username: email,
        password: password,
      );

      // Handle different sign-in steps
      if (result.nextStep.signInStep == AuthSignInStep.done) {
        // Login is complete - fetch WhoAmI data immediately
        // This ensures company ID is available for subsequent API calls
        if (context.mounted) {
          await _fetchAndSaveWhoAmI(context);
        }
      } else {
        // Handle other sign-in steps (MFA, password reset, etc.)
        // For this exercise, we only support simple login
        return ApiResponse.error(
          'Additional authentication steps required. This exercise only supports simple login.',
        );
      }

      return ApiResponse.success(result);
    } catch (e, stackTrace) {
      safePrint('❌ [AuthService.login] Login error: $e');
      safePrint('❌ [AuthService.login] Stack trace: $stackTrace');
      if (e is AuthException) {
        safePrint('❌ [AuthService.login] AuthException details:');
        safePrint('   - Message: ${e.message}');
        safePrint('   - UnderlyingException: ${e.underlyingException}');
        safePrint('   - RecoverySuggestion: ${e.recoverySuggestion}');
      }
      final errorMessage = _parseAmplifyError(context, e);
      return ApiResponse.error(errorMessage);
    }
  }

  Future<ApiResponse<SignOutResult>> logout(BuildContext context) async {
    try {
      final result = await Amplify.Auth.signOut();

      // Clear cached WhoAmI data on logout
      _cachedWhoAmI = null;
      safePrint('WhoAmI cache cleared on logout');

      return ApiResponse.success(result);
    } catch (e) {
      final errorMessage = _parseAmplifyError(context, e);
      return ApiResponse.error(errorMessage);
    }
  }

  Future<AuthUser?> getCurrentUser() async {
    try {
      final user = await Amplify.Auth.getCurrentUser();
      return user;
    } on AuthException {
      return null;
    }
  }

  Future<bool> isUserSignedIn() async {
    try {
      final result = await Amplify.Auth.fetchAuthSession();
      final isSignedIn = result.isSignedIn;
      safePrint('🔍 [AuthService.isUserSignedIn] Session check: $isSignedIn');
      return isSignedIn;
    } catch (e) {
      safePrint('❌ [AuthService.isUserSignedIn] Error: $e');
      return false;
    }
  }

  Future<ApiResponse<WhoAmIModel>> whoAmI(BuildContext context) async {
    final isSignedIn = await isUserSignedIn();

    if (!isSignedIn) {
      return ApiResponse.error(ErrorMessages.authError(context));
    }

    // Check cache first - if we have valid cached data, return it
    if (_cachedWhoAmI != null && _cachedWhoAmI!.companyId != null) {
      safePrint(
        'Using cached WhoAmI data. Company ID: ${_cachedWhoAmI!.companyId}',
      );
      return ApiResponse.success(_cachedWhoAmI!);
    }

    try {
      // The /me endpoint returns data directly: { user: {...}, permissions: [...] }
      safePrint('Fetching WhoAmI from API...');
      final response = await _apiClient.get<Map<String, dynamic>>(
        Endpoints.whoami,
        context: context,
      );

      // Check if API call was successful
      if (!response.success) {
        safePrint('WhoAmI API call failed: ${response.message}');
        return ApiResponse.error(
          response.message ?? ErrorMessages.fetchError(context, 'user info'),
          statusCode: response.statusCode,
        );
      }

      // Parse the response data directly (backend returns data, not wrapped)
      if (response.data == null) {
        safePrint('WhoAmI API returned null data');
        return ApiResponse.error(
          ErrorMessages.fetchError(context, 'user info'),
          statusCode: response.statusCode,
        );
      }

      safePrint(
        'WhoAmI API response received. Data keys: ${response.data!.keys}',
      );

      try {
        // Parse WhoAmI model from the response data
        // The API returns: { user: {...}, permissions: [...] }
        safePrint('Parsing WhoAmI response...');
        safePrint('Response data structure: ${response.data!.keys}');

        final whoAmI = WhoAmIModel.fromJson(response.data!);

        // Validate that we have permissions with company IDs
        if (whoAmI.permissions.isEmpty) {
          safePrint('WARNING: WhoAmI response has no permissions');
          safePrint('Response data: ${response.data}');
          return ApiResponse.error(
            'User has no company permissions',
            statusCode: response.statusCode,
          );
        }

        final companyId = whoAmI.companyId;
        safePrint('🔍 [AuthService] Extracted companyId: $companyId');
        safePrint('🔍 [AuthService] CompanyId type: ${companyId.runtimeType}');
        safePrint(
          '🔍 [AuthService] CompanyId length: ${companyId?.length ?? 0}',
        );

        if (companyId == null || companyId.isEmpty) {
          safePrint('❌ WARNING: Could not extract company ID from WhoAmI');
          safePrint('Permissions: ${whoAmI.permissions}');
          if (whoAmI.permissions.isNotEmpty) {
            final firstPerm = whoAmI.permissions.first;
            safePrint('First permission: ${firstPerm.toJson()}');
            safePrint('First permission companyId: ${firstPerm.companyId}');
            safePrint(
              'First permission companyId type: ${firstPerm.companyId.runtimeType}',
            );
            safePrint(
              'First permission companyId length: ${firstPerm.companyId.length}',
            );
          }
          return ApiResponse.error(
            'Could not determine company ID',
            statusCode: response.statusCode,
          );
        }

        // Cache the WhoAmI data for future use
        _cachedWhoAmI = whoAmI;
        safePrint('✅ WhoAmI cached successfully. Company ID: $companyId');
        safePrint(
          '✅ Company ID verification - Length: ${companyId.length}, Value: $companyId',
        );
        safePrint(
          'User: ${whoAmI.user.email}, Permissions count: ${whoAmI.permissions.length}',
        );

        return ApiResponse.success(whoAmI, statusCode: response.statusCode);
      } catch (e, stackTrace) {
        safePrint('Failed to parse WhoAmI response: $e');
        safePrint('Stack trace: $stackTrace');
        safePrint('Response data: ${response.data}');
        safePrint('Response data type: ${response.data.runtimeType}');
        return ApiResponse.error(
          'Failed to parse user information: ${e.toString()}',
          statusCode: response.statusCode,
        );
      }
    } catch (e, stackTrace) {
      safePrint('WhoAmI request failed: $e');
      safePrint('Stack trace: $stackTrace');
      return ApiResponse.error(ErrorMessages.fetchError(context, 'user info'));
    }
  }

  Future<void> _fetchAndSaveWhoAmI(BuildContext context) async {
    try {
      final whoAmIResponse = await whoAmI(context);
      if (whoAmIResponse.success && whoAmIResponse.data != null) {
        // Store user info - for exercise, we'll use a simple in-memory cache
        // In production app, this would use Hive or shared preferences
        _cachedWhoAmI = whoAmIResponse.data;
        safePrint(
          'WhoAmI data cached successfully. Company ID: ${_cachedWhoAmI?.companyId}',
        );
      } else {
        safePrint('Failed to fetch WhoAmI: ${whoAmIResponse.message}');
      }
    } catch (e) {
      safePrint('Failed to fetch and save WhoAmI data: $e');
      rethrow; // Re-throw to allow caller to handle the error
    }
  }

  // Simple in-memory cache for exercise (in production, use Hive)
  static WhoAmIModel? _cachedWhoAmI;

  WhoAmIModel? get cachedWhoAmI => _cachedWhoAmI;

  String? getCurrentCompanyId() {
    return _cachedWhoAmI?.companyId;
  }

  String _parseAmplifyError(BuildContext context, dynamic error) {
    if (error is AuthException) {
      final errorMessage = error.message;
      final underlyingException = error.underlyingException?.toString() ?? '';
      
      // Log detailed error information
      safePrint('🔍 [AuthService._parseAmplifyError] Parsing AuthException:');
      safePrint('   - Message: $errorMessage');
      safePrint('   - UnderlyingException: $underlyingException');
      safePrint('   - RecoverySuggestion: ${error.recoverySuggestion}');
      
      // Return the most informative error message
      if (errorMessage.isNotEmpty) {
        // Include underlying exception if it provides more context
        if (underlyingException.isNotEmpty && 
            !underlyingException.toLowerCase().contains(errorMessage.toLowerCase())) {
          return '$errorMessage ($underlyingException)';
        }
        return errorMessage;
      }
      
      // Fallback to underlying exception if message is empty
      if (underlyingException.isNotEmpty) {
        return underlyingException;
      }
      
      return ErrorMessages.userFriendly(context, error.toString());
    }
    
    // For non-AuthException errors, return the error string
    final errorString = error.toString();
    safePrint('🔍 [AuthService._parseAmplifyError] Non-AuthException error: $errorString');
    return ErrorMessages.userFriendly(context, errorString);
  }
}
