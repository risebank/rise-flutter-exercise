# Rise Flutter Exercise - Instructions

## Overview

Welcome to the Rise Flutter Exercise! This is a live-coding session designed to assess your Flutter development skills, mobile app architecture understanding, API integration capabilities, and code quality practices.

## Exercise Goal

You will be implementing two missing features in a simplified accounting application:
1. **Task 1**: Create (POST) sales invoices
2. **Task 2**: Update (PATCH) sales invoices

The application already has fully functional viewing capabilities (list and detail views), so you can focus on implementing the create and update functionality.

**Important**: You are responsible for designing and implementing the UI for both tasks. The application provides a design system and theme, but the specific UI/UX choices for the create and update screens are up to you.

## Test Account Credentials

**Email:** `test@risegroup.eu`  
**Password:** `TestPassword123!`  
**Company ID:** The company ID will be automatically retrieved from the `/me` (whoAmI) endpoint after successful login. The app fetches it from the user's permissions.

## Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK
- IDE of your choice (VS Code, Android Studio, etc.)
- Git

## Setup Instructions

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd rise-flutter-exercise
   ```

2. **Checkout the develop branch and create your feature branch:**
   ```bash
   # Fetch all branches
   git fetch origin
   
   # Checkout the develop branch
   git checkout develop
   
   # Create a new feature branch for your work
   git checkout -b feature/your-name-sales-invoices
   ```
   
   **Important:** Always base your feature branch from `develop`, not `main`. This ensures you're working with the latest codebase.

3. **Install dependencies:**
   ```bash
   flutter pub get
   ```

4. **Run code generation:**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

5. **Run the app:**
   ```bash
   flutter run
   ```

## Application Structure

The application follows a feature-based architecture:

```
lib/
├── main.dart                          # App entry point
├── amplifyconfiguration.dart          # Amplify setup
└── src/
    ├── globals/                       # Shared utilities
    │   ├── config/                    # Configuration
    │   ├── services/                  # API client, interceptors
    │   ├── theme/                     # Theme configuration
    │   ├── widgets/                   # Reusable widgets
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

**Important:** Please proceed carefully through both tasks. Take your time to understand the existing codebase structure, follow the patterns established in the code, and ensure your implementation is complete and well-tested before moving to the next task.

### Task 1: Create Sales Invoice (POST)

**Objective:** Implement the feature for creation of a new sales invoice. You are responsible for designing the UI and implementing the backend integration.

**Backend Integration:**
- **Location:** `lib/src/features/sales/services/sales_service.dart`
- **Method:** `createSalesInvoice`
- **Endpoint:** `POST /companies/{company_id}/sales-invoices`
- **Payload:** `SalesInvoiceModel` as JSON (exclude `id`, `created_at`, `updated_at`)

**Requirements:**
1. Implement the `createSalesInvoice` method in `SalesService`
2. Use `_apiClient.post()` method
3. Send `SalesInvoiceModel` as JSON (exclude read-only fields)
4. Parse the response and return `ApiResponse<SalesInvoiceModel>`
5. Handle errors appropriately
6. Design and implement a UI screen for creating invoices
7. Add a route in `main.dart` for the create screen (e.g., `/sales-invoices-create`)
8. Add navigation to the create screen (e.g., a FloatingActionButton on the list screen or a button in the AppBar)
9. Connect the UI to the service method via the provider (`SalesInvoiceCreator`)
10. Show success/error messages to the user
11. Navigate appropriately after successful creation (e.g., back to list or to detail view)

**Hints:**
- Look at `fetchSalesInvoices` for endpoint pattern
- Use `invoice.toJson()` to convert model to JSON
- Remove read-only fields before sending
- Use `ApiResponse.fromApiClientResponse` for parsing
- Check `SalesInvoiceModel` to understand required fields
- Use the existing design system and theme for UI consistency

**Testing:**
- After implementation, you should be able to create a new invoice
- The invoice should appear in the list after creation
- Show a success message after successful creation
- Handle validation errors appropriately

### Task 2: Update Sales Invoice (PATCH)

**Objective:** Implement the feature for updating existing sales invoices. You are responsible for designing the UI and implementing the backend integration.

**Backend Integration:**
- **Location:** `lib/src/features/sales/services/sales_service.dart`
- **Method:** `updateSalesInvoice`
- **Endpoint:** `PATCH /companies/{company_id}/sales-invoices/{invoice_id}`
- **Payload:** Partial `SalesInvoiceModel` as JSON (exclude read-only fields)

**Read-only fields to exclude:**
- `id`
- `created_at`
- `updated_at`
- `journal_number`
- `status`
- `payment_term` (for updates)

**Requirements:**
1. Implement the `updateSalesInvoice` method in `SalesService`
2. Use `_apiClient.patch()` method
3. Send partial `SalesInvoiceModel` as JSON (exclude read-only fields)
4. Parse the response and return `ApiResponse<SalesInvoiceModel>`
5. Handle errors appropriately
6. Design and implement a UI screen for updating invoices
7. Add a route in `main.dart` for the edit screen (e.g., `/sales-invoices/:invoiceId/edit`)
8. Add navigation to the edit screen (e.g., an "Edit" button in the detail screen's AppBar)
9. Connect the UI to the service method via the provider (`UpdateSalesInvoice`)
10. Show success/error messages to the user
11. Navigate appropriately after successful update (e.g., back to detail view)
12. Pre-populate the form with existing invoice data

**Hints:**
- Look at `fetchSalesInvoiceById` for endpoint pattern
- Use `invoice.toJson()` and remove read-only fields
- Use `ApiResponse.fromApiClientResponse` for parsing
- Check `SalesInvoiceModel` to understand all fields
- Use the existing design system and theme for UI consistency
- Consider reusing UI components from Task 1 where appropriate

**Testing:**
- After implementation, you should be able to update an existing invoice
- Changes should be reflected in the detail view
- Show a success message after successful update
- Handle validation errors appropriately

## Environment Configuration

This exercise uses environment variables with fallback values. The application will work out of the box using fallback values, but you can optionally configure your own:

**Option 1: Use Default Values (Recommended)**
- The application includes fallback values that work for the test environment
- No configuration needed - just run the app

**Option 2: Set Environment Variables Locally**
- Copy `.env.example` to `.env.local` (not committed to git)
- Or set environment variables in your IDE/terminal:
  ```bash
  export API_BASE_URL="your-api-url"
  export COGNITO_USER_POOL_ID="your-pool-id"
  export COGNITO_CLIENT_ID="your-client-id"
  export AWS_REGION="eu-central-1"
  export ENVIRONMENT="dev"
  ```

The application reads from environment variables first, then falls back to default values if not set. See `.env.example` for the expected format.

## API Endpoints Reference

### Base URL
The base URL is configured via environment variables (see Environment Configuration section above). The application uses fallback values by default, which are configured for the test environment.

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
- **Status:** ❌ TODO - Task 1
- **Body:** SalesInvoiceModel (without id, timestamps)
- **Returns:** Created sales invoice

#### PATCH /companies/{company_id}/sales-invoices/{invoice_id}
- **Status:** ❌ TODO - Task 2
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
- Uses the existing design system and theme

## Testing Requirements

### Existing Tests

The repository includes tests for:
- Environment configuration (`test/environment_test.dart`)
- Sales invoice models (`test/models/sales_invoice_model_test.dart`)
- Endpoints (`test/services/endpoints_test.dart`)
- Service method placeholders (`test/services/sales_service_test.dart`)

### Test Requirements for Tasks

**Task 1 (Create Sales Invoice):**
- Add unit tests for `createSalesInvoice` method in `test/services/sales_service_test.dart`
- Test cases should cover:
  - Successful invoice creation
  - Error handling (network errors, validation errors, etc.)
  - Proper JSON serialization (excluding read-only fields: `id`, `created_at`, `updated_at`)
  - Response parsing
  - Endpoint URL construction
  - Request payload format

**Task 2 (Update Sales Invoice):**
- Add unit tests for `updateSalesInvoice` method in `test/services/sales_service_test.dart`
- Test cases should cover:
  - Successful invoice update
  - Error handling (network errors, validation errors, etc.)
  - Proper JSON serialization (excluding read-only fields: `id`, `created_at`, `updated_at`, `journal_number`, `status`)
  - Partial update handling
  - Response parsing
  - Endpoint URL construction
  - Request payload format

**Test Structure:**
- Use `flutter_test` package (already included)
- Follow existing test patterns in the repository
- Use descriptive test names
- Group related tests using `group()`
- Ensure all tests pass before submitting

**Running Tests:**
```bash
flutter test
```

All tests must pass for CI to succeed.

## Submitting Your Work

### Creating a Pull Request

Once you have completed both tasks:

1. **Ensure all tests pass locally:**
   ```bash
   flutter test
   dart format .
   flutter analyze
   ```

2. **Commit your changes:**
   ```bash
   git add .
   git commit -m "Implement Task 1 and Task 2: Create and update sales invoices"
   ```

3. **Push your feature branch:**
   ```bash
   git push origin feature/your-name-sales-invoices
   ```

4. **Create a Pull Request:**
   - Go to the repository on GitHub
   - Click "New Pull Request"
   - Set the base branch to **`develop`** (not `main`)
   - Set the compare branch to your feature branch
   - Add a descriptive title and description
   - Submit the PR

5. **CI Checks:**
   - The CI pipeline will automatically run when you create the PR
   - All checks must pass:
     - ✅ Code formatting (`dart format`)
     - ✅ Static analysis (`flutter analyze`)
     - ✅ Tests (`flutter test`)
   - Fix any failing checks before requesting review

6. **Review Process:**
   - Your PR will be reviewed against the `develop` branch
   - Address any feedback or requested changes
   - Once approved, your PR will be merged into `develop`

## Tips

1. **Start with Task 1** - Get create working first, then move to update
2. **Test incrementally** - Test each endpoint as you implement it
3. **Follow patterns** - Look at existing GET implementations for guidance
4. **Handle errors** - Use `ErrorMessages` for user-friendly messages
5. **Show feedback** - Display success/error messages to users
6. **Design thoughtfully** - Consider UX best practices for forms
7. **Check CI** - Make sure your code passes CI checks before finishing
8. **Review models** - Check `SalesInvoiceModel` to understand all available fields
9. **Work carefully** - Take your time to understand the codebase before implementing
10. **Ask questions** - Don't hesitate to ask for clarification during the session

## Questions?

During the live-coding session, feel free to ask questions about:
- API endpoint details
- Expected request/response formats
- Architecture patterns
- Error handling approaches
- Design system usage

## Good Luck! 🚀

Take your time, follow the patterns, and don't hesitate to ask for clarification if needed.
