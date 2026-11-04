#!/bin/bash
# android_body.sh — Pantera's physical actuators on NODE-01 (HONOR X6 / Android)
# Invoked from Pantera's runtime (Debian/proot). Termux:API binaries are reached
# via absolute path because proot shares Android's filesystem/namespace, and the
# Termux loopback ([REDACTED <ip>]:8766) is NOT reachable from proot (isolated netns).
#
# ZERO inference: the model only decides text/action; Android executes locally.
#
# Usage:
#   android_body.sh speak "texto"        -> native Android TTS (es-MX, Google)
#   android_body.sh greet "texto"        -> speak + 400ms vibration
#   android_body.sh vibrate 600          -> vibrate N ms
#   android_body.sh toast "msg"          -> transient toast on screen
#   android_body.sh notify "titulo" "msg"-> persistent notification
#   android_body.sh torch on|off         -> flashlight
#   android_body.sh battery              -> print battery status JSON
#   android_body.sh brightness 50        -> set brightness 0-255

BIN=/data/data/com.termux/files/usr/bin
TTS="$BIN/termux-tts-speak"
VIB="$BIN/termux-vibrate"
TOAST="$BIN/termux-toast"
NOTIFY="$BIN/termux-notification"
TORCH="$BIN/termux-torch"
BATT="$BIN/termux-battery-status"
BRIGHT="$BIN/termux-brightness"

# Guaranteed Spanish (Mexico) voice via Google TTS engine — no inference.
ENGINE="com.google.android.tts"
LOCALE="es-MX"
RATE=0.95
PITCH=1.0

cmd="${1:-speak}"
case "$cmd" in
  speak)
    text="${2:-PANTERA en linea}"
    "$TTS" -e "$ENGINE" -l "$LOCALE" -r "$RATE" -p "$PITCH" "$text"
    ;;
  greet)
    text="${2:-Hola capitán, Pantera a su servicio}"
    "$TTS" -e "$ENGINE" -l "$LOCALE" -r "$RATE" -p "$PITCH" "$text"
    sleep 1
    "$VIB" -d 400
    ;;
  vibrate)
    ms="${2:-500}"
    "$VIB" -d "$ms"
    ;;
  toast)
    msg="${2:-PANTERA}"
    "$TOAST" -s "$msg" 2>/dev/null || "$TOAST" "$msg"
    ;;
  notify)
    title="${2:-PANTERA}"
    msg="${3:-Aviso de Node-01}"
    "$NOTIFY" --title "$title" --content "$msg"
    ;;
  torch)
    state="${2:-on}"
    "$TORCH" "$state"
    ;;
  battery)
    "$BATT"
    ;;
  brightness)
    v="${2:-128}"
    "$BRIGHT" "$v"
    ;;
  *)
    echo "uso: android_body.sh {speak|greet|vibrate|toast|notify|torch|battery|brightness} [arg]"
    exit 1
    ;;
esac
echo "ANDROID_BODY_OK cmd=$cmd"
