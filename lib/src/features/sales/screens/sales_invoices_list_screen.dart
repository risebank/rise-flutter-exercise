import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rise_flutter_exercise/src/features/sales/providers/sales_provider.dart';
import 'package:rise_flutter_exercise/src/features/auth/providers/auth_provider.dart';
import 'package:rise_flutter_exercise/src/features/auth/services/auth_service.dart';

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

    debugPrint('🔍 [SalesInvoicesList] Starting company ID retrieval...');

    // First check cache (should be populated during login)
    _companyId = authService.getCurrentCompanyId();
    debugPrint('🔍 [SalesInvoicesList] Cached company ID: $_companyId');

    // Always fetch fresh WhoAmI to ensure we have the latest data
    // This ensures we're using the correct company ID even if cache is stale
    debugPrint('🔍 [SalesInvoicesList] Fetching fresh WhoAmI data...');
    final whoAmIResponse = await authService.whoAmI(context);

    if (whoAmIResponse.success && whoAmIResponse.data != null) {
      final extractedCompanyId = whoAmIResponse.data!.companyId;
      debugPrint('🔍 [SalesInvoicesList] WhoAmI fetch successful');
      debugPrint(
        '🔍 [SalesInvoicesList] Extracted company ID: $extractedCompanyId',
      );
      debugPrint(
        '🔍 [SalesInvoicesList] Company ID length: ${extractedCompanyId?.length ?? 0}',
      );
      debugPrint(
        '🔍 [SalesInvoicesList] Company ID type: ${extractedCompanyId.runtimeType}',
      );

      if (extractedCompanyId != null && extractedCompanyId.isNotEmpty) {
        _companyId = extractedCompanyId;
      } else {
        debugPrint(
          '❌ [SalesInvoicesList] Extracted company ID is null or empty',
        );
        debugPrint('❌ [SalesInvoicesList] WhoAmI data: ${whoAmIResponse.data}');
        debugPrint(
          '❌ [SalesInvoicesList] Permissions: ${whoAmIResponse.data!.permissions}',
        );
      }
    } else {
      // Log the error for debugging
      debugPrint(
        '❌ [SalesInvoicesList] Failed to fetch WhoAmI: ${whoAmIResponse.message}',
      );
      debugPrint(
        '❌ [SalesInvoicesList] WhoAmI response status: ${whoAmIResponse.statusCode}',
      );
    }

    // Validate company ID before making API call
    if (_companyId == null || _companyId!.isEmpty) {
      debugPrint(
        '❌ ERROR: Company ID is null or empty. Cannot fetch sales invoices.',
      );
      if (mounted) {
        // Don't use fallback - show proper error instead
        setState(() {
          // Error will be shown by provider state
        });
      }
      return;
    }

    debugPrint('✅ [SalesInvoicesList] Using company ID: $_companyId');
    debugPrint(
      '✅ [SalesInvoicesList] Company ID verification - Length: ${_companyId!.length}',
    );

    if (mounted) {
      ref
          .read(salesInvoicesProvider.notifier)
          .fetchSalesInvoices(context, _companyId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final invoicesState = ref.watch(salesInvoicesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Invoices'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout(context);
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: invoicesState.when(
        data: (invoices) {
          if (invoices.isEmpty) {
            return const Center(child: Text('No sales invoices found'));
          }
          return ListView.builder(
            itemCount: invoices.length,
            itemBuilder: (context, index) {
              final invoice = invoices[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(
                    invoice.description ?? 'Invoice ${invoice.id}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (invoice.recipient?.name != null)
                        Text('Customer: ${invoice.recipient!.name}'),
                      if (invoice.invoiceDate != null)
                        Text('Date: ${invoice.invoiceDate}'),
                      if (invoice.status != null)
                        Text('Status: ${invoice.status}'),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (invoice.grossAmount != null)
                        Text(
                          '€${invoice.grossAmount}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      if (invoice.status != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(invoice.status!),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            invoice.status!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  onTap: () {
                    if (_companyId != null) {
                      context.go('/sales-invoices/${invoice.id}');
                    }
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Error: $error',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _loadCompanyIdAndFetch();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return Colors.grey;
      case 'sent':
        return Colors.blue;
      case 'paid':
        return Colors.green;
      case 'overdue':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
