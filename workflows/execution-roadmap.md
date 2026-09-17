# Agentic Ecosystem Execution Roadmap — 4-Phase Implementation Plan

> **Objective:** Systematically stand up, integrate, and operationalize the autonomous and semi-autonomous AI agent ecosystem across the Livirooms Monorepo ([`laravel/`](file:///d:/Project/Fastwork/rental.apartemen/laravel), [`flutter/`](file:///d:/Project/Fastwork/rental.apartemen/flutter), and [`docs/`](file:///d:/Project/Fastwork/rental.apartemen/docs)).

---

## 1. Executive Master Timeline & Phasing

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                              ROADMAP EXECUTION PHASING                                 │
├────────────────────┬────────────────────┬────────────────────┬─────────────────────────┤
│ PHASE 1: WEEKS 1-2 │ PHASE 2: WEEKS 3-4 │ PHASE 3: WEEKS 5-6 │ PHASE 4: WEEKS 7-8+     │
│ Foundation &       │ Agent Tooling &    │ Resilience, Flags  │ Full Autonomy,          │
│ Baseline Audit     │ Adversarial Review │ & Background Sync  │ Self-Healing & Govern   │
└────────────────────┴────────────────────┴────────────────────┴─────────────────────────┘
```

---

## 2. Phase-by-Phase Deliverables & Technical Milestones

### Phase 1: Foundation & Baseline Audit (Weeks 1-2)
**Theme:** *Standardization, baseline contract verification, and automated vulnerability scanning.*

- [x] **Milestone 1.1: Documentation & Contract Map Harmonization**
  - Verify all 85 endpoints in [`docs/ai/03-api-contract.md`](file:///d:/Project/Fastwork/rental.apartemen/docs/ai/03-api-contract.md) match active Laravel routes.
  - Verify dual-mode accommodation invariants (`booking_mode`: `unit` vs `room`) across models and seeders.
- [ ] **Milestone 1.2: Dependency Vulnerability Baselines**
  - Integrate `composer audit` into backend CI pipeline; configure zero-tolerance blocking for CRITICAL CVEs.
  - Audit Flutter pub dependencies (`flutter pub outdated`); resolve deprecated packages and establish pinned versions.
- [ ] **Milestone 1.3: Verification CLI Runner Setup**
  - Operationalize [`docs/workflows/run_api_sequence.xml`](file:///d:/Project/Fastwork/rental.apartemen/docs/workflows/run_api_sequence.xml) into automated test scripts verifying login, token extraction, and protected endpoint integrity.

#### Phase 1 Checkpoint & Gate Criteria
- Zero unresolved CRITICAL or HIGH vulnerabilities in `composer audit`.
- 100% test pass rate on `tests/Feature/Api/*` and `flutter test test/screens/mitra`.

---

### Phase 2: Agent Tooling & Adversarial Review Automation (Weeks 3-4)
**Theme:** *Operationalizing the 4-Angle adversarial review and multi-agent debate bot.*

- [ ] **Milestone 2.1: Adversarial Code Review Bot for PRs**
  - Implement GitHub Action / GitLab CI review bot evaluating PR diffs against the 4 angles:
    1. *Security & IDOR:* Automatic detection of unverified foreign keys and un-sanitized queries.
    2. *Logic & Domain Invariants:* Automatic detection of missing `booking_mode` guards.
    3. *Data Formatting:* Regexp scanner for raw `double.tryParse` without Indonesian thousand-separator dot stripping (`.replaceAll('.', '')`).
    4. *Concurrency & Async:* Scanner for async methods lacking `if (!mounted) return;`.
- [ ] **Milestone 2.2: Multi-Agent Debate Engine**
  - Establish CLI subagent debate orchestrator activating `@security-auditor`, `@backend-optimizer`, and `@mobile-specialist`.
  - Automatically synthesize findings into [`implementation_plan.md`](file:///C:/Users/Baswan/.gemini/antigravity-ide/brain/61a4f6e4-a98f-4393-ad74-58079ff82a29/implementation_plan.md) for complex PRs.
- [ ] **Milestone 2.3: Failure Standard & Drift Auto-Registration**
  - Standardize `BL-FAIL` issue reporting format ([`code-review-sop.md`](file:///d:/Project/Fastwork/rental.apartemen/docs/workflows/code-review-sop.md)).
  - Automate updates to [`docs/ai/04-drift-register.md`](file:///d:/Project/Fastwork/rental.apartemen/docs/ai/04-drift-register.md) on every merged PR.

#### Phase 2 Checkpoint & Gate Criteria
- Automated review bot active on all repository pull requests.
- Zero manual bypasses of 4-angle review gate.

---

### Phase 3: Resilience, Feature Flags & Mobile Background Sync (Weeks 5-6)
**Theme:** *System fault tolerance, zero-downtime database evolution, and mobile kill switches.*

- [ ] **Milestone 3.1: Redis Circuit Breaker Infrastructure**
  - Deploy `App\Services\Resilience\CircuitBreaker` across Midtrans Snap and insurance partner API gateways.
  - Implement fallback routing and automatic state transitions (`CLOSED` ➔ `OPEN` ➔ `HALF-OPEN`).
- [ ] **Milestone 3.2: Mobile Remote Config & Feature Flag Service**
  - Implement `FeatureFlagService` in Flutter with local safe fallback defaults.
  - Wire feature flags to high-impact UI areas (e.g., Mitra multi-tab wizard forms, instant booking sheet).
  - Deploy backend management endpoint `GET/PUT /api/v1/system/feature-flags`.
- [ ] **Milestone 3.3: Mobile Background Synchronization (`Workmanager`)**
  - Configure `Workmanager` daemon in Android and iOS runners.
  - Establish 6-hour periodic cache pruning, telemetry sync, and unsent offline form draft preservation.

#### Phase 3 Checkpoint & Gate Criteria
- Simulating Midtrans gateway outage automatically trips Circuit Breaker to fast-fail without tying up PHP-FPM workers.
- Toggling feature flag remotely disables high-risk feature on mobile device without app crash.

---

### Phase 4: Full Autonomy, Self-Healing & Governance (Weeks 7-8+)
**Theme:** *Continuous monitoring, self-healing background automation, and ecosystem governance.*

- [ ] **Milestone 4.1: Autonomous Drift Detection Daemon**
  - Scheduled worker comparing database schemas (`information_schema.columns`) against Eloquent `$fillable` attributes and API Resource fields.
  - Automatically flags drifts and issues PRs for review.
- [ ] **Milestone 4.2: Automated Error-Clustering & Sentry/Bugsnag Correlation**
  - Correlate backend exception traces and Flutter crash reports into clustered incident tickets.
  - Auto-assign tickets with reproduction steps and preliminary agent-generated diff proposals.
- [ ] **Milestone 4.3: Long-Running Worker Health Monitoring**
  - Implement automatic health heartbeat for Supervisord daemon queue workers (`livirooms-worker`).
  - Automatically alert and restart workers on memory threshold exceedance (> 512 MB).

#### Phase 4 Checkpoint & Gate Criteria
- 100% automated drift detection operational.
- Production error resolution cycle (MTTR) reduced by > 60%.

---

## 3. Success Metrics & Key Performance Indicators (KPIs)

| Metric | Baseline (Pre-Agentic) | Target (Post-Phase 4) | Measurement Frequency |
|---|---|---|---|
| **IDOR & Security Escapes** | 0 detected (High Risk) | **0 escapes (Enforced by Gate)** | Continuous CI |
| **API Contract Mismatches** | Occasional parameter drift | **0 tolerated (Strict Sync)** | Continuous CI |
| **Flutter Runtime `TypeError`** | Edge-case formatting bugs | **0 on formatted currency paths** | Per build & release |
| **Mean Time to Remediate (MTTR)**| 12 - 24 hours | **< 2 hours** | Monthly review |
| **Test Suite Pass Rate** | 100% (48 tests) | **100% (Expanded to > 150 tests)**| Per commit |
| **Database Migration Downtime** | Minimal downtime | **0 seconds (Expand/Contract)** | Per deployment |

---

## 4. Governance & Human-in-the-Loop Safeguards

1. **Production Deployment Sign-Off:** No AI agent may deploy code directly to the production environment without human engineering sign-off.
2. **Database Destructive Operations:** Any migration containing `dropTable` or `dropColumn` requires explicit confirmation and verified backup snapshot verification prior to execution.
3. **Financial State Immunity:** Payment confirmation states (`Order::status = 'confirmed'`) may only transition via cryptographic Midtrans webhook verification; agents are strictly forbidden from writing bypassing status modifiers.
