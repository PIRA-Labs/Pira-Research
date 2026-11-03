# Bitácora de laboratorio --- Liberando un Redmi Watch 4 de Mi Fitness

**Proyecto:** TAAK Intelligence / WATCH-01\
**Fecha de sesión:** 30--31 de agosto de 2026\
**Duración acumulada del frente de investigación:** \~4 días; sesión
final hasta \~05:00\
**Objetivo operativo mínimo:** pulsar una acción en el Redmi Watch 4 y
recibir en nuestro software un mensaje ---el célebre `miau`--- sin
depender de infraestructura cerrada que no controlemos.

> Esta bitácora documenta no sólo lo que funcionó, sino también las
> hipótesis falsas, callejones sin salida, evidencia negativa,
> decisiones arquitectónicas y errores metodológicos. El resultado más
> importante no es un truco específico para un reloj: es un proceso
> reusable de reverse engineering.

## 1. El problema original

El objetivo parecía sencillo:

``` text
Redmi Watch 4
      ↓
TAAK Remote
      ↓
Android companion
      ↓
NODE-01 / Pantera
```

Queríamos convertir un Redmi Watch 4 en una interfaz física para un
agente TAAK. El primer hito era deliberadamente mínimo:

``` text
tap en reloj → Android recibe "miau"
```

El reloj ejecuta Xiaomi Vela/Quick Apps. Ya habíamos logrado instalar y
ejecutar una Quick App propia, firmada por TAAK, por lo que la pregunta
dejó de ser "¿podemos ejecutar código en el reloj?" y pasó a ser:
**¿podemos atravesar el canal de interconexión reloj ↔ Android?**

## 2. Entorno del experimento

### Redmi Watch 4

-   Modelo interno: `lchz.watch.n65gl`
-   Product ID: `16715`
-   DID: `808263400`
-   HyperOS: 2.2.86
-   Plataforma: Vela

### Android de laboratorio

PHONE-BRIDGE-DEV con Mi Fitness 3.57.0i, HyperOS 3.0.302.0.WNEMXAT.C09,
Android 16 y ADB.

### Nodo de agente

HONOR X6 convertido en `NODE-01`, ejecutando Hermes/Pantera en Termux +
Debian.

### Mac de desarrollo

MacBook Air M1 con Android SDK/ADB, Java, Gradle, JADX, Node/npm y
toolchain Xiaomi Vela.

## 3. Fuentes y artefactos consultados

### Xiaomi Vela / XMS

-   Interconnect:
    `https://iot.mi.com/vela/quickapp/en/features/network/interconnect.html`
-   Samples: `https://iot.mi.com/vela/quickapp/en/samples/`
-   Paquete oficial descargado: `interconnect_dev_test_demo.zip`
-   SDK: `xms-wearable-lib_1.4_release.aar`

### Mi Fitness

APK decompilada con JADX en:

``` text
~/Documents/taak-companion/research/mi-fitness-jadx
```

### Gadgetbridge

-   Sitio: `https://gadgetbridge.org/`
-   Xiaomi wearables:
    `https://gadgetbridge.org/gadgets/wearables/xiaomi/`
-   Xiaomi protobuf:
    `https://gadgetbridge.org/basics/topics/xiaomi-protobuf/`
-   Source: `https://codeberg.org/Freeyourgadget/Gadgetbridge.git`

## 4. Hipótesis inicial: usar la API oficial

El sample oficial hace esencialmente:

``` kotlin
nodeApi = Wearable.getNodeApi(context)
messageApi = Wearable.getMessageApi(context)
nodeApi.connectedNodes.addOnSuccessListener { curNode = it[0] }
messageApi.addListener(node.id, listener)
messageApi.sendMessage(node.id, payload)
```

Nuestro companion cargó correctamente el AAR y conectó a XMS, pero
produjo:

``` text
Status: XMS CONNECTED / 0 NODES
```

El reloj estaba conectado a Mi Fitness. Por tanto, "el reloj no está
conectado" no explicaba el resultado.

## 5. Dejar de adivinar: seguir el código

Decompilamos el SDK y seguimos:

``` text
NodeApi.getConnectedNodes()
→ Binder
→ com.xiaomi.xms.wearable.IWearableInterface
→ Mi Fitness
```

En `defpackage/kkt.java` apareció el gate:

``` java
WearableDeviceModel model =
    DeviceManagerExtKt.getInstance(WearableDeviceManager.INSTANCE)
        .getCurrentDeviceModel();

ArrayList nodes = new ArrayList();

if (
    model != null
    && model.getIsDeviceConnected()
    && DeviceModelExtKt.isSupportThirdPartyApp(model)
) {
    nodes.add(new Node(
        model.getDeviceInfo().getDid(),
        model.getDeviceInfo().getName()
    ));
}

callback.onNodesConnected(nodes);
```

Los logs probaron:

``` text
currentDeviceModel       ✅
isDeviceConnected        ✅
isSupportThirdPartyApp   ❓
```

## 6. El átomo: `isSupportThirdPartyApp`

Seguimos esa función hasta:

``` java
return DeviceModelExtKt.isSupportFeature(
    model, Feature.THIRD_PARTY_APP
) || DeviceModelExtKt.isSupportFeature(
    model, Feature.THIRD_PARTY_APP_NO_MARKET
);
```

Y luego:

``` java
List<String> features = deviceModel.getProduct().getFeatures();
return features != null && features.contains(feature);
```

Strings:

``` text
THIRD_PARTY_APP           = "thirdparty_app"
THIRD_PARTY_APP_NO_MARKET = "third_party_no_market"
```

El Product vivo del Redmi Watch 4 contenía `watchface`, `market`,
`launcher`, etc., pero no esos dos flags.

Controles: - Xiaomi Watch S1 Pro → `thirdparty_app` - Xiaomi Watch 2 →
`thirdparty_app` - Xiaomi Watch S4 → `third_party_no_market`

Conclusión:

``` text
Quick Apps          ✅
market              ✅
launcher            ✅
XMS third-party     ❌
```

Poder ejecutar Quick Apps no implica que Mi Fitness exponga el bridge
XMS a una app Android de terceros.

## 7. Hipótesis creativa: ignorar discovery

`getConnectedNodes()` estaba bloqueado. Pregunta: **¿todas las APIs
vuelven a comprobar el mismo feature?**

Ya conocíamos el DID:

``` text
808263400
```

Construimos manualmente un `Node` y llamamos directamente a
`addListener` y `sendMessage`.

Mi Fitness respondió:

``` text
fingerPrintVerify success
is device:808263400 Permission data_manager Granted :false
```

Esto probó:

``` text
package                  ✅
firma                    ✅
DID                      ✅
watch app registrada     ✅
```

El bloqueo nuevo era sólo permiso.

## 8. DEVICE_MANAGER

Solicitamos:

``` kotlin
authApi.requestPermission(
    watchDid,
    Permission.DEVICE_MANAGER
)
```

Resultado físico:

``` text
Status: LISTENER SUCCESS
READY — DID 808263400
```

También corregimos listeners duplicados con
`messageApi.removeListener(watchDid)` antes de registrar.

## 9. Primer éxito físico: PHONE → WATCH

Android envió:

``` text
miau-from-android
```

Resultado:

``` text
Android: SEND SUCCESS
Watch:   connect.onmessage(...)
```

Probado:

``` text
PHONE → XMS/Mi Fitness → WATCH   ✅
```

Esto descartó firma, package, DID, Quick App, API y una incompatibilidad
absoluta del reloj.

## 10. WATCH → PHONE seguía fallando

La Quick App ejecutó:

``` js
this.connect.send({
  data: 'miau-from-watch',
  success: () => { this.status = 'MIAU SENT' },
  fail: (res) => {
    this.status = 'SEND FAILED'
    this.message = res ? ('E' + res.code + ' ' + res.data) : 'NO ERROR DATA'
  }
})
```

Resultado físico:

``` text
SEND FAILED
```

## 11. Cerrando la rama Android

Revertimos `ServiceApi` y encontramos que XMS registra el estado online
de la app en Mi Fitness.

Logs:

``` text
appConnectedStatus:{com.taak.watch.signedtest=true}
fingerPrintVerify success
Permission data_manager Granted :true
getRegisteredCallbackCount:1
```

Estado:

``` text
XMS Binder connected       ✅
package                    ✅
fingerprint                ✅
DID                        ✅
DEVICE_MANAGER             ✅
phone app online           ✅
listener count = 1         ✅
```

Decisión metodológica: **dejar de tocar Android**. Una rama físicamente
probada se cierra hasta que aparezca nueva evidencia.

## 12. Paquetes físicos emitidos por el reloj

Cada pulsación de MIAU produjo:

``` text
SppTaskQueue ... data size 62
DataHandlerAdapter ... did = 808263400, type = 101
Device-Sync ... packet type=20, packet id=6, did=808263400
FITNESS.AppLinkLog: XmsDataHandler handlePacket 20 6 false
Packet has not been handle
```

Por tanto:

``` text
WATCH → Bluetooth transport   ✅
```

El reloj sí emitía; el fallo ocurría después.

## 13. La línea perdida que agotó las opciones

Encontramos `XmsDataHandler.handlePacket`:

``` java
boolean supported =
    model != null
        ? DeviceModelExtKt.isSupportThirdPartyApp(model)
        : false;

log("XmsDataHandler handlePacket "
    + type + " " + packet.d + " " + supported);

if (!supported) {
    return false;
}
```

La línea:

``` text
XmsDataHandler handlePacket 20 6 false
```

significaba literalmente:

``` text
isSupportThirdPartyApp(Redmi Watch 4) == false
```

y Mi Fitness abandonaba el paquete **antes de procesarlo**.

No era JavaScript. No era firma. No era Android. No era Bluetooth. No
era listener. No era DEVICE_MANAGER. No era DID. No era incapacidad del
reloj.

Era un booleano de capability dentro de Mi Fitness.

## 14. Reconstrucción parcial del protocolo

Mapeamos el servicio 20:

``` text
20/0   getInstalledWatchApp
20/1   prepareInstallApp
20/3   uninstallApp
20/4   launchApp
20/6   request phone app status
20/7   syncPhoneAppStatus
20/8   phone → watch message
20/9   watch → phone message
20/10  WeChat-related
20/11  posiblemente WeChat-related
20/21  getWearAppStatus
20/22  syncWearAppStatus
```

Flujo deseado:

``` text
WATCH
  ├── 20/6 ─────────► PHONE   "¿está viva mi app?"
  ◄────────── 20/7 ──         "sí"
  ├── 20/9 ─────────► PHONE   payload
  ▼
"miau"
```

Nuestro reloj llegaba físicamente a `20/6`; Mi Fitness lo recibía y lo
descartaba.

## 15. ¿Podíamos alterar la capability dentro de Mi Fitness?

Seguimos:

``` text
product_<locale>.json
→ ProductListData
→ WearableProduct
→ features + whitelistFeature + androidFeature
→ mProducts[model]
→ WearableDeviceModel.product
→ isSupportThirdPartyApp()
```

Investigamos: - `mergeFeature` - `mergeAndroidFeature` -
`productWhiteListSwitch` - `GlobalConfig.AppConfigs.isGray` -
`DevicePreference` - `ProductManagerRemoteInternal` -
`InternalTestRequest`

El Watch 4 vivo mostraba:

``` text
whitelistFeature = []
androidFeature   = []
```

No apareció un setter/override accesible para fabricar `thirdparty_app`.

ADB no podía leer `/data/user/0/com.xiaomi.wearable/...`; `run-as`
tampoco porque Mi Fitness no era debuggable.

**Ruta de configuración agotada.**

## 16. Opción nuclear: runtime hook

Ya sabíamos qué parche conceptual funcionaría:

``` kotlin
if (model == "lchz.watch.n65gl") return true
return original
```

Encontramos MiWearBridge/LSPosed como evidencia de que esta familia de
hooks es viable.

Pero exigía root + LSPosed + mantener un teléfono Android puente.

Eso podía ser técnicamente correcto y arquitectónicamente malo.

## 17. Por qué evitamos root

PHONE-BRIDGE-DEV y NODE-01 tenían bootloader bloqueado. El desbloqueo
implicaba riesgo/wipe que no justificaba sacrificar datos.

Lección:

``` text
solución técnicamente posible ≠ solución adecuada
```

## 18. Casi compramos otro reloj

Investigamos Wear OS/Xiaomi Watch 2 como escape:

``` text
WATCH → Wi-Fi/Internet → Pantera
```

Era limpio, pero implicaba comprar hardware cuando el Redmi Watch 4 **ya
estaba emitiendo físicamente el paquete correcto**.

## 19. El giro decisivo: cambiar la pregunta

Durante demasiado tiempo preguntamos:

``` text
¿Cómo hacemos que Mi Fitness permita esto?
```

La pregunta que abrió el problema fue:

``` text
¿Por qué necesitamos Mi Fitness?
```

O, en términos de laboratorio:

> **¿Y si mandamos a la chingada a Mi Fitness?**

Buscamos alternatives/open source/Xiaomi protobuf y apareció
**Gadgetbridge**.

## 20. Gadgetbridge: no romper el muro, eliminarlo

Gadgetbridge documenta Redmi Watch 4 dentro de la familia Xiaomi y
trabaja con Xiaomi protobuf.

Nueva arquitectura:

``` text
ANTES
WATCH → Mi Fitness → XMS → TAAK Android

AHORA
WATCH → Xiaomi protobuf → Gadgetbridge / fork TAAK → Pantera
```

El gate vive en Mi Fitness, no en el reloj. Si sustituimos el receptor,
no tenemos obligación de ejecutar:

``` java
if (!isSupportThirdPartyApp()) return false;
```

**El guardia estaba en la puerta de Mi Fitness. No había que
convencerlo: podíamos dejar de usar el edificio.**

## 21. Auth key

Antes de romper pairing preservamos el estado y buscamos la clave
Xiaomi.

Resultado:

``` text
AUTH KEY CANDIDATE ACQUIRED
```

La clave se guardó localmente y **no debe incluirse jamás en el
repositorio**.

## 22. Gadgetbridge desde source

Clonamos:

``` bash
git clone https://codeberg.org/Freeyourgadget/Gadgetbridge.git
```

El primer build falló porque requería Java 21:

``` text
languageVersion=21
```

Configuramos JDK 21 y ejecutamos:

``` text
./gradlew assembleMainDebug
```

Resultado:

``` text
🔥 GADGETBRIDGE BUILD + INSTALL COMPLETE
```

Ahora tenemos:

``` text
source code
+ build reproducible
+ APK instalada
+ auth key
+ protocolo parcialmente mapeado
```

Incluso si Gadgetbridge no implementa service 20, tenemos un lugar
viable para implementarlo.

## 23. Estado al cerrar el laboratorio

``` text
Redmi Watch 4 funcionando               ✅
Quick App TAAK instalada                ✅
firma TAAK válida                       ✅
interconnect.instance()                 ✅
Mi Fitness funcional                    ✅
pairing preservado                      ✅

PHONE → WATCH                           ✅ PHYSICAL
WATCH emite 20/6                        ✅ PHYSICAL
Mi Fitness recibe 20/6                  ✅ PHYSICAL
Mi Fitness procesa 20/6                 ❌ FEATURE GATE

Android package                         ✅
Android fingerprint                     ✅
DID                                     ✅
DEVICE_MANAGER                          ✅
listener                                ✅
phone app online                        ✅

Auth key Xiaomi                         ✅ ACQUIRED
Gadgetbridge source                     ✅
Gadgetbridge build                      ✅
Gadgetbridge instalado                  ✅

Gadgetbridge ↔ Redmi Watch 4            ⏳ NEXT
20/6 custom handler                     ⏳ IF REQUIRED
20/9 → "miau"                           ⏳ FINAL TARGET
```

## 24. Hipótesis para la siguiente sesión

### H1 --- Gadgetbridge conecta directamente

Emparejar usando la auth key. Si conecta, Mi Fitness desaparece de la
arquitectura.

### H2 --- recibe paquetes pero no implementa service 20

Instrumentar Xiaomi protobuf y buscar físicamente `20/6`.

### H3 --- implementar interconnect mínimo

Sólo necesitamos inicialmente:

``` text
20/6 → request phone app status
20/7 → answer online
20/9 → receive payload
```

Después explorar `20/8`.

### H4 --- conservar Quick App instalada

No modificar TAAK Remote sin evidencia. Ya sabemos que produce el
paquete físico correcto.

## 25. Ramas cerradas

No reabrir sin nueva evidencia:

-   `system.internal.message` → `MSG NULL`.
-   Mi Fitness `app.bundle` → callejón sin salida.
-   churn de UI/JS → el reloj ya emite físicamente.
-   Android companion → probado.
-   `connectedNodes` como bug independiente → explicado por feature
    gate.
-   listener/fingerprint/permission → probados.
-   Product JSON vía ADB → bloqueado sin root/debuggable.
-   whitelist/config override → agotado.
-   root de teléfonos actuales → no justifica wipe/riesgo.
-   comprar otro reloj → suspendido.

## 26. Qué hicimos bien

### Convertimos síntomas en invariantes

`PHONE → WATCH funciona` eliminó categorías enteras de hipótesis.

### Seguimos la ejecución hasta el servidor

No nos quedamos en `connectedNodes=[]`; seguimos SDK → Binder → Mi
Fitness → Product → features → boolean.

### Probamos bypasses pequeños antes de soluciones nucleares

DID directo desbloqueó PHONE → WATCH sin root ni patch.

### Separamos hardware de política

El reloj puede emitir. Mi Fitness decide no procesar.

### No confundimos "funciona" con "buena arquitectura"

Root + LSPosed podía servir en laboratorio, pero era una dependencia
diaria mala.

### Preservamos checkpoints

Antes de migrar obtuvimos auth key, preservamos pairing y construimos el
replacement.

## 27. Qué pudimos hacer mejor

Ésta es la autocrítica más importante.

Aceptamos demasiado tiempo esta premisa:

``` text
Redmi Watch 4 ↔ Mi Fitness
```

como si fuera una propiedad física. Era sólo una decisión del
fabricante.

Debimos preguntar mucho antes:

> **¿Existe un replacement open source del componente propietario que
> estamos intentando modificar?**

Búsquedas tempranas como:

``` text
Redmi Watch 4 open source companion
Redmi Watch 4 Gadgetbridge
Xiaomi protobuf Redmi Watch 4
Mi Fitness alternative
```

podían habernos ahorrado muchas horas.

La investigación profunda no fue inútil: ahora poseemos el mapa que
quizá necesitemos para extender Gadgetbridge. Pero sí hubo un **error de
orden de operaciones**.

## 28. Nueva regla TAAK: cuestionar el muro

``` text
Encontramos bloqueo
       │
       ▼
¿hardware/protocolo o política de intermediario?
       │
       ├── hardware/protocolo → reverse engineer
       │
       └── intermediario → ¿podemos eliminarlo?
```

Antes de:

``` text
patch
hook
root
exploit
buy new hardware
```

preguntar:

``` text
replace?
bypass?
open source?
direct protocol?
alternate transport?
```

**La creatividad arquitectónica debe ocurrir antes que la escalada
técnica.**

## 29. Protocolo TAAK reusable de reverse engineering

### Fase 0 --- hito físico mínimo

Definir `input físico → evidencia observable`. Ejemplo: `tap → miau`.

### Fase 1 --- dibujar la cadena

`A → B → C → D → E`.

### Fase 2 --- clasificar componentes

Para cada uno: ¿lo controlamos?, ¿open source?, ¿reemplazable?,
¿obligatorio?, ¿convención del fabricante?

### Fase 3 --- buscar alternatives antes de decompilar

Timebox de 20--30 min: `"<device> open source"`,
`alternative companion`, `protocol implementation`, `Gadgetbridge`, etc.

### Fase 4 --- evidencia física

Logs, packets, callbacks, estados. Medir antes de inferir.

### Fase 5 --- seguir el código end-to-end

`caller → SDK → IPC → service → condition → data source`.

### Fase 6 --- hipótesis falsables

Cada hipótesis debe tener predicción, prueba, resultado y estado.

### Fase 7 --- buscar asimetrías

Una API bloqueada no implica todas bloqueadas: `getConnectedNodes ❌`,
`sendMessage(DID) ✅`.

### Fase 8 --- encontrar el predicado mínimo

Reducir "no funciona" hasta algo como:
`features.contains("thirdparty_app") == false`.

### Fase 9 --- mecanismo vs política

¿El dispositivo no puede, o un software decidió no permitirlo?

### Fase 10 --- escalera de intervención

Preferencia:

``` text
1. API oficial
2. bypass de discovery
3. protocolo directo
4. replacement open source
5. fork/patch del replacement
6. runtime hook
7. root
8. firmware modification
9. replacement hardware
```

### Fase 11 --- cerrar ramas

Etiquetas: `OPEN`, `PROVEN`, `DISPROVEN`, `BLOCKED`, `CLOSED`.

### Fase 12 --- checkpoint antes de destruir

Antes de unpair/wipe/unlock/flash: guardar keys, logs, versions, pairing
state, binaries, source y backups.

### Fase 13 --- criterio de abandono

No sólo "¿podemos seguir?", sino: **"¿la siguiente hora tiene mayor
valor esperado que cambiar la arquitectura?"**

## 30. Plantilla de bitácora para futuros experimentos

``` markdown
# LAB — [nombre]

## Objetivo físico mínimo
[input] → [observable output]

## Arquitectura inicial
A → B → C → D

## Restricciones
- no root
- no wipe
- no gasto

## Componentes reemplazables
| Componente | Propietario | Open source alt | Obligatorio |

## Hipótesis
### H1
Predicción:
Prueba:
Resultado:
Estado: PROVEN / DISPROVEN / OPEN

## Evidencia física
timestamp / log / packet / screenshot

## Invariantes comprobadas
- ...

## Ramas cerradas
- ...

## Bloqueo mínimo actual
`boolean / packet / function / condition`

## Alternativas arquitectónicas
- bypass
- replacement
- protocol direct
- hook
- hardware

## Próximo experimento
Una sola prueba con máximo poder de discriminación.
```

## 31. Lección científica

Durante horas preguntamos:

> ¿Cómo conseguimos que Mi Fitness acepte nuestro reloj como plataforma
> third-party?

Llegamos literalmente a:

``` java
features.contains("thirdparty_app")
```

y la respuesta era:

``` text
false
```

Pero ese `false` sólo era definitivo **dentro del sistema de Xiaomi**.
No era una ley del hardware.

La pregunta correcta terminó siendo:

> **¿Qué pasa si nuestro sistema deja de necesitar la opinión de Mi
> Fitness?**

Ésa es probablemente la lección más reusable de la sesión:

**un bloqueo profundamente comprendido no siempre debe romperse. A veces
comprenderlo suficientemente bien permite descubrir que puede eliminarse
de la arquitectura.**

## 32. Resultado científico

``` text
TAAK Quick App ejecuta en Redmi Watch 4        ✅
interconnect existe                            ✅
Android XMS conecta                            ✅
firma/package compatibles                      ✅
DID directo funciona                           ✅
DEVICE_MANAGER funciona                        ✅
PHONE → WATCH funciona                         ✅
WATCH genera paquete interconnect              ✅
20/6 llega físicamente al teléfono             ✅
Mi Fitness lo rechaza por feature gate         ✅
feature gate exacto identificado               ✅
fuente de capability reconstruida              ✅
config override accesible agotado              ✅
root evitado                                    ✅
nuevo hardware evitado                          ✅
replacement open source encontrado              ✅
auth key obtenida                               ✅
Gadgetbridge compilado desde source             ✅
Gadgetbridge instalado                          ✅
```

## 33. Próxima entrada --- Gadgetbridge takeover

``` text
1. Abrir Gadgetbridge
2. Permisos
3. Detectar Redmi Watch 4
4. Preparar auth key
5. Preservar estado actual
6. Migrar pairing controladamente
7. Confirmar conexión
8. Instrumentar Xiaomi protobuf
9. Buscar 20/6
10. Responder 20/7
11. Recibir 20/9
12. MIAU
```

Criterio de éxito:

``` text
WATCH
  ↓
TAAK Remote
  ↓
Gadgetbridge / TAAK transport
  ↓
"miau-from-watch"
```

Después:

``` text
WATCH → Pantera → acción real
```

## Epílogo

Cuatro días de investigación y una sesión terminando cerca de las cinco
de la mañana produjeron una situación curiosa:

Estuvimos a punto de comprar otro reloj porque un booleano decía
`false`.

Después descubrimos que el booleano pertenecía al software de alguien
más.

Así que decidimos intentar reemplazar el software.

**Fin de turno. El laboratorio queda preservado.**
