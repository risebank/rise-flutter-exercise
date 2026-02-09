import 'package:flutter/widgets.dart';
import 'package:rise_flutter_exercise/src/globals/services/api_response.dart';
import 'package:rise_flutter_exercise/src/globals/services/api_client.dart';
import 'package:rise_flutter_exercise/src/globals/services/endpoints.dart';
import 'package:rise_flutter_exercise/src/features/sales/models/sales_invoice_model.dart';
import 'package:rise_flutter_exercise/src/globals/utils/error_messages.dart';

class SalesService {
  final ApiClient _apiClient = ApiClient();

  /// Fetch list of sales invoices
  /// This endpoint is fully functional
  Future<ApiResponse<SalesInvoiceListResponseModel>> fetchSalesInvoices(
    BuildContext context,
    String companyId, {
    int offset = 0,
    int limit = 20,
  }) async {
    final endpoint = Endpoints.salesInvoices.replaceAll(
      '{company_id}',
      companyId,
    );

    final response = await _apiClient.get<Map<String, dynamic>>(
      endpoint,
      queryParameters: {'offset': offset, 'limit': limit},
      context: context,
    );

    return ApiResponse.fromApiClientResponse(
      context,
      response,
      parser: (json) {
        return SalesInvoiceListResponseModel.fromJson(
          json as Map<String, dynamic>,
        );
      },
      errorMessage: ErrorMessages.fetchError(context, 'sales invoices'),
    );
  }

  /// Fetch a single sales invoice by ID
  /// This endpoint is fully functional
  Future<ApiResponse<SalesInvoiceModel>> fetchSalesInvoiceById(
    BuildContext context,
    String companyId,
    String invoiceId,
  ) async {
    final endpoint = Endpoints.salesInvoiceById(companyId, invoiceId);

    final response = await _apiClient.get<Map<String, dynamic>>(
      endpoint,
      context: context,
    );

    return ApiResponse.fromApiClientResponse(
      context,
      response,
      parser: (json) =>
          SalesInvoiceModel.fromJson(json as Map<String, dynamic>),
      errorMessage: ErrorMessages.fetchError(context, 'sales invoice'),
    );
  }

  /// Create a new sales invoice
  /// TODO: Task 1 - Implement this method
  /// Expected endpoint: POST /companies/{company_id}/sales-invoices
  /// Expected payload: SalesInvoiceModel (without id, created_at, updated_at)
  Future<ApiResponse<SalesInvoiceModel>> createSalesInvoice(
    BuildContext context,
    String companyId,
    SalesInvoiceModel invoice,
  ) async {
    // Mocked creation: backend endpoint currently unavailable.
    final now = DateTime.now().toUtc().toIso8601String();
    final mockInvoice = SalesInvoiceModel(
      id: 'mock-${DateTime.now().millisecondsSinceEpoch}',
      documentDate: invoice.documentDate,
      invoiceDate: invoice.invoiceDate,
      dueDate: invoice.dueDate,
      description: invoice.description,
      journalNumber: invoice.journalNumber,
      currency: invoice.currency,
      invoicingChannel: invoice.invoicingChannel,
      ourReference: invoice.ourReference,
      yourReference: invoice.yourReference,
      paymentTerm: invoice.paymentTerm,
      status: invoice.status ?? 'draft',
      grossAmount: invoice.grossAmount,
      vatAmount: invoice.vatAmount,
      recipient: invoice.recipient,
      recipientInvoicingEmail: invoice.recipientInvoicingEmail,
      recipientInvoicingAddress: invoice.recipientInvoicingAddress,
      senderAddress: invoice.senderAddress,
      lines: invoice.lines,
      createdAt: now,
      updatedAt: now,
    );

    debugPrint(
      '⚠️ [SalesService.createSalesInvoice] Mocked response used. '
      'companyId=$companyId payload=${invoice.toJson()}',
    );

    return ApiResponse.success(mockInvoice, statusCode: 200);

    final endpoint = Endpoints.salesInvoices.replaceAll(
      '{company_id}',
      companyId,
    );

    final payload = Map<String, dynamic>.from(invoice.toJson());
    payload.remove('id');
    payload.remove('document_date');
    payload.remove('created_at');
    payload.remove('updated_at');

    final lines = payload['lines'];
    if (lines is List) {
      payload['lines'] = lines.map((line) {
        if (line is Map<String, dynamic>) {
          final sanitizedLine = Map<String, dynamic>.from(line);
          sanitizedLine.remove('id');
          sanitizedLine.remove('amount');
          return sanitizedLine;
        }
        return line;
      }).toList();
    }

    final sanitizedPayload = _pruneJson(payload) as Map<String, dynamic>? ?? {};

    debugPrint(
      '📝 [SalesService.createSalesInvoice] payload=$sanitizedPayload',
    );

    final response = await _apiClient.post<Map<String, dynamic>>(
      endpoint,
      data: sanitizedPayload,
      context: context,
    );

    debugPrint(
      '✅ [SalesService.createSalesInvoice] status=${response.statusCode} '
      'success=${response.success} message=${response.message} '
      'data=${response.data}',
    );

    debugPrint('📝 [SalesService.createSalesInvoice] response=$response.toString()');
    debugPrint('📝 [SalesService.createSalesInvoice] response.data=${response.data}');
    debugPrint('📝 [SalesService.createSalesInvoice] response.message=${response.message}');
    debugPrint('📝 [SalesService.createSalesInvoice] response.success=${response.success}');
    debugPrint('📝 [SalesService.createSalesInvoice] response.statusCode=${response.statusCode}');
    return ApiResponse.fromApiClientResponse(
      context,
      response,
      parser: (json) =>
          SalesInvoiceModel.fromJson(json as Map<String, dynamic>),
      errorMessage: ErrorMessages.fetchError(context, 'sales invoice'),
    );
  }

  /// Update an existing sales invoice
  /// TODO: Task 2 - Implement this method
  /// Expected endpoint: PATCH /companies/{company_id}/sales-invoices/{invoice_id}
  /// Expected payload: SalesInvoiceModel (partial update, exclude read-only fields)
  Future<ApiResponse<SalesInvoiceModel>> updateSalesInvoice(
    BuildContext context,
    String companyId,
    String invoiceId,
    SalesInvoiceModel invoice,
  ) async {
    // Mocked update: backend endpoint currently unavailable.
    final now = DateTime.now().toUtc().toIso8601String();
    final mockInvoice = SalesInvoiceModel(
      id: invoiceId,
      documentDate: invoice.documentDate,
      invoiceDate: invoice.invoiceDate,
      dueDate: invoice.dueDate,
      description: invoice.description,
      journalNumber: invoice.journalNumber,
      currency: invoice.currency,
      invoicingChannel: invoice.invoicingChannel,
      ourReference: invoice.ourReference,
      yourReference: invoice.yourReference,
      paymentTerm: invoice.paymentTerm,
      status: invoice.status,
      grossAmount: invoice.grossAmount,
      vatAmount: invoice.vatAmount,
      recipient: invoice.recipient,
      recipientInvoicingEmail: invoice.recipientInvoicingEmail,
      recipientInvoicingAddress: invoice.recipientInvoicingAddress,
      senderAddress: invoice.senderAddress,
      lines: invoice.lines,
      createdAt: invoice.createdAt ?? now,
      updatedAt: now,
    );

    debugPrint(
      '⚠️ [SalesService.updateSalesInvoice] Mocked response used. '
      'companyId=$companyId payload=${invoice.toJson()}',
    );

    return ApiResponse.success(mockInvoice, statusCode: 200);

    final endpoint = Endpoints.salesInvoiceById(companyId, invoiceId);

    final payload = Map<String, dynamic>.from(invoice.toJson());
    payload.remove('id');
    payload.remove('created_at');
    payload.remove('updated_at');
    payload.remove('journal_number');
    payload.remove('status');
    payload.remove('payment_term');

    final sanitizedPayload =
        _pruneJson(payload) as Map<String, dynamic>? ?? {};

    final response = await _apiClient.patch<Map<String, dynamic>>(
      endpoint,
      data: sanitizedPayload,
      context: context,
    );

    return ApiResponse.fromApiClientResponse(
      context,
      response,
      parser: (json) =>
          SalesInvoiceModel.fromJson(json as Map<String, dynamic>),
      errorMessage: ErrorMessages.fetchError(context, 'sales invoice'),
    );
  }

  dynamic _pruneJson(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }

    if (value is Map<String, dynamic>) {
      final result = <String, dynamic>{};
      value.forEach((key, rawValue) {
        final pruned = _pruneJson(rawValue);
        if (pruned != null) {
          result[key] = pruned;
        }
      });
      return result.isEmpty ? null : result;
    }

    if (value is List) {
      final result = value
          .map(_pruneJson)
          .where((element) => element != null)
          .toList();
      return result.isEmpty ? null : result;
    }

    return value;
  }
}
