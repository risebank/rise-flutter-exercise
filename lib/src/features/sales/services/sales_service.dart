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
    final endpoint = Endpoints.salesInvoices.replaceAll(
      '{company_id}',
      companyId,
    );

    // Prepare and clean payload: remove read-only and null values recursively
    final raw = Map<String, dynamic>.from(invoice.toJson());
    final payload = _preparePayload(
      raw,
      excludeKeys: {'id', 'created_at', 'updated_at'},
    );

    final response = await _apiClient.post<Map<String, dynamic>>(
      endpoint,
      data: payload,
      context: context,
    );

    return ApiResponse.fromApiClientResponse(
      context,
      response,
      parser: (json) =>
          SalesInvoiceModel.fromJson(json as Map<String, dynamic>),
      errorMessage: ErrorMessages.createError(context, 'sales invoice'),
    );
  }

  // Helper to clean payloads: removes excluded keys, nulls, and empty containers
  Map<String, dynamic> _preparePayload(
    Map<String, dynamic> input, {
    required Set<String> excludeKeys,
  }) {
    Map<String, dynamic> cleanMap(Map<String, dynamic> m) {
      final result = <String, dynamic>{};

      m.forEach((key, value) {
        if (excludeKeys.contains(key)) return;

        if (value == null) return;

        if (value is Map<String, dynamic>) {
          final nested = cleanMap(value);
          if (nested.isNotEmpty) result[key] = nested;
        } else if (value is List) {
          final cleanedList = <dynamic>[];
          for (var item in value) {
            if (item == null) continue;
            if (item is Map<String, dynamic>) {
              final nested = cleanMap(item);
              if (nested.isNotEmpty) cleanedList.add(nested);
            } else {
              cleanedList.add(item);
            }
          }
          if (cleanedList.isNotEmpty) result[key] = cleanedList;
        } else {
          result[key] = value;
        }
      });

      return result;
    }

    return cleanMap(input);
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
    final endpoint = Endpoints.salesInvoiceById(companyId, invoiceId);

    // Prepare and clean payload: remove read-only and null values recursively
    final raw = Map<String, dynamic>.from(invoice.toJson());
    final payload = _preparePayload(
      raw,
      excludeKeys: {
        'id',
        'created_at',
        'updated_at',
        'journal_number',
        'status',
        'payment_term',
      },
    );

    final response = await _apiClient.patch<Map<String, dynamic>>(
      endpoint,
      data: payload,
      context: context,
    );

    return ApiResponse.fromApiClientResponse(
      context,
      response,
      parser: (json) =>
          SalesInvoiceModel.fromJson(json as Map<String, dynamic>),
      errorMessage: ErrorMessages.updateError(context, 'sales invoice'),
    );
  }
}
