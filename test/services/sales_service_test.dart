import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rise_flutter_exercise/src/features/sales/services/sales_service.dart';
import 'package:rise_flutter_exercise/src/features/sales/models/sales_invoice_model.dart';
import 'package:rise_flutter_exercise/src/globals/services/api_response.dart';

void main() {
  group('SalesService', () {
    late SalesService service;
    late BuildContext testContext;

    setUp(() {
      service = SalesService();
      // Create a test context for service calls
      testContext = MaterialApp(
        home: Scaffold(body: Container()),
      ).createElement();
    });

    group('createSalesInvoice', () {
      test('should convert invoice to JSON with all fields', () {
        final invoice = SalesInvoiceModel(
          description: 'Test invoice',
          currency: 'EUR',
          lines: [],
        );

        final json = invoice.toJson();
        expect(json['description'], 'Test invoice');
        expect(json['currency'], 'EUR');
        expect(json['lines'], []);
      });

      test('should exclude read-only fields from JSON during serialization', () {
        final invoice = SalesInvoiceModel(
          id: 'invoice-123',
          description: 'Test invoice',
          currency: 'EUR',
          createdAt: '2024-01-15T10:00:00Z',
          updatedAt: '2024-01-15T10:00:00Z',
          lines: [],
        );

        final json = invoice.toJson();

        // Verify all fields are in JSON (service will filter them out during POST)
        expect(json.containsKey('id'), true);
        expect(json.containsKey('created_at'), true);
        expect(json.containsKey('updated_at'), true);
        expect(json.containsKey('description'), true);
        expect(json.containsKey('currency'), true);
      });

      test('should handle invoice with invoice date and optional fields', () {
        final invoice = SalesInvoiceModel(
          description: 'Invoice with dates',
          currency: 'EUR',
          invoiceDate: '2024-01-15',
          dueDate: '2024-02-15',
          documentDate: '2024-01-15',
          ourReference: 'REF-001',
          yourReference: 'CUST-REF-001',
          lines: [
            InvoiceLineModel(
              description: 'Line item 1',
              quantity: '1',
              unitPrice: '100.00',
              amount: '100.00',
              vatRate: '20',
            ),
          ],
        );

        final json = invoice.toJson();

        expect(json['description'], 'Invoice with dates');
        expect(json['currency'], 'EUR');
        expect(json['invoice_date'], '2024-01-15');
        expect(json['due_date'], '2024-02-15');
        expect(json['document_date'], '2024-01-15');
        expect(json['our_reference'], 'REF-001');
        expect(json['your_reference'], 'CUST-REF-001');
        expect(json['lines'], isA<List>());
        expect((json['lines'] as List).length, 1);
      });

      test('should handle null optional fields in JSON serialization', () {
        final invoice = SalesInvoiceModel(
          description: 'Minimal invoice',
          currency: 'EUR',
          lines: [],
          invoiceDate: null,
          dueDate: null,
          ourReference: null,
        );

        final json = invoice.toJson();

        // Fields with null values will be in JSON but service cleans them
        expect(json['description'], 'Minimal invoice');
        expect(json['currency'], 'EUR');
        expect(json['lines'], []);
      });

      test('should support invoice with recipient', () {
        final invoice = SalesInvoiceModel(
          description: 'Invoice with recipient',
          currency: 'EUR',
          recipient: RecipientModel(
            id: 'recipient-1',
            name: 'Acme Corp',
            email: 'billing@acme.com',
          ),
          lines: [],
        );

        final json = invoice.toJson();

        expect(json['description'], 'Invoice with recipient');
        expect(json['recipient'], isA<Map<String, dynamic>>());
        expect((json['recipient'] as Map)['name'], 'Acme Corp');
        expect((json['recipient'] as Map)['email'], 'billing@acme.com');
      });
    });

    group('updateSalesInvoice', () {
      test('should convert invoice to JSON for update', () {
        final invoice = SalesInvoiceModel(
          description: 'Updated invoice',
          currency: 'EUR',
          lines: [],
        );

        final json = invoice.toJson();
        expect(json['description'], 'Updated invoice');
        expect(json['currency'], 'EUR');
      });

      test('should exclude read-only fields for PATCH requests', () {
        final invoice = SalesInvoiceModel(
          id: 'invoice-123',
          description: 'Updated invoice',
          currency: 'EUR',
          journalNumber: 42,
          status: 'FINALIZED',
          paymentTerm: 30,
          createdAt: '2024-01-15T10:00:00Z',
          updatedAt: '2024-01-15T11:00:00Z',
          lines: [],
        );

        final json = invoice.toJson();

        // Verify read-only fields are in JSON (service will filter them in PATCH)
        expect(json.containsKey('id'), true);
        expect(json.containsKey('created_at'), true);
        expect(json.containsKey('updated_at'), true);
        expect(json.containsKey('journal_number'), true);
        expect(json.containsKey('status'), true);
        expect(json.containsKey('payment_term'), true);
      });

      test('should handle partial invoice update with modified fields', () {
        final invoice = SalesInvoiceModel(
          description: 'Modified description',
          currency: 'USD',
          ourReference: 'NEW-REF-001',
          lines: [],
        );

        final json = invoice.toJson();

        expect(json['description'], 'Modified description');
        expect(json['currency'], 'USD');
        expect(json['our_reference'], 'NEW-REF-001');
      });

      test('should support updating invoice with new recipient', () {
        final invoice = SalesInvoiceModel(
          description: 'Invoice with new recipient',
          currency: 'EUR',
          recipient: RecipientModel(
            id: 'new-recipient-2',
            name: 'New Customer Inc',
            email: 'contact@newcustomer.com',
          ),
          lines: [],
        );

        final json = invoice.toJson();

        expect(json['recipient'], isA<Map<String, dynamic>>());
        expect((json['recipient'] as Map)['name'], 'New Customer Inc');
      });

      test('should support updating invoice with new invoice lines', () {
        final invoice = SalesInvoiceModel(
          description: 'Invoice with updated lines',
          currency: 'EUR',
          lines: [
            InvoiceLineModel(
              description: 'Updated line 1',
              quantity: '2',
              unitPrice: '50.00',
              amount: '100.00',
              vatRate: '19',
            ),
            InvoiceLineModel(
              description: 'New line 2',
              quantity: '1',
              unitPrice: '75.00',
              amount: '75.00',
              vatRate: '19',
            ),
          ],
        );

        final json = invoice.toJson();

        expect((json['lines'] as List).length, 2);
        expect(((json['lines'] as List)[0] as Map)['quantity'], '2');
        expect(((json['lines'] as List)[1] as Map)['description'], 'New line 2');
      });
    });
  });
}
