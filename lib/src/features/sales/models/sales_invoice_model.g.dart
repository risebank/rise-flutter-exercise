// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_invoice_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SalesInvoiceModel _$SalesInvoiceModelFromJson(Map<String, dynamic> json) =>
    SalesInvoiceModel(
      id: json['id'] as String?,
      documentDate: json['document_date'] as String?,
      invoiceDate: json['invoice_date'] as String?,
      dueDate: json['due_date'] as String?,
      description: json['description'] as String?,
      journalNumber: (json['journal_number'] as num?)?.toInt(),
      currency: json['currency'] as String?,
      invoicingChannel: json['invoicing_channel'] as String?,
      ourReference: json['our_reference'] as String?,
      yourReference: json['your_reference'] as String?,
      paymentTerm: (json['payment_term'] as num?)?.toInt(),
      status: json['status'] as String?,
      grossAmount: json['gross_amount'] as String?,
      vatAmount: json['vat_amount'] as String?,
      recipient: json['recipient'] == null
          ? null
          : RecipientModel.fromJson(json['recipient'] as Map<String, dynamic>),
      recipientInvoicingEmail: json['recipient_invoicing_email'] as String?,
      recipientInvoicingAddress: json['recipient_invoicing_address'] == null
          ? null
          : AddressModel.fromJson(
              json['recipient_invoicing_address'] as Map<String, dynamic>,
            ),
      lines: (json['lines'] as List<dynamic>)
          .map((e) => InvoiceLineModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$SalesInvoiceModelToJson(SalesInvoiceModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'document_date': instance.documentDate,
      'invoice_date': instance.invoiceDate,
      'due_date': instance.dueDate,
      'description': instance.description,
      'journal_number': instance.journalNumber,
      'currency': instance.currency,
      'invoicing_channel': instance.invoicingChannel,
      'our_reference': instance.ourReference,
      'your_reference': instance.yourReference,
      'payment_term': instance.paymentTerm,
      'status': instance.status,
      'gross_amount': instance.grossAmount,
      'vat_amount': instance.vatAmount,
      'recipient': instance.recipient,
      'recipient_invoicing_email': instance.recipientInvoicingEmail,
      'recipient_invoicing_address': instance.recipientInvoicingAddress,
      'lines': instance.lines,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

RecipientModel _$RecipientModelFromJson(Map<String, dynamic> json) =>
    RecipientModel(
      id: json['id'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
    );

Map<String, dynamic> _$RecipientModelToJson(RecipientModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
    };

AddressModel _$AddressModelFromJson(Map<String, dynamic> json) => AddressModel(
  street: json['street'] as String?,
  city: json['city'] as String?,
  postalCode: json['postal_code'] as String?,
  region: json['region'] as String?,
  countryCode: json['country_code'] as String?,
);

Map<String, dynamic> _$AddressModelToJson(AddressModel instance) =>
    <String, dynamic>{
      'street': instance.street,
      'city': instance.city,
      'postal_code': instance.postalCode,
      'region': instance.region,
      'country_code': instance.countryCode,
    };

InvoiceLineModel _$InvoiceLineModelFromJson(Map<String, dynamic> json) =>
    InvoiceLineModel(
      id: json['id'] as String?,
      description: json['description'] as String?,
      quantity: json['quantity'] as String?,
      unitPrice: json['unit_price'] as String?,
      vatRate: json['vat_rate'] as String?,
      amount: json['amount'] as String?,
    );

Map<String, dynamic> _$InvoiceLineModelToJson(InvoiceLineModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'quantity': instance.quantity,
      'unit_price': instance.unitPrice,
      'vat_rate': instance.vatRate,
      'amount': instance.amount,
    };

SalesInvoiceListItemModel _$SalesInvoiceListItemModelFromJson(
  Map<String, dynamic> json,
) => SalesInvoiceListItemModel(
  id: json['id'] as String,
  invoiceDate: json['invoice_date'] as String?,
  dueDate: json['due_date'] as String?,
  description: json['description'] as String?,
  status: json['status'] as String?,
  grossAmount: json['gross_amount'] as String?,
  recipient: json['recipient'] == null
      ? null
      : RecipientModel.fromJson(json['recipient'] as Map<String, dynamic>),
);

Map<String, dynamic> _$SalesInvoiceListItemModelToJson(
  SalesInvoiceListItemModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'invoice_date': instance.invoiceDate,
  'due_date': instance.dueDate,
  'description': instance.description,
  'status': instance.status,
  'gross_amount': instance.grossAmount,
  'recipient': instance.recipient,
};

SalesInvoiceListResponseModel _$SalesInvoiceListResponseModelFromJson(
  Map<String, dynamic> json,
) => SalesInvoiceListResponseModel(
  data: (json['data'] as List<dynamic>)
      .map((e) => SalesInvoiceListItemModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$SalesInvoiceListResponseModelToJson(
  SalesInvoiceListResponseModel instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
