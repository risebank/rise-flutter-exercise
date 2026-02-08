import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rise_flutter_exercise/src/features/sales/providers/sales_provider.dart';
import 'package:rise_flutter_exercise/src/features/sales/models/sales_invoice_model.dart';
import 'package:rise_flutter_exercise/src/features/auth/services/auth_service.dart';

class SalesInvoiceDetailScreen extends ConsumerStatefulWidget {
  final String invoiceId;

  const SalesInvoiceDetailScreen({
    super.key,
    required this.invoiceId,
  });

  @override
  ConsumerState<SalesInvoiceDetailScreen> createState() => _SalesInvoiceDetailScreenState();
}

class _SalesInvoiceDetailScreenState extends ConsumerState<SalesInvoiceDetailScreen> {
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
    
    // First try to get from cache
    _companyId = authService.getCurrentCompanyId();
    
    // If not in cache, fetch WhoAmI
    if (_companyId == null || _companyId!.isEmpty) {
      final whoAmIResponse = await authService.whoAmI(context);
      if (whoAmIResponse.success && whoAmIResponse.data != null) {
        _companyId = whoAmIResponse.data!.companyId;
      }
    }
    
    // Fallback to instructions value if still null (for exercise setup)
    _companyId ??= 'company-123'; // From INSTRUCTIONS.md
    
    if (_companyId != null && _companyId!.isNotEmpty && mounted) {
      ref.read(selectedSalesInvoiceProvider.notifier).fetchSalesInvoice(
        context,
        _companyId!,
        widget.invoiceId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final invoiceState = ref.watch(selectedSalesInvoiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice Details'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // TODO: Stage 2 - Add edit button that navigates to edit screen
          // For now, this is just a placeholder
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Stage 2 - Navigate to edit screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Edit functionality - Stage 2 TODO'),
                ),
              );
            },
          ),
        ],
      ),
      body: invoiceState.when(
        data: (invoice) {
          if (invoice == null) {
            return const Center(
              child: Text('Invoice not found'),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection(
                  'Invoice Information',
                  [
                    _buildInfoRow('ID', invoice.id ?? 'N/A'),
                    _buildInfoRow('Status', invoice.status ?? 'N/A'),
                    _buildInfoRow('Invoice Date', invoice.invoiceDate ?? 'N/A'),
                    _buildInfoRow('Due Date', invoice.dueDate ?? 'N/A'),
                    _buildInfoRow('Document Date', invoice.documentDate ?? 'N/A'),
                    if (invoice.journalNumber != null)
                      _buildInfoRow('Journal Number', invoice.journalNumber.toString()),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSection(
                  'Description',
                  [
                    Text(invoice.description ?? 'No description'),
                  ],
                ),
                const SizedBox(height: 24),
                if (invoice.recipient != null)
                  _buildSection(
                    'Recipient',
                    [
                      _buildInfoRow('Name', invoice.recipient!.name ?? 'N/A'),
                      _buildInfoRow('Email', invoice.recipient!.email ?? 'N/A'),
                    ],
                  ),
                if (invoice.recipientInvoicingEmail != null) ...[
                  const SizedBox(height: 24),
                  _buildSection(
                    'Invoicing Email',
                    [
                      Text(invoice.recipientInvoicingEmail!),
                    ],
                  ),
                ],
                if (invoice.recipientInvoicingAddress != null) ...[
                  const SizedBox(height: 24),
                  _buildSection(
                    'Invoicing Address',
                    [
                      _buildInfoRow('Street', invoice.recipientInvoicingAddress!.street ?? 'N/A'),
                      _buildInfoRow('City', invoice.recipientInvoicingAddress!.city ?? 'N/A'),
                      _buildInfoRow('Postal Code', invoice.recipientInvoicingAddress!.postalCode ?? 'N/A'),
                      _buildInfoRow('Region', invoice.recipientInvoicingAddress!.region ?? 'N/A'),
                      _buildInfoRow('Country', invoice.recipientInvoicingAddress!.countryCode ?? 'N/A'),
                    ],
                  ),
                ],
                const SizedBox(height: 24),
                _buildSection(
                  'References',
                  [
                    _buildInfoRow('Our Reference', invoice.ourReference ?? 'N/A'),
                    _buildInfoRow('Your Reference', invoice.yourReference ?? 'N/A'),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSection(
                  'Invoice Lines',
                  invoice.lines.isEmpty
                      ? [const Text('No invoice lines')]
                      : invoice.lines.map((line) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (line.description != null)
                                    Text(
                                      line.description!,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      if (line.quantity != null)
                                        Text('Qty: ${line.quantity}'),
                                      if (line.unitPrice != null)
                                        Text('Price: €${line.unitPrice}'),
                                      if (line.amount != null)
                                        Text(
                                          'Amount: €${line.amount}',
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                    ],
                                  ),
                                  if (line.vatRate != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text('VAT: ${line.vatRate}%'),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                ),
                const SizedBox(height: 24),
                _buildSection(
                  'Totals',
                  [
                    if (invoice.grossAmount != null)
                      _buildInfoRow(
                        'Gross Amount',
                        '€${invoice.grossAmount}',
                        isBold: true,
                      ),
                    if (invoice.vatAmount != null)
                      _buildInfoRow(
                        'VAT Amount',
                        '€${invoice.vatAmount}',
                        isBold: true,
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSection(
                  'Metadata',
                  [
                    _buildInfoRow('Currency', invoice.currency ?? 'N/A'),
                    _buildInfoRow('Invoicing Channel', invoice.invoicingChannel ?? 'N/A'),
                    if (invoice.paymentTerm != null)
                      _buildInfoRow('Payment Term', '${invoice.paymentTerm} days'),
                    if (invoice.createdAt != null)
                      _buildInfoRow('Created At', invoice.createdAt!),
                    if (invoice.updatedAt != null)
                      _buildInfoRow('Updated At', invoice.updatedAt!),
                  ],
                ),
              ],
            ),
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

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
