import 'package:flutter/material.dart';
import 'package:rise_flutter_exercise/src/features/sales/models/sales_invoice_model.dart';
import 'package:rise_flutter_exercise/src/globals/theme/rise_theme.dart';
import 'package:rise_flutter_exercise/src/globals/widgets/rise_card.dart';
import 'package:rise_flutter_exercise/src/globals/widgets/rise_section_header.dart';

class SalesInvoiceForm extends StatefulWidget {
  final SalesInvoiceModel? initialInvoice;
  final Map<String, String> recipientOptions;
  final Future<void> Function(SalesInvoiceModel invoice) onSubmit;
  final bool isSubmitting;
  final String submitLabel;
  final String? errorText;
  final bool showRecipientFields;
  final bool showExtendedFields;

  const SalesInvoiceForm({
    super.key,
    required this.initialInvoice,
    required this.recipientOptions,
    required this.onSubmit,
    required this.isSubmitting,
    required this.submitLabel,
    this.errorText,
    this.showRecipientFields = true,
    this.showExtendedFields = true,
  });

  @override
  State<SalesInvoiceForm> createState() => _SalesInvoiceFormState();
}

class _SalesInvoiceFormState extends State<SalesInvoiceForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _descriptionController;
  late final TextEditingController _invoiceDateController;
  late final TextEditingController _dueDateController;
  late final TextEditingController _documentDateController;
  late final TextEditingController _currencyController;
  late final TextEditingController _ourReferenceController;
  late final TextEditingController _yourReferenceController;
  late final TextEditingController _recipientInvoicingEmailController;
  late final TextEditingController _streetController;
  late final TextEditingController _cityController;
  late final TextEditingController _postalCodeController;
  late final TextEditingController _regionController;
  late final TextEditingController _countryCodeController;
  late final TextEditingController _lineDescriptionController;
  late final TextEditingController _lineQuantityController;
  late final TextEditingController _lineUnitPriceController;
  late final TextEditingController _lineVatRateController;

  String? _selectedRecipientId;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
    _invoiceDateController = TextEditingController();
    _dueDateController = TextEditingController();
    _documentDateController = TextEditingController();
    _currencyController = TextEditingController();
    _ourReferenceController = TextEditingController();
    _yourReferenceController = TextEditingController();
    _recipientInvoicingEmailController = TextEditingController();
    _streetController = TextEditingController();
    _cityController = TextEditingController();
    _postalCodeController = TextEditingController();
    _regionController = TextEditingController();
    _countryCodeController = TextEditingController();
    _lineDescriptionController = TextEditingController();
    _lineQuantityController = TextEditingController();
    _lineUnitPriceController = TextEditingController();
    _lineVatRateController = TextEditingController();
    _loadFromInvoice(widget.initialInvoice);
  }

  @override
  void didUpdateWidget(covariant SalesInvoiceForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialInvoice?.id != widget.initialInvoice?.id) {
      _loadFromInvoice(widget.initialInvoice);
    }
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

  void _loadFromInvoice(SalesInvoiceModel? invoice) {
    _descriptionController.text = invoice?.description ?? '';
    _invoiceDateController.text = invoice?.invoiceDate ?? '';
    _dueDateController.text = invoice?.dueDate ?? '';
    _documentDateController.text = invoice?.documentDate ?? '';
    _currencyController.text = invoice?.currency ?? '';
    _ourReferenceController.text = invoice?.ourReference ?? '';
    _yourReferenceController.text = invoice?.yourReference ?? '';
    _recipientInvoicingEmailController.text =
        invoice?.recipientInvoicingEmail ?? '';

    _streetController.text =
        invoice?.recipientInvoicingAddress?.street?.join(', ') ?? '';
    _cityController.text = invoice?.recipientInvoicingAddress?.city ?? '';
    _postalCodeController.text =
        invoice?.recipientInvoicingAddress?.postalCode ?? '';
    _regionController.text = invoice?.recipientInvoicingAddress?.region ?? '';
    _countryCodeController.text =
        invoice?.recipientInvoicingAddress?.countryCode ?? '';

    final line = invoice?.lines.isNotEmpty == true ? invoice!.lines.first : null;
    _lineDescriptionController.text = line?.description ?? '';
    _lineQuantityController.text = line?.quantity ?? '';
    _lineUnitPriceController.text = line?.unitPrice ?? '';
    _lineVatRateController.text = line?.vatRate ?? '';

    final defaultRecipientId = widget.recipientOptions.isNotEmpty
        ? widget.recipientOptions.keys.first
        : null;
    final invoiceRecipientId = invoice?.recipient?.id;
    if (invoiceRecipientId != null &&
        widget.recipientOptions.containsKey(invoiceRecipientId)) {
      _selectedRecipientId = invoiceRecipientId;
    } else {
      _selectedRecipientId = defaultRecipientId;
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _pickDate({
    required TextEditingController controller,
    DateTime? initialDate,
  }) async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate ?? now,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 10),
    );

    if (selected == null || !mounted) {
      return;
    }

    final year = selected.year.toString().padLeft(4, '0');
    final month = selected.month.toString().padLeft(2, '0');
    final day = selected.day.toString().padLeft(2, '0');
    controller.text = '$year-$month-$day';
  }

  SalesInvoiceModel _buildInvoice() {
    final recipient = widget.showRecipientFields
        ? RecipientModel(id: _selectedRecipientId)
        : RecipientModel(id: null);

    final streetValue = _streetController.text.trim();
    final address = AddressModel(
      street: streetValue.isEmpty ? null : [streetValue],
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

    return Form(
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
                    validator: (value) => _requiredField(value, 'Description'),
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
                    readOnly: true,
                    onTap: () =>
                        _pickDate(controller: _invoiceDateController),
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
                    readOnly: true,
                    onTap: () => _pickDate(controller: _dueDateController),
                    validator: (value) => _requiredField(value, 'Due date'),
                  ),
                  const SizedBox(height: 12),
                  if (widget.showExtendedFields) ...[
                    TextFormField(
                      controller: _documentDateController,
                      decoration: _inputDecoration(
                        label: 'Document date',
                        hint: 'YYYY-MM-DD',
                        fillColor: colors?.surfaceContainer,
                        borderColor: colors?.outlineVariant,
                      ),
                      readOnly: true,
                      onTap: () =>
                          _pickDate(controller: _documentDateController),
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextFormField(
                    controller: _currencyController,
                    decoration: _inputDecoration(
                      label: 'Currency',
                      hint: 'EUR',
                      fillColor: colors?.surfaceContainer,
                      borderColor: colors?.outlineVariant,
                    ),
                    validator: (value) => _requiredField(value, 'Currency'),
                  ),
                  if (widget.showExtendedFields) ...[
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
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (widget.showRecipientFields) ...[
              RiseSectionHeader(title: 'Recipient'),
              RiseCard(
                child: Column(
                  children: [
                    // Temporary hack: restrict recipients to known IDs
                    DropdownButtonFormField<String>(
                      value: _selectedRecipientId,
                      items: widget.recipientOptions.entries
                          .map(
                            (entry) => DropdownMenuItem<String>(
                              value: entry.key,
                              child: Text(entry.value),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedRecipientId = value;
                        });
                      },
                      decoration: _inputDecoration(
                        label: 'Recipient',
                        fillColor: colors?.surfaceContainer,
                        borderColor: colors?.outlineVariant,
                      ),
                      validator: (value) => _requiredField(value, 'Recipient'),
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
            ],
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
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) => _requiredField(value, 'Quantity'),
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
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) => _requiredField(value, 'Unit price'),
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
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (widget.errorText != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  widget.errorText!,
                  style: textTheme.bodyMedium?.copyWith(color: colors?.error),
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.isSubmitting
                    ? null
                    : () async {
                        if (!_formKey.currentState!.validate()) {
                          final theme = Theme.of(context);
                          final riseTheme =
                              theme.extension<RiseAppThemeExtension>();
                          final colors = riseTheme?.config.colors;
                          final textTheme = theme.textTheme;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: colors?.error,
                              behavior: SnackBarBehavior.floating,
                              content: Row(
                                children: [
                                  Icon(Icons.error, color: colors?.onError),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Please fix the highlighted fields.',
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: colors?.onError,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                          return;
                        }
                        await widget.onSubmit(_buildInvoice());
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors?.primary,
                  foregroundColor: colors?.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: widget.isSubmitting
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
                    : Text(widget.submitLabel),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
