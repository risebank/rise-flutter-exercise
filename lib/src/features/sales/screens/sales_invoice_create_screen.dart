import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rise_flutter_exercise/src/features/auth/services/auth_service.dart';
import 'package:rise_flutter_exercise/src/features/sales/models/sales_invoice_model.dart';
import 'package:rise_flutter_exercise/src/features/sales/providers/sales_provider.dart';
import 'package:rise_flutter_exercise/src/globals/theme/rise_theme.dart';
import 'package:rise_flutter_exercise/src/globals/utils/error_messages.dart';
import 'package:rise_flutter_exercise/src/globals/widgets/rise_card.dart';
import 'package:rise_flutter_exercise/src/globals/widgets/rise_section_header.dart';

class SalesInvoiceCreateScreen extends ConsumerStatefulWidget {
  const SalesInvoiceCreateScreen({super.key});

  @override
  ConsumerState<SalesInvoiceCreateScreen> createState() =>
      _SalesInvoiceCreateScreenState();
}

class _SalesInvoiceCreateScreenState
    extends ConsumerState<SalesInvoiceCreateScreen> {
  final _formKey = GlobalKey<FormState>();

  final _descriptionController = TextEditingController();
  final _invoiceDateController = TextEditingController();
  final _dueDateController = TextEditingController();
  final _documentDateController = TextEditingController();
  final _currencyController = TextEditingController();
  final _ourReferenceController = TextEditingController();
  final _yourReferenceController = TextEditingController();
  final _recipientIdController = TextEditingController();
  final _recipientInvoicingEmailController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _regionController = TextEditingController();
  final _countryCodeController = TextEditingController();
  final _lineDescriptionController = TextEditingController();
  final _lineQuantityController = TextEditingController();
  final _lineUnitPriceController = TextEditingController();
  final _lineVatRateController = TextEditingController();

  String? _companyId;
  bool _isLoadingCompany = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCompanyId();
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _invoiceDateController.dispose();
    _dueDateController.dispose();
    _documentDateController.dispose();
    _currencyController.dispose();
    _ourReferenceController.dispose();
    _yourReferenceController.dispose();
    _recipientIdController.dispose();
    _recipientInvoicingEmailController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _regionController.dispose();
    _countryCodeController.dispose();
    _lineDescriptionController.dispose();
    _lineQuantityController.dispose();
    _lineUnitPriceController.dispose();
    _lineVatRateController.dispose();
    super.dispose();
  }

  Future<void> _loadCompanyId() async {
    final authService = AuthService();
    _companyId = authService.getCurrentCompanyId();

    final whoAmIResponse = await authService.whoAmI(context);
    if (whoAmIResponse.success && whoAmIResponse.data != null) {
      final extractedCompanyId = whoAmIResponse.data!.companyId;
      if (extractedCompanyId != null && extractedCompanyId.isNotEmpty) {
        _companyId = extractedCompanyId;
      }
    }

    if (mounted) {
      setState(() {
        _isLoadingCompany = false;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_companyId == null || _companyId!.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ErrorMessages.fetchError(context, 'company info'),
            ),
          ),
        );
      }
      return;
    }

    final invoice = _buildInvoice();
    final created = await ref
        .read(salesInvoiceCreatorProvider.notifier)
        .createSalesInvoice(context, _companyId!, invoice);

    if (!mounted) {
      return;
    }

    if (created != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ErrorMessages.createSuccess(context, 'Sales invoice')),
        ),
      );
      context.go('/sales-invoices');
    }
  }

  SalesInvoiceModel _buildInvoice() {
    const fallbackRecipientId = '718d6a3e-c5ac-49c7-8fae-f57021ca67dd';
    final recipientId = _recipientIdController.text.trim().isEmpty
        ? fallbackRecipientId
        : _recipientIdController.text.trim();
    final recipient = RecipientModel(id: recipientId);

    final address = AddressModel(
      street: _streetController.text.trim().isEmpty
          ? null
          : [_streetController.text.trim()],
      city: _cityController.text.trim().isEmpty
          ? null
          : _cityController.text.trim(),
      postalCode: _postalCodeController.text.trim().isEmpty
          ? null
          : _postalCodeController.text.trim(),
      region: _regionController.text.trim().isEmpty
          ? null
          : _regionController.text.trim(),
      countryCode: _countryCodeController.text.trim().isEmpty
          ? null
          : _countryCodeController.text.trim(),
    );

    final line = InvoiceLineModel(
      description: _lineDescriptionController.text.trim().isEmpty
          ? null
          : _lineDescriptionController.text.trim(),
      quantity: _lineQuantityController.text.trim().isEmpty
          ? null
          : _lineQuantityController.text.trim(),
      unitPrice: _lineUnitPriceController.text.trim().isEmpty
          ? null
          : _lineUnitPriceController.text.trim(),
      vatRate: _lineVatRateController.text.trim().isEmpty
          ? null
          : _lineVatRateController.text.trim(),
    );

    return SalesInvoiceModel(
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      invoiceDate: _invoiceDateController.text.trim().isEmpty
          ? null
          : _invoiceDateController.text.trim(),
      dueDate: _dueDateController.text.trim().isEmpty
          ? null
          : _dueDateController.text.trim(),
      documentDate: _documentDateController.text.trim().isEmpty
          ? null
          : _documentDateController.text.trim(),
      currency: _currencyController.text.trim().isEmpty
          ? null
          : _currencyController.text.trim(),
      ourReference: _ourReferenceController.text.trim().isEmpty
          ? null
          : _ourReferenceController.text.trim(),
      yourReference: _yourReferenceController.text.trim().isEmpty
          ? null
          : _yourReferenceController.text.trim(),
      recipient: recipient,
      recipientInvoicingEmail:
          _recipientInvoicingEmailController.text.trim().isEmpty
              ? null
              : _recipientInvoicingEmailController.text.trim(),
      recipientInvoicingAddress: address,
      lines: [line],
    );
  }

  String? _requiredField(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required';
    }
    return null;
  }

  InputDecoration _inputDecoration({
    required String label,
    String? hint,
    Color? fillColor,
    Color? borderColor,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: fillColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: borderColor ?? Colors.transparent),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final riseTheme = theme.extension<RiseAppThemeExtension>();
    final colors = riseTheme?.config.colors;
    final textTheme = theme.textTheme;
    final createState = ref.watch(salesInvoiceCreatorProvider);
    final isSubmitting = createState.isLoading;

    return Scaffold(
      backgroundColor: colors?.background,
      appBar: AppBar(
        title: Text(
          'Create Invoice',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors?.onSurface),
          onPressed: () => context.pop(),
        ),
        backgroundColor: colors?.surfaceContainerLowest,
        elevation: 0,
      ),
      body: _isLoadingCompany
          ? Center(
              child: CircularProgressIndicator(color: colors?.primary),
            )
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RiseSectionHeader(title: 'Invoice Details'),
                    RiseCard(
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _descriptionController,
                            decoration: _inputDecoration(
                              label: 'Description',
                              fillColor: colors?.surfaceContainer,
                              borderColor: colors?.outlineVariant,
                            ),
                            validator: (value) =>
                                _requiredField(value, 'Description'),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _invoiceDateController,
                            decoration: _inputDecoration(
                              label: 'Invoice date',
                              hint: 'YYYY-MM-DD',
                              fillColor: colors?.surfaceContainer,
                              borderColor: colors?.outlineVariant,
                            ),
                            validator: (value) =>
                                _requiredField(value, 'Invoice date'),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _dueDateController,
                            decoration: _inputDecoration(
                              label: 'Due date',
                              hint: 'YYYY-MM-DD',
                              fillColor: colors?.surfaceContainer,
                              borderColor: colors?.outlineVariant,
                            ),
                            validator: (value) =>
                                _requiredField(value, 'Due date'),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _documentDateController,
                            decoration: _inputDecoration(
                              label: 'Document date',
                              hint: 'YYYY-MM-DD',
                              fillColor: colors?.surfaceContainer,
                              borderColor: colors?.outlineVariant,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _currencyController,
                            decoration: _inputDecoration(
                              label: 'Currency',
                              hint: 'EUR',
                              fillColor: colors?.surfaceContainer,
                              borderColor: colors?.outlineVariant,
                            ),
                            validator: (value) =>
                                _requiredField(value, 'Currency'),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _ourReferenceController,
                            decoration: _inputDecoration(
                              label: 'Our reference',
                              fillColor: colors?.surfaceContainer,
                              borderColor: colors?.outlineVariant,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _yourReferenceController,
                            decoration: _inputDecoration(
                              label: 'Your reference',
                              fillColor: colors?.surfaceContainer,
                              borderColor: colors?.outlineVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    RiseSectionHeader(title: 'Recipient'),
                    RiseCard(
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _recipientIdController,
                            decoration: _inputDecoration(
                              label: 'Recipient ID',
                              hint: 'Default: 718d6a3e-c5ac-49c7-8fae-f57021ca67dd',
                              fillColor: colors?.surfaceContainer,
                              borderColor: colors?.outlineVariant,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _recipientInvoicingEmailController,
                            decoration: _inputDecoration(
                              label: 'Invoicing email',
                              fillColor: colors?.surfaceContainer,
                              borderColor: colors?.outlineVariant,
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    RiseSectionHeader(title: 'Recipient Address'),
                    RiseCard(
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _streetController,
                            decoration: _inputDecoration(
                              label: 'Street',
                              fillColor: colors?.surfaceContainer,
                              borderColor: colors?.outlineVariant,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _cityController,
                            decoration: _inputDecoration(
                              label: 'City',
                              fillColor: colors?.surfaceContainer,
                              borderColor: colors?.outlineVariant,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _postalCodeController,
                            decoration: _inputDecoration(
                              label: 'Postal code',
                              fillColor: colors?.surfaceContainer,
                              borderColor: colors?.outlineVariant,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _regionController,
                            decoration: _inputDecoration(
                              label: 'Region',
                              fillColor: colors?.surfaceContainer,
                              borderColor: colors?.outlineVariant,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _countryCodeController,
                            decoration: _inputDecoration(
                              label: 'Country code',
                              hint: 'e.g. FI',
                              fillColor: colors?.surfaceContainer,
                              borderColor: colors?.outlineVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    RiseSectionHeader(title: 'Invoice Line'),
                    RiseCard(
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _lineDescriptionController,
                            decoration: _inputDecoration(
                              label: 'Line description',
                              fillColor: colors?.surfaceContainer,
                              borderColor: colors?.outlineVariant,
                            ),
                            validator: (value) =>
                                _requiredField(value, 'Line description'),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _lineQuantityController,
                            decoration: _inputDecoration(
                              label: 'Quantity',
                              fillColor: colors?.surfaceContainer,
                              borderColor: colors?.outlineVariant,
                            ),
                            keyboardType:
                                const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (value) =>
                                _requiredField(value, 'Quantity'),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _lineUnitPriceController,
                            decoration: _inputDecoration(
                              label: 'Unit price',
                              fillColor: colors?.surfaceContainer,
                              borderColor: colors?.outlineVariant,
                            ),
                            keyboardType:
                                const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (value) =>
                                _requiredField(value, 'Unit price'),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _lineVatRateController,
                            decoration: _inputDecoration(
                              label: 'VAT rate',
                              hint: 'e.g. 24',
                              fillColor: colors?.surfaceContainer,
                              borderColor: colors?.outlineVariant,
                            ),
                            keyboardType:
                                const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (createState.hasError)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          createState.error.toString(),
                          style: textTheme.bodyMedium?.copyWith(
                            color: colors?.error,
                          ),
                        ),
                      ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isSubmitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors?.primary,
                          foregroundColor: colors?.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: isSubmitting
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    colors?.onPrimary ?? Colors.white,
                                  ),
                                ),
                              )
                            : const Text('Create invoice'),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }
}
