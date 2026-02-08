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
    final isSignedIn = await _service.isUserSignedIn();
    if (isSignedIn) {
      return await _service.getCurrentUser();
    }
    return null;
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
          // Update auth state first
          state = AsyncValue.data(user);
          
          // Ensure WhoAmI is fetched and cached before navigation
          // This ensures company ID is available for subsequent API calls
          if (context.mounted) {
            await _service.whoAmI(context);
          }
          
          // Navigation will be handled by router redirect logic
          // based on the updated auth state
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
      state = AsyncValue.error(
        e.toString(),
        stackTrace,
      );
    }
  }

  Future<void> logout(BuildContext context) async {
    await _service.logout(context);
    emailController.clear();
    passwordController.clear();
    state = const AsyncValue.data(null);
    ref.invalidate(whoAmIProvider);
  }

  void clearError() {
    if (state.hasError) {
      state = AsyncValue.data(state.value);
    }
  }
}

@riverpod
Future<WhoAmIModel?> whoAmI(WhoAmIRef ref) async {
  final authService = AuthService();
  final authState = ref.watch(authProvider);
  
  // Only fetch whoAmI if user is authenticated
  if (authState.hasValue && authState.value != null) {
    // For web, we need BuildContext - this is a simplified approach
    // In a real app, you'd handle context properly
    return null; // Will be fetched via service when context is available
  }
  return null;
}
