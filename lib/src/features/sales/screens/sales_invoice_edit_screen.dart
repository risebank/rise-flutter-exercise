import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rise_flutter_exercise/src/features/auth/services/auth_service.dart';
import 'package:rise_flutter_exercise/src/features/sales/models/sales_invoice_model.dart';
import 'package:rise_flutter_exercise/src/features/sales/providers/sales_provider.dart';
import 'package:rise_flutter_exercise/src/globals/theme/rise_theme.dart';
import 'package:rise_flutter_exercise/src/globals/widgets/rise_card.dart';
import 'package:rise_flutter_exercise/src/globals/widgets/rise_section_header.dart';

class SalesInvoiceEditScreen extends ConsumerStatefulWidget {
  final String invoiceId;

  const SalesInvoiceEditScreen({super.key, required this.invoiceId});

  @override
  ConsumerState<SalesInvoiceEditScreen> createState() =>
      _SalesInvoiceEditScreenState();
}

class _SalesInvoiceEditScreenState
    extends ConsumerState<SalesInvoiceEditScreen> {
  String? _companyId;
  bool _didPrefill = false;

  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _invoiceDateController = TextEditingController();
  final _dueDateController = TextEditingController();
  final _currencyController = TextEditingController();
  final _recipientNameController = TextEditingController();
  final _recipientEmailController = TextEditingController();
  final _lineDescriptionController = TextEditingController();
  final _lineQuantityController = TextEditingController();
  final _lineUnitPriceController = TextEditingController();
  final _lineVatRateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCompanyIdAndFetch();
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _invoiceDateController.dispose();
    _dueDateController.dispose();
    _currencyController.dispose();
    _recipientNameController.dispose();
    _recipientEmailController.dispose();
    _lineDescriptionController.dispose();
    _lineQuantityController.dispose();
    _lineUnitPriceController.dispose();
    _lineVatRateController.dispose();
    super.dispose();
  }

  Future<void> _loadCompanyIdAndFetch() async {
    final authService = AuthService();
    _companyId = authService.getCurrentCompanyId();

    final whoAmIResponse = await authService.whoAmI(context);
    if (whoAmIResponse.success && whoAmIResponse.data != null) {
      _companyId = whoAmIResponse.data!.companyId;
    }

    if (_companyId == null || _companyId!.isEmpty) {
      return;
    }

    if (mounted) {
      ref
          .read(selectedSalesInvoiceProvider.notifier)
          .fetchSalesInvoice(context, _companyId!, widget.invoiceId);
    }
  }

  void _prefill(SalesInvoiceModel invoice) {
    _descriptionController.text = invoice.description ?? '';
    _invoiceDateController.text = invoice.invoiceDate ?? '';
    _dueDateController.text = invoice.dueDate ?? '';
    _currencyController.text = invoice.currency ?? '';
    _recipientNameController.text = invoice.recipient?.name ?? '';
    _recipientEmailController.text = invoice.recipient?.email ?? '';

    final firstLine = invoice.lines.isNotEmpty ? invoice.lines.first : null;
    _lineDescriptionController.text = firstLine?.description ?? '';
    _lineQuantityController.text = firstLine?.quantity ?? '';
    _lineUnitPriceController.text = firstLine?.unitPrice ?? '';
    _lineVatRateController.text = firstLine?.vatRate ?? '';
    _didPrefill = true;
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    final authService = AuthService();
    String? companyId = authService.getCurrentCompanyId();
    final whoAmIResponse = await authService.whoAmI(context);
    if (whoAmIResponse.success && whoAmIResponse.data != null) {
      companyId = whoAmIResponse.data!.companyId;
    }

    if (companyId == null || companyId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to determine company ID')),
        );
      }
      return;
    }

    final invoice = SalesInvoiceModel(
      id: widget.invoiceId,
      description: _descriptionController.text.trim(),
      invoiceDate: _invoiceDateController.text.trim(),
      dueDate: _dueDateController.text.trim(),
      currency: _currencyController.text.trim(),
      recipient: RecipientModel(
        name: _recipientNameController.text.trim(),
        email: _recipientEmailController.text.trim(),
      ),
      lines: [
        InvoiceLineModel(
          description: _lineDescriptionController.text.trim(),
          quantity: _lineQuantityController.text.trim(),
          unitPrice: _lineUnitPriceController.text.trim(),
          vatRate: _lineVatRateController.text.trim(),
        ),
      ],
    );

    final updatedInvoice = await ref
        .read(updateSalesInvoiceProvider.notifier)
        .updateSalesInvoice(context, companyId, widget.invoiceId, invoice);

    if (!mounted) {
      return;
    }

    if (updatedInvoice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update invoice')),
      );
      return;
    }

    ref
        .read(salesInvoicesProvider.notifier)
        .updateInvoiceListItem(updatedInvoice);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invoice updated')),
    );
    context.go('/sales-invoices/${widget.invoiceId}');
  }

  @override
  Widget build(BuildContext context) {
    final invoiceState = ref.watch(selectedSalesInvoiceProvider);
    final updateState = ref.watch(updateSalesInvoiceProvider);
    final isSubmitting = updateState.isLoading;
    final theme = Theme.of(context);
    final riseTheme = theme.extension<RiseAppThemeExtension>();
    final colors = riseTheme?.config.colors;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colors?.background,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors?.onSurface),
          onPressed: () => context.go('/sales-invoices/${widget.invoiceId}'),
        ),
        title: Text(
          'Edit Invoice',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        backgroundColor: colors?.surfaceContainerLowest,
        elevation: 0,
      ),
      body: invoiceState.when(
        loading: () =>
            Center(child: CircularProgressIndicator(color: colors?.primary)),
        error: (error, stack) => Center(
          child: Text(
            error.toString(),
            style: textTheme.bodyMedium?.copyWith(
              color: colors?.onSurfaceVariant,
            ),
          ),
        ),
        data: (invoice) {
          if (invoice == null) {
            return Center(
              child: Text(
                'Invoice not found',
                style: textTheme.titleMedium?.copyWith(
                  color: colors?.onSurfaceVariant,
                ),
              ),
            );
          }

          if (!_didPrefill) {
            _prefill(invoice);
          }

          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const RiseSectionHeader(title: 'Invoice details'),
                  RiseCard(
                    child: Column(
                      children: [
                        _buildTextField(
                          controller: _descriptionController,
                          label: 'Description',
                          isRequired: true,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _invoiceDateController,
                          label: 'Invoice date (YYYY-MM-DD)',
                          isRequired: true,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _dueDateController,
                          label: 'Due date (YYYY-MM-DD)',
                          isRequired: true,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _currencyController,
                          label: 'Currency (e.g. EUR)',
                          isRequired: true,
                          textCapitalization: TextCapitalization.characters,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const RiseSectionHeader(title: 'Recipient'),
                  RiseCard(
                    child: Column(
                      children: [
                        _buildTextField(
                          controller: _recipientNameController,
                          label: 'Name',
                          isRequired: true,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _recipientEmailController,
                          label: 'Email',
                          isRequired: true,
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const RiseSectionHeader(title: 'Line item'),
                  RiseCard(
                    child: Column(
                      children: [
                        _buildTextField(
                          controller: _lineDescriptionController,
                          label: 'Line description',
                          isRequired: true,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _lineQuantityController,
                          label: 'Quantity',
                          isRequired: true,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _lineUnitPriceController,
                          label: 'Unit price',
                          isRequired: true,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _lineVatRateController,
                          label: 'VAT rate (%)',
                          isRequired: true,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isSubmitting ? null : _submit,
                      icon: isSubmitting
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colors?.onPrimary,
                              ),
                            )
                          : const Icon(Icons.save),
                      label:
                          Text(isSubmitting ? 'Updating...' : 'Update invoice'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors?.primary,
                        foregroundColor: colors?.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    TextCapitalization textCapitalization = TextCapitalization.none,
    bool isRequired = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      validator: (value) {
        if (!isRequired) {
          return null;
        }
        final trimmed = value?.trim() ?? '';
        if (trimmed.isEmpty) {
          return 'Required';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
