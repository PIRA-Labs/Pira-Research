---
name: habla
description: User says habla to speak on NODE-01 via Android TTS.
---

# habla — Native Android TTS on NODE-01

When the user wants spoken output from the **phone's own speaker** (not a Telegram
audio file), use the native Android TTS actuator. This costs ZERO inference tokens
— the model only decides the text; Android synthesizes it locally.

## Trigger
- User message starts with or contains `habla` / `habla:` / `Pantera habla` + optional text.
- Example: `habla buenos dias capitán` → speak that text on the phone.

## DO NOT
- Do NOT call the Hermes `text_to_speech` tool for this. That routes through edge TTS,
  emits a `.ogg`, and sends it as a Telegram voice bubble — wrong channel AND burns inference.
  The two outputs are different: native = phone speaks; Hermes TTS = Telegram audio message.

## Procedure
1. Extract the text after the `habla` keyword (if none, use a default greeting).
2. Escape double quotes in the text before passing to the shell.
3. Run the actuator (this is the native-path skill `android_body`; es-MX is forced):
   ```bash
   bash ~/.hermes/scripts/android_body.sh speak "TEXTO AQUÍ"
   ```
   For hellos use `greet` (native voice + 400ms vibration).
   - `speak "texto"`  → native TTS only
   - `greet "texto"`  → native TTS + 400ms vibration (nice for hellos)
   - `vibrate 600`    → haptic only

## Why the absolute path works (pitfall)
- Pantera's runtime is Debian/proot, but proot shares Android's filesystem/namespace,
  so the Termux:API binaries are reachable by absolute path:
  `/data/data/com.termux/files/usr/bin/termux-tts-speak`.
- The Termux loopback ([REDACTED <ip>]:8766) is NOT reachable from proot (isolated netns) —
  do NOT try to call it over http; call the binary directly via the script.

## Engine / voice
- Default engine: `com.google.android.tts` (Google, es-MX capable).
- Script defaults: `-r 0.9 -p 1.0` (slightly slow, normal pitch).
- Optional Spanish tweak (verify on device first): add `-l es-MX` to the speak call
  inside android_body.sh if the voice defaults to another locale.

## Verification
- Expect stdout `ANDROID_BODY_OK cmd=speak` and the phone audibly speaks.
- If silent: confirm Termux:API app installed + TTS data downloaded on the device,
  and that `termux-tts-engines` lists `com.google.android.tts`.

## Combined delivery
- You may ALSO send a short text reply in Telegram (so the chat has a record), but the
  SPOKEN line must come from `android_body.sh speak`, not from text_to_speech.
