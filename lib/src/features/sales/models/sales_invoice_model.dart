import 'package:json_annotation/json_annotation.dart';

part 'sales_invoice_model.g.dart';

@JsonSerializable()
class SalesInvoiceModel {
  final String? id;
  @JsonKey(name: 'document_date')
  final String? documentDate;
  @JsonKey(name: 'invoice_date')
  final String? invoiceDate;
  @JsonKey(name: 'due_date')
  final String? dueDate;
  final String? description;
  @JsonKey(name: 'journal_number')
  final int? journalNumber;
  final String? currency;
  @JsonKey(name: 'invoicing_channel')
  final String? invoicingChannel;
  @JsonKey(name: 'our_reference')
  final String? ourReference;
  @JsonKey(name: 'your_reference')
  final String? yourReference;
  @JsonKey(name: 'payment_term')
  final int? paymentTerm;
  final String? status;
  @JsonKey(name: 'gross_amount')
  final String? grossAmount;
  @JsonKey(name: 'vat_amount')
  final String? vatAmount;
  @JsonKey(name: 'recipient')
  final RecipientModel? recipient;
  @JsonKey(name: 'recipient_invoicing_email')
  final String? recipientInvoicingEmail;
  @JsonKey(name: 'recipient_invoicing_address')
  final AddressModel? recipientInvoicingAddress;
  @JsonKey(name: 'sender_address')
  final AddressModel? senderAddress;
  final List<InvoiceLineModel> lines;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  const SalesInvoiceModel({
    this.id,
    this.documentDate,
    this.invoiceDate,
    this.dueDate,
    this.description,
    this.journalNumber,
    this.currency,
    this.invoicingChannel,
    this.ourReference,
    this.yourReference,
    this.paymentTerm,
    this.status,
    this.grossAmount,
    this.vatAmount,
    this.recipient,
    this.recipientInvoicingEmail,
    this.recipientInvoicingAddress,
    this.senderAddress,
    required this.lines,
    this.createdAt,
    this.updatedAt,
  });

  factory SalesInvoiceModel.fromJson(Map<String, dynamic> json) =>
      _$SalesInvoiceModelFromJson(json);

  Map<String, dynamic> toJson() => _$SalesInvoiceModelToJson(this);
}

@JsonSerializable()
class RecipientModel {
  final String? id;
  final String? name;
  final String? email;

  const RecipientModel({this.id, this.name, this.email});

  factory RecipientModel.fromJson(Map<String, dynamic> json) =>
      _$RecipientModelFromJson(json);

  Map<String, dynamic> toJson() => _$RecipientModelToJson(this);
}

/// Party list item from GET /companies/{id}/parties (for recipient selection).
@JsonSerializable()
class PartyListItemModel {
  final String id;
  @JsonKey(name: 'registration_country_code')
  final String? registrationCountryCode;
  @JsonKey(name: 'business_id')
  final String? businessId;
  final String name;
  final int? number;

  const PartyListItemModel({
    required this.id,
    this.registrationCountryCode,
    this.businessId,
    required this.name,
    this.number,
  });

  factory PartyListItemModel.fromJson(Map<String, dynamic> json) =>
      _$PartyListItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$PartyListItemModelToJson(this);

  /// Converts to RecipientModel for use in invoice payload.
  RecipientModel toRecipient() => RecipientModel(
        id: id,
        name: name,
      );
}

@JsonSerializable()
class AddressModel {
  final List<String>? street;
  final String? city;
  @JsonKey(name: 'postal_code')
  final String? postalCode;
  final String? region;
  @JsonKey(name: 'country_code')
  final String? countryCode;

  const AddressModel({
    this.street,
    this.city,
    this.postalCode,
    this.region,
    this.countryCode,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) =>
      _$AddressModelFromJson(json);

  Map<String, dynamic> toJson() => _$AddressModelToJson(this);
}

@JsonSerializable()
class InvoiceLineModel {
  final String? id;
  final String? description;
  final String? quantity;
  @JsonKey(name: 'unit_price')
  final String? unitPrice;
  @JsonKey(name: 'vat_rate')
  final String? vatRate;
  final String? amount;

  const InvoiceLineModel({
    this.id,
    this.description,
    this.quantity,
    this.unitPrice,
    this.vatRate,
    this.amount,
  });

  factory InvoiceLineModel.fromJson(Map<String, dynamic> json) =>
      _$InvoiceLineModelFromJson(json);

  Map<String, dynamic> toJson() => _$InvoiceLineModelToJson(this);
}

// List response models
@JsonSerializable()
class SalesInvoiceListItemModel {
  final String id;
  @JsonKey(name: 'invoice_date')
  final String? invoiceDate;
  @JsonKey(name: 'due_date')
  final String? dueDate;
  final String? description;
  final String? status;
  @JsonKey(name: 'gross_amount')
  final String? grossAmount;
  @JsonKey(name: 'recipient')
  final RecipientModel? recipient;

  const SalesInvoiceListItemModel({
    required this.id,
    this.invoiceDate,
    this.dueDate,
    this.description,
    this.status,
    this.grossAmount,
    this.recipient,
  });

  factory SalesInvoiceListItemModel.fromJson(Map<String, dynamic> json) =>
      _$SalesInvoiceListItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$SalesInvoiceListItemModelToJson(this);
}

@JsonSerializable()
class SalesInvoiceListResponseModel {
  final List<SalesInvoiceListItemModel> data;
  final Map<String, dynamic>? meta;

  const SalesInvoiceListResponseModel({required this.data, this.meta});

  factory SalesInvoiceListResponseModel.fromJson(Map<String, dynamic> json) =>
      _$SalesInvoiceListResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$SalesInvoiceListResponseModelToJson(this);
}
