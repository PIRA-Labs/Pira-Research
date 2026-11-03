# Next Objectives — PIRA Research & Engineering

**Status:** Active — not completed
**Date:** 2026-10-30
**Organization:** PIRA-Labs

---

## Immediate experimental objectives

### 1. Gadgetbridge → Redmi Watch 4 pairing

We have an auth key candidate obtained during the MIAU milestone. We have
Gadgetbridge built from source and installed on NODE-01. We have NOT yet
attempted pairing.

**What we will do:** Pair Gadgetbridge with WATCH-01 using the preserved auth
key. Observe whether Gadgetbridge detects the device, retrieves device info,
and establishes a stable connection without destroying the existing Mi Fitness
pairing.

**What would constitute success:** Gadgetbridge shows WATCH-01 as a connected
device. We can read device properties through Gadgetbridge's API.

**What would constitute failure:** Gadgetbridge cannot discover or connect to
WATCH-01. The auth key format is rejected. The watch refuses the pairing
handshake. Mi Fitness pairing is disrupted.

**Current state:** Auth key obtained (verified locally, not published).
Gadgetbridge built and installed. Pairing not yet attempted.

---

### 2. Persistent authorization store in PIRA Android

The current `Authorization` object is in-memory only. App restart clears all
grants. This makes the runtime unusable for an agent that operates across
sessions.

**What we will do:** Implement a persistent authorization store using the
existing `SecureKeyStore` (AES-GCM, Android Keystore). Authorizations will
survive app restart. Expired grants will be cleaned up. A revocation UI will
allow the user to withdraw previously granted permissions.

**What would constitute success:** Grant a capability, close the app, reopen
it, and the authorization is still present and valid. Expired grants are
absent. Revocation removes the grant immediately.

**Current state:** `SecureKeyStore` is implemented. `Authorization` data class
exists. Persistent store and revocation UI do not exist.

---

### 3. Keystore hardware backing verification

`SecureKeyStore` generates AES-GCM keys in the Android Keystore. We have not
verified whether these keys are hardware-backed (StrongBox or TEE) on any
target device.

**What we will do:** Query `KeyInfo` for the generated key alias on NODE-01
and any other available test devices. Record whether the key is backed by
StrongBox, TEE, or software only. Document the fallback behavior.

**What would constitute success:** A clear report of hardware backing status
per device, with documented security implications for each case.

**Current state:** Not tested. Hardware backing is assumed but unverified.

---

## Near-term engineering objectives (1–3 months)

### 4. Watch→phone payload through a reproducible path

The MIAU log bridge proved the system works end-to-end, but it depends on
Mi Fitness's internal log format. This is a prototype, not a production path.

**What we will do:** Establish a reproducible watch→phone payload path. The
primary candidate is Gadgetbridge as an open-source transport replacement.
The fallback is a direct BLE protocol implementation. The public XMS API
path is blocked by the feature gate and is not the current target.

**What would constitute success:** A watch-generated payload reaches PIRA
Android through a path that does not depend on parsing proprietary log files.

**Current state:** Log bridge works as prototype. Gadgetbridge pairing not
yet attempted. Direct BLE not yet investigated.

---

### 5. Dynamic capability registry

The current `Capability` enum is hardcoded with four values. As PIRA
integrates more device capabilities, a hardcoded allowlist becomes
unmaintainable.

**What we will do:** Design a capability schema format that allows new
capabilities to be registered without app redeployment. The policy engine
must continue to deny all unregistered capabilities by default.

**What would constitute success:** A new capability can be added through a
policy or configuration update and is immediately enforced by the runtime,
with full audit trail and user consent flow.

**Current state:** Not started. Hardcoded enum in `PiraRuntime.kt`.

---

### 6. Process isolation for the policy engine

`PiraRuntime` and `MainActivity` currently share a process. A compromised UI
component could manipulate policy state.

**What we will do:** Evaluate Android `android:process` and
`android:isolatedProcess` for the `PolicyEngine` component. Measure the
security boundary and performance impact. Implement if the tradeoffs are
acceptable.

**What would constitute success:** `PolicyEngine` runs in a separate process.
The UI can request evaluations but cannot directly modify policy state.

**Current state:** Not started. Single-process architecture.

---

## Medium-term objectives (3–6 months)

### 7. Semantic proposal validation

The current parameter allowlist (`"prompt"`, `"message"`) prevents arbitrary
parameter injection. It does not prevent semantically harmful proposals that
use allowed parameter keys.

**What we will do:** Add a validation layer that checks parameter values
against capability-specific constraints: type, range, format, enum membership.
Test with adversarial proposals that pass the current allowlist.

**What would constitute success:** A set of adversarial proposals that pass
the current key-level allowlist are caught by value-level validation.

**Current state:** Not started. Key-level allowlist only.

---

### 8. Vela black-screen root cause

A from-scratch Vela Quick App black-screens on Redmi Watch 4. The Songbird-derived
structure works. The root cause is unknown.

**What we will do:** Systematically compare working and broken RPKs. Identify
the minimum viable structure. Document renderer requirements.

**What would constitute success:** A from-scratch minimal Vela app that opens
correctly, with documented structural requirements.

**Current state:** Workaround known (use Songbird structure). Root cause
unproven.

---

### 9. Direct BLE protocol implementation

Both Mi Fitness and Gadgetbridge are external dependencies. A direct BLE
protocol would give PIRA full transport control.

**What we will do:** Investigate BLE GATT services and characteristics on
WATCH-01. Attempt to send and receive raw BLE packets. Compare with known
XMS packet structure.

**What would constitute success:** One arbitrary payload sent from NODE-01 to
WATCH-01 via raw BLE without Mi Fitness or Gadgetbridge.

**Current state:** Not started. Assumed to require proprietary service UUIDs
and authentication.

---

## Long-term objectives (6+ months)

### 10. Watch microphone access

Voice is a natural interface for an agent. Whether Vela Quick Apps can access
the watch microphone is unknown.

**What we will do:** Investigate Vela API surface for microphone access. If
available, build a capture→phone→agent pipeline with explicit user control.

**What would constitute success:** One audio frame captured on WATCH-01 and
received on NODE-01.

**Current state:** Assumed unavailable. No Vela microphone API documentation
found.

---

### 11. Multi-user consent model

The current authorization model assumes a single user. A shared household
device requires isolation between user profiles.

**What we will do:** Design a multi-user consent flow with authorization
isolation. Define use cases: shared device, multiple agents, guest access.

**What would constitute success:** Design document for multi-user consent with
at least two distinct user profiles and isolated authorization sets.

**Current state:** Not started. Single-user model only.

---

### 12. Credential rotation

Nebius API keys expire or get compromised. Manual re-entry is error-prone.

**What we will do:** Design an automated key rotation flow that updates the
stored credential without user intervention, with audit trail and grace period
for old keys.

**What would constitute success:** Key rotation completes without user action.
Old key remains valid during grace period. Audit trail records the rotation.

**Current state:** Not investigated.

---

### 13. Watch→HTTP direct networking

If WATCH-01 can make HTTP requests directly, it becomes more autonomous.

**What we will do:** Investigate Vela networking API. Attempt an HTTP GET from
WATCH-01 to NODE-01.

**What would constitute success:** One HTTP GET from WATCH-01 reaching
NODE-01 and receiving a response.

**Current state:** Assumed unavailable based on current evidence.

---

## What we are not claiming

We are not claiming that any of the above objectives are in progress,
partially complete, or likely to succeed. Each is an open question with
documented evidence status.

We are not claiming partnership, endorsement, or integration with Gadgetbridge,
Nebius, Xiaomi, or any third-party project.

We are not claiming that PIRA Android is production-ready. The current
implementation is a prototype with documented limitations.

---

*Statement of objectives maintained by PIRA-Labs.
Updated as experiments complete. Does not represent commitments.*
