import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rise_flutter_exercise/src/features/auth/services/auth_service.dart';
import 'package:rise_flutter_exercise/src/features/auth/models/who_am_i_model.dart';
import 'package:amplify_flutter/amplify_flutter.dart';

part 'auth_provider.g.dart';

@riverpod
class Auth extends _$Auth {
  late final AuthService _service;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Future<AuthUser?> build() async {
    _service = AuthService();
    // Just return getCurrentUser() - it will return null if not signed in
    // This ensures auth state persists on page reload
    // Note: This build method only runs on provider initialization or explicit invalidation
    // Error states set via login() will persist until explicitly cleared

    // First check if user is signed in via Amplify session
    final isSignedIn = await _service.isUserSignedIn();

    if (!isSignedIn) {
      return null;
    }

    // If signed in, get the user
    final user = await _service.getCurrentUser();
    if (user == null) {
      safePrint('⚠️ [AuthProvider] Session exists but user retrieval failed');
    }
    return user;
  }

  Future<void> login(BuildContext context) async {
    // Prevent multiple simultaneous login attempts
    if (state.isLoading) return;

    state = const AsyncValue.loading();

    try {
      final result = await _service.login(
        email: emailController.text.trim(),
        password: passwordController.text,
        context: context,
      );

      if (result.success) {
        // Wait for user to be available before updating state
        final user = await _service.getCurrentUser();

        if (user != null) {
          // WhoAmI is already fetched and cached in AuthService.login()
          // via _fetchAndSaveWhoAmI(), so we don't need to fetch it again here
          // Just verify it's cached
          final companyId = _service.getCurrentCompanyId();
          if (companyId == null || companyId.isEmpty) {
            // If not cached, fetch it now
            if (context.mounted) {
              final whoAmIResponse = await _service.whoAmI(context);
              if (!whoAmIResponse.success) {
                state = AsyncValue.error(
                  'Failed to fetch user company information: ${whoAmIResponse.message}',
                  StackTrace.current,
                );
                return;
              }
            }
          }

          // Update auth state - this will trigger router rebuild and redirect
          // No delay needed - router will handle redirect on next rebuild cycle
          state = AsyncValue.data(user);
        } else {
          state = AsyncValue.error(
            'Failed to retrieve user information after login',
            StackTrace.current,
          );
        }
      } else {
        state = AsyncValue.error(
          result.message ?? 'Login failed',
          StackTrace.current,
        );
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e.toString(), stackTrace);
    }
  }

  Future<void> logout(BuildContext context) async {
    await _service.logout(context);
    emailController.clear();
    passwordController.clear();
    state = const AsyncValue.data(null);
    // Note: whoAmIProvider automatically rebuilds when authProvider changes
    // because it watches authProvider, so no need to invalidate manually
    // Invalidating here would cause CircularDependencyError
  }

  void clearError() {
    if (state.hasError) {
      state = AsyncValue.data(state.value);
    }
  }

  /// Check if user is currently signed in
  /// This checks Amplify session directly (not provider state) to work correctly on page reload
  Future<bool> isUserSignedIn() async {
    try {
      // Check Amplify session directly - don't rely on provider state
      // This ensures it works correctly on page reload when provider state might not be initialized yet
      return await _service.isUserSignedIn();
    } catch (e) {
      safePrint('❌ [AuthProvider.isUserSignedIn] Error: $e');
      return false;
    }
  }
}

@riverpod
Future<WhoAmIModel?> whoAmI(WhoAmIRef ref) async {
  final authState = ref.watch(authProvider);

  // Only fetch whoAmI if user is authenticated
  if (authState.hasValue && authState.value != null) {
    // For web, we need BuildContext - this is a simplified approach
    // In a real app, you'd handle context properly
    return null; // Will be fetched via service when context is available
  }
  return null;
}
