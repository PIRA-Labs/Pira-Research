# TAAK Physical Agent Architecture --- Pantera Beyond the Screen

**Status:** architecture + capability registry · **Snapshot:**
2026-08-30

## 1. Thesis

TAAK is building a physical computing fabric where an AI agent can
inhabit persistent devices, observe system state, operate explicitly
authorized actuators and present low-friction human interfaces.

``` text
AGENT BRAIN → PERSISTENT NODE → BRIDGES → PHYSICAL INTERFACES / ACTUATORS
```

Current reality:

``` text
Pantera/Hermes
     ↓
NODE-01 (HONOR X6)
 ├─ telemetry / crons / SQLite
 ├─ TTS / vibration
 ├─ SSH / Tailscale
 └─ Android HUD

WATCH-01 (Redmi Watch 4)
 ├─ custom Vela RPK
 ├─ touch / timers / UI
 └─ haptic actuator

MISSING LINK: WATCH-01 ⇄ PHONE-BRIDGE ⇄ NODE-01
```

## 2. Capability registry

### NODE-01 --- VERIFIED

Android host; Termux; Debian via proot-distro; Hermes on ARM64; gateway
on-node; SSH; Tailscale; Termux:Boot; wake-lock; Mac-independent
heartbeat; SQLite operational history; TTS; vibration; native NODE-01
HUD.

### WATCH-01 --- VERIFIED

Vela runtime; custom RPK sideload; custom JS; touch; reactive state;
timers; dynamic BPM scheduling; `system.vibrator`; physical haptics;
custom UI; tap tempo; meter selection.

### WATCH-01 --- UNVERIFIED

-   Quick App microphone access.
-   arbitrary watch→phone payload.
-   arbitrary phone→watch payload.
-   audio playback/TTS on watch.
-   custom-app access to individual health/environment sensors.
-   background execution semantics.
-   direct Internet networking; do not assume it.

## 3. Bridge problem

The next milestone is not voice. It is **one controlled payload crossing
the watch/phone boundary**.

``` text
LEVEL 0  WATCH local code                    DONE
LEVEL 1  WATCH → haptic hardware             DONE
LEVEL 2  WATCH → PHONE payload               NEXT
LEVEL 3  PHONE → WATCH payload               NEXT
LEVEL 4  WATCH ⇄ PHONE ⇄ NODE-01            FUTURE
LEVEL 5  WATCH ⇄ Pantera text round trip     FUTURE
LEVEL 6  push-to-talk / STT / TTS            FUTURE
LEVEL 7  contextual agent terminal on wrist  FUTURE
```

Mi Fitness code-mapped leads:

``` text
20/7 syncPhoneAppStatus
20/8 sendPhoneMessage
```

Trace callers/handlers and payloads. These names are leads, not proof
that a Vela app can invoke them.

## 4. TAAK Remote progression

**v0 PING:** WATCH button generates `miau`; observe on phone.\
**v0.1 ACK:** phone returns `pong`; watch renders state.\
**v0.2 NODE:** phone forwards privately to NODE-01.\
**v0.3 PANTERA:** constrained command → Pantera → text response.\
**v0.4 APPROVALS:** explicit APPROVE / REJECT / LATER controls; no
ambiguous one-tap high-impact actions.\
**v1 VOICE:** investigate watch microphone only after transport;
otherwise phone handles mic/STT/TTS while watch acts as
trigger/feedback.

## 5. Useful wearable apps

-   **Pantera Remote:** short prompts, replies, approvals.
-   **TAAK Pulse:** agent/job/project operational state.
-   **Capture:** one-tap capture into Pantera inbox; voice if audio path
    verifies.
-   **Node Monitor:** NODE-01/gateway/connectivity/heartbeat.
-   **Context Actions:** Pantera sends 2--4 temporary actions; watch
    renders and returns selection.
-   **Haptic language:** documented patterns for low-risk notification
    categories.

Keep WATCH-01 thin. Intelligence belongs primarily on NODE-01; the watch
is a fast interface, sensor/actuator endpoint and attention channel.

## 6. Health/wearable boundary

WATCH-01 has health/activity sensors and is interesting for personal
telemetry research, but heart rate, SpO2, sleep and motion are **not
glucose measurements**. Do not infer blood glucose from unrelated watch
sensors and present it as medical measurement.

A diabetes-oriented interface should integrate a validated glucose
source (CGM/glucose meter) if glucose values are needed. Sensor
availability to Xiaomi firmware also does not prove Vela app access;
verify each sensor API independently.

Safe conceptual architecture:

``` text
validated glucose source / CGM
          ↓
phone / health data
          ↓
analysis / reminders
          ↓
WATCH-01 display / haptic / logging
```

## 7. Trust/autonomy boundaries

Pantera may administer its own runtime, config, operational crons,
telemetry, storage, scripts and dedicated operational DB. Explicit
authorization remains required for spending/moving funds, legal
commitments, sensitive client-data actions, high-impact external actions
and public exposure of node services.

Network services default to localhost/Tailscale. Wearable convenience
must not silently expand authority.

## 8. Secret handling

Recommended `.gitignore` baseline:

``` gitignore
.env
.env.*
*.key
*.pem
secrets/
**/secrets/
*.jks
*.keystore
node_modules/
dist/
.DS_Store
```

Before push:

``` bash
git status
git diff --cached
```

## 9. Evidence labels

**VERIFIED:** observed on physical hardware/direct runtime evidence.\
**CODE-MAPPED:** recovered from code but not necessarily exercised.\
**INFERRED:** evidence-backed architectural hypothesis.\
**UNVERIFIED:** idea/target; do not build dependent claims on it.

Hardware features, Xiaomi firmware features and Vela Quick App APIs are
three distinct capability layers.

## 10. Immediate experiments

1.  Freeze/commit Metronome v1 and replace Songbird icon.
2.  Clone known-good Vela structure into `taak-remote`.
3.  Trace Mi Fitness `20/8 sendPhoneMessage` callers/payload.
4.  Attempt WATCH→PHONE fixed `miau`.
5.  Then build PHONE→NODE bridge.
6.  After text round-trip, investigate microphone/audio.
7.  Document every failed transport attempt.

Strategic success criterion:

``` text
WATCH-01 button → "miau" → PHONE-BRIDGE receives it
```

## 11. Generalizable reverse-engineering method

``` text
unknown consumer device
→ identify runtime
→ identify deployment surface
→ reverse engineer companion app
→ establish known-good control
→ mutate incrementally
→ verify hardware API
→ freeze golden build
```

The Metronome is valuable because it proved this method and opened a
reusable wearable platform.

**Operating principle:** *Si lo puedes imaginar, lo podemos programar
--- but mark the difference between imagined, inferred and verified.*
