import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rise_flutter_exercise/src/features/sales/providers/sales_provider.dart';
import 'package:rise_flutter_exercise/src/features/auth/services/auth_service.dart';
import 'package:rise_flutter_exercise/src/globals/widgets/rise_card.dart';
import 'package:rise_flutter_exercise/src/globals/widgets/rise_info_row.dart';
import 'package:rise_flutter_exercise/src/globals/widgets/rise_section_header.dart';
import 'package:rise_flutter_exercise/src/globals/widgets/rise_status_badge.dart';
import 'package:rise_flutter_exercise/src/globals/theme/rise_theme.dart';

class SalesInvoiceDetailScreen extends ConsumerStatefulWidget {
  final String invoiceId;

  const SalesInvoiceDetailScreen({super.key, required this.invoiceId});

  @override
  ConsumerState<SalesInvoiceDetailScreen> createState() =>
      _SalesInvoiceDetailScreenState();
}

class _SalesInvoiceDetailScreenState
    extends ConsumerState<SalesInvoiceDetailScreen> {
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

    // If we still don't have a company ID, show an error
    // This should not happen in normal operation - indicates a configuration issue
    if (_companyId == null || _companyId!.isEmpty) {
      if (mounted) {
        setState(() {
          // Error will be shown by the provider state
        });
      }
      return;
    }

    if (mounted) {
      ref
          .read(selectedSalesInvoiceProvider.notifier)
          .fetchSalesInvoice(context, _companyId!, widget.invoiceId);
    } else if (mounted) {
      // Show error if we couldn't get company ID
      setState(() {
        // The error will be shown by the provider state
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final invoiceState = ref.watch(selectedSalesInvoiceProvider);
    final theme = Theme.of(context);
    final riseTheme = theme.extension<RiseAppThemeExtension>();
    final colors = riseTheme?.config.colors;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colors?.background,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors?.onSurface),
          onPressed: () => context.go('/sales-invoices'),
        ),
        title: Text(
          'Invoice Details',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        backgroundColor: colors?.surfaceContainerLowest,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: colors?.onSurface),
            tooltip: 'Edit invoice',
            onPressed: () =>
                context.go('/sales-invoices/${widget.invoiceId}/edit'),
          ),
        ],
      ),
      body: invoiceState.when(
        data: (invoice) {
          if (invoice == null) {
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
                    'Invoice not found',
                    style: textTheme.titleMedium?.copyWith(
                      color: colors?.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status badge at top
                if (invoice.status != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: RiseStatusBadge(status: invoice.status!),
                  ),
                _buildSection(context, 'Invoice Information', [
                  RiseInfoRow(label: 'ID', value: invoice.id ?? 'N/A'),
                  if (invoice.status != null)
                    RiseInfoRow(label: 'Status', value: invoice.status!),
                  RiseInfoRow(
                    label: 'Invoice Date',
                    value: invoice.invoiceDate ?? 'N/A',
                  ),
                  RiseInfoRow(
                    label: 'Due Date',
                    value: invoice.dueDate ?? 'N/A',
                  ),
                  RiseInfoRow(
                    label: 'Document Date',
                    value: invoice.documentDate ?? 'N/A',
                  ),
                  if (invoice.journalNumber != null)
                    RiseInfoRow(
                      label: 'Journal Number',
                      value: invoice.journalNumber.toString(),
                    ),
                ]),
                const SizedBox(height: 24),
                _buildSection(context, 'Description', [
                  Text(
                    invoice.description ?? 'No description',
                    style: textTheme.bodyLarge,
                  ),
                ]),
                const SizedBox(height: 24),
                if (invoice.recipient != null)
                  _buildSection(context, 'Recipient', [
                    RiseInfoRow(
                      label: 'Name',
                      value: invoice.recipient!.name ?? 'N/A',
                    ),
                    RiseInfoRow(
                      label: 'Email',
                      value: invoice.recipient!.email ?? 'N/A',
                    ),
                  ]),
                if (invoice.recipientInvoicingEmail != null) ...[
                  const SizedBox(height: 24),
                  _buildSection(context, 'Invoicing Email', [
                    Text(
                      invoice.recipientInvoicingEmail!,
                      style: textTheme.bodyLarge,
                    ),
                  ]),
                ],
                if (invoice.recipientInvoicingAddress != null) ...[
                  const SizedBox(height: 24),
                  _buildSection(context, 'Invoicing Address', [
                    RiseInfoRow(
                      label: 'Street',
                      value:
                          invoice.recipientInvoicingAddress!.street?.join(
                            ', ',
                          ) ??
                          'N/A',
                    ),
                    RiseInfoRow(
                      label: 'City',
                      value: invoice.recipientInvoicingAddress!.city ?? 'N/A',
                    ),
                    RiseInfoRow(
                      label: 'Postal Code',
                      value:
                          invoice.recipientInvoicingAddress!.postalCode ??
                          'N/A',
                    ),
                    RiseInfoRow(
                      label: 'Region',
                      value: invoice.recipientInvoicingAddress!.region ?? 'N/A',
                    ),
                    RiseInfoRow(
                      label: 'Country',
                      value:
                          invoice.recipientInvoicingAddress!.countryCode ??
                          'N/A',
                    ),
                  ]),
                ],
                const SizedBox(height: 24),
                _buildSection(context, 'References', [
                  RiseInfoRow(
                    label: 'Our Reference',
                    value: invoice.ourReference ?? 'N/A',
                  ),
                  RiseInfoRow(
                    label: 'Your Reference',
                    value: invoice.yourReference ?? 'N/A',
                  ),
                ]),
                const SizedBox(height: 24),
                _buildSection(
                  context,
                  'Invoice Lines',
                  invoice.lines.isEmpty
                      ? [
                          Text(
                            'No invoice lines',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colors?.onSurfaceVariant,
                            ),
                          ),
                        ]
                      : invoice.lines.map((line) {
                          return RiseCard(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (line.description != null)
                                  Text(
                                    line.description!,
                                    style: textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    if (line.quantity != null)
                                      Text(
                                        'Qty: ${line.quantity}',
                                        style: textTheme.bodyMedium,
                                      ),
                                    if (line.unitPrice != null)
                                      Text(
                                        'Price: €${line.unitPrice}',
                                        style: textTheme.bodyMedium,
                                      ),
                                    if (line.amount != null)
                                      Text(
                                        'Amount: €${line.amount}',
                                        style: textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                  ],
                                ),
                                if (line.vatRate != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      'VAT: ${line.vatRate}%',
                                      style: textTheme.bodySmall?.copyWith(
                                        color: colors?.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                ),
                const SizedBox(height: 24),
                _buildSection(context, 'Totals', [
                  if (invoice.grossAmount != null)
                    RiseInfoRow(
                      label: 'Gross Amount',
                      value: '€${invoice.grossAmount}',
                      isBold: true,
                    ),
                  if (invoice.vatAmount != null)
                    RiseInfoRow(
                      label: 'VAT Amount',
                      value: '€${invoice.vatAmount}',
                      isBold: true,
                    ),
                ]),
                const SizedBox(height: 24),
                _buildSection(context, 'Metadata', [
                  RiseInfoRow(
                    label: 'Currency',
                    value: invoice.currency ?? 'N/A',
                  ),
                  RiseInfoRow(
                    label: 'Invoicing Channel',
                    value: invoice.invoicingChannel ?? 'N/A',
                  ),
                  if (invoice.paymentTerm != null)
                    RiseInfoRow(
                      label: 'Payment Term',
                      value: '${invoice.paymentTerm} days',
                    ),
                  if (invoice.createdAt != null)
                    RiseInfoRow(label: 'Created At', value: invoice.createdAt!),
                  if (invoice.updatedAt != null)
                    RiseInfoRow(label: 'Updated At', value: invoice.updatedAt!),
                ]),
                const SizedBox(height: 32),
              ],
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
                  'Failed to load invoice',
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

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RiseSectionHeader(title: title),
        ...children,
      ],
    );
  }
}
