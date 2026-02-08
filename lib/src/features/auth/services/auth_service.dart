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

      if (result.nextStep.signInStep == AuthSignInStep.done) {
        // Fetch user info after successful login
        if (context.mounted) {
          await _fetchAndSaveWhoAmI(context);
        }
      }

      return ApiResponse.success(result);
    } catch (e) {
      final errorMessage = _parseAmplifyError(context, e);
      return ApiResponse.error(errorMessage);
    }
  }

  Future<ApiResponse<SignOutResult>> logout(BuildContext context) async {
    try {
      final result = await Amplify.Auth.signOut();
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
    final result = await Amplify.Auth.fetchAuthSession();
    return result.isSignedIn;
  }

  Future<ApiResponse<WhoAmIModel>> whoAmI(BuildContext context) async {
    final isSignedIn = await isUserSignedIn();

    if (!isSignedIn) {
      return ApiResponse.error(ErrorMessages.authError(context));
    }

    final response = await _apiClient.get(Endpoints.whoami, context: context);
    return ApiResponse.fromApiClientResponse(
      context,
      response,
      parser: (json) => WhoAmIModel.fromJson(json as Map<String, dynamic>),
      errorMessage: ErrorMessages.fetchError(context, 'user info'),
    );
  }

  Future<void> _fetchAndSaveWhoAmI(BuildContext context) async {
    try {
      final whoAmIResponse = await whoAmI(context);
      if (whoAmIResponse.success && whoAmIResponse.data != null) {
        // Store user info if needed (can use Hive or shared preferences)
        // For now, we'll just fetch it when needed
      }
    } catch (e) {
      safePrint('Failed to fetch and save WhoAmI data: $e');
    }
  }

  String _parseAmplifyError(BuildContext context, dynamic error) {
    if (error is AuthException) {
      final errorMessage = error.message;
      if (errorMessage.isNotEmpty) {
        return ErrorMessages.userFriendly(context, errorMessage);
      }
      return ErrorMessages.userFriendly(context, error.toString());
    }
    return ErrorMessages.userFriendly(context, error.toString());
  }
}
