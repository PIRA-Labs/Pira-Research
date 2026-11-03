# WATCH-01 --- Redmi Watch 4 / Vela Reverse-Engineering Runbook

**Device:** Redmi Watch 4 · **user-reported model string:** `m3215w1` ·
**Watch OS:** HyperOS 2.2.86 · **Runtime:** Xiaomi Vela / Quick App
`.rpk` · **Mi Fitness package:** `com.xiaomi.wearable` · **Mi Fitness
observed:** `3.57.0i`

This is the route that successfully produced a custom TAAK app executing
on physical Redmi Watch 4 hardware.

## 1. Discovery: Vela

A watch-side easter egg during exploration (repeated taps in
version/about → constellation/boat sequence) exposed a boat game
identifying Xiaomi Vela. That reframed the problem: find the Vela Quick
App deployment path rather than root/flash the watch.

The community repository used did **not** explicitly list Redmi Watch 4
as supported. This route was experimental and verified empirically.

## 2. Development chain

``` text
Mac
 │ ADB / Android SDK / build tools
 ▼
Xiaomi Android phone
 │ Mi Fitness hidden Third App Support
 │ Bluetooth
 ▼
Redmi Watch 4
 └─ Vela Quick App runtime → custom RPK
```

Phone must be paired to the watch. Verify:

``` bash
adb devices
```

If deploy silently fails, suspect USB/ADB before changing RPK code.

## 3. Community tooling

Repository: `oryonatan/xiaomi-band-development`\
Local path: `~/Documents/watch01/xiaomi-band-development`

The deploy script requires ADB, Android SDK, `javac`, `d8`, and a phone
paired to the watch. It reads `src/manifest.json`, builds/locates the
RPK, creates a Java launcher dex, pushes the RPK to the phone, opens Mi
Fitness's hidden debug fragment and automates the install UI.

## 4. Hidden Mi Fitness route

JADX reverse engineering exposed:

``` text
com.xiaomi.xms.wearable.ui.debug.ThirdAppDebugFragment
com.xiaomi.fitness.baseui.common.FragmentParams$b
com.xiaomi.fitness.baseui.common.CommonBaseActivity
```

The deploy launcher dynamically loads Mi Fitness classes and launches
`ThirdAppDebugFragment` through `CommonBaseActivity`. It compiles Java
with `javac`, converts with `d8`, pushes `classes.dex` to
`/data/local/tmp/launch.dex`, then invokes it through Android
`app_process`.

No watch root, bootloader modification or custom firmware was required.

## 5. Mi Fitness protocol findings

  service/op        mapping                   evidence
  ----------------- ------------------------- -------------------------------------
  `20/0`            getInstalledWatchApp      VERIFIED
  `20/1`            prepareInstallApp         VERIFIED
  `20/3`            uninstallApp              CODE-MAPPED
  `20/4`            launchApp                 CODE-MAPPED
  `20/7`            syncPhoneAppStatus        CODE-MAPPED
  `20/8`            sendPhoneMessage          CODE-MAPPED; semantics not verified
  `20/11`           send WeChat license       CODE-MAPPED
  `20/21`           getWearAppStatus          CODE-MAPPED
  incoming `20/2`   observed after transfer   exact meaning unresolved

Never invent the `20/2` meaning.

Recovered prepare request:

``` proto
message PrepareInstallAppRequest {
  string packageName = 1;
  int32 versionCode = 2;
  int32 packageSize = 3;
}
```

Response:

``` proto
message PrepareInstallAppResponse {
  enum/status field1 = 1;
  int32 expectedSliceLength = 2;
}
```

Successful logs showed `prepareInstallThirdApp status: 0`,
`prepareInstallApp success`, RPK mass-data transfer ending
`errorCode=[0]`, and an incoming `20/2`. After reconnect, `20/0`
returned an installed custom app (`com.application.watch.demo`, app name
`taak-metronome`).

### Capability-check trap

Decompiled code contained `isSupportThirdPartyApp()` using
`THIRD_PARTY_APP` / `THIRD_PARTY_APP_NO_MARKET`. Generic handlers
sometimes evaluated support false, **yet direct prepare/install/transfer
worked physically**. A false generic capability flag is therefore not
proof this path cannot work on this device/version.

## 6. First custom TAAK scaffold: installed, black screen

Toolchain:

``` text
Node 22.23.2
npm 10.9.8
aiot-toolkit 2.0.5
@aiot-toolkit/jsc ^1.0.3
```

The original RPK installed, but opening it black-screened. These
experiments did **not** fix it:

-   `minPlatformVersion` 1200 → 1000
-   `designWidth` 480 → 192
-   minimal white screen with TAAK text

The bundle contained the expected UI, so stale build was not the simple
explanation. **Exact root cause remains unproven.**

## 7. Songbird control experiment

Community `examples/songbird` opened successfully and used the same
toolkit/JSC versions, ruling out toolkit mismatch.

Known-good anatomy:

``` text
.page
 ├─ header
 └─ list
     └─ list-item
```

Experiments:

1.  Original Songbird → opens.
2.  Radically minimal replacement → black.
3.  Restore; change only `Songbook`→`TAAK` → opens.
4.  Replace dynamic song title with `120 BPM` → visible update.
5.  Gradually mutate behavior while preserving known-good structural
    anatomy → continues opening.

**VERIFIED:** substantial custom UI/logic works inside this known-good
structure.\
**UNVERIFIED:** why the from-scratch minimal app black-screened.

We solved the engineering route around the renderer issue, not its root
cause.

## 8. Build + deploy ritual

``` bash
cd ~/Documents/watch01/xiaomi-band-development/examples/songbird
npm run build
```

Then:

``` bash
cd ~/Documents/watch01/xiaomi-band-development
./scripts/deploy.sh --project ./examples/songbird --no-build
```

Combined:

``` bash
cd ~/Documents/watch01/xiaomi-band-development/examples/songbird && npm run build && cd ../.. && ./scripts/deploy.sh --project ./examples/songbird --no-build
```

Operator lesson: `npm run build` from repo root gives
`Missing script: "build"`; the npm project is `examples/songbird`.

Debug:

``` bash
bash -x ./scripts/deploy.sh --project ./examples/songbird --no-build 2>&1 | tail -80
```

## 9. TAAK Metronome milestones

### Touch/reactivity

`-`/`+`, START/STOP and live state updates physically verified.

### Timers

A beat counter was displayed to prove scheduling. At 120 BPM,
`60000/120 = 500 ms`; the counter advanced at expected tempo.
`setInterval()` + reactive timer updates verified.

### Hardware vibration

Manifest feature:

``` json
{"name":"system.vibrator"}
```

Code:

``` js
import vibrator from '@system.vibrator'

vibrator.vibrate({ mode: 'short' })
```

Physical result: vibration on every beat. Verified chain:

``` text
JS → timer → Vela system API → vibration motor → wrist
```

### Beat-1 accent experiment

Two short pulses \~110 ms apart physically worked but felt like an extra
subdivision. Reverted to one pulse per beat; bar position became visual.

### Unicode/font quirk

`●`, `○` and Unicode minus rendered as strange "Hebrew/alien" glyphs.
Fix: ASCII `-` and actual circular `<div>` elements. This removed
unsupported glyph dependency.

### Final v1 UX

-   TAAK / METRONOME
-   compact beat dots
-   `- [BPM] +`
-   tap BPM to start/stop + visual running state
-   meter selector `2/4`, `3/4`, `4/4`, `6/8`
-   tap tempo
-   one short haptic pulse per beat
-   no required scroll
-   centered compact controls

## 10. Remaining Songbird icon

Asset:

``` text
examples/songbird/src/common/logo.png
```

Manifest:

``` json
"icon": "/common/logo.png"
```

Replacing that PNG and rebuilding/deploying completes the visible
Songbird→TAAK migration. Do not delete `songs.js` merely for cleanliness
until imports are checked and a new golden build is verified.

## 11. Golden-build discipline

Backups during exploration included `index.ux.bak`,
`index.ux.golden-haptic`, `index.ux.working-v1`, `index.ux.pretty-v1`.

``` bash
cd ~/Documents/watch01/xiaomi-band-development
git add examples/songbird
git commit -m "feat: TAAK Metronome v1 for Redmi Watch 4"
```

Never commit signing private keys.

## 12. Networking reality

Do not assume direct WATCH→HTTP→NODE. Current evidence indicates Redmi
Watch 4 does not expose the standard request/download/upload route we
would normally use. Most plausible architecture:

``` text
WATCH-01 ⇄ Bluetooth ⇄ PHONE-BRIDGE ⇄ Internet/Tailscale ⇄ NODE-01/Pantera
```

Mi Fitness `20/8 sendPhoneMessage` and `20/7 syncPhoneAppStatus` are
promising leads, **not yet verified app-facing channels**.

## 13. NEXT FRONTIER --- PING PANTERA

Prove transport before voice.

**A. WATCH→PHONE:** one TAAK Remote button emits fixed `miau`; success =
payload observed on phone.\
**B. PHONE→WATCH:** return `pong`; render it.\
**C. PHONE→NODE:** forward privately to NODE-01.\
**D. Full round trip:** WATCH→PHONE→NODE→Pantera→PHONE→WATCH.\
**E. Voice:** only then investigate microphone/audio APIs.

The watch physically has a microphone, but hardware presence does
**not** prove Vela Quick Apps can access it. If unavailable, the watch
can still be push-to-talk/control while the phone handles
microphone/STT/TTS.

## 14. Reproduction checklist

``` text
[ ] watch paired in Mi Fitness
[ ] phone USB debugging
[ ] adb devices → device
[ ] Android SDK / javac / d8
[ ] xiaomi-band-development cloned
[ ] npm deps in examples/songbird
[ ] Songbird builds
[ ] hidden Third App Support opens
[ ] RPK transfers successfully
[ ] custom app appears on watch
[ ] known-good Songbird-derived UI opens
[ ] touch works
[ ] timer works
[ ] system.vibrator declared
[ ] physical vibration works
[ ] golden build committed
[ ] logo.png replaced
```

## 15. Failure knowledge

-   Successful install ≠ compatible render tree.
-   `minPlatformVersion`/`designWidth` alone did not solve black screen.
-   Same toolkit versions can yield working vs black-screen apps;
    compare structure.
-   Generic TypeScript `navigator.vibrate()` definitions are not Vela
    evidence.
-   Grepping `node_modules` creates false-positive noise.
-   Unsupported Unicode can look like unrelated alien glyphs.
-   ADB/USB failures can masquerade as deploy failures.
-   Preserve known-good list/list-item anatomy until the renderer
    boundary is deliberately mapped.
