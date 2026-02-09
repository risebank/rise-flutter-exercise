import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:rise_flutter_exercise/src/features/auth/screens/login_screen.dart';
import 'package:rise_flutter_exercise/src/features/sales/screens/sales_invoices_list_screen.dart';
import 'package:rise_flutter_exercise/src/features/sales/screens/sales_invoice_detail_screen.dart';
import 'package:rise_flutter_exercise/src/features/auth/providers/auth_provider.dart';
import 'package:rise_flutter_exercise/src/globals/theme/rise_theme.dart';
import 'amplifyconfiguration.dart';

void main([List<String>? args, String? envFile]) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment file (defaults to .env.dev for development)
  await dotenv.load(fileName: envFile ?? '.env.dev');

  // Initialize Amplify
  await configureAmplify();

  runApp(const ProviderScope(child: MyApp()));
}

final goRouterProvider = Provider<GoRouter>((ref) {
  // Watch auth state to rebuild router when auth changes
  ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/sales-invoices',
        builder: (context, state) => const SalesInvoicesListScreen(),
      ),
      GoRoute(
        path: '/sales-invoices/:invoiceId',
        builder: (context, state) {
          final invoiceId = state.pathParameters['invoiceId']!;
          return SalesInvoiceDetailScreen(invoiceId: invoiceId);
        },
      ),
    ],
    redirect: (context, state) async {
      try {
        final isGoingToLogin = state.matchedLocation == '/login';

        // Try to read auth state, but handle gracefully if provider is rebuilding
        AsyncValue<AuthUser?>? authStateValue;
        try {
          authStateValue = ref.read(authProvider);
        } catch (e) {
          // Provider is rebuilding, allow current navigation to proceed
          debugPrint('⚠️ [Router] Auth provider rebuilding, allowing current navigation');
          return null;
        }

        // If we couldn't read auth state, allow navigation to proceed
        if (authStateValue == null) {
          debugPrint('⚠️ [Router] Auth state is null, allowing current navigation');
          return null;
        }

        debugPrint(
          '🔍 [Router] Redirect check - Auth state: isLoading=${authStateValue.isLoading}, hasValue=${authStateValue.hasValue}, hasError=${authStateValue.hasError}',
        );
        debugPrint('🔍 [Router] Current location: ${state.matchedLocation}');

        // CRITICAL: If auth state is loading (e.g., during login), don't redirect
        // This prevents blank screen during login by keeping the login screen mounted
        if (authStateValue.isLoading) {
          debugPrint(
            '⏳ [Router] Auth state is loading (login in progress), allowing current navigation',
          );
          return null; // Don't redirect while loading - keeps login screen visible
        }

        // If we're on login page and there's an error, stay on login page
        // This prevents flicker when login fails - user should see the error message
        if (isGoingToLogin && authStateValue.hasError) {
          debugPrint(
            '⏳ [Router] Login error detected, staying on login page to show error',
          );
          return null; // Stay on login page to show error
        }

        // Check if user is signed in via Amplify session (not just provider state)
        // This ensures auth persists on page reload and handles logout transitions
        // Only check session if not loading to avoid premature redirects during login
        final authNotifier = ref.read(authProvider.notifier);
        final isSignedIn = await authNotifier.isUserSignedIn();

        debugPrint(
          '🔍 [Router] Is signed in: $isSignedIn, Going to login: $isGoingToLogin',
        );
        debugPrint(
          '🔍 [Router] Auth state value: ${authStateValue.value?.userId ?? "null"}',
        );

        // Redirect to login if not authenticated and not already going to login
        if (!isSignedIn && !isGoingToLogin) {
          debugPrint('➡️ [Router] Redirecting to /login (not authenticated)');
          return '/login';
        }

        // Redirect to sales invoices if authenticated and trying to access login
        // BUT only if login is not in progress (checked above)
        if (isSignedIn && isGoingToLogin) {
          debugPrint(
            '➡️ [Router] Redirecting to /sales-invoices (authenticated, trying to access login)',
          );
          return '/sales-invoices';
        }

        // Allow navigation to proceed
        debugPrint('✅ [Router] Allowing navigation to proceed');
        return null;
      } catch (e) {
        // If there's an error reading providers (e.g., during rebuild), 
        // allow navigation to proceed - the router will retry on next rebuild
        debugPrint('⚠️ [Router] Error during redirect check: $e');
        return null;
      }
    },
  );
});

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'Rise Flutter Exercise',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark, // Default to dark mode to match rise-mobile-app
      routerConfig: router,
      // Prevent white flash during route transitions by using dark background
      builder: (context, child) {
        // Use dark theme background color (#131313) to prevent white flashes
        return Container(
          color: const Color(0xff131313), // Dark background from RiseAppColors.dark
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
