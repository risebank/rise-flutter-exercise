import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rise_flutter_exercise/src/features/sales/models/sales_invoice_model.dart';
import 'package:rise_flutter_exercise/src/features/sales/providers/sales_provider.dart';
import 'package:rise_flutter_exercise/src/features/auth/services/auth_service.dart';
import 'package:rise_flutter_exercise/src/globals/theme/rise_theme.dart';

class SalesInvoiceEditScreen extends ConsumerStatefulWidget {
  final String invoiceId;

  const SalesInvoiceEditScreen({super.key, required this.invoiceId});

  @override
  ConsumerState<SalesInvoiceEditScreen> createState() =>
      _SalesInvoiceEditScreenState();
}

class _SalesInvoiceEditScreenState extends ConsumerState<SalesInvoiceEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _currencyController = TextEditingController();

  String? _companyId;
  SalesInvoiceModel? _originalInvoice;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCompanyIdAndInvoice());
  }

  Future<void> _loadCompanyIdAndInvoice() async {
    final authService = AuthService();

    final whoAmIResponse = await authService.whoAmI(context);

    if (whoAmIResponse.success && whoAmIResponse.data != null) {
      _companyId = whoAmIResponse.data!.companyId;
    } else {
      _companyId = authService.getCurrentCompanyId();
    }

    if (_companyId != null && _companyId!.isNotEmpty) {
      // Fetch the current invoice to pre-populate the form
      final response = await ref
          .read(selectedSalesInvoiceProvider.notifier)
          .fetchSalesInvoiceAsyncValue(context, _companyId!, widget.invoiceId);

      if (mounted) {
        setState(() {
          _isLoading = false;
          // Pre-populate form with current invoice data
          if (response != null) {
            _originalInvoice = response;
            _descriptionController.text = response.description ?? '';
            _currencyController.text = response.currency ?? '';
          }
        });
      }
    } else {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_companyId == null || _companyId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Company ID not available')),
      );
      return;
    }

    if (_originalInvoice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invoice data not available')),
      );
      return;
    }

    // Create updated invoice with form values
    final updatedInvoice = SalesInvoiceModel(
      id: _originalInvoice!.id,
      description: _descriptionController.text.trim(),
      currency: _currencyController.text.trim().isEmpty
          ? 'EUR'
          : _currencyController.text.trim(),
      invoiceDate: _originalInvoice!.invoiceDate,
      dueDate: _originalInvoice!.dueDate,
      documentDate: _originalInvoice!.documentDate,
      ourReference: _originalInvoice!.ourReference,
      yourReference: _originalInvoice!.yourReference,
      recipient: _originalInvoice!.recipient,
      recipientInvoicingEmail: _originalInvoice!.recipientInvoicingEmail,
      recipientInvoicingAddress: _originalInvoice!.recipientInvoicingAddress,
      senderAddress: _originalInvoice!.senderAddress,
      lines: _originalInvoice!.lines,
      createdAt: _originalInvoice!.createdAt,
      updatedAt: _originalInvoice!.updatedAt,
    );

    final updater = ref.read(updateSalesInvoiceProvider.notifier);

    final result = await updater.updateSalesInvoice(
      context,
      _companyId!,
      widget.invoiceId,
      updatedInvoice,
    );

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invoice updated successfully')),
      );
      // Navigate back to detail view
      context.go('/sales-invoices/${widget.invoiceId}');
    } else {
      final state = ref.read(updateSalesInvoiceProvider);
      final message =
          state.hasError ? state.asError!.error.toString() : 'Failed to update invoice';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final riseTheme = theme.extension<RiseAppThemeExtension>();
    final colors = riseTheme?.config.colors;
    final textTheme = theme.textTheme;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: colors?.background,
        appBar: AppBar(
          title: Text('Edit Invoice', style: textTheme.titleLarge),
          backgroundColor: colors?.surfaceContainerLowest,
        ),
        body: Center(
          child: CircularProgressIndicator(color: colors?.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colors?.background,
      appBar: AppBar(
        title: Text('Edit Invoice', style: textTheme.titleLarge),
        backgroundColor: colors?.surfaceContainerLowest,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _currencyController,
                decoration: const InputDecoration(labelText: 'Currency'),
                validator: (v) => v == null || v.trim().isEmpty ? null : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
