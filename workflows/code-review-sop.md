# Code Review Standard Operating Procedure (SOP) — Adversarial Review & Quality Assurance

> **Scope:** Monorepo codebase ([`laravel/`](file:///d:/Project/Fastwork/rental.apartemen/laravel) and [`flutter/`](file:///d:/Project/Fastwork/rental.apartemen/flutter))
> **Reference Standard:** 4-Angle Adversarial Quality Framework + Zero-Tolerance Regression Matrix

---

## 1. The 4-Angle Adversarial Code Review Framework

Before any code modification or pull request is eligible for integration into `main` or `staging`, it must undergo automated or paired adversarial auditing across four distinct evaluation vectors.

```
                   ┌───────────────────────────────────────────────┐
                   │               CODE PULL REQUEST               │
                   └───────────────────────┬───────────────────────┘
                                           │
         ┌───────────────────┬─────────────┴───────┬───────────────────┐
         ▼                   ▼                     ▼                   ▼
┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
│     ANGLE 1     │ │     ANGLE 2     │ │     ANGLE 3     │ │     ANGLE 4     │
│ Security & IDOR │ │ Correctness &   │ │ Real-Data &     │ │ Concurrency &   │
│                 │ │ Business Logic  │ │ Formatting      │ │ Async States    │
└────────┬────────┘ └────────┬────────┘ └────────┬────────┘ └────────┬────────┘
         │                   │                     │                   │
         └───────────────────┼─────────────────────┴───────────────────┘
                             │
                             ▼
            ┌──────────────────────────────────┐
            │   ADVERSARIAL VERDICT REPORT     │
            │  (PASS / BLOCKED with BL-FAIL)   │
            └──────────────────────────────────┘
```

---

### Angle 1: Security & IDOR Verification

The reviewer explicitly attempts to exploit the code through unauthorized access and malicious inputs.

- **Check 1.1: Multi-Tenant Host ID Isolation**
  - Verify every Controller endpoint inspecting or mutating an accommodation, booking, order, or room-type rigorously validates ownership:
    ```php
    // VULNERABLE: Bypasses check if host_id is null
    if ($accommodation->host_id && $accommodation->host_id !== $user->id) abort(403);

    // SECURE (Mandatory Livirooms Standard):
    if (! $user || ! $accommodation || $accommodation->host_id !== $user->id) {
        if (! $user->hasRole('admin')) {
            return ApiResponse::error('Anda tidak memiliki akses ke properti ini.', 403);
        }
    }
    ```
- **Check 1.2: Path Traversal in File & Gallery Handlers**
  - Verify photo deletion and upload endpoints do not accept raw directory relative paths (`../../`):
    ```php
    $imageParam = $request->query('image') ?? $request->query('path');
    $cleanFilename = basename($imageParam); // Mandatory basename sanitization
    ```
- **Check 1.3: Mass Assignment & Eloquent Injection**
  - Confirm `$fillable` is explicitly declared. Reject `$request->all()` passed directly to `Model::create()` or `Model::update()`.
- **Check 1.4: Mobile Credential Storage**
  - Verify access tokens, refresh tokens, and biometric PINs use encrypted hardware storage (`FlutterSecureStorage`), never unencrypted shared preferences.

---

### Angle 2: Correctness & Logic Validation

The reviewer verifies business invariants across accommodation types, state transitions, and pricing schedules.

- **Check 2.1: Hotel vs. Property Invariant Enforcement**
  - Verify `booking_mode` adherence ([`docs/domain/hotel-vs-property.md`](file:///d:/Project/Fastwork/rental.apartemen/docs/domain/hotel-vs-property.md)):
    - Mode `'unit'` (Apartment/Villa): 1 internal `unit_type` record, pricing mapped via `unit_type_prices`.
    - Mode `'room'` (Hotel): multiple distinct `unit_types` with inventory counts.
- **Check 2.2: Order & Booking State Machine Transitions**
  - Verify transitions adhere strictly to allowed state paths:
    `pending_payment` ➔ `confirmed` (via Midtrans webhook) ➔ `checked_in` ➔ `completed` / `cancelled`.
  - Ensure client callbacks **never** directly mutate order payment status (`docs/payments/system.md`). The webhook is the single source of truth.
- **Check 2.3: Strike-Through & Original Pricing Integrity**
  - Verify `price_original` is always greater than or equal to discounted `base_price`.
  - Ensure null values are safely handled without mutating non-discounted listings.

---

### Angle 3: Real-Data Reproduction & Data-Clustering

The reviewer stress-tests edge-case data shapes, localized formatting, and database casting.

- **Check 3.1: Indonesian Currency & Numeric Formatting Pitfall**
  - Dart's `double.tryParse("500.000")` parses to `500.0` (decimal fraction), truncating Indonesian currency. All inputs must strip dots before parsing:
    ```dart
    final cleanAmount = double.tryParse(rawControllerText
        .replaceAll('.', '')
        .replaceAll(',', '')
        .replaceAll(' ', '')
        .trim());
    ```
- **Check 3.2: PostgreSQL vs. SQLite Driver Differences**
  - PostgreSQL enforces strict type checking and case sensitivity on `ILIKE`. Queries must not rely on SQLite-specific permissive type coercion.
- **Check 3.3: Pagination and Nullable Collection Safety**
  - APIs must return standardized `data: []` arrays and `meta` blocks (`current_page`, `last_page`, `total`), not null fields.
  - Mobile model factories (`fromJson`) must use defensive extractors (`Formatters.asInt`, `Formatters.asString`).

---

### Angle 4: Concurrency, Deadlocks & Asynchronous States

The reviewer analyzes race conditions, high-traffic collisions, and unmounted Flutter widget lifecycles.

- **Check 4.1: Pessimistic Row Locking on Inventory & Pricing**
  - Updating room availability or price records must occur inside `DB::transaction()` with pessimistic row locks to prevent simultaneous double-booking:
    ```php
    DB::transaction(function () use ($unitPriceId, $payload) {
        $price = UnitTypePrice::where('id', $unitPriceId)->lockForUpdate()->firstOrFail();
        $price->update($payload);
    });
    ```
- **Check 4.2: Asynchronous Mounted Guards in Flutter**
  - Every `await` in Flutter widgets must be immediately followed by a mount check prior to interacting with context or calling `setState()`:
    ```dart
    final result = await _hostService.updateProperty(id, payload);
    if (!mounted) return; // Mandatory guard
    ScaffoldMessenger.of(context).showSnackBar(...);
    ```
- **Check 4.3: Un-uploaded Local File Stripping**
  - When submitting galleries or media arrays, un-uploaded local file paths (`file:///`, `/data/user/`) must be stripped so local device paths do not corrupt the server database.

---

## 2. Business Logic Failure Reporting Standard (`BL-FAIL`)

When an adversarial review identifies a logic or security flaw, it must be documented using the standardized failure schema.

### Failure Severity Classification Matrix

| Severity | Definition | SLA / Blocking Rule |
|---|---|---|
| **CRITICAL** | IDOR vulnerability, unauthorized financial mutation, double-booking race condition, or app crash on primary user path. | **PR Hard Block.** Hotfix required within 4 hours. |
| **HIGH** | Business rule invariant violation, currency truncation, broken filter in listing search, unhandled null exception. | **PR Hard Block.** Must be resolved before merge. |
| **MEDIUM** | Missing secondary validation, non-optimized N+1 query, non-critical localized string formatting issue. | Merge allowed with approved remediation task. |
| **LOW** | Code cleanliness, missing docstring, minor UI padding misalignment. | Non-blocking. Logged for sprint cleanup. |

### Standard Incident / Bug Report Template
```markdown
### [BL-FAIL-042] Vulnerability / Logic Flaw Summary
- **Target File:** `laravel/app/Http/Controllers/Api/UnitTypePriceController.php`
- **Severity:** CRITICAL
- **Angle:** Angle 1 (Security/IDOR) & Angle 4 (Concurrency)
- **Problem Statement:**
  Record authorization allowed modification of unit prices where host_id was unassigned.
  Concurrent updates did not utilize database row locking.
- **Reproduction Steps:**
  1. Authenticate as Host User B.
  2. Send PUT `/api/v1/unit-type-prices/{id}` targeting Price belonging to Host User A.
  3. Observe HTTP 200 instead of HTTP 403.
- **Exploit / Impact Scenario:**
  Malicious or rogue partner modifies pricing of competitors' hotel rooms.
- **Prescribed Solution:**
  1. Add strict host ownership check: `if ($accommodation->host_id !== $user->id) abort(403);`
  2. Wrap in `DB::transaction()` with `UnitTypePrice::lockForUpdate()`.
- **Regression Test Added:**
  `tests/Feature/Api/UnitTypePriceApiTest.php::test_orphaned_or_unauthorized_price_record_is_blocked`
```

---

## 3. Pull Request (PR) Checklist & CI Pipeline Automation

Every Pull Request submitted to the repository must satisfy the automated CI validation gate:

```
[ Developer Pushes Branch ]
            │
            ▼
┌────────────────────────────────────────┐
│         PRE-COMMIT AUTOMATION          │
│  - PHP CS Fixer & Pint                 │
│  - Dart Formatter & Flutter Analyze    │
└───────────────────┬────────────────────┘
                    │
                    ▼
┌────────────────────────────────────────┐
│           CI PIPELINE AUDIT            │
│  1. `composer audit` (PHP Security)    │
│  2. `php artisan test` (Laravel Suite) │
│  3. `flutter test` (Mitra & Guest)     │
│  4. Contract Diff Check vs docs/ai/    │
└───────────────────┬────────────────────┘
                    │
                    ▼
┌────────────────────────────────────────┐
│       MULTI-AGENT REVIEW BOT           │
│  Runs 4-Angle Audit + PR Checklist     │
│  Signs off or blocks merge             │
└────────────────────────────────────────┘
```

### Mandatory PR Author Checklist
Before requesting review, the author confirms:
- [ ] **Zero Database Drift:** Any new column or relation has an accompanying migration with reversible `down()` method.
- [ ] **Contract Sync:** Any updated API endpoint has been mirrored in [`docs/ai/03-api-contract.md`](file:///d:/Project/Fastwork/rental.apartemen/docs/ai/03-api-contract.md).
- [ ] **Defensive Parsing:** Flutter models use `.replaceAll('.', '')` on Indonesian currency fields.
- [ ] **Mounted Safety:** All async methods in Flutter widgets check `if (!mounted) return;`.
- [ ] **Tests Passing:** `php artisan test` passes with zero failures; `flutter test` passes with 100% success rate.
- [ ] **Documentation Update:** [`docs/ai/04-drift-register.md`](file:///d:/Project/Fastwork/rental.apartemen/docs/ai/04-drift-register.md) updated with change summary.
