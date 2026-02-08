# Rise Flutter Exercise - Instructions

## Overview

Welcome to the Rise Flutter Exercise! This is a live-coding session designed to assess your Flutter development skills, mobile app architecture understanding, API integration capabilities, and code quality practices.

## Exercise Goal

You will be implementing two missing features in a simplified accounting application:
1. **Stage 1**: Create (POST) sales invoices
2. **Stage 2**: Update (PATCH) sales invoices

The application already has fully functional viewing capabilities (list and detail views), so you can focus on implementing the create and update functionality.

## Test Account Credentials

**Email:** `test@risebank.com`  
**Password:** `TestPassword123!`  
**Company ID:** The company ID will be automatically retrieved from the `/me` (whoAmI) endpoint after successful login. The app fetches it from the user's permissions. If the whoAmI endpoint doesn't return a company ID, the app falls back to `company-123` as specified in the instructions.

## Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK
- IDE of your choice (VS Code, Android Studio, etc.)
- Git

## Setup Instructions

1. **Clone the repository:**
   ```bash
   git clone https://github.com/risebank/rise-flutter-exercise.git
   cd rise-flutter-exercise
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Set up environment variables:**
   ```bash
   cp .env.example .env.dev
   ```
   The `.env.dev` file is already configured with development environment values matching `rise-mobile-app`. 
   The app loads `.env.dev` by default (development environment).

4. **Run code generation:**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

5. **Run the app:**
   ```bash
   flutter run
   ```

## Application Structure

The application follows a feature-based architecture similar to `rise-mobile-app`:

```
lib/
├── main.dart                          # App entry point
├── amplifyconfiguration.dart          # Amplify setup
└── src/
    ├── globals/                       # Shared utilities
    │   ├── config/                    # Configuration
    │   ├── services/                  # API client, interceptors
    │   └── utils/                     # Error messages, etc.
    └── features/
        ├── auth/                      # Authentication (sign-in only)
        │   ├── models/
        │   ├── providers/
        │   ├── screens/
        │   └── services/
        └── sales/                     # Sales invoices feature
            ├── models/
            ├── providers/
            ├── screens/
            ├── services/
            └── widgets/
```

## Architecture Patterns

### State Management
- Uses **Riverpod** with `@riverpod` annotations for state management
- All providers use `AsyncValue` for async state handling
- Follow the existing patterns in `auth_provider.dart` and `sales_provider.dart`

### API Calls
- All API calls go through `ApiClient` in `lib/src/globals/services/api_client.dart`
- Use `ApiResponse<T>` wrapper for consistent error handling
- Follow the pattern in `sales_service.dart` for GET requests

### Error Handling
- Use `ErrorMessages` utility for user-friendly error messages
- Display errors using SnackBar or error widgets
- Show success messages for create/update operations

### Code Style
- Follow Dart/Flutter style guide
- Use meaningful variable and function names
- Add comments where necessary
- The CI pipeline will check formatting and analysis

## Exercise Tasks

### Stage 1: Create Sales Invoice (POST)

**Location:** `lib/src/features/sales/services/sales_service.dart`

**Task:** Implement the `createSalesInvoice` method.

**Requirements:**
1. Use `_apiClient.post()` method
2. Endpoint: `/companies/{company_id}/sales-invoices`
3. Send `SalesInvoiceModel` as JSON (exclude `id`, `created_at`, `updated_at`)
4. Parse the response and return `ApiResponse<SalesInvoiceModel>`
5. Handle errors appropriately

**Hints:**
- Look at `fetchSalesInvoices` for endpoint pattern
- Use `invoice.toJson()` to convert model to JSON
- Remove read-only fields before sending
- Use `ApiResponse.fromApiClientResponse` for parsing

**Testing:**
- After implementation, you should be able to create a new invoice
- The invoice should appear in the list after creation
- Show a success message after successful creation

### Stage 2: Update Sales Invoice (PATCH)

**Location:** `lib/src/features/sales/services/sales_service.dart`

**Task:** Implement the `updateSalesInvoice` method.

**Requirements:**
1. Use `_apiClient.patch()` method
2. Endpoint: `/companies/{company_id}/sales-invoices/{invoice_id}`
3. Send partial `SalesInvoiceModel` as JSON (exclude read-only fields)
4. Parse the response and return `ApiResponse<SalesInvoiceModel>`
5. Handle errors appropriately

**Read-only fields to exclude:**
- `id`
- `created_at`
- `updated_at`
- `journal_number`
- `status`
- `payment_term` (for updates)

**Hints:**
- Look at `fetchSalesInvoiceById` for endpoint pattern
- Use `invoice.toJson()` and remove read-only fields
- Use `ApiResponse.fromApiClientResponse` for parsing

**Testing:**
- After implementation, you should be able to update an existing invoice
- Changes should be reflected in the detail view
- Show a success message after successful update

## Environment Configuration

This exercise uses the **development environment** setup, matching the configuration from `rise-mobile-app`:
- **Environment:** Development (`ENVIRONMENT=dev`)
- **API Base URL:** Development API endpoint
- **Cognito:** Development user pool and client ID
- **Region:** `eu-central-1`

The configuration is loaded from `.env.dev` file by default, following the same pattern as `rise-mobile-app`'s `main_dev.dart`.

## API Endpoints Reference

### Base URL
The base URL is configured in `.env.dev` file as `API_BASE_URL` (development environment).

### Authentication
All API calls require authentication via Bearer token (handled automatically by `AuthInterceptor`).

### Endpoints

#### GET /companies/{company_id}/sales-invoices
- **Status:** ✅ Fully implemented
- **Returns:** List of sales invoices
- **Query params:** `offset`, `limit`

#### GET /companies/{company_id}/sales-invoices/{invoice_id}
- **Status:** ✅ Fully implemented
- **Returns:** Single sales invoice

#### POST /companies/{company_id}/sales-invoices
- **Status:** ❌ TODO - Stage 1
- **Body:** SalesInvoiceModel (without id, timestamps)
- **Returns:** Created sales invoice

#### PATCH /companies/{company_id}/sales-invoices/{invoice_id}
- **Status:** ❌ TODO - Stage 2
- **Body:** Partial SalesInvoiceModel (without read-only fields)
- **Returns:** Updated sales invoice

## Code Quality Requirements

The CI pipeline checks:
- ✅ Code formatting (`dart format`)
- ✅ Static analysis (`flutter analyze`)
- ✅ Tests (`flutter test`)

Make sure your code:
- Passes all formatting checks
- Has no analysis errors or warnings
- Follows the existing code patterns
- Includes proper error handling

## Tips

1. **Start with Stage 1** - Get create working first, then move to update
2. **Test incrementally** - Test each endpoint as you implement it
3. **Follow patterns** - Look at existing GET implementations for guidance
4. **Handle errors** - Use `ErrorMessages` for user-friendly messages
5. **Show feedback** - Display success/error messages to users
6. **Check CI** - Make sure your code passes CI checks before finishing

## Questions?

During the live-coding session, feel free to ask questions about:
- API endpoint details
- Expected request/response formats
- Architecture patterns
- Error handling approaches

## Good Luck! 🚀

Take your time, follow the patterns, and don't hesitate to ask for clarification if needed.
