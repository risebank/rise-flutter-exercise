import 'package:flutter_test/flutter_test.dart';
import 'package:rise_flutter_exercise/src/features/sales/models/sales_invoice_model.dart';

void main() {
  group('SalesInvoiceModel', () {
    test('should create model from JSON', () {
      final json = {
        'id': 'test-id',
        'document_date': '2026-01-16',
        'invoice_date': '2026-01-16',
        'due_date': '2026-01-30',
        'description': 'Test invoice',
        'currency': 'EUR',
        'status': 'approved',
        'gross_amount': '100.00',
        'vat_amount': '24.00',
        'lines': [],
      };

      final model = SalesInvoiceModel.fromJson(json);

      expect(model.id, 'test-id');
      expect(model.documentDate, '2026-01-16');
      expect(model.invoiceDate, '2026-01-16');
      expect(model.dueDate, '2026-01-30');
      expect(model.description, 'Test invoice');
      expect(model.currency, 'EUR');
      expect(model.status, 'approved');
      expect(model.grossAmount, '100.00');
      expect(model.vatAmount, '24.00');
      expect(model.lines, isEmpty);
    });

    test('should convert model to JSON', () {
      final model = SalesInvoiceModel(
        id: 'test-id',
        documentDate: '2026-01-16',
        invoiceDate: '2026-01-16',
        dueDate: '2026-01-30',
        description: 'Test invoice',
        currency: 'EUR',
        status: 'approved',
        grossAmount: '100.00',
        vatAmount: '24.00',
        lines: [],
      );

      final json = model.toJson();

      expect(json['id'], 'test-id');
      expect(json['document_date'], '2026-01-16');
      expect(json['invoice_date'], '2026-01-16');
      expect(json['due_date'], '2026-01-30');
      expect(json['description'], 'Test invoice');
      expect(json['currency'], 'EUR');
      expect(json['status'], 'approved');
      expect(json['gross_amount'], '100.00');
      expect(json['vat_amount'], '24.00');
      expect(json['lines'], isEmpty);
    });

    test('should handle null values', () {
      final model = SalesInvoiceModel(lines: []);

      expect(model.id, isNull);
      expect(model.description, isNull);
      expect(model.currency, isNull);
    });

    test('should handle recipient model', () {
      final json = {
        'id': 'test-id',
        'recipient': {
          'id': 'recipient-id',
          'name': 'Test Recipient',
          'email': 'test@example.com',
        },
        'lines': [],
      };

      final model = SalesInvoiceModel.fromJson(json);

      expect(model.recipient?.id, 'recipient-id');
      expect(model.recipient?.name, 'Test Recipient');
      expect(model.recipient?.email, 'test@example.com');
    });

    test('should handle invoice lines', () {
      final json = {
        'id': 'test-id',
        'lines': [
          {
            'description': 'Line item 1',
            'quantity': '2',
            'unit_price': '50.00',
            'amount': '100.00',
            'vat_rate': '24',
          },
        ],
      };

      final model = SalesInvoiceModel.fromJson(json);

      expect(model.lines.length, 1);
      expect(model.lines.first.description, 'Line item 1');
      expect(model.lines.first.quantity, '2');
      expect(model.lines.first.unitPrice, '50.00');
      expect(model.lines.first.amount, '100.00');
      expect(model.lines.first.vatRate, '24');
    });
  });
}
