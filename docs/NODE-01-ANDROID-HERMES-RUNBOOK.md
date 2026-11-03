# NODE-01 --- Android → Linux → Hermes/Pantera Runbook

**Device:** HONOR X6 · **OS:** Android 14 / MagicOS 8 ·
**Architecture:** ARM64/aarch64 · **RAM/storage:** 4 GB/64 GB · **Hermes
snapshot:** v0.20.6 (2026.8.27)

This reconstructs the route used to turn a normal Android phone into an
always-on TAAK agent node. Android menu labels can vary by MagicOS
release; the final architecture and runtime checks below are the
important parts.

## 1. Developer access and ADB

Open the phone's About/software information and repeatedly tap the
build/software version entry until Developer Options unlock (Android
convention: seven taps; exact MagicOS label may vary). Enable **USB
debugging**, connect the phone to the Mac, unlock it and accept the RSA
authorization prompt.

``` bash
adb devices
```

Expected: `<serial>    device`. If `unauthorized`, accept the phone
prompt. If empty, suspect cable/data mode/USB debugging before changing
software.

Useful checks:

``` bash
adb get-state
adb shell getprop ro.product.model
adb shell getprop ro.product.cpu.abi
```

## 2. F-Droid + Termux

Working route used F-Droid rather than the obsolete Play Store Termux
build. Install **Termux** (`com.termux`), **Termux:API**, and
**Termux:Boot**.

``` bash
pkg update
pkg upgrade
pkg install openssh proot-distro python git curl
termux-wake-lock
```

Termux:API exposes controlled Android capabilities such as
TTS/vibration. Termux:Boot plus wake-lock is part of persistence. Exempt
the relevant apps from aggressive OEM battery optimization where
possible.

## 3. SSH

``` bash
sshd
whoami
```

Termux SSH used port `8022`; the observed Termux user was `u0_a216`.
Initial LAN setup used `192.168.100.37`, but durable automation moved to
Tailscale rather than DHCP addresses.

``` bash
ssh -p 8022 <termux-user>@<phone-ip>
```

NODE-01's observed Tailscale address was `100.86.8.36`; operational UX
became `ssh node01` via local SSH config. A dedicated Mac→NODE key was
used. **Never commit/paste the private key.**

## 4. Debian userspace

``` bash
proot-distro install debian
proot-distro login debian
uname -m
python3 --version
```

Expected architecture: `aarch64`. This is a Debian userspace under
Android, not root/custom ROM.

### Critical path lesson: two apparent homes

Migration spent substantial time confusing Termux home and the
Debian/rootfs view. Intermediate copies looked correct from one
environment but were invisible to Hermes.

**Final verified source of truth:** the active Hermes/gateway/cron state
was verified under the `/root/.hermes` tree resolved by the actual
`proot-distro login debian` runtime. Do not infer the path from the host
side; ask the process:

``` bash
proot-distro login debian
printf 'HOME=%s
' "$HOME"
python3 - <<'PY'
import os
print(os.path.expanduser('~/.hermes'))
PY
```

Rule: **copy state to the path Hermes itself resolves, not the path that
merely looks equivalent from Termux.**

## 5. Hermes on ARM64

Verified snapshot:

``` text
Hermes Agent 0.20.6
Python 3.11.16
aarch64
Nous Portal → tencent/hy3:free
```

Gateway:

``` bash
hermes gateway run
```

Credentials are intentionally omitted. Re-auth interactively when
required; never put tokens in Git.

### Evolution: Mac dependency → autonomous node

Early development behavior meant closing/shutting the development
computer could kill the useful gateway path. That failed the persistence
goal. Architecture was moved so **NODE-01 owns Pantera's persistent
runtime and operational jobs**; the Mac became secondary for
development/heavy compute/human access.

The real proof was turning off the Mac and observing NODE-01 continue
producing heartbeats. That passed.

## 6. Boot persistence

``` text
Android boot
  ↓
Termux:Boot
  ↓
termux-wake-lock
  ↓
sshd
  ↓
node01-bridge.py
  ↓
proot Debian
  ↓
Hermes gateway / Pantera jobs
```

Representative sequence:

``` bash
termux-wake-lock
sshd
python ~/node01-bridge.py &
proot-distro login debian -- hermes gateway run
```

Do not create duplicate gateway processes; check first:

``` bash
ps -ef | grep -i hermes
```

## 7. NODE-01 bridge

`~/node01-bridge.py` is a known-good component. Verified behavior:

-   local `127.0.0.1:8765`;
-   `/status` and `/health`;
-   Hermes refresh in background roughly every 15 s;
-   cached telemetry for fast HUD reads;
-   `uptime_seconds` uses `time.monotonic()`, so it resets on bridge
    restart.

**Do not casually replace this bridge.** Add beside it unless a tested
migration requires replacement.

## 8. Android as a physical body

With Termux:API:

``` bash
termux-tts-speak "Pantera online"
termux-vibrate -d 200
```

A helper existed at `/root/.hermes/scripts/android_body.sh`. This
established the abstraction: Hermes decides; controlled scripts expose
Android actuators.

## 9. Pantera migration

Verified migrated artifacts:

-   `MEMORY.md`
-   `SOUL.md`
-   `scripts/node01-heartbeat.py`
-   `secrets/pantera_turso.json` (**secret; never Git**)
-   operational heartbeat cron

Verified cron snapshot:

``` text
job: 3b405769e474
schedule: */10 * * * *
mode: --no-agent
```

The heartbeat intentionally spends no model tokens.

Persistent proof artifacts:

``` text
/root/.hermes/pantera/node01_ops.db
/root/.hermes/pantera/HEARTBEAT.live
```

A live check observed two independently written heartbeat rows
(`ts 1787979061 → 1787979086`). This was evidence that the node survived
independently of the Mac.

Do not use the TAAK BOC credential/database (`taak_api_token.json`) for
Pantera operational telemetry. That boundary was deliberate.

## 10. NODE-01 Launcher / HUD

Recovered Mac project: `node01-launcher/`. Main Java source:

``` text
app/src/main/java/dev/vale/node01/MainActivity.java
```

Package: `dev.vale.node01`.

The recovered implementation used Android SDK primitives directly
(`Activity`, custom `View`, `Canvas/Paint`, connectivity APIs, package
manager, settings intents, sockets). It was intentionally lightweight.

HUD concepts included NODE-01/HONOR X6/ARM64 identity, Pantera,
Hermes/gateway/cron/SSH state, battery/charging, network state, and a
tools drawer. Visual language: black + terminal/sci-fi green.

### Toolchain

Android SDK/build-tools on the Mac were required. Related tooling
explicitly used `javac`, Android `android.jar`, `d8`, ADB and SDK
build-tools. Preserve the actual launcher repo's build wrapper rather
than reconstructing Gradle details from memory.

Typical install/debug loop:

``` bash
adb devices
adb install -r <path-to-apk>
adb shell pm list packages | grep -i node
adb logcat
```

## 11. Failure knowledge

**ADB empty:** check cable/data mode → phone unlocked → Developer
Options → USB debugging → RSA authorization; only then restart ADB.

**"Linux" ≠ Android root:** proot gives userspace, not kernel/root
privileges.

**Gateway dies with Mac:** architecture is still dev-hosted; move
persistence to NODE-01 and prove it with Mac-off testing.

**Hermes cannot see copied files:** enter the exact runtime and print
`$HOME`/`expanduser('~/.hermes')`; do not guess Termux-home vs rootfs.

**Android kills processes:** Termux:Boot + wake-lock + battery
exemptions; test after screen-off and reboot. "Works while ADB is
connected" is not persistence.

## 12. Reproduction checklist

``` text
[ ] Developer Options / USB debugging
[ ] adb devices → device
[ ] F-Droid Termux + API + Boot
[ ] openssh / proot-distro / Python
[ ] wake-lock
[ ] sshd :8022
[ ] Tailscale
[ ] Debian aarch64
[ ] Hermes authenticated in active Debian environment
[ ] gateway works
[ ] boot persistence after reboot
[ ] Mac-off independence
[ ] /health and /status
[ ] heartbeat advances
[ ] TTS/vibration
[ ] NODE-01 Launcher installs
[ ] no secrets committed
```

## 13. Not yet solved

A one-command generic Android→TAAK installer, guaranteed behavior across
OEM battery managers, watch↔phone messaging, and formal device
enrollment/key rotation remain future work.
