# PIRA Research — Technical Provenance & Experiment Archive

**Status:** Active research archive
**Organization:** PIRA-Labs
**License:** MIT (documentation); see NOTICE.md for third-party credits

---

## Why this repository exists

PIRA did not begin as a hackathon submission.

Before PIRA was a runtime, it was a series of hands-on experiments with
Android devices, Bluetooth wearables, agent persistence, and Xiaomi's
proprietary communication protocols.

This repository preserves those experiments — both what worked and what did not —
so the engineering choices behind PIRA are reproducible, auditable, and
discoverable.

---

## What you will find here

- **NODE-01** — how an inexpensive Android phone (HONOR X6) became an
  always-on Hermes agent node running Termux + Debian + proot-distro
- **WATCH-01** — reverse engineering of Xiaomi's XMS wearable protocol on a
  Redmi Watch 4, including the feature gate that blocks third-party apps
- **Bidirectional bridge** — the MIAU experiment that achieved physical
  watch→phone→agent communication without modifying Mi Fitness
- **Architecture evolution** — how device bridge research informed PIRA's
  trust-boundary design
- **Security research** — early experiments with Keystore, BLE pairing,
  permission boundaries, and action authorization that shaped PIRA's
  deny-by-default policy engine

---

## What you will NOT find here

- API keys, signing material, or credentials (never committed, never published)
- Full decompiled source code from proprietary applications
- The Mi Fitness APK or extracted class files
- Xiaomi authentication keys or pairing secrets
- Personal device identifiers beyond what is needed for reproducibility

We document conclusions and methodologies. We do not distribute artifacts
we are not entitled to share.

---

## Evidence methodology

Every document in this archive uses one of these labels:

| Label | Meaning |
|-------|---------|
| **Verified** | Observed on physical hardware or confirmed by runtime evidence |
| **Code-mapped** | Recovered from decompiled code but not necessarily exercised |
| **Inferred** | Evidence-backed architectural hypothesis |
| **Unverified** | Idea or target; do not build dependent claims on it |

Dates are taken from Git commits, log timestamps, and file metadata.
Where dates cannot be determined, uncertainty is preserved.

---

## Relationship to PIRA

These experiments directly informed PIRA's architecture:

```text
TAAK research (2026-08 to 2026-09)
    │
    ├── Android as agent runtime          → PIRA Android companion
    ├── XMS wearable protocol             → PIRA capability authorization
    ├── Feature-gate discovery            → PIRA deny-by-default policy
    ├── Log-based event bridge            → PIRA audit trail concept
    ├── Keystore credential storage       → PIRA SecureKeyStore
    ├── Device identity research          → PIRA DID/capability model
    └── Mi Fitness as driver              → PIRA trusted executor boundary
```

PIRA's central thesis — *agents may propose actions, but only a trusted
user-controlled runtime can authorize and execute them* — emerged directly
from observing what happens when an agent is given unrestricted access to
device APIs versus when every capability is typed, scoped, and logged.

---

## Repository structure

```
Pira-Research/
├── README.md                  ← you are here
├── RESEARCH_INDEX.md          ← quick reference to all documents
├── TIMELINE.md                ← chronological reconstruction
├── docs/
│   ├── NODE-01-ANDROID-HERMES-RUNBOOK.md
│   ├── TAAK-PHYSICAL-AGENT-ARCHITECTURE.md
│   ├── WATCH-01-VELA-REVERSE-ENGINEERING.md
│   └── TAAK-WATCH-01-ARTIFACTS-REPRODUCIBILITY-RUNBOOK-2026-08-31.md
├── experiments/
│   ├── TAAK-WATCH-01-LAB-BITACORA-2026-08-31.md
│   ├── PANTERA_SANSON_LAB_2026-09-01.md
│   ├── result-2026-09-01-miau-rx.md
│   └── wearable-xms-important.txt
├── decisions/
│   └── README.md              ← key decisions and their evidence
└── references/
    └── pantera_recovery.md    ← gateway/operational recovery notes
```

---

## How to read this archive

Start with `RESEARCH_INDEX.md` for a structured overview, then `TIMELINE.md`
for the chronological journey. Dive into specific topics via `docs/`.

If you are reviewing PIRA for the Nebius AI Hackathon, the most relevant
documents are:

1. `TIMELINE.md` — the research journey in one document
2. `experiments/PANTERA_SANSON_LAB_2026-09-01.md` — the MIAU bidirectional bridge
3. `docs/TAAK-PHYSICAL-AGENT-ARCHITECTURE.md` — capability registry and trust boundaries

---

## Missing evidence

Some experiments are remembered but their artifacts were not preserved:

- Original Termux bootstrap scripts (reconstructed from runbook notes)
- Early ADB automation scripts before the NODE-01 runbook was written
- Gadgetbridge pairing session logs (auth key preserved locally, not published)
- Failed XMS packet experiments (logs not captured)
- Original Vela Quick App black-screen debugging session (root cause unproven)

These gaps are documented where relevant. Absence of evidence is noted
explicitly.

---

## License

Documentation in this repository is released under the MIT License.
See `LICENSE.md` for details.

Third-party acknowledgements: Textura/GetLayers (landing template), pmndrs
(grass shader), Xiaomi (XMS protocol — analyzed, not endorsed), Gadgetbridge
(open-source companion project).

---

*Research archive maintained by PIRA-Labs. Last updated: 2026-10-30*
