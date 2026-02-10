import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rise_flutter_exercise/src/features/sales/providers/sales_provider.dart';
import 'package:rise_flutter_exercise/src/features/sales/widgets/invoice_list_item.dart';
import 'package:rise_flutter_exercise/src/features/auth/providers/auth_provider.dart';
import 'package:rise_flutter_exercise/src/features/auth/services/auth_service.dart';
import 'package:rise_flutter_exercise/src/globals/theme/rise_theme.dart';

class SalesInvoicesListScreen extends ConsumerStatefulWidget {
  const SalesInvoicesListScreen({super.key});

  @override
  ConsumerState<SalesInvoicesListScreen> createState() =>
      _SalesInvoicesListScreenState();
}

class _SalesInvoicesListScreenState
    extends ConsumerState<SalesInvoicesListScreen> {
  String? _companyId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCompanyIdAndFetch();
    });
  }

  Future<void> _loadCompanyIdAndFetch() async {
    // Get company ID from WhoAmI service
    final authService = AuthService();

    // First check cache (should be populated during login)
    _companyId = authService.getCurrentCompanyId();

    // Always fetch fresh WhoAmI to ensure we have the latest data
    // This ensures we're using the correct company ID even if cache is stale
    final whoAmIResponse = await authService.whoAmI(context);

    if (whoAmIResponse.success && whoAmIResponse.data != null) {
      final extractedCompanyId = whoAmIResponse.data!.companyId;

      if (extractedCompanyId != null && extractedCompanyId.isNotEmpty) {
        _companyId = extractedCompanyId;
      } else {
        debugPrint(
          '❌ [SalesInvoicesList] Extracted company ID is null or empty',
        );
      }
    } else {
      debugPrint(
        '❌ [SalesInvoicesList] Failed to fetch WhoAmI: ${whoAmIResponse.message}',
      );
    }

    // Validate company ID before making API call
    if (_companyId == null || _companyId!.isEmpty) {
      if (mounted) {
        // Don't use fallback - show proper error instead
        setState(() {
          // Error will be shown by provider state
        });
      }
      return;
    }

    if (mounted) {
      ref
          .read(salesInvoicesProvider.notifier)
          .fetchSalesInvoices(context, _companyId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final invoicesState = ref.watch(salesInvoicesProvider);
    final theme = Theme.of(context);
    final riseTheme = theme.extension<RiseAppThemeExtension>();
    final colors = riseTheme?.config.colors;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colors?.background,
      appBar: AppBar(
        title: Text(
          'Sales Invoices',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        backgroundColor: colors?.surfaceContainerLowest,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: colors?.onSurface),
            tooltip: 'Logout',
            onPressed: () async {
              await ref.read(authProvider.notifier).logout(context);
              // Router redirect will automatically handle navigation to /login
            },
          ),
        ],
      ),
      body: invoicesState.when(
        data: (invoices) {
          // Check if we've attempted to fetch - if not, show loading
          final hasAttemptedFetch =
              ref.read(salesInvoicesProvider.notifier).hasAttemptedFetch;

          if (!hasAttemptedFetch) {
            // Initial state - show loading until fetch is triggered
            return Center(
              child: CircularProgressIndicator(color: colors?.primary),
            );
          }

          // After fetch, show empty state if no invoices
          if (invoices.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: colors?.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No sales invoices found',
                    style: textTheme.titleMedium?.copyWith(
                      color: colors?.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              if (_companyId != null) {
                await ref
                    .read(salesInvoicesProvider.notifier)
                    .fetchSalesInvoices(context, _companyId!);
              }
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: invoices.length,
              itemBuilder: (context, index) {
                final invoice = invoices[index];
                return InvoiceListItem(
                  invoice: invoice,
                  companyId: _companyId ?? '',
                );
              },
            ),
          );
        },
        loading: () =>
            Center(child: CircularProgressIndicator(color: colors?.primary)),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: colors?.error),
                const SizedBox(height: 16),
                Text(
                  'Failed to load invoices',
                  style: textTheme.titleMedium?.copyWith(
                    color: colors?.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: textTheme.bodyMedium?.copyWith(
                    color: colors?.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    _loadCompanyIdAndFetch();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors?.primary,
                    foregroundColor: colors?.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
