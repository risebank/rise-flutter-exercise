import 'package:rise_flutter_exercise/src/globals/config/environment.dart';

class Endpoints {
  static String get baseUrl => Environment.apiBaseUrl;

  // User endpoints
  static const String whoami = '/me';

  // Sales endpoints
  static const String salesInvoices = '/companies/{company_id}/sales-invoices';

  static String salesInvoiceById(String companyId, String invoiceId) {
    return '/companies/$companyId/sales-invoices/$invoiceId';
  }

  // Parties (for recipient selection when creating invoices)
  static String parties(String companyId) => '/companies/$companyId/parties';
}
