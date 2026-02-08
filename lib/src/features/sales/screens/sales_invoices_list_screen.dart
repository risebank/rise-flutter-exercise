import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rise_flutter_exercise/src/features/sales/providers/sales_provider.dart';
import 'package:rise_flutter_exercise/src/features/sales/models/sales_invoice_model.dart';
import 'package:rise_flutter_exercise/src/features/auth/providers/auth_provider.dart';
import 'package:rise_flutter_exercise/src/features/auth/services/auth_service.dart';

class SalesInvoicesListScreen extends ConsumerStatefulWidget {
  const SalesInvoicesListScreen({super.key});

  @override
  ConsumerState<SalesInvoicesListScreen> createState() => _SalesInvoicesListScreenState();
}

class _SalesInvoicesListScreenState extends ConsumerState<SalesInvoicesListScreen> {
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
    
    // Always fetch WhoAmI to ensure we have the latest data
    // The cache might not be populated yet if login just completed
    final whoAmIResponse = await authService.whoAmI(context);
    
    if (whoAmIResponse.success && whoAmIResponse.data != null) {
      _companyId = whoAmIResponse.data!.companyId;
    } else {
      // If WhoAmI fails, try cache as fallback
      _companyId = authService.getCurrentCompanyId();
    }
    
    // Fallback to instructions value if still null (for exercise setup)
    // This should only happen if WhoAmI endpoint fails and cache is empty
    _companyId ??= 'company-123'; // From INSTRUCTIONS.md
    
    if (_companyId != null && _companyId!.isNotEmpty && mounted) {
      ref.read(salesInvoicesProvider.notifier).fetchSalesInvoices(
        context,
        _companyId!,
      );
    } else if (mounted) {
      // Show error if we couldn't get company ID
      setState(() {
        // The error will be shown by the provider state
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final invoicesState = ref.watch(salesInvoicesProvider);
    final authState = ref.watch(authProvider);

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
            return const Center(
              child: Text('No sales invoices found'),
            );
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
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
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
