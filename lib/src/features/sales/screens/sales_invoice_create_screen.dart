import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rise_flutter_exercise/src/features/sales/models/sales_invoice_model.dart';
import 'package:rise_flutter_exercise/src/features/sales/providers/sales_provider.dart';
import 'package:rise_flutter_exercise/src/features/auth/services/auth_service.dart';
import 'package:go_router/go_router.dart';
import 'package:rise_flutter_exercise/src/globals/theme/rise_theme.dart';

class SalesInvoiceCreateScreen extends ConsumerStatefulWidget {
  const SalesInvoiceCreateScreen({super.key});

  @override
  ConsumerState<SalesInvoiceCreateScreen> createState() =>
      _SalesInvoiceCreateScreenState();
}

class _SalesInvoiceCreateScreenState
    extends ConsumerState<SalesInvoiceCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _currencyController = TextEditingController();

  String? _companyId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCompanyId());
  }

  Future<void> _loadCompanyId() async {
    final authService = AuthService();

    final whoAmIResponse = await authService.whoAmI(context);

    if (whoAmIResponse.success && whoAmIResponse.data != null) {
      _companyId = whoAmIResponse.data!.companyId;
    } else {
      _companyId = authService.getCurrentCompanyId();
    }

    if (mounted) setState(() {});
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_companyId == null || _companyId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Company ID not available')),
      );
      return;
    }

    final invoice = SalesInvoiceModel(
      description: _descriptionController.text.trim(),
      currency: _currencyController.text.trim().isEmpty
          ? 'EUR'
          : _currencyController.text.trim(),
      lines: [],
    );

    final creator = ref.read(salesInvoiceCreatorProvider.notifier);

    final result = await creator.createSalesInvoice(context, _companyId!, invoice);

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invoice created: ${result.id ?? 'unknown'}')),
      );
      // Navigate back to list via router
      context.go('/sales-invoices');
    } else {
      final state = ref.read(salesInvoiceCreatorProvider);
      final message = state.hasError ? state.asError!.error.toString() : 'Failed to create invoice';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final riseTheme = theme.extension<RiseAppThemeExtension>();
    final colors = riseTheme?.config.colors;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colors?.background,
      appBar: AppBar(
        title: Text('Create Invoice', style: textTheme.titleLarge),
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
                child: const Text('Create'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
