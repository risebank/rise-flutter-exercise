import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rise_flutter_exercise/src/features/auth/services/auth_service.dart';
import 'package:rise_flutter_exercise/src/features/sales/models/sales_invoice_model.dart';
import 'package:rise_flutter_exercise/src/features/sales/providers/sales_provider.dart';
import 'package:rise_flutter_exercise/src/features/sales/widgets/sales_invoice_form.dart';
import 'package:rise_flutter_exercise/src/globals/theme/rise_theme.dart';
import 'package:rise_flutter_exercise/src/globals/utils/error_messages.dart';

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
  bool _isLoadingCompany = true;
  final Map<String, String> _recipientOptions = const {
    '718d6a3e-c5ac-49c7-8fae-f57021ca67dd': 'Basemark Oy',
    '64867891-2bda-4cf8-8c94-5fc25b77a3e0': 'Growity Oy',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCompanyIdAndFetch();
    });
  }

  Future<void> _loadCompanyIdAndFetch() async {
    final authService = AuthService();
    _companyId = authService.getCurrentCompanyId();

    final whoAmIResponse = await authService.whoAmI(context);
    if (whoAmIResponse.success && whoAmIResponse.data != null) {
      final extractedCompanyId = whoAmIResponse.data!.companyId;
      if (extractedCompanyId != null && extractedCompanyId.isNotEmpty) {
        _companyId = extractedCompanyId;
      }
    }

    if (_companyId != null && _companyId!.isNotEmpty && mounted) {
      await ref
          .read(selectedSalesInvoiceProvider.notifier)
          .fetchSalesInvoice(context, _companyId!, widget.invoiceId);
    }

    if (mounted) {
      setState(() {
        _isLoadingCompany = false;
      });
    }
  }

  Future<void> _submit(SalesInvoiceModel invoice) async {
    if (_companyId == null || _companyId!.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorMessages.fetchError(context, 'company info')),
          ),
        );
      }
      return;
    }

    final updated = await ref
        .read(updateSalesInvoiceProvider.notifier)
        .updateSalesInvoice(
          context,
          _companyId!,
          widget.invoiceId,
          invoice,
        );

    if (!mounted) {
      return;
    }

    if (updated != null) {
      final theme = Theme.of(context);
      final riseTheme = theme.extension<RiseAppThemeExtension>();
      final colors = riseTheme?.config.colors;
      final textTheme = theme.textTheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: colors?.success,
          behavior: SnackBarBehavior.floating,
          content: Row(
            children: [
              Icon(Icons.check_circle, color: colors?.onSuccess),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  ErrorMessages.updateSuccess(context, 'Sales invoice'),
                  style: textTheme.bodyMedium?.copyWith(
                    color: colors?.onSuccess,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      await ref
          .read(salesInvoicesProvider.notifier)
          .fetchSalesInvoices(context, _companyId!);
      await ref
          .read(selectedSalesInvoiceProvider.notifier)
          .fetchSalesInvoice(context, _companyId!, widget.invoiceId);
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/sales-invoices/${widget.invoiceId}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final riseTheme = theme.extension<RiseAppThemeExtension>();
    final colors = riseTheme?.config.colors;
    final textTheme = theme.textTheme;
    final invoiceState = ref.watch(selectedSalesInvoiceProvider);
    final updateState = ref.watch(updateSalesInvoiceProvider);

    return Scaffold(
      backgroundColor: colors?.background,
      appBar: AppBar(
        title: Text(
          'Edit Invoice',
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
          ? Center(child: CircularProgressIndicator(color: colors?.primary))
          : invoiceState.when(
              data: (invoice) {
                if (invoice == null) {
                  return Center(
                    child: Text(
                      'Invoice not found',
                      style: textTheme.bodyLarge?.copyWith(
                        color: colors?.onSurfaceVariant,
                      ),
                    ),
                  );
                }
                return SalesInvoiceForm(
                  initialInvoice: invoice,
                  recipientOptions: _recipientOptions,
                  showRecipientFields: false,
                  showExtendedFields: false,
                  isSubmitting: updateState.isLoading,
                  submitLabel: 'Save changes',
                  errorText: updateState.hasError
                      ? updateState.error.toString()
                      : null,
                  onSubmit: _submit,
                );
              },
              loading: () =>
                  Center(child: CircularProgressIndicator(color: colors?.primary)),
              error: (error, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    error.toString(),
                    style: textTheme.bodyMedium?.copyWith(color: colors?.error),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
    );
  }
}
