# Sales Invoice API Reference

This document describes the backend API contracts for the sales invoice endpoints used in this exercise. The backend uses strict schema validation; send only the fields documented below.

## Base URL

Configured via `Environment.apiBaseUrl` (fallback: `https://6fsryeht36.execute-api.eu-central-1.amazonaws.com`).

## Authentication

All requests require a Bearer token (handled automatically by `AuthInterceptor`).

---

## GET /companies/{company_id}/parties

List parties for recipient selection when creating invoices.

### Query Parameters

| Parameter | Type | Required | Notes |
|-----------|------|----------|-------|
| `scope` | string | Yes | `"registry"` or `"associated"` |
| `query` | string | No | Search by party name |
| `offset` | string | No | Pagination offset |
| `limit` | string | No | Max results (default 10) |
| `sort` | string | No | `"name"` or `"updated_at"` |

### Response (200)

Array of party objects:

```json
[
  {
    "id": "uuid",
    "name": "string",
    "registration_country_code": "string",
    "business_id": "string",
    "number": 123
  }
]
```

Use `scope=associated` for parties linked to the company. `SalesService.fetchParties` and `PartyListItemModel` are provided; use `toRecipient()` to build the recipient for the invoice payload.

---

## POST /companies/{company_id}/sales-invoices

Create a new sales invoice.

### Request Body (JSON)

Only these fields are accepted. Do **not** send read-only or computed fields.

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `description` | string | No | Invoice description |
| `invoice_date` | string (ISO date YYYY-MM-DD) | No | Invoice date |
| `due_date` | string (ISO date YYYY-MM-DD) | No | Due date |
| `our_reference` | string | No | Our reference |
| `your_reference` | string | No | Your reference |
| `currency` | string | No | Must be `"EUR"` |
| `invoicing_channel` | string | No | One of: `"email"`, `"einvoice"`, `"letter"` |
| `recipient` | object | No | See Recipient schema below |
| `recipient_invoicing_email` | string | No | Email for invoicing |
| `recipient_invoicing_address` | object | No | See Address schema below |
| `lines` | array | Yes (min 1) | At least one line item (see Line schema) |

### Recipient Object

```json
{
  "id": "uuid",           // Optional - existing party ID (required to link to a customer)
  "name": "string",       // Optional
  "registration_country_code": "string",  // Optional
  "business_id": "string" // Optional
}
```

**Important:** For creating invoices, you must provide `recipient.id` with a valid party UUID. Use the [parties list endpoint](#get-companiescompany_idparties) to fetch parties and populate a recipient dropdown.

### Address Object

```json
{
  "street": ["string"],   // Array of street lines
  "city": "string",
  "postal_code": "string",
  "region": "string",
  "country_code": "string"  // ISO 3166-1 alpha-2 (e.g. "FI")
}
```

### Line Item Object (request)

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `product_id` | uuid | No | Product ID (null for ad-hoc lines) |
| `title` | string | No | Line title |
| `description` | string | No | Line description |
| `quantity` | string | No | Positive number (regex: `POSITIVE_NUMBER_REGEX`) |
| `unit_name` | string | No | Unit name |
| `unit_price` | string | No | Number (regex: `NUMBER_REGEX`) |
| `vat_rate` | string | No | Percentage (regex: `PERCENTAGE_REGEX`) |
| `discount_percentage` | string | No | Percentage |
| `type` | string | No | One of: `"services"`, `"goods"`, `"electronic_services"` |

### Response

- **201**: Created sales invoice (full `SalesInvoiceModel`)
- **400**: Validation error

---

## PATCH /companies/{company_id}/sales-invoices/{invoice_id}

Update an existing sales invoice. Only the fields listed below are accepted; any additional properties will cause a validation error.

### Request Body (JSON)

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `description` | string | No | Invoice description |
| `internal_notes` | string | No | Internal notes |
| `invoice_date` | string (ISO date) | No | Invoice date |
| `due_date` | string (ISO date) | No | Due date |
| `our_reference` | string | No | Our reference |
| `your_reference` | string | No | Your reference |
| `currency` | string | No | Must be `"EUR"` |
| `invoicing_channel` | string | No | One of: `"email"`, `"einvoice"`, `"letter"` |
| `recipient` | object | No | Same as POST |
| `recipient_invoicing_email` | string | No | |
| `recipient_invoicing_address` | object | No | Same as POST |
| `lines` | array | No | Line items (min 1 if provided) |

### Read-only Fields (do NOT send)

- `id`
- `created_at`
- `updated_at`
- `journal_number` / `invoice_number`
- `status`
- `payment_term`
- `gross_amount`
- `vat_amount`

### Response

- **200**: Updated sales invoice
- **400**: Validation error
- **404**: Invoice not found

---

## Model Alignment Notes

The Flutter `SalesInvoiceModel` and `InvoiceLineModel` may have slightly different field names. When building the request payload:

- Use `toJson()` but **remove** read-only fields before sending
- Map `RecipientModel` to `{ id, name, ... }` — the API expects `recipient.id` for existing parties
- For lines, the API uses `title` and `description`; the Flutter model uses `description` — both map to the line item description
- Ensure numeric strings (`quantity`, `unit_price`, `vat_rate`) are sent as strings, not numbers (the API validates with regex)
