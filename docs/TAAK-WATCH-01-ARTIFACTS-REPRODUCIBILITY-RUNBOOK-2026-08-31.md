# TAAK WATCH-01 — Artifacts, Reproducibility & Mobile/Wearable App Engineering Runbook

**Project:** TAAK Intelligence / WATCH-01  
**Date:** 31 August 2026  
**Purpose:** Preserve the exact practical knowledge gained while building Android + Xiaomi Vela wearable applications, signing them, installing them, connecting them through Xiaomi XMS, and proving real phone→watch message delivery on a Redmi Watch 4.

> This document is intentionally operational. It is meant so that another TAAK agent — especially Pantera — can reconstruct the development environment, build new Android apps quickly, build new Vela wearable apps quickly, sign them correctly, deploy them, and reuse the already-proven communication path.

---

# 1. Why this document exists

During this research we did more than reverse engineer Mi Fitness.

We also built and validated a complete application-development workflow across two device classes:

```text
Mac development environment
        │
        ├── Android app
        │     ↓
        │   Android phone
        │
        └── Xiaomi Vela Quick App
              ↓
          Redmi Watch 4
```

We also proved real inter-device communication:

```text
Android phone
   ↓
XMS / Mi Fitness
   ↓
Redmi Watch 4

Payload:
"miau-from-android"

Result on watch:
MESSAGE RECEIVED
```

That is extremely important because it means the lab already has a reusable reference implementation for:

- creating Android apps;
- signing Android apps;
- installing Android apps through ADB;
- creating Vela wearable apps;
- signing wearable apps;
- deploying wearable apps;
- matching Android/wearable package identity;
- using Xiaomi XMS APIs;
- requesting wearable permissions;
- registering listeners;
- sending phone→watch messages;
- receiving those messages inside a watch Quick App.

This runbook preserves that path.

---

# 2. System architecture proven in the lab

The physically proven working path is:

```text
┌──────────────────────────────┐
│ MacBook Air M1               │
│ source + build toolchains    │
└──────────────┬───────────────┘
               │
               ├───────────────────────────────┐
               │                               │
               ▼                               ▼
┌────────────────────────┐       ┌────────────────────────┐
│ Android Companion      │       │ TAAK Remote            │
│ Kotlin / Android       │       │ Xiaomi Vela Quick App  │
│ XMS AAR                │       │ JavaScript / UX        │
└──────────────┬─────────┘       └──────────────┬─────────┘
               │                                │
               ▼                                ▼
┌────────────────────────┐       ┌────────────────────────┐
│ Xiaomi Android phone   │       │ Redmi Watch 4          │
│ Mi Fitness + XMS       │──────►│ Vela / HyperOS         │
└────────────────────────┘       └────────────────────────┘
```

Physically proven:

```text
PHONE → WATCH   ✅
WATCH → PHONE   ❌ blocked by Mi Fitness feature gate
```

The phone→watch success is therefore a **known-good reference path**.

---

# 3. Device inventory

## 3.1 Redmi Watch 4

Observed identifiers:

```text
Commercial model: Redmi Watch 4
Internal model:   lchz.watch.n65gl
Product ID:       16715
DID:              808263400
HyperOS:          2.2.86
Platform:         Xiaomi Vela
```

Important property:

The watch can run Quick Apps and accepts our custom TAAK-signed package.

---

## 3.2 Android bridge phone

Development bridge:

```text
Role: PHONE-BRIDGE-DEV
OS: Android 16
Mi Fitness: 3.57.0i
HyperOS: 3.0.302.0.WNEMXAT.C09
ADB: enabled
```

Known ADB serial during the session:

```text
GUIFCYHIJFW44XDU
```

USB/ADB can be flaky. Always verify first:

```bash
adb devices
```

Do not assume a failed install is an application problem until ADB connectivity has been checked.

---

# 4. Mac development environment

Primary environment:

```text
MacBook Air M1
Apple Silicon / arm64
```

Important paths/tools:

```text
ANDROID_HOME=/opt/homebrew/share/android-commandlinetools

adb:
/opt/homebrew/share/android-commandlinetools/platform-tools/adb

Android CLI:
/opt/homebrew/share/android-commandlinetools/cmdline-tools/latest/bin/android

Build tools:
34.0.0

Platform tools:
37.0.1

Android platform:
android-34
```

Java 17 used for earlier Android/Xiaomi work:

```bash
export JAVA_HOME="/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home"
export PATH="$JAVA_HOME/bin:$PATH"
```

Gadgetbridge currently requires Java 21:

```bash
brew install openjdk@21

export JAVA_HOME="/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home"
export PATH="$JAVA_HOME/bin:$PATH"
```

Useful checks:

```bash
java -version
javac -version
```

---

# 5. Android application: TAAK Companion

## 5.1 Project path

```text
/Users/valedev/Documents/taak-companion
```

This is the known-good Android application workspace.

---

## 5.2 Android package identity

Critical package:

```text
com.taak.watch.signedtest
```

This package identity must match the wearable application when using Xiaomi XMS interconnect.

This matching was not cosmetic.

It was required for:

- fingerprint verification;
- watch app lookup;
- XMS listener key resolution;
- interconnect routing.

---

# 6. Xiaomi XMS SDK

Official AAR used:

```text
app/libs/xms-wearable-lib_1.4_release.aar
```

Original source package came from Xiaomi's official interconnect demo:

```text
interconnect_dev_test_demo.zip
```

Relevant APIs:

```kotlin
Wearable.getNodeApi(context)
Wearable.getMessageApi(context)
Wearable.getAuthApi(context)
Wearable.getServiceApi(context)
```

Important XMS abstractions:

```text
NodeApi
MessageApi
AuthApi
ServiceApi
```

---

# 7. Android signing identity

The Android app was signed with the custom TAAK signing identity.

Keystore path:

```text
~/Documents/taak-companion/signing/taak-watch.keystore
```

Alias:

```text
taak-watch
```

Certificate metadata:

```text
RSA: 2048
Signature: SHA256withRSA

DN:
CN=TAAK STUDIO
OU=TECNOLOGIA
O=TAAK STUDIO
L=Mexico City
ST=CDMX
C=MX
```

Certificate fingerprints observed:

```text
SHA-1:
05:1E:27:7B:10:0E:99:6A:12:72:6C:91:14:3E:72:36:51:EE:F4:9F

SHA-256:
65:18:49:6A:E8:36:2F:ED:72:AE:2D:9E:37:FE:15:0E:C1:E8:24:C9:0D:6E:39:41:0E:CB:23:93:4B:C0:07:90
```

**Never commit keystore passwords or private keys.**

Gradle signing pattern:

```kotlin
signingConfigs {
    create("taak") {
        storeFile = file("../signing/taak-watch.keystore")
        storePassword = System.getenv("TAAK_STORE_PASSWORD")
        keyAlias = "taak-watch"
        keyPassword = System.getenv("TAAK_KEY_PASSWORD")
    }
}
```

Environment variables must exist before building.

If the build fails with missing password/configuration, first verify:

```text
TAAK_STORE_PASSWORD
TAAK_KEY_PASSWORD
```

without printing their values.

---

# 8. Android MainActivity — known-good baseline

This is the known-good application logic that achieved:

```text
XMS connected
permission granted
listener registered
PHONE → WATCH message delivered
```

```kotlin
package com.taak.watch.signedtest

import android.os.Bundle
import android.widget.Button
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity

import com.xiaomi.xms.wearable.Wearable
import com.xiaomi.xms.wearable.message.OnMessageReceivedListener
import com.xiaomi.xms.wearable.auth.Permission
import com.xiaomi.xms.wearable.node.Node
import com.xiaomi.xms.wearable.service.OnServiceConnectionListener

class MainActivity : AppCompatActivity() {

    private val watchDid = "808263400"
    private var curNode: Node? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        val status = findViewById<TextView>(R.id.status)
        val lastMessage = findViewById<TextView>(R.id.lastMessage)
        val sendTest = findViewById<Button>(R.id.sendTest)

        val messageApi = Wearable.getMessageApi(applicationContext)
        val authApi = Wearable.getAuthApi(applicationContext)
        val serviceApi = Wearable.getServiceApi(applicationContext)

        status.text = "Status: WAITING FOR XMS"
        lastMessage.text = "DID bypass: $watchDid"

        val serviceListener = object : OnServiceConnectionListener {
            override fun onServiceConnected() {
                runOnUiThread {
                    status.text = "Status: XMS CONNECTED / DID BYPASS"
                    curNode = Node(watchDid, "Redmi Watch 4")

                    val messageListener =
                        OnMessageReceivedListener { did, message ->
                            runOnUiThread {
                                status.text = "Status: MESSAGE RECEIVED"
                                lastMessage.text = "From $did: ${String(message)}"
                            }
                        }

                    status.text = "Status: REQUESTING DEVICE_MANAGER..."

                    authApi.requestPermission(
                        watchDid,
                        Permission.DEVICE_MANAGER
                    ).addOnSuccessListener {
                        runOnUiThread {
                            status.text = "Status: PERMISSION RESPONSE OK"
                        }

                        fun registerCleanListener() {
                            messageApi.addListener(
                                watchDid,
                                messageListener
                            ).addOnSuccessListener {
                                runOnUiThread {
                                    status.text = "Status: LISTENER SUCCESS"
                                    lastMessage.text = "READY — DID $watchDid"
                                }
                            }.addOnFailureListener {
                                runOnUiThread {
                                    status.text = "Status: LISTENER FAILED"
                                    lastMessage.text =
                                        "${it.javaClass.simpleName}: ${it.message}"
                                }
                            }
                        }

                        messageApi.removeListener(watchDid)
                            .addOnSuccessListener { registerCleanListener() }
                            .addOnFailureListener { registerCleanListener() }

                    }.addOnFailureListener {
                        runOnUiThread {
                            status.text = "Status: PERMISSION REQUEST FAILED"
                            lastMessage.text =
                                "${it.javaClass.simpleName}: ${it.message}"
                        }
                    }
                }
            }

            override fun onServiceDisconnected() {
                runOnUiThread {
                    status.text = "Status: XMS DISCONNECTED"
                }
            }
        }

        serviceApi.registerServiceConnectionListener(serviceListener)

        sendTest.setOnClickListener {
            status.text = "Status: SENDING..."

            messageApi.sendMessage(
                watchDid,
                "miau-from-android".toByteArray()
            ).addOnSuccessListener {
                runOnUiThread {
                    status.text = "Status: SEND SUCCESS"
                    lastMessage.text = "Sent: miau-from-android"
                }
            }.addOnFailureListener {
                runOnUiThread {
                    status.text = "Status: SEND FAILED"
                    lastMessage.text =
                        "${it.javaClass.simpleName}: ${it.message}"
                }
            }
        }
    }
}
```

This code should be treated as a **reference implementation**.

Do not casually refactor it while debugging unrelated layers.

---

# 9. Why the DID bypass matters

Official Xiaomi sample flow:

```text
getConnectedNodes()
→ choose first Node
→ use node.id
```

Redmi Watch 4 returned:

```text
0 NODES
```

because Mi Fitness filters devices using:

```text
isSupportThirdPartyApp()
```

We bypassed discovery:

```kotlin
private val watchDid = "808263400"

curNode = Node(
    watchDid,
    "Redmi Watch 4"
)
```

This was a major reusable technique:

> If discovery is policy-filtered, test whether direct addressing still works.

It did.

---

# 10. Required Android wearable permission

Direct XMS calls initially hit:

```text
Permission data_manager Granted :false
```

The required permission was:

```kotlin
Permission.DEVICE_MANAGER
```

Request:

```kotlin
authApi.requestPermission(
    watchDid,
    Permission.DEVICE_MANAGER
)
```

After this:

```text
Status: LISTENER SUCCESS
READY — DID 808263400
```

---

# 11. Listener lifecycle issue

At one point XMS produced duplicate listener errors:

```text
IllegalStateException:
You have registered...
```

Known fix:

```kotlin
messageApi.removeListener(watchDid)
    .addOnSuccessListener {
        registerCleanListener()
    }
    .addOnFailureListener {
        registerCleanListener()
    }
```

Important SDK detail:

```text
MessageApi.removeListener(String)
```

does not use a listener object argument.

---

# 12. Android→watch message transmission

Known-good send:

```kotlin
messageApi.sendMessage(
    watchDid,
    "miau-from-android".toByteArray()
)
```

Physical Android result:

```text
Status: SEND SUCCESS
Sent: miau-from-android
```

Physical watch result:

```text
Message Rec...
```

and the Quick App's message callback fired.

This proves that an Android app built in this workspace can send arbitrary byte payloads to the wearable application through XMS.

---

# 13. Building Android apps quickly

When creating future TAAK Android apps, Pantera should reuse this workflow.

## 13.1 Verify ADB

```bash
export ANDROID_HOME="/opt/homebrew/share/android-commandlinetools"
export PATH="$ANDROID_HOME/platform-tools:$PATH"

adb devices -l
```

## 13.2 Enter project

```bash
cd ~/Documents/taak-companion
```

## 13.3 Ensure Java

For this app, Java 17 was the established environment:

```bash
export JAVA_HOME="/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home"
export PATH="$JAVA_HOME/bin:$PATH"
```

## 13.4 Ensure signing environment variables

Do not echo their values.

Check only existence:

```bash
test -n "$TAAK_STORE_PASSWORD" && echo STORE_OK
test -n "$TAAK_KEY_PASSWORD" && echo KEY_OK
```

## 13.5 Build

Typical Gradle workflow:

```bash
./gradlew assembleDebug
```

or the relevant signed build variant configured by the project.

## 13.6 Locate APK

```bash
find app/build/outputs/apk -type f -name '*.apk'
```

## 13.7 Install

```bash
adb install -r /path/to/app.apk
```

If install fails unexpectedly:

```bash
adb devices
```

before changing source code.

---

# 14. Wearable application: TAAK Remote

## 14.1 Toolchain repository

Local Xiaomi wearable development toolkit:

```text
/Users/valedev/Documents/watch01/xiaomi-band-development
```

Repository used:

```text
https://github.com/oryonatan/xiaomi-band-development
```

---

# 15. Known-good wearable project

Primary wearable project:

```text
/Users/valedev/Documents/watch01/xiaomi-band-development/examples/taak-signed-test
```

Package:

```text
com.taak.watch.signedtest
```

Display identity:

```text
TAAK Remote
```

This package must match Android when using Xiaomi interconnect.

---

# 16. Wearable signing

The watch application uses the same TAAK identity conceptually as the Android application.

Custom signing assets were placed under:

```text
sign/debug
sign/release
```

The private key is sensitive.

**Never print, paste, upload, or commit it.**

The important operational lesson:

```text
Android package       == wearable package
Android signature     compatible with wearable identity
```

This combination was accepted by Mi Fitness/XMS.

---

# 17. Watch manifest capability

The wearable manifest included:

```json
{
  "name": "system.interconnect"
}
```

Without the correct interconnect capability, the Quick App cannot use the XMS interconnection API.

---

# 18. Watch interconnect API

Known import:

```js
import interconnect from '@system.interconnect'
```

Create connection object:

```js
const connect = interconnect.instance()
```

Known methods/events observed from official docs/sample:

```text
instance()
getReadyState()
diagnosis()
send()
getApkStatus()

onmessage
onopen
onclose
onerror
```

Ready states:

```text
1 = connected
2 = disconnected
```

Diagnosis examples:

```text
0    OK
204  CONNECT_TIMEOUT
1001 APP_UNINSTALLED
1000 OTHERS
```

Send failures can include:

```text
204  timeout
1006 disconnected
```

---

# 19. Known-good wearable UI pattern

A major practical discovery:

Generic layouts caused black/poor rendering on Redmi Watch 4.

The reliable pattern came from the `songbird` example.

Known-good layout structure:

```ux
<div class="page">
  <div class="header">
    ...
  </div>

  <list class="main-list">
    <list-item>
      ...
    </list-item>
  </list>
</div>
```

Do not assume ordinary web-style layout behaves well on Vela wearables.

When a new watch UI renders black, compare against Songbird before debugging signing/networking.

---

# 20. Known-good Songbird reference

Working project:

```text
/Users/valedev/Documents/watch01/xiaomi-band-development/examples/songbird
```

Package:

```text
com.application.watch.demo
```

This application was kept as a known-good rendering reference.

Important backups:

```text
src/pages/index/index.ux.PRE-MESSAGE-TEST
src/manifest.json.PRE-MESSAGE-TEST
```

Do not modify this reference casually.

---

# 21. Other wearable experiments

These projects helped distinguish UI/signing issues from protocol issues.

## `taak-remote`

Outcome:

```text
black / zombie app
```

Do not use as baseline.

## `taak-bridge`

Outcome:

```text
black generic-div implementation
```

Do not use as baseline.

## `taak-known-good`

Working clone direction that validated TAAK signing.

Useful historically, but `taak-signed-test` became the main interconnect project.

## `songbird`

Known-good renderer/reference.

## `taak-signed-test`

Current authoritative project for TAAK interconnect experiments.

---

# 22. Wearable build workflow

From project directory:

```bash
cd ~/Documents/watch01/xiaomi-band-development/examples/taak-signed-test
npm run build
```

---

# 23. Wearable deployment workflow

From toolkit root:

```bash
cd ~/Documents/watch01/xiaomi-band-development

./scripts/deploy.sh \
  --project ./examples/taak-signed-test \
  --no-build
```

This is the known deployment path.

Uninstall was observed to be unreliable.

Prefer version bumps/build/deploy when possible rather than assuming uninstall will behave like Android.

---

# 24. Known-good watch message receiver

The Quick App successfully received a phone-originated message.

The conceptual handler is:

```js
this.connect.onmessage = (event) => {
  this.status = 'MESSAGE RECEIVED'
  this.message = event.data
}
```

Exact event shape should continue to follow the working local source and Xiaomi official sample.

Physical success was observed when Android sent:

```text
miau-from-android
```

The watch UI changed to indicate reception.

This is one of the most important proven results in the project.

---

# 25. Watch→phone send implementation

Known current implementation:

```js
sendMiau() {
  this.status = 'MIAU PRESSED'
  this.message = 'Sending'

  try {
    this.connect.send({
      data: 'miau-from-watch',

      success: () => {
        this.status = 'MIAU SENT'
        this.message = 'miau-from-watch'
      },

      fail: (res) => {
        this.status = 'SEND FAILED'
        this.message = res
          ? ('E' + res.code + ' ' + res.data)
          : 'NO ERROR DATA'
      }
    })
  } catch (e) {
    this.status = 'SEND EXCEPTION'
    this.message = '' + e
  }
}
```

Important:

This send failure is **not currently considered a JavaScript bug**.

Physical logs prove the watch emits service `20/6`, and Mi Fitness blocks the packet before handshake completion.

Do not churn this code without new evidence.

---

# 26. Do not repeat the `getReadyState()` mistake

Adding `getReadyState()` during initialization previously caused:

```text
INIT ERROR
```

Do not add extra lifecycle instrumentation into `onInit()` casually.

When diagnosing the next layer, prefer logs on the Android/Gadgetbridge side before destabilizing the wearable app.

---

# 27. The phone→watch success test

This is the canonical end-to-end regression test.

## Watch

Open:

```text
TAAK Remote
```

Confirm the app loads.

## Android

Open:

```text
TAAK Companion
```

Expected state:

```text
Status: LISTENER SUCCESS
READY — DID 808263400
```

Press:

```text
Send Test
```

Expected Android:

```text
Status: SEND SUCCESS
Sent: miau-from-android
```

Expected watch:

```text
MESSAGE RECEIVED
```

If this regression ever stops working, verify in this order:

```text
1. watch app opens
2. Android package unchanged
3. wearable package unchanged
4. signatures unchanged
5. ADB/app install okay
6. Mi Fitness connected
7. DEVICE_MANAGER permission
8. DID still 808263400
9. listener registration
10. only then investigate code
```

---

# 28. Why Android and wearable package matching matters

Mi Fitness performs lookups approximately like:

```text
calling Android package
      ↓
WatchAppRepository.getWatchApp(package, did)
      ↓
stored fingerprint comparison
```

Therefore these identities are part of the protocol security model.

Known-good:

```text
Android:
com.taak.watch.signedtest

Watch:
com.taak.watch.signedtest
```

Do not rename one side independently when testing XMS.

For a future separate application, either:

- give both sides the same new package and sign them consistently; or
- reuse this package while prototyping.

---

# 29. Physical evidence of fingerprint verification

Observed Mi Fitness log:

```text
fingerPrintVerify package:com.taak.watch.signedtest did:808263400
callingPackage:com.taak.watch.signedtest
fingerPrintVerify success
```

This is important because it proves the signing procedure was accepted by the actual server-side Mi Fitness logic.

---

# 30. Physical evidence of permission

Observed:

```text
Permission data_manager Granted :true
```

This validates the `AuthApi.requestPermission` path.

---

# 31. Physical evidence of listener registration

Observed:

```text
registerMessageListener did:808263400
registerMessageListener messageKey:key_message_com.taak.watch.signedtest
getRegisteredCallbackCount:1
```

This proves the Android listener is actually registered in Mi Fitness, not merely locally inside the Android process.

---

# 32. Physical evidence of Android online state

Observed:

```text
appConnectedStatus:{
  com.taak.watch.signedtest=true
}
```

This closed the hypothesis that the watch send failed because Android was offline.

---

# 33. Physical evidence of watch message transport

Pressing MIAU on the watch generated:

```text
SppTaskQueue ... data size 62
DataHandlerAdapter ... did = 808263400, type = 101
Device-Sync ... packet type=20, packet id=6, did=808263400
XmsDataHandler handlePacket 20 6 false
Packet has not been handle
```

Therefore:

```text
watch JS action              ✅
watch interconnect stack     ✅
watch Bluetooth transport    ✅
phone receives packet        ✅
Mi Fitness policy handler    ❌
```

This distinction should be preserved in future debugging.

---

# 34. The XMS service-20 map

Current reconstructed map:

```text
20/0   getInstalledWatchApp
20/1   prepareInstallApp
20/3   uninstallApp
20/4   launchApp

20/6   request phone app status
20/7   sync phone app status
20/8   phone → watch payload
20/9   watch → phone payload

20/10  WeChat-related
20/11  likely WeChat-related

20/21  getWearAppStatus
20/22  syncWearAppStatus
```

This map is useful for future Gadgetbridge implementation.

---

# 35. Relevant protobuf structures

Reverse engineering identified structures equivalent to:

```proto
message qhr {
  mhr app = 1;
  bytes content = 2;
}

message mhr {
  string packageName = 1;
  bytes fingerprint = 2;
}
```

Do not treat obfuscated class names as stable APIs.

The semantic fields matter more than Java class names.

---

# 36. Official Xiaomi server-side feature gate

Critical logic:

```java
return isSupportFeature(
    model,
    Feature.THIRD_PARTY_APP
) || isSupportFeature(
    model,
    Feature.THIRD_PARTY_APP_NO_MARKET
);
```

Relevant feature strings:

```text
thirdparty_app
third_party_no_market
```

Redmi Watch 4 lacks both.

This affects Mi Fitness, not the physical ability of the watch to emit the protocol.

---

# 37. Product capability source

Mi Fitness eventually loads product capabilities from its product configuration/cache pipeline.

Observed private cache form:

```text
/data/user/0/com.xiaomi.wearable/files/config/product_<locale>.json
```

Conceptual pipeline:

```text
backend/cache
   ↓
ProductListData
   ↓
WearableProduct
   ↓
features
+ whitelistFeature
+ androidFeature
   ↓
WearableDeviceModel.product
   ↓
isSupportThirdPartyApp
```

This investigation is documented elsewhere, but matters here because it explains why application-level changes did not fix WATCH→PHONE.

---

# 38. Secrets and repository hygiene

Do **not** commit:

```text
TAAK keystore passwords
private PEM keys
watch signing private keys
Xiaomi auth key
Hermes credentials
SSH private keys
tokens
```

Safe to commit:

```text
certificate fingerprints
public certificate metadata
package names
device model
DID
source code without secrets
build commands
protocol maps
logs with secrets redacted
```

The Xiaomi auth key acquired during the experiment should remain local/private.

---

# 39. Gadgetbridge local setup

Repository:

```text
/Users/valedev/Documents/Gadgetbridge
```

Official source:

```text
https://codeberg.org/Freeyourgadget/Gadgetbridge.git
```

Build dependency:

```text
JDK 21
```

Environment:

```bash
export JAVA_HOME="/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home"
export PATH="$JAVA_HOME/bin:$PATH"
```

Build:

```bash
cd ~/Documents/Gadgetbridge
./gradlew assembleMainDebug
```

APK discovery:

```bash
find app/build/outputs/apk -type f -iname '*main*debug*.apk'
```

Install:

```bash
adb install -r /path/to/Gadgetbridge.apk
```

Physical result:

```text
GADGETBRIDGE BUILD + INSTALL COMPLETE
```

---

# 40. Why building Gadgetbridge from source matters

We did not only install an app.

We established a modifiable companion stack.

That means TAAK can now potentially implement:

```text
Xiaomi protobuf transport
      ↓
service 20 parsing
      ↓
20/6 response
      ↓
20/7 state sync
      ↓
20/9 payload
      ↓
Pantera
```

without root or Mi Fitness.

---

# 41. Next Gadgetbridge code investigation

Next session should answer:

```text
1. Where does Redmi Watch 4 pairing/auth live?
2. Where are unknown Xiaomi protobuf packets dispatched?
3. Is service 20 already partially implemented?
4. Can we log raw service/id?
5. Can we reply to 20/6?
6. Can we receive 20/9?
7. Can existing TAAK Remote remain installed?
```

Do not start by rewriting the watch app.

The watch side has already emitted the correct physical packet.

---

# 42. Fast Android app creation checklist for Pantera

When asked tomorrow:

> "Pantera, make me an Android app and install it."

Recommended process:

```text
1. Decide package name.
2. Create/reuse Gradle Android project.
3. Use Java/Kotlin compatible with current toolchain.
4. Add required permissions/dependencies.
5. Build with Gradle.
6. Verify APK path.
7. `adb devices`.
8. `adb install -r`.
9. Launch/test.
10. Capture logs.
```

For XMS apps specifically:

```text
1. Android package must match watch package.
2. Use TAAK signing config.
3. Include official XMS AAR.
4. Use known DID if discovery is filtered.
5. Request DEVICE_MANAGER.
6. remove stale listener.
7. add listener.
8. send regression payload.
```

---

# 43. Fast wearable app creation checklist for Pantera

When asked:

> "Pantera, make me a watch app."

Recommended process:

```text
1. Start from working Songbird-style structure.
2. Copy to a new example project if truly required.
3. Define package.
4. If interconnect is needed, match Android package.
5. Add `system.interconnect` permission/capability.
6. Use TAAK signing files without exposing private keys.
7. Build with `npm run build`.
8. Deploy with `deploy.sh`.
9. Verify physical rendering.
10. Only then add network/interconnect logic.
```

Avoid:

```text
generic div-only UI
renaming package on one side only
debugging protocol before confirming rendering
changing known-good signing
adding lifecycle instrumentation randomly
```

---

# 44. Reusable app-development pattern

For rapid prototyping, separate concerns.

## Stage A — hello world

Android:

```text
app launches
button works
text changes
```

Watch:

```text
app opens
screen renders
button changes state
```

## Stage B — identity

```text
package
signature
manifest
permissions
```

## Stage C — transport

```text
connection opens
listener registered
```

## Stage D — one-way message

```text
phone sends "miau"
watch displays "message received"
```

## Stage E — reverse path

```text
watch sends "miau"
phone displays it
```

This staging prevents UI, signing, transport and protocol bugs from being mixed together.

---

# 45. Working directory inventory

## Android

```text
~/Documents/taak-companion
```

Important:

```text
app/libs/xms-wearable-lib_1.4_release.aar
signing/taak-watch.keystore
```

Research:

```text
~/Documents/taak-companion/research/mi-fitness-jadx
~/Documents/taak-companion/research/xiaomi-official
```

## Wearable

```text
~/Documents/watch01/xiaomi-band-development
```

Projects:

```text
examples/songbird
examples/taak-signed-test
examples/taak-known-good
examples/taak-bridge
examples/taak-remote
```

## Gadgetbridge

```text
~/Documents/Gadgetbridge
```

---

# 46. Source-control recommendations

Suggested TAAK Intelligence structure:

```text
taak-intelligence/
├── labs/
│   └── watch-01/
│       ├── README.md
│       ├── lab-bitacora-2026-08-31.md
│       ├── artifacts-reproducibility.md
│       ├── protocol-map.md
│       └── logs/
│
├── runbooks/
│   ├── android-app-build-install.md
│   ├── vela-quickapp-build-deploy.md
│   └── xiaomi-xms-interconnect.md
│
└── architecture/
    └── physical-agent-watch-node.md
```

Do not copy secret files into this repo.

---

# 47. Recommended future automation for Pantera

Pantera could eventually encapsulate common actions as scripts.

Example conceptual scripts:

```text
scripts/android-build-install.sh
scripts/watch-build-deploy.sh
scripts/adb-healthcheck.sh
scripts/watch-regression-test.sh
```

A future `android-build-install.sh` should:

```text
check ADB
check Java
check signing env
build
find APK
install
report package/version
```

A future `watch-build-deploy.sh` should:

```text
validate project
npm build
validate RPK output
deploy
report package/version
```

This would convert today's manual expertise into repeatable lab infrastructure.

---

# 48. Recommended logging discipline

Every experiment should record:

```text
timestamp
device
app version
package
commit hash
firmware
command
physical observation
relevant logs
status
```

Particularly for wearable work, “it compiled” is not enough.

The hierarchy should be:

```text
COMPILED
INSTALLED
OPENED
RENDERED
CONNECTED
MESSAGE SENT
MESSAGE RECEIVED
PHYSICALLY PROVEN
```

Only the final states should be treated as strong evidence.

---

# 49. Key lessons from Android app development

We learned:

```text
ADB workflow                    ✅
Gradle build workflow           ✅
APK discovery                   ✅
APK install/update              ✅
custom signing                  ✅
environment-variable secrets    ✅
third-party AAR integration     ✅
Kotlin Android API usage        ✅
UI status instrumentation       ✅
physical callback validation    ✅
```

This is a reusable Android development capability, not a one-off hack.

---

# 50. Key lessons from wearable app development

We learned:

```text
Xiaomi Vela Quick App structure      ✅
UX layout constraints                ✅
Songbird-style safe UI               ✅
custom package identity              ✅
custom signing                       ✅
manifest capability configuration    ✅
npm build                            ✅
RPK deployment                       ✅
physical app launch                  ✅
interconnect instance                ✅
onmessage receive                    ✅
connect.send invocation              ✅
```

Again: this is reusable application engineering knowledge.

---

# 51. The most important physical milestone

This exact event should remain prominently documented:

```text
Android app:
messageApi.sendMessage(
    "808263400",
    "miau-from-android"
)

        ↓

Mi Fitness / XMS

        ↓

Redmi Watch 4:
TAAK Remote
connect.onmessage(...)

        ↓

WATCH SCREEN:
MESSAGE RECEIVED
```

That moment proved the entire custom application identity, signing and communication chain.

It was not theoretical.

It was physically observed.

---

# 52. Known-safe baseline before future modifications

Before starting future work, preserve:

```text
Android MainActivity known-good version
watch index.ux known-good version
manifest known-good version
signing configuration
XMS AAR
Songbird reference
auth key private copy
Gadgetbridge source checkout
```

Suggested backups:

```text
PRE-GADGETBRIDGE-TAKEOVER
PHONE-TO-WATCH-KNOWN-GOOD
```

Never begin a major protocol change without a known-good rollback point.

---

# 53. What Pantera should understand tomorrow

Pantera should be able to infer from these documents:

1. We can already build Android apps locally.
2. We can install them through ADB quickly.
3. We can build Vela wearable apps.
4. We can deploy them to Redmi Watch 4.
5. We have a valid TAAK signing identity.
6. Matching Android/watch packages are important.
7. XMS phone→watch works physically.
8. Watch→phone is blocked by Mi Fitness policy, not our apps.
9. Gadgetbridge is installed from source as the replacement candidate.
10. The next engineering step is transport replacement, not rewriting known-good apps.

---

# 54. Immediate next experiment

Do **not** modify the known-good Android or watch applications first.

Next:

```text
open Gadgetbridge
↓
grant required permissions
↓
detect Redmi Watch 4
↓
use preserved Xiaomi auth key
↓
controlled pairing migration
↓
confirm Gadgetbridge transport
↓
instrument protobuf
↓
observe 20/6
↓
reply 20/7
↓
receive 20/9
↓
MIAU
```

---

# 55. Definition of success for the next stage

Minimum:

```text
tap watch
→ Gadgetbridge/TAAK receives packet
```

Target:

```text
tap watch
→ "miau-from-watch"
→ Android
```

Final architecture:

```text
Redmi Watch 4
      ↓
TAAK Remote
      ↓
Gadgetbridge / TAAK transport
      ↓
NODE-01 / Pantera
      ↓
agent action / TTS / automation
```

---

# 56. Final operational principle

The lab now has two valuable things:

```text
1. a working implementation;
2. the explanation of why the remaining direction fails.
```

That combination is what makes future iteration fast.

The goal from here is not to “remember what we did.”

The goal is that **Pantera can reproduce it, modify it and build the next app without rediscovering the same facts.**

This document is the handoff for that purpose.
