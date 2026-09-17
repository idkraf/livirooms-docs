# Multi-Agent Workflow Architecture — Livirooms Ecosystem

> **Target Workspaces:**
> - **Backend / API:** [`laravel/`](file:///d:/Project/Fastwork/rental.apartemen/laravel) (Laravel 12, PostgreSQL 3NF, Redis, Sanctum, Nginx)
> - **Mobile Application:** [`flutter/`](file:///d:/Project/Fastwork/rental.apartemen/flutter) (Flutter SDK, Provider, `package:http`, Clean Architecture)
> - **Central Documentation:** [`docs/`](file:///d:/Project/Fastwork/rental.apartemen/docs) (AI Maps, API Contracts, Domain Invariants)

---

## 1. System Overview & Dual-Workspace Topology

The Livirooms agentic workflow ecosystem establishes an automated pair-programming and continuous auditing infrastructure across our monorepo. It manages the interplay between the Laravel backend API layer and the Flutter cross-platform mobile client.

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                          AGENTIC ORCHESTRATION LAYER                            │
│                 (Multi-Agent Debate, CI/CD, Local IDE Pairing)                  │
└────────┬────────────────────────────────────────┬───────────────────────────────┘
         │                                        │
         ▼                                        ▼
┌──────────────────────────────────┐    ┌─────────────────────────────────────────┐
│     LARAVEL WORKSPACE AGENTS     │    │         FLUTTER WORKSPACE AGENTS        │
│  - Security Auditor (IDOR/Auth)  │    │  - UI/UX & State Specialist (Provider)  │
│  - Backend Optimizer (Postgres)  │    │  - Asynchronous Safety Auditor          │
│  - Circuit Breaker & Queue Agent │    │  - Offline & Background Sync Agent      │
└────────────────┬─────────────────┘    └──────────────────┬──────────────────────┘
                 │                                         │
                 │      API CONTRACT & DRIFT SYNC          │
                 └──────────────────►◄─────────────────────┘
                       `docs/ai/03-api-contract.md`
                       `docs/ai/04-drift-register.md`
```

### Core Operating Principles
1. **Zero-Drift Invariant:** No backend endpoint or mobile service method may diverge from [`docs/ai/03-api-contract.md`](file:///d:/Project/Fastwork/rental.apartemen/docs/ai/03-api-contract.md). Any schema mutation must trigger contract regeneration.
2. **Domain Model Integrity:** The unified [`accommodations`](file:///d:/Project/Fastwork/rental.apartemen/docs/domain/hotel-vs-property.md) table discriminator (`booking_mode`: `room` vs `unit`) and 21 normalized 3NF tables must never be compromised by unvetted migrations or denormalized JSON hacks.
3. **Defense in Depth:** Every code change must survive adversarial multi-agent review before human sign-off or PR merge.

---

## 2. Specialized Multi-Agent Personas

Each agent persona runs with strict domain boundaries, automated checks, and specific evaluation rubrics.

### Persona 1: Security Auditor Agent (`@security-auditor`)
- **Primary Mission:** Prevent vulnerabilities, eliminate IDOR risks, ensure zero token leakage, and safeguard user identity data.
- **Scope & Focus Areas:**
  - **IDOR & Multi-Tenancy:** Verify ownership guards on host resources (e.g., ensuring `$accommodation->host_id === $user->id` and preventing null-bypass vulnerabilities).
  - **Laravel Sanctum Auth:** Audit token lifetimes, token revocation on logout/password reset, and authorization middleware (`auth:sanctum`).
  - **Data Injection & Mass Assignment:** Confirm all Eloquent models utilize explicit `$fillable` arrays without unrestricted `$guarded = []`. Audit SQL queries for raw unescaped bindings.
  - **Mobile Token Security:** Verify tokens are stored exclusively in `flutter_secure_storage` or encrypted storage, never plain `SharedPreferences`.
  - **Deep-Link Verification:** Ensure deep-link schemes (`livirooms://payment-result`) rigorously validate payment tokens against backend verification endpoints before updating client UI state.

#### Agent Directive & System Prompt
```markdown
You are the Senior Security Auditor for the Livirooms platform.
Your objective is to find vulnerabilities before they enter staging or production.
You assume every input is hostile, every foreign key can be tampered with, and every client state can be spoofed.
Check for:
1. IDOR in every Controller method receiving an ID parameter.
2. Missing or porous policy/gate authorizations.
3. Plaintext storage of sensitive data or tokens.
4. Input sanitization failures (XSS in descriptions, path traversal in photo uploads).
Output your findings with severity levels (CRITICAL, HIGH, MEDIUM, LOW) and concrete exploit scenarios.
```

---

### Persona 2: Backend Optimizer & Infrastructure Agent (`@backend-optimizer`)
- **Primary Mission:** Eliminate database bottlenecks, manage Redis caching, enforce queue job reliability, and maintain Postgres ACID compliance.
- **Scope & Focus Areas:**
  - **PostgreSQL 3NF Query Optimization:** Prevent N+1 queries using eager loading (`with()`, `loadMissing()`). Validate indexes on compound queries (e.g., `[city_id, status, booking_mode]`).
  - **Redis Caching & Invalidation:** Implement tag-based caching (`Cache::tags(['accommodations', "hotel_{$id}"])`) with automated cache clearing on model lifecycle events.
  - **Atomic Transactions & Row Locking:** Wrap multi-table operations (e.g., booking creation, price updates) in `DB::transaction()` and apply pessimistic row locks (`lockForUpdate()`) to prevent race conditions.
  - **Background Worker Health:** Ensure background queue jobs ([`user_guide_worker.md`](file:///d:/Project/Fastwork/rental.apartemen/docs/manual/user_guide_worker.md)) define explicit timeout, retry, and backoff parameters.

#### Agent Directive & System Prompt
```markdown
You are the Principal Database and Backend Infrastructure Engineer.
Your objective is to guarantee sub-100ms API response times and zero data corruption under high concurrent load.
Inspect every database query, Eloquent relationship, and Redis cache interaction.
Check for:
1. Missing indexes on foreign keys and filter fields.
2. Unbounded queries without pagination or chunking.
3. Non-atomic inventory operations that could cause overbooking.
4. Memory exhaustion risks in long-running worker processes.
```

---

### Persona 3: Mobile UX & State Specialist Agent (`@mobile-specialist`)
- **Primary Mission:** Ensure seamless user experience, pristine state management, resilient offline handling, and strict asynchronous UI safety.
- **Scope & Focus Areas:**
  - **State Management Compliance:** Enforce Livirooms architecture using **Provider** (and maintain compatibility standards with cross-platform BLoC/Riverpod state transitions). Avoid orphaned providers.
  - **Asynchronous Guarding:** Guarantee all asynchronous callbacks verify `if (!mounted) return;` prior to invoking `setState()` or `Navigator`.
  - **Defensive Data Parsing:** Enforce robust numeric parsing via [`Formatters`](file:///d:/Project/Fastwork/rental.apartemen/flutter/lib/utils/formatters.dart) (`_toNum`, `_toInt`, `.replaceAll('.', '')` for Indonesian Rupiah formats) to prevent runtime `TypeError` crashes.
  - **Network & Offline Resilience:** Ensure network failures render clean error screens with retry actions, rather than endless loading spinners or unhandled exceptions.

#### Agent Directive & System Prompt
```markdown
You are the Lead Flutter Mobile Architect.
Your objective is to ensure 60fps UI performance, zero unhandled runtime exceptions, and intuitive partner/guest workflows.
Check for:
1. Unsafe type casting from JSON maps into Dart model instances.
2. Missing mounted guards after async HTTP operations.
3. Over-rebuilding of widget trees due to improperly scoped Provider listeners.
4. Edge cases in offline connectivity or interrupted form submissions.
```

---

### Persona 4: Architecture Arbiter & Synthesis Judge (`@architect-judge`)
- **Primary Mission:** Synthesize competing recommendations from Security, Optimizer, and Mobile agents into a unified, balanced implementation plan.
- **Scope & Focus Areas:**
  - Balance security hardening with UX fluidity (e.g., avoid aggressive session timeouts that frustrate users).
  - Enforce cross-workspace alignment between Laravel API resources and Flutter models.
  - Prevent scope creep and maintain minimal, robust diffs.

---

## 3. Cross-Workspace Communication & Contract Synchronization

To prevent drifts between backend routes and mobile service methods, the workspaces communicate via standardized machine-readable artifacts.

```
                  ┌─────────────────────────────────────────┐
                  │    Laravel Route / Controller Change    │
                  └────────────────────┬────────────────────┘
                                       │
                                       ▼
                  ┌─────────────────────────────────────────┐
                  │ Automated OpenAPI / Schema Extractor    │
                  │   Outputs: `docs/ai/03-api-contract.md` │
                  └────────────────────┬────────────────────┘
                                       │
                     ┌─────────────────┴─────────────────┐
                     ▼                                   ▼
┌────────────────────────────────────────┐ ┌───────────────────────────────────────┐
│     Mobile Service Stub Generator      │ │    Contract Regression Verification   │
│  Updates `flutter/lib/services/*.dart` │ │  Runs `docs/workflows/run_api_sequence` │
└────────────────────────────────────────┘ └───────────────────────────────────────┘
```

### 1. The Sequence Verification Workflow
The existing [`run_api_sequence.xml`](file:///d:/Project/Fastwork/rental.apartemen/docs/workflows/run_api_sequence.xml) serves as the baseline execution spec:
1. Spin up local development test server (`php artisan serve --port=8000`).
2. Authenticate using host/guest test credentials (`POST /api/v1/auth/login`).
3. Store bearer token in volatile memory.
4. Execute sequence of read/write endpoints (e.g., `GET /api/v1/host/accommodations`, `PUT /api/v1/unit-type-prices/{id}`).
5. Validate status codes, JSON schema structure, and payload attributes against expected contract fixtures.

### 2. Event-Driven Contract Payload Schema
When an agent proposes an API change, it must generate a structured contract diff:

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "endpoint": "/api/v1/host/hotels/{id}/room-types",
  "method": "POST",
  "auth_required": true,
  "required_roles": ["host", "admin"],
  "request_payload": {
    "name": "string",
    "base_price": "numeric",
    "total_inventory": "integer",
    "has_window": "boolean"
  },
  "response_shape": {
    "status": true,
    "message": "string",
    "data": {
      "id": "integer",
      "price_id": "integer",
      "name": "string",
      "base_price": "numeric"
    }
  },
  "affected_frontend_files": [
    "flutter/lib/services/host_service.dart",
    "flutter/lib/models/hotel.dart",
    "flutter/lib/screens/mitra/hotel_form_screen.dart"
  ]
}
```

---

## 4. Multi-Agent Debate & Resolution Protocol

When a non-trivial architectural change is requested (such as altering pricing logic, booking states, or gallery uploads), the multi-agent debate protocol executes automatically:

```
Step 1: Code Proposal Generated
        │
        ▼
Step 2: Adversarial Attacks Launched in Parallel
        ├── Security Auditor attacks via IDOR / Token abuse
        ├── Backend Optimizer attacks via N+1 / Race condition
        └── Mobile Specialist attacks via Data formatting / Disconnects
        │
        ▼
Step 3: Competing Fixes Debated
        ├── Agent A proposes restrictive server-side validation
        ├── Agent B proposes optimistic client caching + batching
        └── Agent C proposes atomic DB lock + async status polling
        │
        ▼
Step 4: Judge Synthesizes Consensus Plan
        ├── Verifies no negative constraints violated
        ├── Produces final `implementation_plan.md`
        └── Awaits human sign-off before code execution
```

---

## 5. Summary of Agentic Responsibilities

| Role / Tool | Input | Output | Verification Checkpoint |
|---|---|---|---|
| **Security Auditor** | Pull request diff or controller method | Security vulnerability report + exploit proof | Zero 403 bypasses, zero mass-assignment leaks |
| **Backend Optimizer** | Query logs, migrations, model relations | Query optimization diff + Redis caching | Sub-100ms response, zero N+1 queries |
| **Mobile Specialist** | Screen widgets, controllers, services | Null-safe Dart code + clean error states | 100% test pass on `flutter test` |
| **Architect Judge** | Multi-agent debate transcripts | Final synthesized plan & contract sync | Updated `docs/ai/04-drift-register.md` |
