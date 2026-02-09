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
  bool _obscurePassword = true;
  bool _isFormValid = false;
  String? _emailError;
  String? _passwordError;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final Auth _authNotifier; // Store notifier reference to avoid using ref after dispose

  @override
  void initState() {
    super.initState();
    // Get controllers from provider and store references
    _authNotifier = ref.read(authProvider.notifier);
    _emailController = _authNotifier.emailController;
    _passwordController = _authNotifier.passwordController;

    // Don't clear errors automatically - let them persist so users can see what went wrong
    // Errors will only be cleared when user explicitly tries to login again

    // Listen to text field changes for validation
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
  }

  @override
  void dispose() {
    // Remove listeners before disposing
    _emailController.removeListener(_validateForm);
    _passwordController.removeListener(_validateForm);
    super.dispose();
  }

  String _formatErrorMessage(String error) {
    // Extract user-friendly error message
    // Remove technical details and provide clear feedback
    if (error.toLowerCase().contains('incorrect username or password') ||
        error.toLowerCase().contains('notauthorized')) {
      return 'Incorrect email or password. Please check your credentials and try again.';
    }
    if (error.toLowerCase().contains('network') ||
        error.toLowerCase().contains('connection')) {
      return 'Network error. Please check your internet connection and try again.';
    }
    if (error.toLowerCase().contains('timeout')) {
      return 'Request timed out. Please try again.';
    }
    // Return the error as-is if it's already user-friendly
    return error;
  }

  void _validateForm() {
    // Guard against calling setState after widget is disposed
    if (!mounted) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Email validation
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    String? emailError;
    if (email.isEmpty) {
      emailError = null;
    } else if (!emailRegex.hasMatch(email)) {
      emailError = 'Please enter a valid email address';
    } else {
      emailError = null;
    }

    // Password validation - matches backend Cognito policy:
    // - Minimum 8 characters
    // - Must contain digits (numbers)
    // - Must contain lowercase letters
    // - Must contain symbols (special characters)
    // - Uppercase letters are optional
    String? passwordError;
    if (password.isEmpty) {
      passwordError = null;
    } else {
      final hasMinLength = password.length >= 8;
      final hasDigits = RegExp(r'[0-9]').hasMatch(password);
      final hasLowercase = RegExp(r'[a-z]').hasMatch(password);
      // Match common special characters - use regular string to properly escape quotes
      final hasSymbols = RegExp('[!@#\$%^&*()_+\\-=\\[\\]{};\':"\\\\|,.<>\\/?]').hasMatch(password);

      if (!hasMinLength) {
        passwordError = 'Password must be at least 8 characters';
      } else if (!hasDigits) {
        passwordError = 'Password must contain at least one number';
      } else if (!hasLowercase) {
        passwordError = 'Password must contain at least one lowercase letter';
      } else if (!hasSymbols) {
        passwordError = 'Password must contain at least one special character';
      } else {
        passwordError = null;
      }
    }

    // Form is valid if email is valid and password meets all requirements
    final isEmailValid = emailRegex.hasMatch(email);
    final isPasswordValid = passwordError == null && password.isNotEmpty;
    final isValid = isEmailValid && isPasswordValid;

    // Only update state if widget is still mounted
    if (mounted) {
      setState(() {
        _emailError = emailError;
        _passwordError = passwordError;
        _isFormValid = isValid;
      });
    }
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
              child: Form(
                key: const ValueKey('login_form'),
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
                    key: const ValueKey('email_field'),
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    enabled: !authState.isLoading,
                    style: textTheme.bodyLarge,
                    onChanged: (_) => _validateForm(),
                    autofillHints: const [AutofillHints.email],
                    textInputAction: TextInputAction.next,
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
                      errorText: _emailError,
                      errorStyle: textTheme.bodySmall?.copyWith(
                        color: colors?.error,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: _emailError != null
                              ? (colors?.error ?? Colors.red)
                              : (colors?.outlineVariant ?? Colors.transparent),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: _emailError != null
                              ? (colors?.error ?? Colors.red)
                              : (colors?.outlineVariant ?? Colors.transparent),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: _emailError != null
                              ? (colors?.error ?? Colors.red)
                              : (colors?.primary ?? Colors.blue),
                          width: 2,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: colors?.error ?? Colors.red,
                          width: 2,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: colors?.error ?? Colors.red,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    key: const ValueKey('password_field'),
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    enabled: !authState.isLoading,
                    style: textTheme.bodyLarge,
                    onChanged: (_) => _validateForm(),
                    autofillHints: const [AutofillHints.password],
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: textTheme.bodyMedium?.copyWith(
                        color: colors?.onSurfaceVariant,
                      ),
                      prefixIcon: Icon(
                        Icons.lock_outlined,
                        color: colors?.onSurfaceVariant,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: colors?.onSurfaceVariant,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: colors?.surfaceContainerLowest,
                      errorText: _passwordError,
                      errorStyle: textTheme.bodySmall?.copyWith(
                        color: colors?.error,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: _passwordError != null
                              ? (colors?.error ?? Colors.red)
                              : (colors?.outlineVariant ?? Colors.transparent),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: _passwordError != null
                              ? (colors?.error ?? Colors.red)
                              : (colors?.outlineVariant ?? Colors.transparent),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: _passwordError != null
                              ? (colors?.error ?? Colors.red)
                              : (colors?.primary ?? Colors.blue),
                          width: 2,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: colors?.error ?? Colors.red,
                          width: 2,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: colors?.error ?? Colors.red,
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
                        onPressed: _isFormValid && !authState.isLoading
                            ? () async {
                                // Clear any previous errors before attempting login
                                authNotifier.clearError();
                                await authNotifier.login(context);
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isFormValid
                              ? (colors?.primary)
                              : (colors?.surfaceContainerHigh),
                          foregroundColor: _isFormValid
                              ? (colors?.onPrimary)
                              : (colors?.onSurfaceVariant),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Login',
                          style: textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: _isFormValid
                                ? (colors?.onPrimary)
                                : (colors?.onSurfaceVariant),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: colors?.onErrorContainer,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _formatErrorMessage(error.toString()),
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
                            onPressed: _isFormValid
                                ? () async {
                                    authNotifier.clearError();
                                    await authNotifier.login(context);
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isFormValid
                                  ? (colors?.primary)
                                  : (colors?.surfaceContainerHigh),
                              foregroundColor: _isFormValid
                                  ? (colors?.onPrimary)
                                  : (colors?.onSurfaceVariant),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Try Again',
                              style: textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: _isFormValid
                                    ? (colors?.onPrimary)
                                    : (colors?.onSurfaceVariant),
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
      ),
    );
  }
}
