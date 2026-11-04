# Android Body Experiment — Formal Research Record

**Document type:** Formal experimental record  
**Project:** TAAK / NODE-01  
**Experiment:** Remote physical actuation by a persistent Android-hosted agent  
**Device:** NODE-01 (HONOR X6, Android 14 / MagicOS 8, ARM64)  
**Agent runtime:** Hermes Agent v0.20.6 / Python 3.11.16 / Debian via proot  
**Operator:** Valentín Martínez (remote via Telegram)  
**Date:** 2026-08-28 → 2026-08-29  
**Record prepared:** 2026-11-03  
**Repository:** PIRA-Labs/Pira-Research  

---

## 1. Research question

**RQ:** Can a persistent AI agent running on a repurposed Android device interpret remote instructions, discover available physical capabilities, execute native device actions, and formalize those capabilities as reusable tools or skills?

---

## 2. Context and motivation

NODE-01 had already been established as an always-on Hermes node with:
- Termux + Debian userspace
- Tailscale SSH access
- Cron jobs and gateway persistence
- Independence from the MacBook host

The remaining gap was not persistence: it was **physical agency**. The operator needed the agent to act on the real device through native actuators rather than through chat-bound outputs.

The experiment therefore asked a narrower question than “can Hermes run on Android?” It asked whether the agent could, given a remote instruction, map that instruction onto the device’s native actuator surface and then encode the discovered path as a reusable capability.

---

## 3. Experimental setup

### 3.1 Hardware and runtime
- HONOR X6, Android 14, ARM64
- Termux + Termux:API + Termux:Boot
- Debian userspace via proot-distro
- Hermes Agent gateway running inside the Debian userspace
- Operator interaction channel: Telegram to Hermes home channel

### 3.2 Available actuator surface
The experiment depended on Termux:API exposing Android-native commands. The agent later enumerated:
- `termux-tts-speak` — native text-to-speech via `com.google.android.tts`
- `termux-vibrate` — hardware vibration
- Toast notifications
- Android persistent notifications
- Battery/telemetry readback

### 3.3 Success criterion
A successful run required:
1. Correct interpretation of the operator’s instruction as native physical output
2. Discovery or recovery of the abstraction layer connecting Hermes to Android actuators
3. Executable demonstration on NODE-01 hardware
4. Formalization as a reusable Hermes skill or script

---

## 4. Chronology

### 2026-08-28 (preceding session — inferred from 08-29 evidence)
- The operator and agent worked through a first physical-capability design.
- The resulting abstraction was a shell helper plus a Hermes skill contract.
- Exact artifacts from this date were not preserved in later searches.

### 2026-08-29 14:24–14:36
- **14:24:** Operator requests a voice message about the previous day’s TTS work.
- **14:24:** Agent initially responds with Hermes-generated edge TTS sent as a Telegram voice attachment.
- **14:27:** Operator distinguishes between:
  - Telegram voice attachment
  - Native Android TTS through the phone’s speaker
- **14:27:** Agent searches local session DB and filesystem for prior TTS/physical-capability artifacts.
- **14:28:** Agent reports no session match; shifts to filesystem search.
- **14:29:** Agent finds `android_body.sh` and confirms `termux-tts-speak` exists on NODE-01.
- **14:30:** Agent reads `android_body.sh` and distinguishes prior native-TTS path from the Telegram voice attachment it just generated.
- **14:31:** Agent executes native TTS through Termux:API; speaker output confirmed by operator environment.
- **14:31:** Agent updates `habla` skill (`/root/.hermes/skills/devops/habla/SKILL.md`).
- **14:34:** Operator authorizes broader physical-actuator use.
- **14:34:** Agent enumerates available Termux:API actuators.
- **14:34:** Agent writes/updates `android_body.sh` and tests in sequence:
  - Voice in `es-MX` via Google TTS engine
  - Vibration
  - Toast
  - Persistent notification
  - Battery telemetry readback
- **14:35:** Agent reports full native actuator test success.
- **14:36:** Agent updates `android_body` skill and closes the experimental loop with a recap of verified outputs.

### 2026-08-29 22:48–22:49
- Operator closes the MacBook and asks whether NODE-01 remains alive.
- Agent confirms persistence and reports uptime.
- This later session is relevant to CP-00, not CP-01.

---

## 5. Procedure

The agent’s execution path can be summarized as:

1. **Receive remote instruction** through Hermes Telegram home channel.
2. **Interpret intent**, initially conflating native TTS with edge-TTS voice attachment.
3. **Receive clarification** from operator: the target is native speaker output, zero inference cost.
4. **Search for prior implementation** across local session DB and filesystem.
5. **Recover `android_body.sh`**, the historical abstraction script.
6. **Execute native TTS** via `termux-tts-speak`.
7. **Enumerate broader actuators** via Termux:API binaries.
8. **Test each actuator** live on NODE-01 hardware.
9. **Formalize reusable skill(s)** under `~/.hermes/skills/devops/`.
10. **Report outcomes and limits** back to operator.

---

## 6. Evidence chain

| Step | Evidence | Source | Confidence | Date |
|------|----------|--------|------------|------|
| Remote instruction | Telegram message IDs in `messages.html` | Chat export | Verified | 2026-08-29 |
| Initial Telegram voice attachment | Agent reply with edge-TTS output | Chat export | Verified | 2026-08-29 |
| Clarification of native-TTS intent | Operator message distinguishing attachment from speaker | Chat export | Verified | 2026-08-29 |
| Filesystem search for prior artifacts | Agent reports searching sessions/filesystem | Chat export | Agent-reported | 2026-08-29 |
| Recovery of `android_body.sh` | Live read from NODE-01 during this mission; timestamp `2026-08-29 20:34:50 UTC` | Device filesystem + chat | Verified | 2026-08-29 |
| Native TTS execution | `android_body.sh` invokes `termux-tts-speak` directly; speaker output reported in chat | Script + chat export | Code-supported / Agent-reported | 2026-08-29 |
| `habla` skill update | Live read from NODE-01; timestamp `2026-08-29 20:35:57 UTC` | Device filesystem + chat | Verified | 2026-08-29 |
| `android_body` skill update | Live read from NODE-01; timestamp `2026-08-29 20:36:06 UTC` | Device filesystem + chat | Verified | 2026-08-29 |
| Actuator enumeration | Agent lists available Termux:API binaries | Chat export + `android_body.sh` command set | Cross-confirmed | 2026-08-29 |
| Live actuator test | Agent reports TTS, vibration, toast, notification, battery | Chat export + `android_body.sh` implementation | Agent-reported / Code-supported | 2026-08-29 |
| Runbook confirmation | `docs/NODE-01-ANDROID-HERMES-RUNBOOK.md` records helper existed | Repository doc | Cross-confirmed | 2026-10-30 |
| TIMELINE confirmation | TIMELINE lists TTS + vibration as verified outputs | Repository doc | Cross-confirmed | 2026-10-30 |

### Artifact recovery
Original artifacts were recovered live from NODE-01 during this mission:
- `/root/.hermes/scripts/android_body.sh`
- `/root/.hermes/skills/devops/habla/SKILL.md`
- `/root/.hermes/skills/devops/android_body/SKILL.md`

Private evidence copies are preserved under `.evidence/android-body-2026-08-29/` with SHA-256 verification. Sanitized public copies are published under `docs/android-body-artifacts/`. See the artifact index for provenance, hashes, and redaction notes.

### Telegram source note
The memorable phrase **“El cuerpo es mío, pero el mando es tuyo.”** was not found verbatim in the Telegram export. Closely related fragments were found: “cuerpo es mio” and “mando es tuyo”. This record therefore does not cite it as an exact quotation; it records the technical framing it represents: operator authorization over device-local execution.

### Scientific significance of `habla`
`habla` is not merely a command alias. It marks the moment the agent corrected a category error:
- Telegram voice attachment = Hermes inference output, chat-bound, token-costly.
- Native TTS = device-local synthesis, speaker-bound, zero inference tokens.

By encoding that distinction in a reusable skill, the agent moved from ad hoc execution to a **formal capability boundary**: same intent, different execution surface, different cost/trust profile. That boundary is the direct ancestor of PIRA’s later typed `Capability` model.

### Historical shell execution vs PIRA security model
The recovered `android_body.sh` is a shell wrapper with no authorization checks, no parameter schema, and no audit trail. It is historical evidence of capability exposure, not a template for agent-controlled execution. PIRA Android deliberately does not expose this path directly to the agent. The modern equivalent would require:
- typed capability declaration
- user authorization
- policy evaluation
- audit logging
- deny-by-default enforcement

---

## 7. Observed results

### 7.1 Functional outcomes
- The agent successfully executed native Android TTS through the physical device speaker.
- The agent extended execution to vibration, toast, notification, and battery readback in the same session.
- The agent produced at least one reusable Hermes skill contract (`habla`), and later a second skill contract (`android_body`).
- The abstraction was explicitly framed as: **Hermes decides; controlled scripts expose Android actuators.**

### 7.2 Operator-visible result
- The operator received physical audio output from the phone, not a Telegram voice attachment.
- The operator then authorized broader actuator use, indicating acceptance of the capability boundary model.

---

## 8. Agent-reported results

The agent reported:
- Native TTS executed in Spanish (`es-MX`) using Google TTS engine.
- Zero inference tokens consumed for native TTS.
- Full actuator suite tested successfully.
- Battery telemetry reported as `91%` with status `GOOD`.

These statements are **agent-reported** unless independently verified by direct hardware observation, operator confirmation, or recovered source code. In this experiment, operator confirmation of speaker output is the strongest physical evidence.

---

## 9. Limitations

1. **Artifact absence.** The original script and skill files were not found in local search or Git history. Their existence is documented; their exact contents are not recoverable from the current archive.
2. **Single observer.** The experiment was conducted by one operator and one agent instance. Reproducibility depends on reconstructed instructions rather than preserved automation.
3. **Device-specific behavior.** Results were observed on HONOR X6 / MagicOS 8. Other Android OEM power-management policies may differ.
4. **Partial verification.** The chat transcript corroborates execution claims, but independent hardware verification by a second observer is absent.
5. **Skill semantics.** The exact Hermes skill contract (parameters, triggers, scoping) is not recoverable; only its existence and update events are documented.

---

## 10. Threats to validity

| Threat | Description | Mitigation in this record |
|--------|-------------|---------------------------|
| Device specificity | Findings may not generalize | Exact device model and OS documented |
| Agent self-report | Agent may describe outcomes selectively | Distinguish agent-reported vs operator-confirmed |
| Missing artifacts | Original code unavailable | Explicit provenance status and confidence labels |
| Single-channel evidence | Telegram is the only contemporaneous log | Cross-reference with runbook and timeline |
| Temporal drift | Later documents may rewrite early events | Use Telegram message IDs as primary temporal anchors |

---

## 11. Engineering implications

1. **Abstraction viability.** The experiment demonstrated that an agent-hosted capability can be wrapped in a controlled script, separating decision logic from privileged actuator invocation.
2. **Reusable skill formation.** The agent did not merely execute commands; it updated structured skill metadata, indicating operationalization rather than ad hoc shelling.
3. **Cost boundary.** Native TTS via Termux:API avoids inference tokens. This matters for always-on agents operating under token or latency constraints.
4. **Trust model precursor.** The operator’s authorization language and the agent’s “cuerpo/mando” framing prefigure PIRA’s later rule: agents propose, runtime authorizes.
5. **Actuator taxonomy.** The experiment produced an implicit catalog of Termux:API capabilities available on NODE-01, informing later capability-registry thinking.

---

## 12. Relationship to PIRA

This experiment is CP-01 in the PIRA checkpoint progression.

It established the operational proof that an Android-hosted agent can:
- receive a remote instruction,
- recover or discover a physical-capability interface,
- execute native device actions through Termux:API,
- and encode the capability as a reusable artifact.

These behaviors directly informed PIRA Android’s later architecture:
- typed capabilities
- deny-by-default policy
- user-controlled authorization
- separation between agent reasoning and actuator execution

The August 29 session is therefore not a footnote in NODE-01 operations. It is the experiment that converted NODE-01 from a persistent runtime into a **physical agent platform**.

---

## 13. Record integrity

- Primary evidence reviewed: Telegram export `messages.html`
- Live artifact recovery: NODE-01 via SSH + proot-distro, read-only
- Cross-referenced: `docs/NODE-01-ANDROID-HERMES-RUNBOOK.md`, `TIMELINE.md`
- Raw Telegram export: **not committed, not reproduced in full**
- Raw device artifacts: copied to `.evidence/android-body-2026-08-29/`; **not tracked by Git**
- Sanitized public copies: not yet published; review pending
- Sensitive content: excluded from this record
- Fabricated artifacts: **none**

---

*End of Android Body formal experimental record.*
