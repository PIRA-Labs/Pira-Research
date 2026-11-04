# PIRA Checkpoints — Experimental Progression

**Status:** Historical and planned checkpoints for the PIRA research lineage  
**Evidence basis:** Telegram exports, Taak-Intelligence documents, PIRA-Research archives  
**Last updated:** 2026-11-03  

---

## CP-00 — Persistent Agent Runtime

**Research question:** Can a low-cost Android device operate as an independent, persistent AI-agent runtime?

**Status:** Historical experiment completed; evidence confidence high.

**Evidence highlights:**
- HONOR X6 running Termux + Debian + Hermes ARM64
- Tailscale SSH access
- Boot persistence via Termux:Boot and wake-lock
- Mac-off heartbeat continuation verified by SQLite rows (`ts 1787979061 → 1787979086`)

**Primary documents:**
- `docs/NODE-01-ANDROID-HERMES-RUNBOOK.md`
- `references/pantera_recovery.md`

**Relationship to PIRA:** Proved the device-class target and operational persistence model that PIRA Android inherits.

---

## CP-01 — Remote Physical Actuation and Agent Skills

**Research question:** Can an Android-hosted agent execute native physical capabilities in response to remote instructions and encapsulate those capabilities as reusable skills?

**Status:** Historical experiment completed as reported; independently verifiable from Telegram evidence, with some missing source artifacts.

**Evidence highlights:**
- August 28–29 Telegram conversations: native TTS via `termux-tts-speak`
- Recovery of `android_body.sh` reported in chat
- Live tests: TTS (`es-MX`), vibration, toast, notification, battery telemetry
- Hermes skill updates: `habla` and `android_body`
- Operator confirmation of speaker output

**Primary documents:**
- `experiments/android-body-2026-08-29.md`
- `docs/NODE-01-ANDROID-HERMES-RUNBOOK.md` — Section 8
- `TIMELINE.md` — Phase 1 entries

**Missing artifacts:**
- Original `android_body.sh`
- Original `habla/SKILL.md`
- Original `android_body/SKILL.md`

**Relationship to PIRA:** Established that physical capabilities could be wrapped as controlled scripts and formalized as skills, directly prefiguring PIRA’s capability-registry and trusted-executor model.

---

## CP-02 — Wearable Communication

**Research question:** Can a custom wearable application exchange physical events with an Android companion through the available Xiaomi ecosystem?

**Status:** Historical experimental milestone demonstrated with documented transport limitations.

**Evidence highlights:**
- Redmi Watch 4 Vela Quick App deployment without root
- TAAK Metronome v1: touch, timers, vibration
- Phone → watch via XMS with DID bypass (`miau-from-android`)
- Watch → phone event detection via Mi Fitness log bridge (`20/6`)
- Bidirectional MIAU confirmed at 02:33 CST, 2026-09-01

**Primary documents:**
- `docs/WATCH-01-VELA-REVERSE-ENGINEERING.md`
- `docs/TAAK-WATCH-01-ARTIFACTS-REPRODUCIBILITY-RUNBOOK-2026-08-31.md`
- `experiments/TAAK-WATCH-01-LAB-BITACORA-2026-08-31.md`
- `experiments/PANTERA_SANSON_LAB_2026-09-01.md`
- `experiments/result-2026-09-01-miau-rx.md`
- `experiments/FORMAL-VELA-ANDROID-MIAU-MILESTONE.md`

**Known limitations:**
- Watch → phone arbitrary payload via public API remains blocked by feature gate
- Gadgetbridge pairing unverified
- Transport depends on Mi Fitness in current prototype

**Relationship to PIRA:** The feature-gate discovery shaped the deny-by-default principle; the log-bridge prototype informed audit-trail design.

---

## CP-03 — PIRA Android v0.1.0

**Research question:** Can historical agent/device research be translated into a typed, user-controlled Android runtime architecture?

**Status:** Initial released implementation; hardware-verified prototype.

**Evidence highlights:**
- Kotlin runtime with typed `Capability` enum and `ActionProposal`
- `PolicyEngine` deny-by-default implementation
- Android Keystore AES-GCM credential storage
- Emergency stop and audit logging
- Unit tests for policy behavior
- Debug APK installed on HONOR VNE-LX3

**Primary documents:**
- `PIRA-Labs/Pira-Android/README.md`
- `docs/EXPERIMENTS.md` in Pira-Android
- `docs/THREAT_MODEL.md` in Pira-Android

**Important distinctions:**
- Does not include the historical MIAU XMS adapter by default
- Does not include historical `android_body.sh` actuator wrappers
- Does not imply prior wearable/body capabilities are pre-integrated

**Relationship to PIRA:** This is the first formal product artifact, not the culmination of the research program.

---

## CP-04 — Authorized Physical Intelligence

**Research question:** Can PIRA integrate real physical capabilities into a trusted runtime that separates agent reasoning from user-authorized execution?

**Status:** Planned; not yet implemented or validated.

**Target capabilities:**
- Android-native TTS
- Battery and sensor readings
- User-approved physical actions
- Wearable messaging through a validated transport
- Structured capability discovery
- Execution audit trails

**Primary documents:**
- `RESEARCH_ROADMAP.md`
- `NEXT_OBJECTIVES.md`
- `docs/TAAK-PHYSICAL-AGENT-ARCHITECTURE.md`
- `experiments/FORMAL-VELA-ANDROID-MIAU-MILESTONE.md` — Section 5

**Design constraint:**
> AI agents may propose actions, but only a trusted user-controlled runtime can authorize and execute them.

**Relationship to PIRA:** Informs PIRA Android v0.2 design; no implementation during this research-mission pass.

---

## Checkpoint reading guide

1. Start with `CP-01` if your focus is physical actuation and agent skills.
2. Start with `CP-02` if your focus is wearable transport and protocol research.
3. Start with `CP-03` if your focus is the current released implementation.
4. Start with `CP-04` if your focus is architecture, security, or upcoming research.

All checkpoints share evidence labels:
- **Verified** — hardware/runtime observation
- **Agent-reported** — agent-claimed outcome; corroborated but not independently re-run
- **Code-supported** — source exists and describes capability
- **Missing artifact** — claimed but not yet recovered
- **Unverified** — target with no completed evidence

---

*Checkpoint map maintained by PIRA-Labs.*
