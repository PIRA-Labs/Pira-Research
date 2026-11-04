---
name: android_body
description: Actuate NODE-01 phone hardware via Termux API, no inference.
---

# android_body — Pantera's native phone actuators (NODE-01)

Pantera runs on the HONOR X6 (Android) via proot Debian. The phone's hardware is
reachable through Termux:API binaries by ABSOLUTE PATH (proot shares Android's fs,
but the Termux loopback [REDACTED <ip>]:8766 is NOT reachable from proot — call the binary
directly, never over http). All actions are LOCAL: zero Hermes inference tokens.

## Wrapper
All actuators live in `~/.hermes/scripts/android_body.sh` (executed from Debian/proot):
```bash
bash ~/.hermes/scripts/android_body.sh <cmd> [arg...]
```

## Commands
- `speak "texto"`   -> native Android TTS, forced es-MX (Google engine), rate 0.95, pitch 1.0. **This is Pantera's voice. NO inference.**
- `greet "texto"`   -> speak + 400ms vibration (nice hellos).
- `vibrate 600`     -> haptic N ms.
- `toast "msg"`     -> transient on-screen toast.
- `notify "title" "msg"` -> persistent notification (TAAK node alerts).
- `torch on|off`    -> flashlight.
- `battery`         -> prints battery JSON (level, health, temp, plugged).
- `brightness 128`  -> set 0-255.

## Pitfalls
- Always pass `-e com.google.android.tts -l es-MX` to `termux-tts-speak` or the voice
  may default to another locale. The script already does this.
- `termux-tts-speak` is at `/data/data/com.termux/files/usr/bin/termux-tts-speak`.
- If speech is silent: verify Termux:API app installed, TTS data downloaded, and
  `termux-tts-engines` lists `com.google.android.tts`.
- Do NOT use the Hermes `text_to_speech` tool when the intent is "phone speaks" —
  that burns inference and returns a Telegram .ogg, not the handset speaker.

## Other available native capabilities (not yet in wrapper — extend as needed)
toast, notification, vibrate, torch, battery, brightness, audio-info, location,
sensor, sms-send, telephony-call, camera-photo, microphone-record, speech-to-text,
wifi-*, clipboard, wallpaper, volume, fingerprint, nfc, infrared.
SENSITIVE (need Vale written OK before any use): sms-send, telephony-call,
microphone-record, camera-photo, location, speech-to-text, clipboard.
