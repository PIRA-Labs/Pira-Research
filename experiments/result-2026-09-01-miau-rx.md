# TAAK Redmi Watch 4 MIAU RX Investigation

## Root cause

- `com.xiaomi.xms.wearable.XmsComponent$XmsDataHandler.handlePacket(String did, int type, yjt packet)` computes `zIsSupportThirdPartyApp` from the current device model and logs `XmsDataHandler handlePacket 20 6 false`.
- Exact gate:
  - `research/mi-fitness-jadx/sources/com/xiaomi/xms/wearable/XmsComponent.java`
  - `research/mi-fitness-jadx/sources/com/xiaomi/xms/wearable/extensions/DeviceModelExtKt.java`
  - `research/mi-fitness-jadx/sources/com/xiaomi/fitness/device/manager/DeviceModelExtKt.java`
- Exact branch:
  - `if (!zIsSupportThirdPartyApp) { return false; }`
  - `isSupportThirdPartyApp()` is exactly:
    - `isSupportFeature(wearableDeviceModel, Feature.THIRD_PARTY_APP)`
    - `|| isSupportFeature(wearableDeviceModel, Feature.THIRD_PARTY_APP_NO_MARKET)`
  - `isSupportFeature()` is exactly:
    - `List<String> features = deviceModel.getProduct().getFeatures();`
    - `return features != null && features.contains(feature);`
- Because Redmi Watch 4 product features do not include `thirdparty_app` or `third_party_no_market`, Mi Fitness returns `false` before `handleThirdAppPacket()` runs.
- That means packet `20/6` dies before it can start `WearableXmsService`, so neither `isServiceConnected(packageName)` nor `syncPhoneAppStatus(...)` can help for this device in the stock app.

## Non-destructive bypass result

- Best safe v0.1 path found: an ADB-side log bridge that watches Mi Fitness logcat for the exact physical packet signature and forwards an explicit Android broadcast to TAAK.
- Why this is the best safe path:
  - The public XMS binder API exposed by `app/libs/xms-wearable-lib_1.4_release.aar` has no raw packet callback for `type=101` or inner `type=20`.
  - Mi Fitness is not debuggable on NODE-01, so `run-as com.xiaomi.wearable` cannot access its private `files/config/product_*.json` cache.
  - Re-signing/reinstalling Mi Fitness would require uninstalling the current app because package signature mismatch blocks `adb install -r`, which would destroy the current authenticated session.

## Backup and risk notes

- Backed up the installed Mi Fitness split APKs to:
  - `research/node01-backups/mi-fitness-3.57.0i-splits/`
- Live package facts from NODE-01:
  - package: `com.xiaomi.wearable`
  - versionName: `3.57.0i`
  - versionCode: `357000`
  - apkSigningVersion: `3`
  - dataDir: `/data/user/0/com.xiaomi.wearable`
- Live service fact:
  - `WearableXmsService` is running in process `com.xiaomi.wearable:device`
  - recent caller package includes `com.taak.watch.signedtest`
  - our app is bound successfully, so binding is not the blocker

## Files added for the prototype

- `app/src/main/java/com/taak/watch/signedtest/MiauBroadcastReceiver.kt`
- `app/src/main/java/com/taak/watch/signedtest/MiauEventStore.kt`
- `scripts/node01-miau-log-bridge.sh`

## Files updated for the prototype

- `app/src/main/AndroidManifest.xml`
- `app/src/main/java/com/taak/watch/signedtest/MainActivity.kt`

## Prototype behavior

- Helper script observes Mi Fitness logcat for:
  - `DeviceDataHandler-handlePacket:type=..., packet type=20, packet id=6, did=808263400`
- On each match it emits:
  - action: `com.taak.watch.MIAU`
  - package: `com.taak.watch.signedtest`
  - extras:
    - `source=redmi-watch-4`
    - `did=808263400`
    - `event=miau`
    - `transport=xiaomi-service-20-command-6-logcat`
- TAAK companion persists the event and updates UI to:
  - `RX status: MIAU RECEIVED`
  - `Last RX: did=808263400 ...`

## Minimal patch path if destructive patching is ever revisited

- Smallest app logic patch inside Mi Fitness would be in:
  - `research/mi-fitness-jadx/sources/com/xiaomi/xms/wearable/XmsComponent.java`
- Preferred branch edit:
  - allow `type == 20 && packet.d == 6` for `did == 808263400` or package `com.taak.watch.signedtest` before the `!zIsSupportThirdPartyApp` return
- But deployment is high-risk because changing Mi Fitness signature would require uninstall/reinstall and would likely destroy the preserved authenticated session.
