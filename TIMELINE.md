# PIRA Research — Technical Timeline

Reconstruction of the experimental journey that led to PIRA.

**Evidence sources:** taak-companion Git history, Taak-Intelligence documents,
file metadata, and session notes. Dates are taken from commits, log timestamps,
and document snapshots. Uncertainty is preserved where evidence is incomplete.

---

## Phase 0 — Before the lab (pre-2026-08)

**Evidence:** Reconstructed from later documentation; no dated artifacts found.

**What we know:**
- An always-on AI agent gateway was running on a MacBook Air M1.
- Hermes Agent provided the runtime; Pantera was the agent identity.
- Operational crons, heartbeats, and telemetry kept the agent alive while the
  Mac was open.

**Problem identified:** The MacBook could not be the permanent physical home of
the agent. Closing the Mac killed the gateway. Persistence required moving the
runtime onto inexpensive hardware that could stay on 24/7.

**Confidence:** Reconstructed from ADRs and NODE-01 runbook notes.

---

## Phase 1 — Android as agent runtime (≈ 2026-08-15 to 2026-08-20)

**Evidence:** NODE-01 ANDROID HERMES RUNBOOK; Taak-Intelligence README snapshot
2026-08-30; hardware map.

### Milestones

1. **Device acquisition:** HONOR X6 selected as inexpensive Android target.
   Specs: Android 14 / MagicOS 8, ARM64, 4 GB RAM, 64 GB storage.
   Device ID: NODE-01.

2. **Developer access:** Seven-tap Developer Options unlock, USB debugging
   enabled, ADB connection established from MacBook Air M1.
   **Verified:** `adb devices` returned device serial.

3. **F-Droid + Termux:** Installed Termux, Termux:API, Termux:Boot from F-Droid
   (not Play Store, which carries an obsolete build).
   **Verified:** `pkg update && pkg upgrade && pkg install openssh
   proot-distro python git curl` completed.

4. **Termux SSH:** Enabled `sshd` on port 8022. Observed user `u0_a216`.
   **Verified:** SSH login from Mac confirmed.

5. **Tailscale:** Moved from LAN IP (`192.168.100.37`) to Tailscale address
   (`100.86.8.36`) for durable automation. SSH config simplified to `ssh node01`.
   **Verified:** Operational connectivity confirmed.

6. **Debian userspace:** Installed `proot-distro install debian` and logged in.
   Architecture confirmed `aarch64`.
   **Critical lesson learned:** Termux home and Debian rootfs home are two
   different paths. Hermes state must be copied to the path Hermes itself
   resolves inside the proot session, not the path that merely looks equivalent
   from Termux.

7. **Hermes on ARM64:** Verified snapshot:
   - Hermes Agent 0.20.6
   - Python 3.11.16
   - Architecture: aarch64
   - Model: tencent/hy3:free → later laguna(xs-2.1):free

8. **Boot persistence:** Termux:Boot + wake-lock + battery optimization exemption.
   Verified boot sequence:
   ```
   Android boot → Termux:Boot → termux-wake-lock → sshd →
   node01-bridge.py → proot Debian → Hermes gateway
   ```

9. **Mac-off proof:** Turned off the MacBook. Observed NODE-01 heartbeat
   continuing independently.
   **Verified:** Two independently written heartbeat rows observed in SQLite
   (`ts 1787979061 → 1787979086`).

10. **NODE-01 Bridge:** Local HTTP bridge on `127.0.0.1:8765` with `/status`
    and `/health`. Cached telemetry for fast HUD reads. Uses `time.monotonic()`
    for uptime.
    **Verified:** Operational.

11. **Physical outputs:** Termux:API TTS and vibration as first Android
    actuators. `termux-tts-speak` and `termux-vibrate` confirmed working.

12. **NODE-01 Launcher:** Native Android app (Java, SDK primitives) for HUD.
    Package: `dev.vale.node01`. Concepts: battery, network, SSH state, tools
    drawer. Visual: black + terminal green.
    **Status:** Recovered from Mac project; build environment preserved.

### Key decisions

- **Persistence must live on NODE-01, not the Mac.** The Mac is development
  host; NODE-01 owns the persistent runtime.
- **Do not casually replace the bridge.** Add beside it unless a tested
  migration requires replacement.

### Evidence summary

| Component | Status |
|-----------|--------|
| ADB + Developer Options | **Verified** |
| Termux + F-Droid | **Verified** |
| SSH + Tailscale | **Verified** |
| proot Debian aarch64 | **Verified** |
| Hermes gateway on ARM64 | **Verified** |
| Boot persistence | **Verified** |
| Mac-off independence | **Verified** |
| NODE-01 bridge | **Verified** |
| TTS + vibration | **Verified** |
| NODE-01 Launcher | **Code exists, build not re-verified** |

---

## Phase 2 — Wearable research begins (≈ 2026-08-20 to 2026-08-25)

**Evidence:** WATCH-01 VELA REVERSE ENGINEERING; TAAK-PHYSICAL-AGENT-ARCHITECTURE;
hardware map.

### Context

With NODE-01 as Pantera's physical home, the next question became:
> If Pantera lives on NODE-01, how does she communicate with a human
> through a wearable?

The Redmi Watch 4 was selected as WATCH-01. The goal was not just a
smartwatch app — it was a **remote physical interface to an agent**.

### Hardware

| Property | Value |
|----------|-------|
| Device | Redmi Watch 4 |
| Model string | m3215w1 |
| Internal | lchz.watch.n65gl |
| Product ID | 16715 |
| DID | 808263400 |
| OS | HyperOS 2.2.86 / Vela |

### Early questions

- Can we run custom code on the watch?
- What runtime does Vela expose?
- Is there an official development path?
- Can the watch communicate with an Android phone programmatically?

**Confidence:** Partially verified. Device identifiers and Vela runtime
confirmed. Custom app deployment was verified later.

---

## Phase 3 — Vela Quick App discovery (≈ 2026-08-25 to 2026-08-28)

**Evidence:** WATCH-01 VELA REVERSE ENGINEERING sections 1–5.

### Discovery path

1. **Easter egg:** Repeated taps in version/about exposed a boat game
   identifying the runtime as **Xiaomi Vela**. This reframed the problem:
   find the Vela Quick App deployment path rather than root/flash.

2. **Community tooling:** Found `oryonatan/xiaomi-band-development` repository.
   The repo did NOT explicitly list Redmi Watch 4 as supported. This route
   was experimental.

3. **Hidden Mi Fitness route:** JADX reverse engineering of Mi Fitness exposed:
   - `com.xiaomi.xms.wearable.ui.debug.ThirdAppDebugFragment`
   - `com.xiaomi.fitness.baseui.common.CommonBaseActivity`
   - Hidden debug UI accessible through ADB automation

4. **Deploy mechanism:** The deploy script:
   - Compiles Java with `javac`
   - Converts to DEX with `d8`
   - Pushes `classes.dex` to `/data/local/tmp/launch.dex`
   - Invokes through Android `app_process`
   - Launches `ThirdAppDebugFragment` through `CommonBaseActivity`
   - No root, bootloader modification, or custom firmware required

5. **Toolchain confirmed:**
   - Node.js 22.23.2
   - npm 10.9.8
   - aiot-toolkit 2.0.5
   - @aiot-toolkit/jsc ^1.0.3

### Key finding

**Verified:** A custom Quick App can be built, signed, and deployed to
Redmi Watch 4 through Mi Fitness's hidden debug interface without root.

---

## Phase 4 — Vela app development: the black screen problem (≈ 2026-08-28)

**Evidence:** WATCH-01 VELA REVERSE ENGINEERING sections 6–8.

### Problem

The original TAAK RPK installed but opened to a black screen. Experiments
that did NOT fix it:
- `minPlatformVersion` 1200 → 1000
- `designWidth` 480 → 192
- Minimal white screen with TAAK text

The bundle contained the expected UI, so stale build was not the simple
explanation. **Root cause remains unproven.**

### Solution found

Community `examples/songbird` opened successfully with the same toolkit versions.
Comparative analysis showed the working anatomy:

```
.page
 ├─ header
 └─ list
     └─ list-item
```

Gradually mutating Songbird while preserving this structure produced a working
custom app. **Solved the engineering route, not the root cause.**

### TAAK Metronome v1

Verified milestones:
- Touch/reactivity: `-`/`+`, START/STOP working
- Timers: beat counter at correct BPM (120 BPM = 500ms interval)
- Hardware vibration: `system.vibrator` → physical haptic pulse per beat
- Meter selection: 2/4, 3/4, 4/4, 6/8
- Tap tempo

**Verified:** `JS → timer → Vela system API → vibration motor → wrist`

Unicode quirks discovered: `●`, `○`, and Unicode minus rendered as alien glyphs.
Fix: ASCII `-` and actual `<div>` circles.

---

## Phase 5 — XMS SDK integration: PHONE → WATCH (≈ 2026-08-28 to 2026-08-30)

**Evidence:** WATCH-01 VELA REVERSE ENGINEERING sections 9–13;
TAAK-WATCH-01-ARTIFACTS-REPRODUCIBILITY-RUNBOOK.

### XMS SDK

Official AAR: `xms-wearable-lib_1.4_release.aar`
Source: Xiaomi's official `interconnect_dev_test_demo.zip`

Key APIs:
```kotlin
Wearable.getNodeApi(context)
Wearable.getMessageApi(context)
Wearable.getAuthApi(context)
Wearable.getServiceApi(context)
```

### The `0 NODES` problem

`getConnectedNodes()` returned empty for Redmi Watch 4, even though the watch
was connected and Mi Fitness could see it.

Root cause traced through decompilation:
```java
// XmsDataHandler.handlePacket
boolean supported = model != null
    ? DeviceModelExtKt.isSupportThirdPartyApp(model)
    : false;
if (!supported) { return false; }
```

`isSupportThirdPartyApp` checks:
```java
features.contains("thirdparty_app")
|| features.contains("third_party_no_market")
```

Redmi Watch 4 product features: `watchface`, `market`, `launcher` — but NOT
`thirdparty_app` or `third_party_no_market`.

**Conclusion:** The feature gate is a SOFTWARE POLICY, not a hardware or
protocol limitation.

### DID bypass

Since the DID was known (`808263400`), we bypassed discovery entirely:
```kotlin
curNode = Node("808263400", "Redmi Watch 4")
messageApi.sendMessage(watchDid, "miau-from-android".toByteArray())
```

**Verified:** `SEND SUCCESS` on Android, `MESSAGE RECEIVED` on watch.

**First physical phone→watch message delivered.**

### Permission requirement

Initial calls hit `Permission data_manager Granted :false`. Required permission:
`Permission.DEVICE_MANAGER`. After requesting it:
```
Status: LISTENER SUCCESS
READY — DID 808263400
```

### Android→watch status

```
XMS Binder connected    ✅
package                 ✅
fingerprint             ✅
DID                     ✅
DEVICE_MANAGER          ✅
listener count = 1      ✅
PHONE → WATCH           ✅ PHYSICAL
```

---

## Phase 6 — The hard problem: WATCH → PHONE (≈ 2026-08-30 to 2026-09-01)

**Evidence:** TAAK-WATCH-01-LAB-BITACORA-2026-08-31; result-2026-09-01-miau-rx.md;
PANTERA_SANSON_LAB_2026-09-01.md.

### Watch-side code

The Vela Quick App used:
```js
this.connect.send({
  data: 'miau-from-watch',
  success: () => { this.status = 'MIAU SENT' },
  fail: (res) => { this.status = 'SEND FAILED' }
})
```

Result: **SEND FAILED** consistently.

### Physical packet observation

Using Gadgetbridge as an oscilloscope for the protocol, we observed that
pressing MIAU on the watch DID produce a physical packet:
```
service/type 20
command/id 6
```

Log line on phone:
```
DeviceDataHandler-handlePacket:type=101,packet type=20,packet id=6,did=808263400
XmsDataHandler handlePacket 20 6 false
```

**Key insight:** The watch was transmitting. Bluetooth was delivering. Mi
Fitness was receiving. But the feature gate caused Mi Fitness to discard the
packet before any third-party app could see it.

### MIAU log bridge

Since Mi Fitness already logged the evidence, we built an ADB-side bridge:

```
Mi Fitness Transfer.device.log
    ↓  (incremental tail, detect 20/6)
adb broadcast
    ↓
com.taak.watch.MIAU
    ↓
TAAK Bridge (MiauBroadcastReceiver)
    ↓
MiauEventStore + UI update
```

First attempt: `adb logcat` — **failed** (too noisy, MagicOS filtered).
Second attempt: direct `Transfer.device.log` tail — **success**.

**02:33 CST, September 1, 2026 — bidirectional MIAU confirmed:**
```
CALL SUCCESS
MIAU RECEIVED
PANTERA ONLINE
```

### What was proven

```
WATCH → Bluetooth → NODE-01          ✅
Mi Fitness receives 20/6              ✅
Mi Fitness discards by feature gate   ✅
Log bridge extracts event             ✅
TAAK Bridge receives MIAU             ✅
TAAK Bridge → WATCH (PANTERA ONLINE)  ✅
```

### What was NOT proven

- Watch → phone arbitrary payload via public API
- Gadgetbridge ↔ Redmi Watch 4 connectivity
- Custom service 20 handler in Gadgetbridge

---

## Phase 7 — Architectural pivot (≈ 2026-09-01)

**Evidence:** PANTERA_SANSON_LAB_2026-09-01.md sections 19–31.

### The key question change

For too long the question was:
> How do we make Mi Fitness accept this?

The question that unlocked progress:
> **Why do we need Mi Fitness at all?**

### Decision: use Mi Fitness as driver, not as platform

Instead of patching, hooking, or replacing Mi Fitness, we stopped treating it
as the communication layer and started treating it as a **proven transport
driver** we could observe from outside.

### Gadgetbridge investigation

- Cloned Gadgetbridge from Codeberg
- Required Java 21 (up from 17)
- Built successfully: `./gradlew assembleMainDebug`
- Installed on NODE-01
- Auth key obtained and preserved locally (NOT published)

**Status at end of lab:** Gadgetbridge ready for pairing investigation.
Mi Fitness pairing preserved and untouched.

### Open questions

- Can Gadgetbridge connect to Redmi Watch 4 with the auth key?
- Can we instrument Xiaomi protobuf in Gadgetbridge?
- Can we implement a minimal service 20 handler?

---

## Phase 8 — PIRA genesis (≈ 2026-09-01 to 2026-10-30)

**Evidence:** PIRA-Android ADRs; PIRA web obsidian vault; PIRA-Labs org creation
2026-10-30.

### From experiments to architecture

The experiments revealed a pattern:
- Agents need physical access
- Device APIs are powerful but dangerous
- Permission boundaries are often software policies, not hardware limits
- Audit trails and deny-by-default are essential
- Users must retain explicit control

These became PIRA's design principles:

> **AI agents may propose actions, but only a trusted user-controlled
> runtime can authorize and execute them.**

### PIRA Android

The `taak-companion` project evolved into PIRA Android:
- Package renamed from `com.taak.watch.signedtest` to PIRA namespace
- Architecture formalized: typed proposals → policy engine → executor → Android APIs
- ADRs recorded: infrastructure-first, deny-by-default, typed actions
- Threat model documented
- Unit tests added

### PIRA Web

The landing page was built as the public face of the project:
- Next.js 16 + React 19
- Three.js meadow scene with WebGL grass
- Cinematic scroll-driven narrative
- Pirophone mascot

### PIRA Research

This repository. The experiments, decisions, and evidence that preceded PIRA.

---

## Missing evidence

The following experiments are remembered but artifacts were not preserved:

| Missing artifact | Reason |
|-----------------|--------|
| Original Termux bootstrap scripts | Reconstructed from runbook notes |
| Early ADB automation (pre-runbook) | Not yet documented |
| Gadgetbridge pairing session logs | Auth key preserved locally only |
| Failed XMS packet experiments | Logs not captured |
| Vela black-screen debugging session | Root cause unproven |
| Original Hermes config.yaml | Contains credentials, not reproducible |
| Mac→NODE-01 file copy failures | Noted in runbook, not logged |

---

## Chronological evidence map

```
2026-08-15  NODE-01 acquisition, ADB, Termux
2026-08-17  SSH + Tailscale, Debian proot
2026-08-18  Hermes on ARM64, gateway running
2026-08-19  Boot persistence verified, Mac-off proof
2026-08-20  NODE-01 Bridge, TTS/vibration
2026-08-22  Redmi Watch 4 acquisition (WATCH-01)
2026-08-25  Vela runtime discovery via easter egg
2026-08-26  xiaomi-band-development toolchain
2026-08-27  Hidden Mi Fitness debug route
2026-08-28  First custom RPK installed (black screen)
2026-08-28  Songbird analysis → TAAK Metronome v1
2026-08-29  Vibration, timers, touch verified
2026-08-30  XMS SDK integration, 0 NODES problem
2026-08-30  DID bypass, DEVICE_MANAGER permission
2026-08-30  PHONE → WATCH verified (miau-from-android)
2026-08-31  WATCH → PHONE: SEND FAILED, protocol analysis
2026-08-31  TAAK-WATCH-01-ARTIFACTS-REPRODUCIBILITY-RUNBOOK
2026-08-31  Gadgetbridge cloned, built, installed
2026-09-01  02:33 — MIAU bidirectional bridge milestone
2026-09-01  PANTERA_SANSON_LAB notebook closed
2026-09-01  taak-companion commit 5295f081b
2026-09-xx  PIRA architecture concept emerges
2026-10-xx  PIRA Android formalized with ADRs
2026-10-30  PIRA-Labs organization created on GitHub
```

---

*Timeline maintained by PIRA-Labs. Last updated: 2026-10-30*
