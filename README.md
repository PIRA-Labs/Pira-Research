# PIRA Research — Evidence Archive & Experimental Provenance

**Status:** Active research archive
**Organization:** PIRA-Labs
**License:** MIT (documentation); see NOTICE.md for third-party credits

---

## Research question

How can autonomous AI agents acquire persistent, useful, and verifiable physical capabilities through inexpensive Android devices while preserving user control over execution?

This archive preserves the experimental history behind that question: what worked, what failed, and what the recovered evidence actually shows.

---

## How to read this archive

Start with `docs/CHECKPOINTS.md` for the experimental progression, then `docs/SCIENTIFIC_OVERVIEW.md` for the research formulation, then `TIMELINE.md` for the chronological journey. Dive into specific records via `docs/` and `experiments/`.

Key documents:
- `docs/CHECKPOINTS.md` — CP-00 through CP-04 with evidence status
- `docs/SCIENTIFIC_OVERVIEW.md` — research problem, methodology, findings, limitations
- `experiments/android-body-2026-08-29.md` — CP-01 formal record with evidence chain
- `experiments/FORMAL-VELA-ANDROID-MIAU-MILESTONE.md` — CP-02 formal record
- `docs/android-body-artifacts/` — sanitized public copies of recovered NODE-01 artifacts

---

## Checkpoints

- **CP-00** — Persistent agent runtime on repurposed Android hardware
- **CP-01** — Remote physical actuation and reusable agent skills, including native TTS
- **CP-02** — Wearable communication research with documented transport limitations
- **CP-03** — Typed, user-controlled Android runtime implementation
- **CP-04** — Planned authorized physical intelligence behind explicit user consent

CP-01 is the foundational physical-intelligence experiment. The August 29 session demonstrated that an Android-hosted agent can recover a prior physical-capability interface, execute native device actions through Termux:API, and encode the behavior as reusable Hermes skills. The original artifacts were recovered from NODE-01 with SHA-256 provenance and are documented in `experiments/android-body-2026-08-29.md`.

CP-02 covers wearable research. The critical finding was that third-party watch→phone messaging was blocked by a software feature gate, not a hardware or protocol limit. That observation directly shaped PIRA's deny-by-default policy.

CP-03 is the current released implementation. It translates experimental findings into a typed Android runtime with a deterministic policy engine, short-lived authorizations, audit logging, and emergency stop.

CP-04 is the next milestone: native physical capability execution behind PIRA's authorization boundary, starting with trusted TTS.

---

## Evidence methodology

Every document uses one of these labels:

| Label | Meaning |
|-------|---------|
| **Verified** | Observed on physical hardware or confirmed by runtime evidence |
| **Code-mapped** | Recovered from decompiled code but not necessarily exercised |
| **Inferred** | Evidence-backed architectural hypothesis |
| **Unverified** | Target with no completed evidence |

Dates are taken from Git commits, log timestamps, file metadata, and Telegram message IDs. Where dates cannot be determined, uncertainty is preserved.

---

## Artifact recovery

Original NODE-01 artifacts recovered during this mission:
- `android_body.sh`
- `habla/SKILL.md`
- `android_body/SKILL.md`

Private evidence is preserved under `.evidence/android-body-2026-08-29/` and is excluded from Git. Sanitized public copies are published under `docs/android-body-artifacts/` with provenance and redaction notes.

---

## Repository structure

```
Pira-Research/
├── README.md                  ← you are here
├── RESEARCH_INDEX.md          ← structured document map
├── TIMELINE.md                ← chronological reconstruction
├── docs/
│   ├── CHECKPOINTS.md         ← CP-00 to CP-04
│   ├── SCIENTIFIC_OVERVIEW.md ← research formulation
│   ├── NODE-01-ANDROID-HERMES-RUNBOOK.md
│   ├── TAAK-PHYSICAL-AGENT-ARCHITECTURE.md
│   ├── WATCH-01-VELA-REVERSE-ENGINEERING.md
│   ├── TAAK-WATCH-01-ARTIFACTS-REPRODUCIBILITY-RUNBOOK-2026-08-31.md
│   └── android-body-artifacts/ ← recovered artifact provenance
├── experiments/
│   ├── android-body-2026-08-29.md
│   ├── TAAK-WATCH-01-LAB-BITACORA-2026-08-31.md
│   ├── PANTERA_SANSON_LAB_2026-09-01.md
│   ├── result-2026-09-01-miau-rx.md
│   └── wearable-xms-important.txt
├── decisions/
│   └── README.md
└── references/
    └── pantera_recovery.md
```

---

## What this repository is NOT

- It is not the PIRA runtime or Android application
- It is not a product marketing repository
- It does not distribute Mi Fitness binaries, Xiaomi auth keys, signing keys, or credentials
- It does not claim that historical experimental paths are already integrated into PIRA Android

---

## Evidence and limitations

This archive preserves primary evidence, including negative results and uncertainty. Key limitations:

- Some evidence is corroborated by agent reports and chat exports, but not independently re-run by a second observer
- Wearable results are device- and firmware-version-specific
- The historical `android_body.sh` wrapper lacks authorization, schema validation, and audit controls; it is evidence of capability exposure, not a secure execution template
- PIRA Android v0.1.0 does not include the historical actuator or wearable adapters
- Comprehensive security evaluation remains future work

---

## License

Documentation is released under the MIT License. See `LICENSE.md`.

Third-party acknowledgements: Textura/GetLayers (landing template), pmndrs (grass shader), Xiaomi (XMS protocol — analyzed, not endorsed), Gadgetbridge (open-source companion project).

---

*Research archive maintained by PIRA-Labs. Last updated: 2026-11-03*
