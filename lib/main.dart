import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
      // Wait for auth state to initialize (important for page reload)
      final authStateValue = ref.read(authProvider);

      debugPrint(
        '🔍 [Router] Redirect check - Auth state: isLoading=${authStateValue.isLoading}, hasValue=${authStateValue.hasValue}, hasError=${authStateValue.hasError}',
      );
      debugPrint('🔍 [Router] Current location: ${state.matchedLocation}');

      // If auth state is still loading, wait a bit and allow current navigation
      if (authStateValue.isLoading) {
        debugPrint(
          '⏳ [Router] Auth state is loading, allowing current navigation',
        );
        return null; // Don't redirect while loading
      }

      // Check if user is signed in via Amplify session (not just provider state)
      // This ensures auth persists on page reload
      final authNotifier = ref.read(authProvider.notifier);
      final isSignedIn = await authNotifier.isUserSignedIn();
      final isGoingToLogin = state.matchedLocation == '/login';

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
      if (isSignedIn && isGoingToLogin) {
        debugPrint(
          '➡️ [Router] Redirecting to /sales-invoices (authenticated, trying to access login)',
        );
        return '/sales-invoices';
      }

      // Allow navigation to proceed
      debugPrint('✅ [Router] Allowing navigation to proceed');
      return null;
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
      themeMode: ThemeMode.light, // Default to light mode for exercise
      routerConfig: router,
    );
  }
}
