import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rise_flutter_exercise/src/features/sales/services/sales_service.dart';
import 'package:rise_flutter_exercise/src/features/sales/models/sales_invoice_model.dart';
import 'package:rise_flutter_exercise/src/features/auth/providers/auth_provider.dart';

part 'sales_provider.g.dart';

@riverpod
class SalesInvoices extends _$SalesInvoices {
  late final SalesService _service;

  @override
  Future<List<SalesInvoiceListItemModel>> build() async {
    _service = SalesService();
    // Initial state - empty list
    return [];
  }

  Future<void> fetchSalesInvoices(BuildContext context, String companyId) async {
    state = const AsyncValue.loading();
    
    try {
      final response = await _service.fetchSalesInvoices(context, companyId);
      
      if (response.success && response.data != null) {
        state = AsyncValue.data(response.data!.data);
      } else {
        state = AsyncValue.error(
          response.message ?? 'Failed to fetch sales invoices',
          StackTrace.current,
        );
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e.toString(), stackTrace);
    }
  }
}

@riverpod
class SelectedSalesInvoice extends _$SelectedSalesInvoice {
  late final SalesService _service;

  @override
  Future<SalesInvoiceModel?> build() async {
    _service = SalesService();
    return null;
  }

  Future<void> fetchSalesInvoice(
    BuildContext context,
    String companyId,
    String invoiceId,
  ) async {
    state = const AsyncValue.loading();
    
    try {
      final response = await _service.fetchSalesInvoiceById(
        context,
        companyId,
        invoiceId,
      );
      
      if (response.success && response.data != null) {
        state = AsyncValue.data(response.data);
      } else {
        state = AsyncValue.error(
          response.message ?? 'Failed to fetch sales invoice',
          StackTrace.current,
        );
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e.toString(), stackTrace);
    }
  }
}

// Placeholder provider - will be used in Stage 1
@riverpod
class SalesInvoiceCreator extends _$SalesInvoiceCreator {
  late final SalesService _service;

  @override
  Future<SalesInvoiceModel?> build() async {
    _service = SalesService();
    return null;
  }

  /// Create a new sales invoice
  /// TODO: Stage 1 - Connect this to the service method
  Future<SalesInvoiceModel?> createSalesInvoice(
    BuildContext context,
    String companyId,
    SalesInvoiceModel invoice,
  ) async {
    state = const AsyncValue.loading();
    
    try {
      final response = await _service.createSalesInvoice(
        context,
        companyId,
        invoice,
      );
      
      if (response.success && response.data != null) {
        state = AsyncValue.data(response.data);
        return response.data;
      } else {
        state = AsyncValue.error(
          response.message ?? 'Failed to create sales invoice',
          StackTrace.current,
        );
        return null;
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e.toString(), stackTrace);
      return null;
    }
  }
}

// Placeholder provider - will be used in Stage 2
@riverpod
class UpdateSalesInvoice extends _$UpdateSalesInvoice {
  late final SalesService _service;

  @override
  Future<SalesInvoiceModel?> build() async {
    _service = SalesService();
    return null;
  }

  /// Update an existing sales invoice
  /// TODO: Stage 2 - Connect this to the service method
  Future<SalesInvoiceModel?> updateSalesInvoice(
    BuildContext context,
    String companyId,
    String invoiceId,
    SalesInvoiceModel invoice,
  ) async {
    state = const AsyncValue.loading();
    
    try {
      final response = await _service.updateSalesInvoice(
        context,
        companyId,
        invoiceId,
        invoice,
      );
      
      if (response.success && response.data != null) {
        state = AsyncValue.data(response.data);
        return response.data;
      } else {
        state = AsyncValue.error(
          response.message ?? 'Failed to update sales invoice',
          StackTrace.current,
        );
        return null;
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e.toString(), stackTrace);
      return null;
    }
  }
}
