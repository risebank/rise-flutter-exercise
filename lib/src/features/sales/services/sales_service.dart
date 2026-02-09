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

    debugPrint(
      '🔎 [SalesService.fetchSalesInvoiceById] '
      'success=${response.success} '
      'status=${response.statusCode} '
      'message=${response.message} '
      'data=${response.data}',
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

    final payload = Map<String, dynamic>.from(invoice.toJson());
    payload.remove('id');
    payload.remove('created_at');
    payload.remove('updated_at');
    payload.remove('status');
    payload.remove('gross_amount');
    payload.remove('vat_amount');
    payload.remove('journal_number');

    // Keep recipient as nested object with just id (remove name/email if null)
    final recipient = payload['recipient'];
    if (recipient is RecipientModel) {
      payload['recipient'] = recipient.toJson();
    }
    if (payload['recipient'] is Map<String, dynamic>) {
      final recipientMap =
          Map<String, dynamic>.from(payload['recipient'] as Map);
      // Remove null fields from recipient, keep only id
      recipientMap.removeWhere((key, value) => value == null);
      if (recipientMap.isNotEmpty) {
        payload['recipient'] = recipientMap;
      } else {
        payload.remove('recipient');
      }
    }

    if (payload['lines'] is List) {
      payload['lines'] = (payload['lines'] as List)
          .map((line) {
            if (line is InvoiceLineModel) {
              return line.toJson();
            }
            if (line is Map<String, dynamic>) {
              return Map<String, dynamic>.from(line);
            }
            return null;
          })
          .where((line) => line != null)
          .map((line) {
            final map = Map<String, dynamic>.from(line as Map);
            map.remove('id');
            return map;
          })
          .toList();
    }

    final cleanedPayload = _removeNulls(payload);
    _normalizeNumericStrings(cleanedPayload);
    debugPrint(
      '🧾 [SalesService.createSalesInvoice] payload=$cleanedPayload',
    );

    final response = await _apiClient.post<Map<String, dynamic>>(
      endpoint,
      data: cleanedPayload,
      context: context,
    );

    debugPrint(
      '✅ [SalesService.createSalesInvoice] '
      'success=${response.success} '
      'status=${response.statusCode} '
      'message=${response.message} '
      'data=${response.data}',
    );

    return ApiResponse.fromApiClientResponse(
      context,
      response,
      parser: (json) =>
          SalesInvoiceModel.fromJson(json as Map<String, dynamic>),
      errorMessage: ErrorMessages.createError(context, 'sales invoice'),
    );
  }

  static Map<String, dynamic> _removeNulls(Map<String, dynamic> input) {
    final cleaned = <String, dynamic>{};

    input.forEach((key, value) {
      if (value == null) {
        return;
      }
      if (value is Map<String, dynamic>) {
        final nested = _removeNulls(value);
        if (nested.isNotEmpty) {
          cleaned[key] = nested;
        }
        return;
      }
      if (value is List) {
        final cleanedList = value
            .map((item) {
              if (item is Map<String, dynamic>) {
                return _removeNulls(item);
              }
              return item;
            })
            .where((item) {
              if (item is Map<String, dynamic>) {
                return item.isNotEmpty;
              }
              return item != null;
            })
            .toList();
        if (cleanedList.isNotEmpty) {
          cleaned[key] = cleanedList;
        }
        return;
      }

      cleaned[key] = value;
    });

    return cleaned;
  }

  static void _normalizeNumericStrings(Map<String, dynamic> input) {
    final numericKeys = {
      'quantity',
      'unit_price',
      'vat_rate',
      'amount',
    };

    void normalizeValue(String key, Map<String, dynamic> map) {
      final value = map[key];
      if (value is String) {
        final trimmed = value.trim();
        if (trimmed.isEmpty) {
          return;
        }
        final parsed = num.tryParse(trimmed);
        if (parsed != null) {
          map[key] = parsed;
        }
      }
    }

    input.forEach((key, value) {
      if (numericKeys.contains(key)) {
        normalizeValue(key, input);
      } else if (value is Map<String, dynamic>) {
        _normalizeNumericStrings(value);
      } else if (value is List) {
        for (final item in value) {
          if (item is Map<String, dynamic>) {
            _normalizeNumericStrings(item);
          }
        }
      }
    });
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
    // TODO: Task 2 - Implement PATCH request to update sales invoice
    throw UnimplementedError(
      'updateSalesInvoice is not yet implemented. '
      'This is Task 2 of the exercise - please implement the PATCH endpoint.',
    );
  }
}
