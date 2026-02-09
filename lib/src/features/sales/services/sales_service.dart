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
    // Log the company ID being used
    debugPrint(
      '🔍 [SalesService] Fetching sales invoices with companyId: $companyId',
    );
    debugPrint('🔍 [SalesService] Company ID length: ${companyId.length}');
    debugPrint('🔍 [SalesService] Company ID type: ${companyId.runtimeType}');

    final endpoint = Endpoints.salesInvoices.replaceAll(
      '{company_id}',
      companyId,
    );
    debugPrint('🔍 [SalesService] Full endpoint URL: $endpoint');

    final response = await _apiClient.get<Map<String, dynamic>>(
      endpoint,
      queryParameters: {'offset': offset, 'limit': limit},
      context: context,
    );

    debugPrint(
      '📥 [SalesService] Received API response - success: ${response.success}',
    );
    debugPrint('📥 [SalesService] Response message: ${response.message}');
    debugPrint(
      '📥 [SalesService] Response status code: ${response.statusCode}',
    );
    debugPrint(
      '📥 [SalesService] Response data type: ${response.data?.runtimeType}',
    );

    return ApiResponse.fromApiClientResponse(
      context,
      response,
      parser: (json) {
        debugPrint('🔄 [SalesService] Parsing response data');
        debugPrint('🔄 [SalesService] JSON type: ${json.runtimeType}');
        debugPrint('🔄 [SalesService] JSON: $json');
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
    // TODO: Task 1 - Implement POST request to create sales invoice
    throw UnimplementedError(
      'createSalesInvoice is not yet implemented. '
      'This is Task 1 of the exercise - please implement the POST endpoint.',
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
    // TODO: Task 2 - Implement PATCH request to update sales invoice
    throw UnimplementedError(
      'updateSalesInvoice is not yet implemented. '
      'This is Task 2 of the exercise - please implement the PATCH endpoint.',
    );
  }
}
