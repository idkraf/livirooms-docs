# Safety Net, Rollback Checkpoints & Resilience Engineering

> **Target Workspaces:**
> - **Backend / Database:** [`laravel/`](file:///d:/Project/Fastwork/rental.apartemen/laravel) (PostgreSQL, Redis, Queue Workers)
> - **Mobile Application:** [`flutter/`](file:///d:/Project/Fastwork/rental.apartemen/flutter) (Remote Config, Local Persistence, Workmanager)

---

## 1. Database Migration Safeguards & Reversible Evolution

In production, database migrations must execute without locking critical tables for extended periods and must always provide a safe rollback path.

```
                  ZERO-DOWNTIME SCHEMA EVOLUTION PATTERN
                  
Phase 1: EXPAND          Phase 2: DUAL-WRITE       Phase 3: CONTRACT
┌──────────────┐         ┌──────────────────────┐  ┌──────────────┐
│ Add new col  │ ──────► │ Read new col,        │ ─► Drop old col │
│ as NULLABLE  │         │ fallback to old col  │  │ after 1 cycle│
└──────────────┘         └──────────────────────┘  └──────────────┘
```

### 1. The Symmetry Rule for Migrations
Every migration file must possess a completely functional, tested `down()` method that safely reverses the `up()` method without dropping un-backed-up production data.

```php
// Example: Adding price_original to accommodations table
return new class extends Migration
{
    public function up(): void
    {
        Schema::table('accommodations', function (Blueprint $table) {
            // Always nullable on initial deploy to prevent locking existing rows
            $table->decimal('price_original', 12, 2)->nullable()->after('price_from');
            $table->index(['price_original', 'status']);
        });
    }

    public function down(): void
    {
        Schema::table('accommodations', function (Blueprint $table) {
            $table->dropIndex(['price_original', 'status']);
            $table->dropColumn('price_original');
        });
    }
};
```

### 2. Zero-Downtime Expand-and-Contract Steps
When modifying column types or splitting models:
1. **Expand:** Add the new column as `nullable`. Do not rename existing columns immediately.
2. **Dual-Write:** Update Eloquent models to write to both the old and new columns.
3. **Backfill:** Execute an idempotent Artisan chunked background command (`php artisan data:backfill-column --chunk=500`).
4. **Contract:** Point readers exclusively to the new column. Once verified across a full release cycle, drop the deprecated column via a subsequent migration.

### 3. Atomic Multi-Model Transactions & Row-Level Locking
All multi-table write operations (such as creating bookings, orders, and associated price snapshots) must execute inside `DB::transaction()`:

```php
return DB::transaction(function () use ($unitTypeId, $bookingData) {
    // 1. Acquire pessimistic lock on inventory record
    $unitType = UnitType::where('id', $unitTypeId)->lockForUpdate()->firstOrFail();

    if ($unitType->remaining <= 0) {
        throw new BookingInventoryExhaustedException('Stok kamar tidak lagi tersedia.');
    }

    // 2. Decrement remaining inventory atomically
    $unitType->decrement('remaining');

    // 3. Persist booking record with snapshot pricing
    $booking = Booking::create([...]);
    $order = Order::create([...]);

    return $order;
});
```

---

## 2. Redis-Backed Circuit Breakers for External Integrations

Livirooms interacts with external third-party services: Midtrans Payment Gateway, Third-party Insurance APIs, and FCM Push Notification services. When an external partner experiences latency or outages, a Circuit Breaker prevents cascade failures from exhausting Laravel PHP-FPM worker pools.

```
                           CIRCUIT BREAKER STATE MACHINE
                           
                   Success threshold reached
                    ┌─────────────────────────┐
                    │                         │
                    ▼                         │
            ┌──────────────┐           ┌──────────────┐
            │    CLOSED    │           │  HALF-OPEN   │
            │(Normal Flow) │           │(Canary Probe)│
            └──────┬───────┘           └──────▲───────┘
                   │                          │
   Failure limit   │                          │ Cooldown
   exceeded        │                          │ expired (60s)
                   ▼                          │
            ┌─────────────────────────────────┴┐
            │               OPEN               │
            │    (Fast-Fail & Return Fallback) │
            └──────────────────────────────────┘
```

### Circuit Breaker Implementation Architecture

```php
namespace App\Services\Resilience;

use Illuminate\Support\Facades\Redis;
use Illuminate\Support\Facades\Log;

class CircuitBreaker
{
    private const STATE_CLOSED = 'CLOSED';
    private const STATE_OPEN = 'OPEN';
    private const STATE_HALF_OPEN = 'HALF_OPEN';

    public static function execute(string $serviceKey, callable $action, callable $fallback, int $failureThreshold = 5, int $recoveryTimeoutSec = 60)
    {
        $redisKey = "circuit:{$serviceKey}";
        $state = Redis::get("{$redisKey}:state") ?? self::STATE_CLOSED;

        // 1. If Circuit is OPEN, check if recovery timeout has elapsed
        if ($state === self::STATE_OPEN) {
            $openedAt = (int) Redis::get("{$redisKey}:opened_at");
            if (time() - $openedAt > $recoveryTimeoutSec) {
                $state = self::STATE_HALF_OPEN;
                Redis::set("{$redisKey}:state", self::STATE_HALF_OPEN);
            } else {
                Log::warning("Circuit breaker OPEN for {$serviceKey}. Fast-failing to fallback.");
                return $fallback();
            }
        }

        // 2. Execute protected action
        try {
            $result = $action();

            // If successful in HALF-OPEN state, restore to CLOSED
            if ($state === self::STATE_HALF_OPEN) {
                Redis::del("{$redisKey}:failures");
                Redis::set("{$redisKey}:state", self::STATE_CLOSED);
            }

            return $result;
        } catch (\Throwable $e) {
            // 3. Track consecutive failures
            $failures = Redis::incr("{$redisKey}:failures");

            if ($failures >= $failureThreshold || $state === self::STATE_HALF_OPEN) {
                Redis::set("{$redisKey}:state", self::STATE_OPEN);
                Redis::set("{$redisKey}:opened_at", time());
                Log::critical("Circuit breaker tripped to OPEN for {$serviceKey} due to error: {$e->getMessage()}");
            }

            return $fallback();
        }
    }
}
```

### Graceful Fallbacks per External Provider
- **Midtrans Snap Outage:** Fall back to queuing invoice generation and offering manual bank transfer verification details; inform guest with clear status message without crashing checkout screen.
- **Insurance Policy Issue Partner API:** Dispatch `IssueInsurancePolicyJob` to delayed background retry queue ([`user_guide_worker.md`](file:///d:/Project/Fastwork/rental.apartemen/docs/manual/user_guide_worker.md)) with exponential backoff (`30s`, `2m`, `10m`).
- **FCM Push Notification Service:** Queue notification in database; fall back to in-app notification center.

---

## 3. Mobile Feature Flagging & Instant Rollback

Because native mobile app store review cycles take between 24 and 72 hours, critical bugs in production screens cannot wait for hotfix app deployments. The Flutter app implements a dynamic Feature Flag system backed by remote configuration with local fallback.

```
                      FLUTTER CLIENT FEATURE FLAG FLOW
                      
                  ┌────────────────────────────────┐
                  │    App Launch / Foreground     │
                  └───────────────┬────────────────┘
                                  │
                                  ▼
                  ┌────────────────────────────────┐
                  │ Fetch Remote Config / Feature  │
                  │ Flags (`GET /api/v1/features`) │
                  └───────────────┬────────────────┘
                                  │
                   ┌──────────────┴──────────────┐
             Success                             Network Fail
                   ▼                                   ▼
        ┌─────────────────────┐             ┌─────────────────────┐
        │ Cache Flags locally │             │ Read cached SharedPreferences
        │ in Secure Store     │             │ or local safe defaults
        └──────────┬──────────┘             └──────────┬──────────┘
                   │                                   │
                   └─────────────────┬─────────────────┘
                                     │
                                     ▼
                  ┌────────────────────────────────────┐
                  │ Evaluate Feature Flag Gate         │
                  │ e.g. `isFeatureEnabled('new_form')`│
                  └──────────────────┬─────────────────┘
                                     │
                    ┌────────────────┴────────────────┐
                 ENABLED                           DISABLED
                    ▼                                 ▼
        ┌─────────────────────────┐       ┌─────────────────────────┐
        │ Render Enhanced Screen  │       │ Render Safe Legacy View │
        └─────────────────────────┘       └─────────────────────────┘
```

### Feature Flag Manager in Flutter
```dart
class FeatureFlagService {
  static const Map<String, bool> _defaultFlags = {
    'mitra_v2_forms': true,
    'instant_booking_modal': true,
    'dynamic_tax_breakdown': true,
    'offline_draft_sync': true,
  };

  final Map<String, bool> _activeFlags = Map.from(_defaultFlags);

  bool isEnabled(String featureKey) {
    return _activeFlags[featureKey] ?? _defaultFlags[featureKey] ?? false;
  }

  Future<void> syncRemoteFlags(ApiClient api) async {
    try {
      final res = await api.get('/api/v1/system/feature-flags');
      if (res is Map && res['data'] is Map) {
        final Map<String, dynamic> remote = res['data'];
        remote.forEach((key, val) {
          if (val is bool) _activeFlags[key] = val;
        });
      }
    } catch (_) {
      // Graceful fallback: maintain current in-memory / default flags
    }
  }
}
```

### Kill-Switch Example in Mitra Screen
If an unforeseen bug occurs on the multi-tab form in production, the backend disables `'mitra_v2_forms'`. The app seamlessly falls back without throwing errors:

```dart
Widget build(BuildContext context) {
  final featureFlags = Provider.of<FeatureFlagService>(context);

  if (!featureFlags.isEnabled('mitra_v2_forms')) {
    return const LegacyMitraFormFallbackScreen();
  }

  return const PropertyFormScreen();
}
```

---

## 4. Automated Dependency & Security Auditing

Dependency vulnerabilities in third-party PHP packages or Flutter plugins are intercepted prior to code integration.

```
                           DEPENDENCY AUDITING PIPELINE
                           
       Laravel Workspace                              Flutter Workspace
┌───────────────────────────────┐              ┌───────────────────────────────┐
│ `composer audit --format=json`│              │     `flutter pub outdated`    │
│ Parses CVEs, advisory links   │              │ Checks out-of-bounds plugins  │
└───────────────┬───────────────┘              └───────────────┬───────────────┘
                │                                              │
                └───────────────────────┬──────────────────────┘
                                        │
                                        ▼
                         ┌─────────────────────────────┐
                         │ Severity Gate Evaluation:   │
                         │ CRITICAL / HIGH ➔ BLOCKS CI │
                         └─────────────────────────────┘
```

### 1. Backend Automation: `composer audit`
- **Execution:** Runs in pre-commit hooks and nightly cron.
- **Rule:** If `composer audit` reports an advisory with `CVE` severity `CRITICAL` or `HIGH`, deployment builds are blocked until the affected dependency is upgraded or patched.

### 2. Mobile Automation: `flutter pub outdated`
- **Execution:** Runs on dependency update requests.
- **Rule:** Flag any package where major versions contain breaking API signature changes before developer adoption.

---

## 5. Routine Scheduled SOP & Mobile Background Sync

To ensure long-term stability without manual intervention:
1. **Laravel Scheduler (`routes/console.php`):**
   - Daily at 01:00: Cancel expired pending bookings (`payments:cancel-expired`).
   - Daily at 02:00: Clean orphaned temporary gallery uploads older than 24 hours (`accommodations:cleanup-temp-uploads`).
   - Weekly on Sunday: Prune soft-deleted user tokens and stale session logs (`sanctum:prune-expired`).
2. **Flutter Background Synchronization (`Workmanager`):**
   - Scheduled every 6 hours when connected to unmetered Wi-Fi.
   - Cleans local image cache directories to prevent storage bloat.
   - Retries unsent draft forms or telemetry sync when mobile connectivity was abruptly terminated.
