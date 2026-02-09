import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rise_flutter_exercise/src/features/auth/providers/auth_provider.dart';
import 'package:rise_flutter_exercise/src/globals/theme/rise_theme.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  @override
  void initState() {
    super.initState();
    // Clear any previous error state when entering the screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).clearError();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);
    final theme = Theme.of(context);
    final riseTheme = theme.extension<RiseAppThemeExtension>();
    final colors = riseTheme?.config.colors;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colors?.background,
      appBar: AppBar(
        title: Text(
          'Login',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: colors?.surfaceContainerLowest,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Rise Flutter Exercise',
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors?.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to continue',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors?.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  TextField(
                    controller: authNotifier.emailController,
                    keyboardType: TextInputType.emailAddress,
                    enabled: !authState.isLoading,
                    style: textTheme.bodyLarge,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: textTheme.bodyMedium?.copyWith(
                        color: colors?.onSurfaceVariant,
                      ),
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: colors?.onSurfaceVariant,
                      ),
                      filled: true,
                      fillColor: colors?.surfaceContainerLowest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: colors?.outlineVariant ?? Colors.transparent,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: colors?.outlineVariant ?? Colors.transparent,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: colors?.primary ?? Colors.blue,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: authNotifier.passwordController,
                    obscureText: true,
                    enabled: !authState.isLoading,
                    style: textTheme.bodyLarge,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: textTheme.bodyMedium?.copyWith(
                        color: colors?.onSurfaceVariant,
                      ),
                      prefixIcon: Icon(
                        Icons.lock_outlined,
                        color: colors?.onSurfaceVariant,
                      ),
                      filled: true,
                      fillColor: colors?.surfaceContainerLowest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: colors?.outlineVariant ?? Colors.transparent,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: colors?.outlineVariant ?? Colors.transparent,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: colors?.primary ?? Colors.blue,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  authState.when(
                    data: (_) => SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () async {
                          await authNotifier.login(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors?.primary,
                          foregroundColor: colors?.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Login',
                          style: textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colors?.onPrimary,
                          ),
                        ),
                      ),
                    ),
                    loading: () => SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors?.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colors?.onPrimary ?? (colors?.primary ?? Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                    error: (error, _) => Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colors?.errorContainer,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: colors?.error ?? Colors.transparent,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: colors?.onErrorContainer,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  error.toString(),
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colors?.onErrorContainer,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () async {
                              authNotifier.clearError();
                              await authNotifier.login(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colors?.primary,
                              foregroundColor: colors?.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Try Again',
                              style: textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colors?.onPrimary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
