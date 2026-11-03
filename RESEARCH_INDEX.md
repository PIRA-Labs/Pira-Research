# Research Index — PIRA Technical Provenance

Quick-reference map to every document in this archive.

---

## Documents by topic

### Android agent runtime
- `docs/NODE-01-ANDROID-HERMES-RUNBOOK.md` — Full runbook: HONOR X6 → Termux → Debian → Hermes on ARM64
- `references/pantera_recovery.md` — Model expiration, gateway restart, self-protection pitfall

### Wearable reverse engineering
- `docs/WATCH-01-VELA-REVERSE-ENGINEERING.md` — Redmi Watch 4 / Vela Quick Apps, deployment, Metronome v1
- `docs/TAAK-WATCH-01-ARTIFACTS-REPRODUCIBILITY-RUNBOOK-2026-08-31.md` — Signing, ADB, XMS AAR, known-good MainActivity
- `experiments/wearable-xms-important.txt` — WearableXmsService analysis, packet IDs, feature gate
- `experiments/result-2026-09-01-miau-rx.md` — Root cause of the XMS third-party app block and bypass

### Laboratory notebooks
- `experiments/TAAK-WATCH-01-LAB-BITACORA-2026-08-31.md` — Day-by-day lab log: pairing, XMS, permission, listener
- `experiments/PANTERA_SANSON_LAB_2026-09-01.md` — The MIAU bidirectional bridge milestone

### Architecture and design
- `docs/TAAK-PHYSICAL-AGENT-ARCHITECTURE.md` — Capability registry, bridge levels, trust boundaries, evidence labels
- `experiments/FORMAL-VELA-ANDROID-MIAU-MILESTONE.md` — **Formal milestone record: artifact preservation, evidence register, methodology, knowledge transfer, security foundation, release inventory**
- `RESEARCH_ROADMAP.md` — Prioritized research plan with P0/P1/P2/P3 items, evidence criteria, dependencies, and 4 research themes — **Formal milestone record: artifact preservation, evidence register, methodology, knowledge transfer, security foundation, release inventory**
- `README.md` — Archive overview and PIRA relationship

### Decisions
- `decisions/README.md` — Key decisions with evidence and alternatives considered

---

## Documents by evidence level

### Verified (physical hardware evidence)
- NODE-01 Termux + Debian + Hermes on ARM64
- Redmi Watch 4 Vela Quick App execution
- TAAK Metronome v1: touch, timers, vibration
- Phone → watch message via XMS (`miau-from-android` delivered)
- Watch emits physical `20/6` packet observed on phone
- bidirectional MIAU bridge (watch → logcat → broadcast → app → watch)

### Code-mapped (decompiled/reverse engineered)
- WearableXmsService packet dispatch
- isSupportThirdPartyApp feature gate
- XMS service 20 protocol mapping (20/0–20/22)
- Gadgetbridge source integration points

### Inferred (evidence-backed hypotheses)
- Gadgetbridge as Mi Fitness replacement
- 20/8 sendPhoneMessage as phone→watch channel
- Direct BLE protocol as long-term path

### Unverified (targets, not yet proven)
- Watch → phone arbitrary payload via public API
- Watch microphone access from Vela Quick App
- Direct WATCH → HTTP → NODE without phone bridge
- Custom interconnect implementation in Gadgetbridge

---

## Chronological reading order

1. `README.md` — context and motivation
2. `TIMELINE.md` — chronological reconstruction
3. `docs/NODE-01-ANDROID-HERMES-RUNBOOK.md` — agent runtime foundation
4. `docs/WATCH-01-VELA-REVERSE-ENGINEERING.md` — wearable deployment
5. `docs/TAAK-WATCH-01-ARTIFACTS-REPRODUCIBILITY-RUNBOOK-2026-08-31.md` — XMS integration
6. `experiments/TAAK-WATCH-01-LAB-BITACORA-2026-08-31.md` — detailed lab log
7. `experiments/result-2026-09-01-miau-rx.md` — the feature gate discovery
8. `experiments/PANTERA_SANSON_LAB_2026-09-01.md` — the milestone
9. `docs/TAAK-PHYSICAL-AGENT-ARCHITECTURE.md` — design implications

---

## Source repositories

These experiments originated in two private repositories:

- `taak-companion` — Android runtime, XMS integration, ADB scripts
  (local: `/Users/valedev/Documents/taak-companion`)
- `Taak-Intelligence/TAAK-INTELLIGENCE-2026-08-30` — lab notebooks, architecture,
  runbooks (local: `/Users/valedev/Documents/Taak-Intelligence`)

This archive contains only analysis, conclusions, and sanitized references.
Full source code, binaries, and sensitive artifacts remain in the original
repositories.

---

*Last updated: 2026-10-30*
