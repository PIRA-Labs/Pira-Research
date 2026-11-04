# PIRA — Scientific Research Overview

**Status:** Active retrospective research program  
**Scope:** Evidence-backed experimental history, not a product roadmap  
**Last updated:** 2026-11-03  

---

## Research problem

Autonomous AI agents increasingly operate on devices with physical actuators: speakers, vibration motors, displays, sensors, radios. Most current agent runtimes either:
- remain confined to digital outputs, or
- grant agents unrestricted access to device APIs.

Both options are inadequate for trusted physical presence.

PIRA investigates a third path:

> **How can autonomous AI agents acquire persistent, useful, and verifiable physical capabilities through inexpensive Android devices while preserving user control over execution?**

---

## What we actually did

We did not design PIRA on paper. We built a sequence of physical prototypes and observed where the boundaries broke.

### Phase A — Persistent runtime on repurposed hardware
- Target device: HONOR X6, Android 14, ARM64, ~$100 USD equivalent class
- Stack: Termux → proot Debian → Hermes Agent → Tailscale SSH → cron jobs
- Key finding: persistence depends on process and boot management, not on the host computer. Turning off the MacBook did not kill the agent.

### Phase B — Native physical actuation from a remote agent
- Remote instruction → agent interpretation → recovery of historical abstraction script → native TTS through `com.google.android.tts`
- Extends to vibration, toast, notification, battery telemetry
- Result: the agent can act on the physical device without inference tokens, and can encode the capability as a reusable Hermes skill

### Phase C — Wearable communication through a closed ecosystem
- Target: Redmi Watch 4 (Vela / HyperOS)
- Finding: the blocking condition for third-party watch→phone messaging was a software feature gate, not a hardware or protocol limit
- Implication: deny-by-default and audit-before-discard become essential when transport layers silently drop payloads

### Phase D — Type-safe, user-controlled runtime
- Translation of experimental findings into a typed Android architecture
- Core guarantee: agents may propose actions; only a trusted, user-controlled runtime may authorize and execute them

---

## Methodology

We followed an iterative empirical approach:

1. **Physical minimum first:** input físico → evidencia observable
2. **Map the chain:** A → B → C → D → E
3. **Classify components:** do we control it? is it open? is it replaceable?
4. **Search alternatives before decompiling**
5. **Measure before inferring**
6. **Trace code end-to-end:** caller → SDK → IPC → service → condition → data source
7. **Falsifiable hypotheses:** each has prediction, test, result, status
8. **Find asymmetries:** one blocked API does not mean all APIs are blocked
9. **Distinguish mechanism from policy:** can the device, or did software decide not to allow it?

This is retrospective organization. We are not claiming these phases were executed under a formal research protocol at the time; we are reconstructing a defensible framework that matches the actual work.

---

## Findings

| Finding | Evidence type | Impact |
|---------|--------------|--------|
| Inexpensive Android can host a persistent Hermes runtime | Verified | Target platform validated |
| Agent-driven native TTS avoids inference cost | Agent-reported + runbook | Operational efficiency |
| Physical capabilities can be wrapped as reusable skills | Agent-reported + cross-doc | Reusability pattern |
| Wearable transport can be silently blocked by software policy | Verified | Deny-by-default rationale |
| Log observation can substitute for protocol modification | Verified | Audit-trail rationale |
| Feature gates are policy, not hardware limits | Code-mapped | Bypass / replacement strategy |

---

## Limitations

- Single-researcher experiments; reproducibility depends on reconstructed instructions, not fully automated fixtures
- Some evidence is agent-reported and corroborated, but not independently re-run by a second observer
- Wearable results are device- and firmware-version-specific
- Historical `android_body.sh` is a shell wrapper without authorization or audit controls; it is evidence of capability exposure, not a secure execution template
- PIRA Android v0.1.0 does not integrate the historical actuator or wearable adapters
- Comprehensive security evaluation is future work

---

## Longer-term directions

Plausible extensions grounded in existing evidence:
- Agentic environmental sensing on repurposed Android devices
- Distributed sensor-node configurations
- Trusted agent-to-device capability interfaces
- Open-source transport replacements for closed wearable ecosystems
- Multi-device coordination with explicit user consent

These are research hypotheses, not implemented features.

---

*This overview is a concise formulation, not an approved research title or doctoral thesis statement.*
