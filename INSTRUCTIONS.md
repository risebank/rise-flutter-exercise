# Rise Flutter Exercise - Instructions

## Overview

This is a **1-hour live-coding session** that assesses your ability to interpret an assignment, follow existing patterns, and implement features. AI coding tools (Cursor, Claude, Copilot, etc.) are encouraged.

You will implement two features in a simplified accounting application:

1. **Task 1**: Create (POST) sales invoices
2. **Task 2**: Update (PATCH) sales invoices

Viewing (list and detail) is already implemented. You focus on create and update, including UI design.

**Suggested order:** Start with Task 1 (service → provider → screen → route). Move to Task 2 when Task 1 is working. Prioritize working code over perfection.

**Session format:** ~1 hour. You will be observed while implementing. Explain your approach and decisions as you go.

## Prerequisites

### Flutter & Dart

- **Flutter SDK**: 3.24 or later (stable channel)
- **Dart SDK**: 3.5 or later (bundled with Flutter)
- **IDE**: Cursor, VS Code, Android Studio, or similar
- **Git**

**Recommended:** Use [FVM](https://fvm.app/) with the project's `.fvmrc` (Flutter 3.38.3) for consistent versions:

```bash
fvm install
fvm use
```

### Supported Platforms

The exercise supports:

- **Web** (Chrome recommended)
- **Android**
- **iOS**

Desktop (Windows, macOS, Linux) is not supported.

### Verify Setup

```bash
flutter doctor
flutter run -d chrome   # or -d android, -d ios
```

## Test Account

| Field      | Value                          |
| ---------- | ------------------------------ |
| Email      | `test@risegroup.eu`            |
| Password   | `TestPassword123!`             |
| Company ID | Fetched from `/me` after login |

## Setup

1. **Clone and branch**

   ```bash
   git clone <repository-url>
   cd rise-flutter-exercise
   git fetch origin
   git checkout develop
   git checkout -b feature/{your-name}-sales-invoices
   ```

2. **Install and generate**

   ```bash
   flutter pub get
   dart run build_runner build --delete-conflicting-outputs
   ```

3. **Run**
   ```bash
   flutter run -d chrome   # or -d android, -d ios
   ```

## Application Structure

```
lib/src/
├── globals/           # ApiClient, theme, ErrorMessages, Endpoints
├── features/
│   ├── auth/          # Login, whoAmI
│   └── sales/         # Models (incl. PartyListItemModel), providers, services, screens, widgets
```

`SalesService.fetchParties` and `PartyListItemModel` are provided for Task 1 recipient selection.

## Patterns

| Area   | Pattern                                                  |
| ------ | -------------------------------------------------------- |
| State  | Riverpod with `@riverpod`, `AsyncValue`                  |
| API    | `ApiClient`, `ApiResponse.fromApiClientResponse`         |
| Errors | `ErrorMessages` utility, SnackBar for feedback           |
| UI     | `RiseAppThemeExtension`, `RiseCard`, `RiseSectionHeader` |

---

## Task 1: Create Sales Invoice (POST)

### Backend

- **Method:** `createSalesInvoice` in `lib/src/features/sales/services/sales_service.dart`
- **Endpoint:** `POST /companies/{company_id}/sales-invoices`
- **Payload:** See [API Reference](docs/API_REFERENCE.md)

### Requirements

1. Implement `createSalesInvoice` using `_apiClient.post()`
2. Exclude read-only fields: `id`, `created_at`, `updated_at`
3. Return `ApiResponse<SalesInvoiceModel>`
4. Add create screen and route (e.g. `/sales-invoices/create`)
5. Add navigation (e.g. FAB on list screen)
6. Use `SalesInvoiceCreator` provider
7. Show success/error messages and navigate after success

### API Notes

- **Recipient:** The API requires `recipient.id` with a valid party UUID. Use `SalesService.fetchParties` (GET `/companies/{id}/parties?scope=associated`) to load parties for a recipient dropdown. `PartyListItemModel.toRecipient()` builds the payload.
- **Lines:** At least one line with `description`, `quantity`, `unit_price`, `vat_rate` (sent as strings per [API Reference](docs/API_REFERENCE.md))

---

## Task 2: Update Sales Invoice (PATCH)

### Backend

- **Method:** `updateSalesInvoice` in `lib/src/features/sales/services/sales_service.dart`
- **Endpoint:** `PATCH /companies/{company_id}/sales-invoices/{invoice_id}`
- **Payload:** See [API Reference](docs/API_REFERENCE.md)

### Read-only Fields (do not send)

`id`, `created_at`, `updated_at`, `journal_number`, `status`, `payment_term`, `gross_amount`, `vat_amount`

### Requirements

1. Implement `updateSalesInvoice` using `_apiClient.patch()`
2. Send only allowed fields (see API Reference)
3. Return `ApiResponse<SalesInvoiceModel>`
4. Add edit screen and route (e.g. `/sales-invoices/:invoiceId/edit`)
5. Add navigation (e.g. Edit button on detail screen)
6. Use `UpdateSalesInvoice` provider
7. Pre-populate form with existing invoice data
8. Show success/error messages and navigate after success

---

## API Reference

See **[docs/API_REFERENCE.md](docs/API_REFERENCE.md)** for:

- POST and PATCH request schemas
- Recipient and address formats
- Line item format
- Validation rules

---

## Code Quality & CI

Before submitting, ensure:

```bash
dart format .
flutter analyze
flutter test
```

CI runs formatting, analysis, and tests. All must pass.

---

## Tests

### Existing Tests

- `test/environment_test.dart`
- `test/models/sales_invoice_model_test.dart`
- `test/services/endpoints_test.dart`
- `test/services/sales_service_test.dart`

### Required New Tests

In `test/services/sales_service_test.dart`:

- **Task 1 - createSalesInvoice:** success, errors, JSON serialization (no read-only fields), response parsing
- **Task 2 - updateSalesInvoice:** success, errors, partial update, JSON serialization, response parsing

Replace the `UnimplementedError` expectation with tests for the implemented behavior (e.g. mock `ApiClient`).

---

## Submitting

1. Run `flutter test`, `dart format .`, `flutter analyze`
2. Commit and push your feature branch
3. Open a PR against **`develop`** (not `main`)
4. Fix any CI failures before review

---

## Environment

Default fallbacks work without configuration. Optional overrides:

- Copy `.env.example` to `.env.local`, or
- Set `API_BASE_URL`, `COGNITO_USER_POOL_ID`, `COGNITO_CLIENT_ID`, `AWS_REGION`, `ENVIRONMENT`

---

## Tips

1. Start with Task 1
2. Follow `fetchSalesInvoices` and `fetchSalesInvoiceById` as patterns
3. Use `SalesService.fetchParties` for the recipient dropdown; `PartyListItemModel.toRecipient()` for the payload
4. Use `invoice.toJson()` and remove read-only fields before sending
5. Reuse form components between create and edit
6. Use `ErrorMessages` for all user-facing messages
7. **AI-assisted:** Reference the API Reference and existing code (e.g. `sales_service.dart`, `sales_invoice_detail_screen.dart`) when asking AI to implement. The API has strict schemas—sending extra fields causes validation errors.
