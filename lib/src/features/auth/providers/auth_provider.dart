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
    state = const AsyncValue.loading();
    
    try {
      final result = await _service.login(
        email: emailController.text.trim(),
        password: passwordController.text,
        context: context,
      );

      if (result.success) {
        final user = await _service.getCurrentUser();
        state = AsyncValue.data(user);
      } else {
        state = AsyncValue.error(result.message ?? 'Login failed', StackTrace.current);
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
  final context = ref.read(authProvider.notifier);
  // Note: This is a simplified version - in real app, you'd pass context properly
  return null; // Will be implemented when we have proper context handling
}
