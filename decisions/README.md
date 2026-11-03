# Key Decisions — PIRA Research

Engineering decisions made during the research phase, with evidence and
alternatives considered.

---

## D-001: Use Termux instead of a custom Android ROM

**Decision:** Run the agent runtime inside Termux + proot-distro Debian on
stock Android, rather than rooting the device or installing a custom ROM.

**Evidence:**
- Termux + F-Droid installed successfully on HONOR X6
- proot-distro provides a full Debian userspace without root
- Hermes Agent v0.20.6 ran on aarch64 without modification
- Boot persistence achieved with Termux:Boot + wake-lock

**Alternatives considered:**
- Custom Android ROM (rejected: requires unlocked bootloader, wipes data,
  high maintenance)
- Root + direct Linux deploy (rejected: same risks)
- Cloud-only runtime (rejected: defeats the physical-device goal)

**Rejected alternatives may become viable later** if device capabilities
expand or if PIRA needs kernel-level access.

---

## D-002: Tailscale over LAN IPs

**Decision:** Use Tailscale for NODE-01 connectivity rather than DHCP LAN
addresses.

**Evidence:**
- Observed LAN IP `192.168.100.37` worked initially
- Tailscale address `100.86.8.36` proved more durable across network changes
- SSH config simplified to `ssh node01`

---

## D-003: Persistence on NODE-01, not the Mac

**Decision:** Move the always-on Hermes gateway from the MacBook Air M1 to
NODE-01.

**Evidence:**
- Mac-off test proved NODE-01 continued heartbeats independently
- `/root/.hermes/pantera/node01_ops.db` and `HEARTBEAT.live` confirmed
  independent operation
- Cron job `*/10 * * * *` running in no-agent mode (no model tokens)

**Impact:** This decision is what made PIRA possible. Without a persistent
physical runtime, there is no trust boundary to enforce.

---

## D-004: Copy state to Hermes-resolved path, not Termux-looking path

**Decision:** When migrating Hermes state to NODE-01, copy to the path that
Hermes resolves inside the proot session, not the path that merely looks
equivalent from Termux.

**Evidence:** Hours lost to confusion between Termux home and Debian rootfs
views. Files appeared correct from one environment but invisible to Hermes.

**Fix:** Enter the exact runtime and print `$HOME` and `expanduser('~/.hermes')`.

---

## D-005: Use Mi Fitness as transport driver, not as platform

**Decision:** Instead of modifying, patching, or replacing Mi Fitness, observe
what it already receives and translate it into our own event system.

**Evidence:**
- Mi Fitness received the `20/6` packet physically (Transfer.device.log)
- Feature gate caused Mi Fitness to discard it before third-party delivery
- ADB logcat was too noisy; direct log file tail worked
- The log bridge achieved bidirectional MIAU without touching Mi Fitness

**Alternatives considered:**
- Patch Mi Fitness APK (rejected: requires uninstall/reinstall, destroys
  authenticated session)
- LSPosed runtime hook (rejected: requires root, bootloader unlock)
- Gadgetbridge as full replacement (accepted as next step, not immediate)
- Buy different watch (rejected: hardware already emits correct packets)

**Lesson:** A deeply understood blocker does not always need to be broken.
Sometimes it can be eliminated from the architecture.

---

## D-006: DID direct addressing bypasses discovery

**Decision:** When `getConnectedNodes()` returns empty due to capability
filtering, test whether direct addressing with a known DID still works.

**Evidence:**
- `getConnectedNodes()` returned `0 NODES` for Redmi Watch 4
- Direct `Node("808263400", "Redmi Watch 4")` + `sendMessage(DID, bytes)`
  succeeded
- `fingerPrintVerify success` confirmed package + signature accepted

**Reusable technique:** If discovery is policy-filtered, test whether direct
addressing still works. An API blocked for discovery is not necessarily blocked
for direct operation.

---

## D-007: Permission.DEVICE_MANAGER over Permission.data_manager

**Decision:** Request `DEVICE_MANAGER` permission for XMS message operations.

**Evidence:**
- Initial `Permission data_manager Granted :false`
- After requesting `DEVICE_MANAGER`: `LISTENER SUCCESS`, `READY — DID 808263400`

**Impact:** This unlocked the entire phone→watch communication path.

---

## D-008: Vela app structure must match known-good anatomy

**Decision:** When developing Vela Quick Apps, preserve the Songbird structural
anatomy (`.page > header + list > list-item`) rather than building from scratch.

**Evidence:**
- From-scratch minimal app → black screen (root cause unproven)
- Songbird structure with TAAK branding → opens and runs correctly
- Gradual mutation of Songbird produced TAAK Metronome v1

**Lesson:** When a renderer behaves unexpectedly, find a known-good structure
and mutate it rather than rebuilding from assumptions.

---

## D-009: Never destroy the authenticated pairing

**Decision:** Freeze the Gadgetbridge/hardware-hacking branch to preserve the
existing Mi Fitness ↔ Sansón pairing.

**Evidence:**
- Uninstalling Mi Fitness would require re-pairing
- Re-pairing risks losing the authenticated session
- The pairing is infrastructure, not just configuration

**Rule established:** Before any unpair/wipe/unlock/flash operation, save
keys, logs, versions, pairing state, binaries, source, and backups.

---

## D-010: Log files as temporary event buses

**Decision:** Use Mi Fitness's `Transfer.device.log` as an event detection
source for prototype v0.1.

**Evidence:**
- `adb logcat` failed (noisy, filtered)
- Direct incremental tail of `Transfer.device.log` detected `20/6` packets
- Bridge converted log events to Android broadcasts
- TAAK Bridge received and displayed `MIAU RECEIVED`

**Status:** Prototype path. Not the final architecture. But it proved the
system works end-to-end.

---

## D-011: Keep the watch interface thin

**Decision:** Intelligence belongs on NODE-01. The watch is a fast interface,
sensor/actuator endpoint, and attention channel — not a compute platform.

**Evidence:** Vela Quick App capabilities are limited. No confirmed direct
Internet access. Microphone access unverified.

**PIRA implication:** PIRA's policy engine runs on the trusted node. The
wearable renders proposals and returns user decisions. It does not run the
agent.

---

*Decisions maintained by PIRA-Labs. Last updated: 2026-10-30*
