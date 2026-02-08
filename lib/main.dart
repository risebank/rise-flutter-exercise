import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rise_flutter_exercise/src/features/auth/screens/login_screen.dart';
import 'package:rise_flutter_exercise/src/features/sales/screens/sales_invoices_list_screen.dart';
import 'package:rise_flutter_exercise/src/features/sales/screens/sales_invoice_detail_screen.dart';
import 'package:rise_flutter_exercise/src/features/auth/providers/auth_provider.dart';
import 'amplifyconfiguration.dart';

void main([List<String>? args, String? envFile]) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment file (defaults to .env.dev for development)
  await dotenv.load(fileName: envFile ?? '.env.dev');

  // Initialize Amplify
  await configureAmplify();

  runApp(const ProviderScope(child: MyApp()));
}

final _router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
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
  redirect: (context, state) {
    final authState = ProviderScope.containerOf(context).read(authProvider);
    
    // Check if user is logged in (state has data and value is not null)
    final isLoggedIn = authState.hasValue && authState.value != null;
    final isGoingToLogin = state.matchedLocation == '/login';

    // Redirect to login if not authenticated and not already going to login
    if (!isLoggedIn && !isGoingToLogin) {
      return '/login';
    }
    
    // Redirect to sales invoices if authenticated and trying to access login
    if (isLoggedIn && isGoingToLogin) {
      return '/sales-invoices';
    }
    
    // Allow navigation to proceed
    return null;
  },
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Rise Flutter Exercise',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}
