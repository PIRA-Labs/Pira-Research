# Vela / Android / MIAU Milestone — Formal Research Record

**Document type:** Formal experimental milestone record
**Project:** PIRA — Physical Intelligence Runtime for Agents
**Organization:** PIRA-Labs
**Milestone:** Bidirectional watch↔phone physical transport confirmed
**Date:** 2026-09-01 02:33 CST
**Primary device:** NODE-01 (HONOR X6, Android 14 / MagicOS 8, ARM64, 4 GB RAM)
**Wearable:** WATCH-01 (Redmi Watch 4, HyperOS 2.2.86 / Vela)
**Bridge phone:** PHONE-BRIDGE-DEV (Xiaomi Android, Android 16, Mi Fitness 3.57.0i)
**Research period:** 2026-08-22 to 2026-09-01
**Document version:** 1.0 — 2026-10-30

---

## Abstract

This document formally records the experimental milestone that established
physical bidirectional communication between a Redmi Watch 4 wearable and an
Android phone running a custom companion application. The work was part of the
TAAK physical-agent infrastructure research program that preceded PIRA.

The milestone demonstrated:

1. Custom Vela Quick App deployment on Redmi Watch 4 without root
2. Android→watch message delivery via Xiaomi XMS public API
3. Watch→phone event extraction via Mi Fitness log observation
4. Bidirectional user-visible communication without modifying Mi Fitness

The central technical finding: the blocking condition was a software feature
gate (`isSupportThirdPartyApp`), not a hardware or protocol limitation. This
distinction directly informed PIRA's deny-by-default trust-boundary architecture.

---

## 1. Historical Artifact Preservation

### 1.1 Source repositories

All primary artifacts are preserved in `/Users/valedev/Documents/taak-companion/`
and `/Users/valedev/Documents/Taak-Intelligence/`. These are private local
repositories. Selected sanitized analysis has been published to
`PIRA-Labs/Pira-Research`.

### 1.2 Preserved scripts and skills

| Artifact | Location | Status | Reproducibility |
|----------|----------|--------|-----------------|
| `node01-miau-log-bridge.sh` | taak-companion/scripts/ | Preserved locally | Requires NODE-01, Mi Fitness, ADB |
| `MiauBroadcastReceiver.kt` | taak-companion/app/src/main/java/.../ | Published in PIRA-Research as analysis | Reference implementation |
| `MiauEventStore.kt` | taak-companion/app/src/main/java/.../ | Published in PIRA-Research as analysis | Reference implementation |
| NODE-01 bridge (`node01-bridge.py`) | NODE-01 /root/.hermes/scripts/ | Preserved on device | Operational, running |
| TAAK Remote Vela app | watch01/xiaomi-band-development/examples/songbird/ | Preserved locally | Requires Vela toolchain |
| ADB deploy script | watch01/xiaomi-band-development/scripts/deploy.sh | Preserved locally | Requires ADB + paired phone |
| Mi Fitness backups | taak-companion/research/node01-backups/mi-fitness-3.57.0i-splits/ | Preserved locally | Not published |
| Xiaomi auth key | taak-companion/research/auth/ | Preserved locally, NOT published | N/A — sensitive |
| JADX decompilation | taak-companion/research/mi-fitness-jadx/ | Preserved locally | Not published (proprietary) |

### 1.3 Provenance chain

```
2026-08-25  Vela runtime discovered via easter egg
2026-08-27  Hidden Mi Fitness debug route (ThirdAppDebugFragment)
2026-08-28  First custom RPK installed (black screen, root cause unproven)
2026-08-28  Songbird analysis → TAAK Metronome v1 (known-good structure)
2026-08-29  Vibration, timers, touch verified physically
2026-08-30  XMS SDK: 0 NODES problem, DID bypass, DEVICE_MANAGER permission
2026-08-30  PHONE → WATCH verified: miau-from-android delivered
2026-08-31  WATCH → PHONE: 20/6 observed, feature gate identified
2026-09-01  MIAU log bridge: second attempt successful
2026-09-01  02:33 CST: bidirectional MIAU confirmed
2026-09-01  taak-companion commit 5295f081b
```

### 1.4 Reproducibility status

| Component | Reproducible | Notes |
|-----------|-------------|-------|
| NODE-01 Hermes setup | Yes | Runbook in PIRA-Research |
| Vela Quick App deploy | Yes | Requires xiaomi-band-development toolchain |
| TAAK Metronome v1 | Yes | Known-good Songbird-derived structure |
| XMS phone→watch | Yes | Requires Mi Fitness pairing, DEVICE_MANAGER permission |
| MIAU log bridge | Partial | Depends on Mi Fitness log format; may vary by version |
| Gadgetbridge pairing | Unverified | Auth key obtained, pairing not completed |
| Watch→phone via public API | No | Feature gate blocks it |

---

## 2. Evidence Register

### 2.1 Evidence taxonomy

| Label | Definition | Application in this milestone |
|-------|-----------|-------------------------------|
| **Verified** | Observed on physical hardware or confirmed by runtime evidence | Watch vibration, message delivery, bidirectional MIAU |
| **Code-mapped** | Recovered from decompiled code but not necessarily exercised | WearableXmsService packet dispatch, feature gate logic |
| **Inferred** | Evidence-backed architectural hypothesis | Gadgetbridge as replacement path |
| **Unverified** | Idea or target; do not build dependent claims on it | Watch→phone via public API, direct BLE |

### 2.2 Primary evidence items

| ID | Evidence | Source | Confidence | Date |
|----|----------|--------|-----------|------|
| E-001 | `adb devices` returned NODE-01 serial | ADB command output | **Verified** | 2026-08-15 |
| E-002 | Hermes 0.20.6 running on aarch64 | Runtime check | **Verified** | 2026-08-18 |
| E-003 | NODE-01 heartbeat continued after MacBook shutdown | SQLite rows ts 1787979061→1787979086 | **Verified** | 2026-08-19 |
| E-004 | Redmi Watch 4 DID: 808263400 | Physical device observation | **Verified** | 2026-08-22 |
| E-005 | Vela runtime confirmed via easter egg | Watch UI interaction | **Verified** | 2026-08-25 |
| E-006 | Custom RPK installed via ThirdAppDebugFragment | ADB + deploy script | **Verified** | 2026-08-27 |
| E-007 | TAAK Metronome v1: vibration physically verified | Watch haptic feedback | **Verified** | 2026-08-29 |
| E-008 | `getConnectedNodes()` returned 0 NODES | XMS API call output | **Verified** | 2026-08-30 |
| E-009 | DID bypass: `Node("808263400", "Redmi Watch 4")` + sendMessage succeeded | XMS API callback | **Verified** | 2026-08-30 |
| E-010 | `Permission.DEVICE_MANAGER` required and granted | XMS permission flow | **Verified** | 2026-08-30 |
| E-011 | PHONE → WATCH: "miau-from-android" delivered | Watch UI display | **Verified** | 2026-08-30 |
| E-012 | WATCH → PHONE: 20/6 packet observed in Transfer.device.log | Log file analysis | **Verified** | 2026-08-31 |
| E-013 | `XmsDataHandler handlePacket 20 6 false` log line | Mi Fitness logcat | **Verified** | 2026-08-31 |
| E-014 | `isSupportThirdPartyApp(Redmi Watch 4) == false` | JADX decompilation + runtime feature list | **Code-mapped** | 2026-08-31 |
| E-015 | Feature gate: `features.contains("thirdparty_app")` | JADX decompilation | **Code-mapped** | 2026-08-31 |
| E-016 | MIAU log bridge first attempt failed (adb logcat) | Runtime observation | **Verified** | 2026-09-01 |
| E-017 | MIAU log bridge second attempt succeeded | Broadcast receiver + UI | **Verified** | 2026-09-01 02:33 |
| E-018 | `CALL SUCCESS / MIAU RECEIVED / PANTERA ONLINE` | NODE-01 UI display | **Verified** | 2026-09-01 02:33 |
| E-019 | Gadgetbridge built from source | Gradle build output | **Verified** | 2026-08-31 |
| E-020 | Gadgetbridge installed on NODE-01 | ADB install output | **Verified** | 2026-08-31 |
| E-021 | Auth key candidate obtained | Local file (NOT published) | **Verified** | 2026-08-31 |
| E-022 | Gadgetbridge ↔ Redmi Watch 4 pairing | NOT completed | **Unverified** | — |
| E-023 | Mi Fitness product JSON config override | NOT accessible | **Verified blocked** | 2026-08-31 |
| E-024 | Mi Fitness not debuggable on NODE-01 | `run-as` failure | **Verified** | 2026-08-31 |

### 2.3 Missing evidence

| Missing item | Impact | Mitigation |
|-------------|--------|-----------|
| Original Termux bootstrap scripts | Cannot reproduce exact NODE-01 setup | Runbook reconstructs the sequence |
| Early ADB automation (pre-runbook) | Cannot reproduce exact early experiments | Runbook captures verified final state |
| Gadgetbridge pairing logs | Cannot verify H1–H4 from lab close | Auth key preserved; pairing remains future work |
| Failed XMS packet experiments | Incomplete failure-mode taxonomy | Documented in lab bitácora |
| Vela black-screen root cause | Cannot prevent recurrence without understanding | Workaround documented; root cause open |
| Original Hermes config.yaml | Contains credentials | Not reproducible by design |
| Mi Fitness APK full hash | Cannot verify exact build | Version 3.57.0i (357000) documented |

---

## 3. Academic Methodology

### 3.1 Research framework

This research followed an iterative empirical methodology:

**Phase 0 — Define physical minimum:**
```text
input físico → evidencia observable
```
Example: `tap en reloj → evento en teléfono`

**Phase 1 — Draw the chain:**
```text
A → B → C → D → E
```
Example: `WATCH → Bluetooth → Mi Fitness → XMS → Android app`

**Phase 2 — Classify components:**
For each component: do we control it? Is it open source? Is it replaceable?
Is it mandatory? Is it a manufacturer convention?

**Phase 3 — Search for alternatives before decompiling:**
Timebox 20–30 minutes for `"<device> open source"`, `alternative companion`,
`protocol implementation`, `Gadgetbridge`.

**Phase 4 — Physical evidence:**
Logs, packets, callbacks, states. Measure before inferring.

**Phase 5 — Follow the code end-to-end:**
`caller → SDK → IPC → service → condition → data source`

**Phase 6 — Falsifiable hypotheses:**
Each hypothesis must have: prediction, test, result, status (PROVEN/DISPROVEN/OPEN/CLOSED).

**Phase 7 — Find asymmetries:**
One API blocked does not mean all APIs blocked (`getConnectedNodes ❌`, `sendMessage(DID) ✅`).

**Phase 8 — Find the minimum predicate:**
Reduce "it doesn't work" to `boolean condition == false`.

**Phase 9 — Mechanism vs policy:**
Does the device CANNOT, or did software DECIDE not to allow it?

**Phase 10 — Intervention ladder:**
1. Official API
2. Discovery bypass
3. Direct protocol
4. Open-source replacement
5. Fork/patch replacement
6. Runtime hook
7. Root
8. Firmware modification
9. Replacement hardware

**Phase 11 — Close branches:**
Labels: `OPEN`, `PROVEN`, `DISPROVEN`, `BLOCKED`, `CLOSED`.

**Phase 12 — Checkpoint before destruction:**
Before unpair/wipe/unlock/flash: save keys, logs, versions, pairing state,
binaries, source, backups.

**Phase 13 — Abandonment criterion:**
Not just "can we continue?" but: **"Does the next hour have higher expected
value than changing architecture?"**

### 3.2 Threats to validity

| Threat | Description | Mitigation |
|--------|-------------|-----------|
| **Device specificity** | Findings may not generalize to other Xiaomi watches | Documented exact device model, OS version, DID |
| **Software version dependency** | Mi Fitness 3.57.0i may behave differently from other versions | Version documented; feature gate logic traced |
| **Single observer** | One researcher conducted the experiments | Reproducibility runbook published |
| **Proprietary dependency** | Core transport depends on Mi Fitness, a closed application | Gadgetbridge investigation initiated |
| **Confirmation bias** | Researcher wanted the system to work | Failed experiments documented (adb logcat, black screen, etc.) |
| **Temporal validity** | Xiaomi may change APIs, features, or gate logic | Exact packet IDs, log formats, and feature strings preserved |
| **Selection bias** | Watch was chosen because it was available | Documented selection criteria (cost, Vela runtime, BLE) |
| **No control group** | Cannot compare against a known-good open alternative | Gadgetbridge as prospective control |

### 3.3 Evidence quality assessment

- **High confidence:** Physical bidirectional MIAU, feature gate identification,
  DID bypass, DEVICE_MANAGER permission requirement
- **Medium confidence:** Gadgetbridge build reproducibility, auth key acquisition,
  Vela Quick App deployment path
- **Low confidence:** Watch→phone via public API, Gadgetbridge↔watch connectivity,
  direct BLE protocol implementation
- **Unproven:** Vela black-screen root cause, watch microphone access,
  direct watch→HTTP networking

---

## 4. Engineering Knowledge Transfer

### 4.1 Historical findings → PIRA design implications

| Historical finding | PIRA design implication |
|--------------------|------------------------|
| Feature gate blocks third-party apps despite working transport | **Deny-by-default policy engine** — transport availability ≠ capability authorization |
| DID bypass works when discovery is filtered | **Direct capability addressing** — PIRA should allow known-DID capability calls when user has pre-authorized |
| Mi Fitness receives but discards the packet | **Audit before discard** — PIRA logs every proposal, even denied ones |
| Log files as temporary event buses | **Audit trail as first-class output** — PIRA's `AuditLogger` is not an afterthought |
| Keystore-backed credential storage | **SecureKeyStore** — Android Keystore AES-GCM, hardware backing TBD |
| Emergency stop via shared flag | **Emergency stop** — independent flag blocks policy evaluation before any capability check |
| Mi Fitness as driver, not platform | **Trusted executor boundary** — PIRA uses system APIs through a controlled layer, not direct agent access |
| Preserving pairing/integrity over architectural elegance | **Non-destructive experimentation** — PIRA's development methodology prioritizes existing user data and configurations |

### 4.2 Reusable experimental techniques

| Technique | Origin | Current PIRA status |
|-----------|--------|---------------------|
| DID direct addressing | XMS research | Not yet implemented in PIRA Android |
| Log-based event detection | MIAU bridge prototype | Audit trail concept; production uses structured logging |
| Feature gate identification via decompilation | XMS reverse engineering | Policy engine allowlist approach |
| Known-good structure mutation | Vela Songbird → Metronome | PIRA Android follows this (evolving from taak-companion base) |
| Non-destructive bypass before modification | Mi Fitness investigation | Core PIRA principle: observe before intercept |

### 4.3 Implementation lessons for PIRA

1. **Transport availability is not capability authorization.** A device may
   physically receive a command but the system may discard it. PIRA's policy
   engine must evaluate proposals before they reach any transport layer.

2. **Feature flags in closed systems are policy, not physics.** When a closed
   system blocks an operation, determine whether the block is enforced by
   hardware/protocol or by software policy. Software policy can often be
   bypassed or replaced; hardware limits cannot.

3. **Audit trails must capture denied proposals.** The MIAU log bridge worked
   because Mi Fitness logged the packet before discarding it. PIRA's audit
   logger records every decision, including denials.

4. **Preserve existing user configurations.** The decision not to root, re-pair,
   or modify Mi Fitness preserved months of authenticated session state. PIRA
   must never require destructive operations to function.

5. **Agent output is untrusted.** The `PolicyEngine` in PIRA Android explicitly
   validates every `ActionProposal` against allowlist, parameter schema,
   authorization state, and emergency stop. This emerged from observing what
   happens when an agent is given unrestricted access to device APIs.

---

## 5. Security Research Foundation

### 5.1 Trust boundary evolution

```
TAAK research (2026-08 to 2026-09)
    │
    ├── XMS feature gate → deny-by-default
    ├── Log observation → audit trail
    ├── DID bypass → scoped addressing
    ├── Mi Fitness as driver → trusted executor boundary
    └── Keystore experiments → SecureKeyStore
         │
         ▼
PIRA trust boundary (2026-10)
    │
    ├── Agent output (untrusted)
    ├── Typed ActionProposal
    ├── PolicyEngine (deny by default)
    ├── User consent / Authorization
    ├── Capability executor (revalidates)
    ├── AuditLogger
    └── Revocation / emergency stop
```

### 5.2 Implemented trust-boundary mechanisms

| Mechanism | Implementation | Status | Evidence |
|-----------|---------------|--------|----------|
| **Deny by default** | `PolicyEngine.evaluate()` returns `Decision(false, ...)` for any unrecognized capability, missing authorization, expired grant, parameter mismatch, or emergency stop | **Implemented** | PiraRuntime.kt lines 22–40 |
| **Typed action proposals** | `Capability` enum: CAMERA_LOOK, BATTERY_READ, WEARABLE_MESSAGE, WEB_SEARCH. Proposals are `data class ActionProposal(capability, target, parameters)` | **Implemented** | PiraRuntime.kt lines 16–17 |
| **Short-lived authorization** | `Authorization(expiresAtMs, nonce, used)` — one-use, time-limited | **Implemented** | PiraRuntime.kt line 18 |
| **Parameter allowlist** | Only `"prompt"` and `"message"` keys accepted; WEARABLE_MESSAGE limited to 120 chars | **Implemented** | PiraRuntime.kt lines 33–37 |
| **Emergency stop** | `emergencyStop` callback reads `pira_security/emergency_stop` flag | **Implemented** | PiraRuntime.kt line 22, MainActivity.kt |
| **Audit logging** | `AuditLogger` records every decision to SharedPreferences | **Implemented** | PiraRuntime.kt lines 42–46 |
| **Credential isolation** | Nebius API key stored in Android Keystore (AES-GCM), never logged | **Implemented** | PiraRuntime.kt lines 48–78 |
| **Exported component removal** | MIAU broadcast receiver removed from PIRA manifest | **Implemented** | THREAT_MODEL.md, AndroidManifest.xml |

### 5.3 Research-phase trust mechanisms (pre-PIRA)

| Mechanism | Research phase | Current status |
|-----------|---------------|----------------|
| Mi Fitness pairing preservation | Decision D-009 | Principle adopted in PIRA |
| Non-dructive bypass (log bridge) | MIAU prototype | Audit trail concept |
| DID direct addressing | XMS research | Not yet in PIRA Android |
| Feature gate analysis | XMS decompilation | Inform ADR-0001 (infrastructure-first) |
| Auth key handling | Gadgetbridge research | SecureKeyStore pattern |

### 5.4 Unresolved security items

| Item | Risk | Mitigation path |
|------|------|-----------------|
| Keystore hardware backing not verified | Keys may be software-backed on some devices | Test on StrongBox-capable device; document fallback |
| Revocation UI incomplete | User cannot revoke authorizations after granting | Build revocation activity in MainActivity |
| Durable grant storage | Authorizations lost on app restart | Implement persistent grant store with expiry cleanup |
| BLE identity not validated | Xiaomi BLE identity could be spoofed | PIRA does not trust BLE identity without additional proof |
| Live Nebius/vision behavior untested | Actual model behavior with untrusted output unknown | Integration testing with adversarial prompts |
| Prompt injection on agent output | Agent may craft proposals that pass parameter allowlist but execute harmful actions | Extend allowlist, add semantic validation layer |
| No process isolation | PiraRuntime and MainActivity share process | Future: move PolicyEngine to separate process |

---

## 6. Current Release Inventory

### 6.1 PIRA Android — existing implementation

**Repository:** `PIRA-Labs/Pira-Android` (private)
**Local path:** `/Users/valedev/Documents/Pira-Android`
**Package:** `com.taak.watch.signedtest` (legacy; PIRA namespace pending)
**Language:** Kotlin
**Min SDK:** Not yet documented in extracted files
**Build system:** Gradle (Android)

### 6.2 Component inventory

| Component | File | Lines | Status | Limitations |
|-----------|------|-------|--------|-------------|
| `Capability` enum | PiraRuntime.kt | 1 | Implemented | Only 4 capabilities; not extensible at runtime |
| `ActionProposal` | PiraRuntime.kt | 1 | Implemented | Simple data class; no schema validation |
| `Authorization` | PiraRuntime.kt | 1 | Implemented | No persistent store; lost on restart |
| `PolicyEngine` | PiraRuntime.kt | 18 | Implemented | Allowlist is hardcoded; no policy DSL |
| `Decision` | PiraRuntime.kt | 1 | Implemented | No structured error codes |
| `AuditLogger` | PiraRuntime.kt | 4 | Implemented | SharedPreferences only; last event only |
| `SecureKeyStore` | PiraRuntime.kt | 30 | Implemented | Hardware backing unverified |
| `NebiusClient` | PiraRuntime.kt | 35 | Implemented | Live validation pending; no retry logic |
| `TavilyClient` | PiraRuntime.kt | partial | Implemented | Full extent not reviewed |
| `WebSearchProposal` | PiraRuntime.kt | 1 | Implemented | Scope fixed to "tavily.basic" |
| `MainActivity` | MainActivity.kt | 290 | Implemented | Monolithic; no ViewModel; no navigation component |
| Camera integration | MainActivity.kt | partial | Implemented | Foreground-only; no background capture |
| Voice/STT | MainActivity.kt | stub | Planned | "My voice is coming soon" |
| Emergency stop | MainActivity.kt | partial | Implemented | SharedPreferences flag; no UI to clear |
| MIAU receiver | MainActivity.kt | partial | Research adapter | Removed from PIRA manifest per THREAT_MODEL |

### 6.3 Documentation inventory

| Document | Path | Lines | Status |
|----------|------|-------|--------|
| Architecture | docs/ARCHITECTURE.md | 17 | Complete |
| Threat model | docs/THREAT_MODEL.md | 20 | Draft |
| Decision register | docs/DECISION_REGISTER.md | 8 | Partial |
| Development log | docs/DEVELOPMENT_LOG.md | Unknown | Exists |
| Experiments | docs/EXPERIMENTS.md | Unknown | Exists |
| Third-party licenses | docs/THIRD_PARTY_LICENSES.md | Unknown | Exists |
| ADRs | docs/adr/0001-infrastructure-first.md | 28 | 1 ADR |
| NOTICE | NOTICE | Unknown | Exists |

### 6.4 Test inventory

| Test type | Status | Notes |
|-----------|--------|-------|
| Unit tests | Unknown | Not found in exploration |
| Integration tests | Unknown | Not found |
| UI tests | Unknown | Not found |
| Security tests | Manual only | Emergency stop, deny-by-default tested via UI buttons |

### 6.5 Build status

| Target | Status | Evidence |
|--------|--------|----------|
| Debug APK | Unknown | Not verified in this session |
| Release APK | Unknown | Not verified |
| Signing | Configured | TAAK signing identity documented in runbook |

### 6.6 Known limitations (honest)

1. **Single-file runtime.** `PiraRuntime.kt` contains all core logic in 122
   lines. This is prototype scale, not production architecture.

2. **No persistent authorization store.** Authorizations are in-memory only.
   App restart clears all grants.

3. **Audit logger is append-only last-event.** `SharedPreferences` with a single
   `"last"` key. No history, no query, no export.

4. **No ViewModel or navigation.** `MainActivity` is 290 lines of inline UI
   logic. No architecture components.

5. **Camera is foreground-only.** No background capture, no scheduling, no
   agent-triggered capture without user present.

6. **Voice is unimplemented.** STT/TTS stub only.

7. **Nebius integration unverified.** Client code exists but live model behavior
   with actual agent output has not been tested.

8. **No automated tests.** No unit, integration, or UI tests found.

9. **Legacy package name.** `com.taak.watch.signedtest` is the research-phase
   package. PIRA namespace not yet assigned.

10. **Xiaomi/XMS is research adapter.** WEARABLE_MESSAGE capability exists but
    the XMS integration is explicitly documented as "optional research adapter,
    not an unrestricted command path."

11. **Keystore hardware backing unverified.** AES-GCM key generation does not
    require StrongBox. Behavior on devices without hardware-backed Keystore is
    untested.

12. **No process isolation.** PolicyEngine, AuditLogger, and NebiusClient run
    in the same process as the UI. A compromised UI component could manipulate
    policy state.

---

## 7. Relationship to PIRA Ecosystem

### 7.1 Mapping table

| Research artifact | PIRA component | Relationship |
|-------------------|---------------|--------------|
| `PolicyEngine` (PiraRuntime.kt) | PIRA Android policy engine | Direct descendant of feature gate analysis |
| `ActionProposal` / `Capability` | PIRA typed proposal schema | Derived from "agents propose, runtime decides" |
| `Authorization` (one-use, time-limited) | PIRA grant model | Derived from replay/parameter tampering threat |
| `AuditLogger` | PIRA audit trail | Derived from Mi Fitness log observation |
| `SecureKeyStore` | PIRA credential storage | Derived from Keystore experiments |
| `Emergency stop` | PIRA revocation mechanism | Derived from "preserve pairing integrity" principle |
| MIAU log bridge | PIRA event extraction concept | Proof that observation can substitute for modification |
| DID bypass | PIRA capability addressing | Direct addressing when discovery is filtered |
| Feature gate analysis | PIRA deny-by-default ADR | Root cause of infrastructure-first decision |
| Vela Quick App | PIRA wearable client (future) | WATCH-01 as thin interface confirmed |
| Gadgetbridge investigation | PIRA transport abstraction | Open-source replacement path for closed transports |

### 7.2 Open research questions

| Question | Source | Priority |
|----------|--------|----------|
| Can Gadgetbridge connect to Redmi Watch 4? | Lab close | High |
| Can PIRA support dynamic capability registration? | PolicyEngine limitation | High |
| How does PIRA handle multi-user consent? | Single-user current design | Medium |
| What is the minimum viable wearable protocol? | MIAU milestone | Medium |
| Can PIRA's policy engine run in a separate process? | Process isolation | Medium |
| How does PIRA handle credential rotation? | SecureKeyStore design | Low |

---

## 8. Publication Record

| Artifact | Published | Location |
|----------|-----------|----------|
| PIRA-Research README | Yes | `PIRA-Labs/Pira-Research/README.md` |
| TIMELINE.md | Yes | `PIRA-Labs/Pira-Research/TIMELINE.md` |
| RESEARCH_INDEX.md | Yes | `PIRA-Labs/Pira-Research/RESEARCH_INDEX.md` |
| decisions/README.md | Yes | `PIRA-Labs/Pira-Research/decisions/README.md` |
| NODE-01 ANDROID HERMES RUNBOOK | Yes | `PIRA-Labs/Pira-Research/docs/` |
| WATCH-01 VELA REVERSE ENGINEERING | Yes | `PIRA-Labs/Pira-Research/docs/` |
| TAAK-PHYSICAL-AGENT-ARCHITECTURE | Yes | `PIRA-Labs/Pira-Research/docs/` |
| Reproducibility runbook | Yes | `PIRA-Labs/Pira-Research/docs/` |
| MIAU lab bitácora | Yes | `PIRA-Labs/Pira-Research/experiments/` |
| PANTERA_SANSON_LAB notebook | Yes | `PIRA-Labs/Pira-Research/experiments/` |
| MIAU root cause analysis | Yes | `PIRA-Labs/Pira-Research/experiments/` |
| XMS artifact reference (sanitized) | Yes | `PIRA-Labs/Pira-Research/experiments/` |
| Pantera recovery notes | Yes | `PIRA-Labs/Pira-Research/references/` |
| Full decompiled Mi Fitness source | **No** | Proprietary; not publishable |
| Mi Fitness APK | **No** | Proprietary; not publishable |
| Xiaomi auth key | **No** | Sensitive; not publishable |
| TAAK signing keystore | **No** | Sensitive; not publishable |
| Original Hermes config.yaml | **No** | Contains credentials |

---

## 9. Conclusion

The Vela / Android / MIAU milestone established that physical bidirectional
communication between a wearable and an agent runtime is achievable without
modifying closed vendor applications. The key technical insight — that the
blocking condition was a software feature gate, not a hardware or protocol
limitation — directly shaped PIRA's deny-by-default architecture.

The milestone also established methodological principles that continue to guide
PIRA development: non-destructive experimentation, preserve existing user
configurations, audit before intercept, and treat agent output as untrusted.

The research archive preserves the full evidentiary chain. The PIRA Android
implementation contains the direct architectural descendants of these findings.

---

*Formal research record maintained by PIRA-Labs.
Document version: 1.0 — 2026-10-30
Source commit: taak-companion@5295f081b*
