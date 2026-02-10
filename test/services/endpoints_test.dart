import 'package:flutter_test/flutter_test.dart';
import 'package:rise_flutter_exercise/src/globals/services/endpoints.dart';

void main() {
  group('Endpoints', () {
    test('should have valid base URL', () {
      expect(Endpoints.baseUrl, isNotEmpty);
      expect(Endpoints.baseUrl, startsWith('http'));
    });

    test('should have correct whoami endpoint', () {
      expect(Endpoints.whoami, '/me');
    });

    test('should have correct sales invoices endpoint', () {
      expect(Endpoints.salesInvoices, '/companies/{company_id}/sales-invoices');
    });

    test('should generate correct sales invoice by ID endpoint', () {
      final endpoint = Endpoints.salesInvoiceById('company-123', 'invoice-456');
      expect(endpoint, '/companies/company-123/sales-invoices/invoice-456');
    });

    test('should generate correct parties endpoint', () {
      final endpoint = Endpoints.parties('company-123');
      expect(endpoint, '/companies/company-123/parties');
    });
  });
}
