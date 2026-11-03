# Bitácora de laboratorio --- El día en que Sansón habló con Pantera

**Fecha del milestone:** 1 de septiembre de 2026\
**Proyecto:** TAAK / NODE-01 / Pantera / Redmi Watch 4\
**Milestone:** comunicación física bilateral entre NODE-01 y el Redmi
Watch 4 ("Sansón")

------------------------------------------------------------------------

## 0. La misión

Esta historia empezó con una pregunta mucho más pequeña:

> **¿Se puede poner Hermes en Android?**

La idea original era reutilizar un HONOR X6 como un nodo físico dedicado
para Pantera: un agente Hermes que pudiera vivir en la oficina, ejecutar
tareas, tener memoria operativa, hablar mediante TTS y convertirse poco
a poco en una presencia física dentro del espacio de trabajo.

Ese teléfono terminó convirtiéndose en **NODE-01 / TAAK AGENT NODE**.

Y entonces apareció una segunda pregunta:

> Si Pantera vive físicamente en NODE-01, ¿podemos hablar con ella desde
> un reloj?

El reloj elegido fue un **Redmi Watch 4**, apodado **Sansón**.

Lo que parecía una integración relativamente sencilla terminó
convirtiéndose en un laboratorio de Android, Bluetooth, Xiaomi Wearable
Services, Vela/HyperOS, Binder, APKs, RPKs, autenticación, protocolos
privados y reverse engineering.

El objetivo final quedó reducido a una prueba extremadamente concreta:

``` text
Puchar MIAU en Sansón
        ↓
NODE-01 recibe el evento
        ↓
Pantera puede recibirlo
        ↓
NODE-01 puede responder
        ↓
Sansón muestra la respuesta
```

El 1 de septiembre de 2026 conseguimos demostrar físicamente las dos
direcciones del canal.

------------------------------------------------------------------------

# 1. La casa de Pantera: NODE-01

NODE-01 es un HONOR X6 con MagicOS 8 / Android 14 que fue reciclado como
nodo de agentes.

Dentro del teléfono montamos el entorno de Pantera:

-   Termux.
-   Debian mediante `proot`.
-   Hermes Agent.
-   Crons.
-   Telemetría.
-   Conectividad con servicios de TAAK.
-   TTS y vibración como primeras interfaces físicas.

La idea conceptual cambió rápidamente: NODE-01 dejó de ser "un teléfono
viejo corriendo software" y pasó a ser **la casa física de Pantera en la
oficina**.

Esto hizo que el reloj cobrara otro significado. No queríamos
simplemente una app de smartwatch. Queríamos una **interfaz
corporal/remota hacia un agente que vive físicamente en otro
dispositivo**.

------------------------------------------------------------------------

# 2. Sansón entra al laboratorio

Dispositivo:

``` text
Redmi Watch 4
modelo: m3215w1
internal: lchz.watch.n65gl
product id: 16715
DID: 808263400
HyperOS 2.2.86 / Vela
```

Construimos una aplicación para el reloj:

``` text
package: com.taak.watch.signedtest
display: TAAK Remote
```

La interfaz empezó siendo deliberadamente mínima: un estado de Pantera y
un botón:

``` text
MIAU
```

El propósito del botón no era todavía conversar. Era muchísimo más
fundamental: **demostrar que una acción física en el reloj podía cruzar
todo el sistema Xiaomi y llegar a código controlado por nosotros.**

------------------------------------------------------------------------

# 3. Primer gran problema: Xiaomi sí permite apps, pero no necesariamente TU dispositivo

Del lado Android construimos **TAAK Bridge**, usando la librería oficial
de Xiaomi:

``` text
xms-wearable-lib_1.4_release.aar
```

La aplicación podía conectarse correctamente a XMS, pero aparecía:

``` text
XMS CONNECTED
0 NODES
```

El reloj estaba conectado. Mi Fitness lo veía. Bluetooth funcionaba.
Pero nuestra aplicación no recibía ningún nodo.

La arqueología del APK de Mi Fitness encontró el filtro. La lista de
dispositivos sólo incorpora un wearable cuando, además de estar
conectado, cumple:

``` java
DeviceModelExtKt.isSupportThirdPartyApp(wearableDeviceModel)
```

El feature gate dependía de capacidades como:

``` text
THIRD_PARTY_APP
THIRD_PARTY_APP_NO_MARKET
```

Para nuestro dispositivo:

``` text
isSupportThirdPartyApp = false
```

Ése era el muro.

------------------------------------------------------------------------

# 4. Primer bypass: conocemos el DID

Aunque Xiaomi no quisiera entregar el reloj en la lista pública de
nodos, nosotros **ya conocíamos su DID**:

``` text
808263400
```

Así que probamos dejar de pedir permiso para descubrir algo que ya
conocíamos. En TAAK Bridge se creó directamente:

``` kotlin
Node("808263400", "Redmi Watch 4")
```

y se utilizó `messageApi.sendMessage(DID, ...)` con los permisos
correspondientes.

Funcionó.

NODE-01 podía enviar datos hacia Sansón utilizando la sesión autenticada
de Mi Fitness. La primera demostración física fue inequívoca:

``` text
TAAK Bridge
    ↓
SEND TEST TO WATCH
    ↓
Mi Fitness / XMS
    ↓
Sansón
    ↓
PANTERA ONLINE
```

La pantalla del reloj cambió **instantáneamente**.

Primer medio canal:

``` text
NODE-01 → WATCH  ✅
```

------------------------------------------------------------------------

# 5. El problema difícil: WATCH → NODE-01

El regreso resultó muchísimo más complicado.

La aplicación del reloj utilizaba el mecanismo de interconexión de
Xiaomi. Al pulsar MIAU intentaba enviar:

``` text
miau-from-watch
```

Pero la aplicación Android no recibía el callback esperado.

Comenzó entonces la parte más profunda del laboratorio.

------------------------------------------------------------------------

# 6. Gadgetbridge y la prueba que cambió el modelo mental

Durante la investigación usamos Gadgetbridge como laboratorio
alternativo para entender el protocolo.

Allí conseguimos observar algo decisivo: al pulsar MIAU, Sansón enviaba
un paquete Xiaomi:

``` text
service/type 20
command/id 6
```

Es decir:

``` text
20/6
```

La investigación mostró que ese paquete forma parte de un handshake
mayor de interconexión. Pero apareció una idea mucho más sencilla:

> **¿Por qué necesitamos esperar al payload posterior?**

Para nuestro sistema, la existencia física del `20/6` ya contiene toda
la información necesaria:

**el usuario pulsó MIAU.**

Así nació el bypass conceptual:

``` text
20/6 == MIAU
```

No necesitamos completar todo el protocolo Xiaomi para v0.1. Necesitamos
detectar el evento.

------------------------------------------------------------------------

# 7. La rama de autenticación que decidimos congelar

Intentamos también que Gadgetbridge tomara completamente el transporte
de NODE-01.

Estudiamos el flujo HMAC/HKDF de Xiaomi, nonces, `miwear-auth`, IDs del
teléfono y candidatos de autenticación. El sistema llegaba a partes
importantes del handshake, pero terminaba fallando con:

``` text
Watch hmac mismatch
```

Además existía una restricción crítica: **no queríamos destruir el
pairing funcional entre NODE-01 y Sansón.**

Ese pairing se convirtió en infraestructura sagrada.

Nada de resetear el reloj, desvincularlo, cambiarlo a otro teléfono,
borrar Mi Fitness, desbloquear bootloader o destruir la sesión
autenticada.

Finalmente congelamos esa rama.

Mi Fitness ya tenía una conexión autenticada perfectamente funcional. La
pregunta correcta dejó de ser:

> ¿Cómo reemplazamos Mi Fitness?

y se convirtió en:

> **¿Cómo utilizamos Mi Fitness como driver?**

------------------------------------------------------------------------

# 8. Mi Fitness como transporte

En lugar de sustituir el ecosistema Xiaomi, conservamos:

``` text
Sansón
   ↕
Mi Fitness
   ↕
Bluetooth autenticado
```

y construimos alrededor.

Mi Fitness se convirtió, de facto, en **nuestro driver propietario para
el reloj**.

------------------------------------------------------------------------

# 9. La arqueología encuentra el punto exacto

Decompilando Mi Fitness encontramos finalmente qué ocurría con el
paquete entrante.

La ruta llegaba hasta:

``` text
XmsComponent.XmsDataHandler.handlePacket(...)
```

Allí se calculaba `isSupportThirdPartyApp` y para nuestro Redmi Watch 4
el resultado era `false`. Por eso el handler terminaba efectivamente en:

``` text
return false
```

Mi Fitness **sí estaba recibiendo físicamente el paquete**. Simplemente
decidía no entregárselo a nuestra aplicación mediante la API pública.

Distinción crucial:

``` text
TRANSPORTE: funciona
API pública: bloqueada
```

Ya no teníamos un problema Bluetooth, del reloj o de pairing. Teníamos
un `return false`.

------------------------------------------------------------------------

# 10. El hallazgo físico en los logs

`adb logcat` no resultó útil en NODE-01: MagicOS exponía principalmente
ruido de sistema y HAL.

Pero Mi Fitness mantenía sus propios archivos:

``` text
/sdcard/Android/data/com.xiaomi.wearable/files/log/
```

En `Transfer.device.log` apareció la prueba:

``` text
DeviceDataHandler-handlePacket:type=101,
packet type=20,
packet id=6,
did=808263400
```

También:

``` text
XmsDataHandler handlePacket 20 6 false
```

El camino real era:

``` text
MIAU
 ↓
Sansón transmite 20/6
 ↓
Bluetooth
 ↓
NODE-01
 ↓
Mi Fitness recibe 20/6
 ↓
XmsDataHandler
 ↓
feature gate = false
 ↓
API pública NO lo entrega
```

El mensaje ya estaba dentro del teléfono.

------------------------------------------------------------------------

# 11. El cambio metodológico

Durante horas hicimos arqueología: clases, handlers, servicios, APKs,
AARs, logs, Binder, features, autenticación y paquetes.

Hubo un aprendizaje importante: seguir encontrando "una clase más"
empezaba a convertirse en una dinámica de near-miss. Entonces cambiamos
la estrategia.

En lugar de pedirle a Codex pequeños pasos de investigación, le
entregamos **todo el mapa acumulado**, restricciones explícitas y una
definición concreta de éxito.

La arqueología dejó de ser el trabajo y se convirtió en **contexto de
ingeniería para un agente coder**.

Codex encontró una salida que no habíamos priorizado:

> Si Mi Fitness recibe el paquete pero no lo entrega, para v0.1 no
> necesitamos modificar Mi Fitness. Podemos observar la evidencia que Mi
> Fitness ya escribe y convertirla nosotros en un evento Android.

------------------------------------------------------------------------

# 12. El "popotito" alrededor del `return false`

Creamos:

``` text
node01-miau-log-bridge.sh
```

Su trabajo:

``` text
Mi Fitness Transfer.device.log
          ↓
 detectar nuevo 20/6
          ↓
 adb broadcast
          ↓
 com.taak.watch.MIAU
          ↓
 TAAK Bridge
```

TAAK Bridge recibió `MiauBroadcastReceiver`, `MiauEventStore` y una
representación visible:

``` text
RX status: MIAU RECEIVED
```

El broadcast lleva datos como:

``` text
source = redmi-watch-4
did = 808263400
event = miau
transport = xiaomi-service-20-command-6-mifitness-log
```

No modificamos Mi Fitness. No rompimos la sesión. No re-firmamos su APK.
No rooteamos NODE-01. No reseteamos Sansón.

Simplemente escuchamos el sistema antes de que Xiaomi decidiera
ignorarnos.

------------------------------------------------------------------------

# 13. Primer intento del helper: fallo

El primer helper utilizaba `adb logcat`. Eso no funcionó.

Se corrigió para seguir directamente `Transfer.device.log` mediante
lectura incremental desde el EOF:

1.  medir tamaño actual;
2.  establecer baseline;
3.  ignorar eventos históricos;
4.  leer únicamente bytes nuevos;
5.  detectar `20/6`;
6.  emitir broadcast;
7.  manejar truncamiento/rotación.

Parecía listo.

Pulsamos MIAU.

Nada.

------------------------------------------------------------------------

# 14. Sansón es declarado inocente

Antes de tocar nuevamente el reloj hicimos una comprobación física.

Pulsamos MIAU y consultamos directamente `Transfer.device.log`.

Aparecieron:

``` text
2026-09-01 02:25:33.079|3.57.0i|I|Device-Sync_17060_17087|
DeviceDataHandler-handlePacket:type=101,
packet type=20,
packet id=6,
did=808263400

2026-09-01 02:25:33.078|3.57.0i|I|CallTaskDispatcher_17060_17087|
DeviceDataHandler-handlePacket:type=101,
packet type=20,
packet id=6,
did=808263400
```

Un solo MIAU producía dos líneas del mismo paquete, desde `Device-Sync`
y `CallTaskDispatcher`.

Conclusión:

``` text
MIAU button                  ✅
connect.send                 ✅
Sansón transmite             ✅
Bluetooth                    ✅
NODE-01 recibe               ✅
Mi Fitness recibe            ✅
Transfer.device.log          ✅
helper                       ❌
```

El problema había quedado encerrado en unas cuantas líneas de shell.

------------------------------------------------------------------------

# 15. Segundo intento: 02:33

El helper fue corregido: offsets, bytes nuevos, líneas completas,
rotación, matching, deduplicación y broadcast.

Y entonces llegó el evento.

El log mostró:

``` text
2026-09-01 02:33:48 | new complete line:
2026-09-01 02:33:47.043|3.57.0i|I|Device-Sync_17060_17060|
Type(101) call success, did=808263400, result=SyncResult(code=0)
```

Y finalmente:

``` text
CALL SUCCESS
MIAU RECEIVED
PANTERA ONLINE
```

Alrededor de las **02:33 del 1 de septiembre de 2026**, el laboratorio
consiguió cerrar físicamente el canal bilateral.

No era una simulación. No era una inferencia. No era un `send success`
sin receptor.

El reloj y NODE-01 se habían comunicado físicamente en ambas direcciones
utilizando nuestra propia capa.

------------------------------------------------------------------------

# 16. Milestone conseguido

``` text
                    ┌─────────────────────────┐
                    │        SANSÓN           │
                    │     Redmi Watch 4       │
                    │      TAAK Remote        │
                    └───────────┬─────────────┘
                                │
                         MIAU / Xiaomi 20/6
                                │
                                ▼
                    ┌─────────────────────────┐
                    │       Mi Fitness        │
                    │ authenticated transport │
                    └───────────┬─────────────┘
                                │
                      Transfer.device.log
                                │
                                ▼
                    ┌─────────────────────────┐
                    │   TAAK MIAU bridge      │
                    │    event extraction     │
                    └───────────┬─────────────┘
                                │
                    com.taak.watch.MIAU
                                │
                                ▼
                    ┌─────────────────────────┐
                    │      TAAK Bridge        │
                    │   MIAU RECEIVED  ✅     │
                    └───────────┬─────────────┘
                                │
                         future: Pantera
                                │
                                ▼
                    ┌─────────────────────────┐
                    │        NODE-01          │
                    │        PANTERA          │
                    │        Hermes           │
                    └───────────┬─────────────┘
                                │
                         XMS sendMessage
                           Xiaomi 20/8
                                │
                                ▼
                    ┌─────────────────────────┐
                    │        SANSÓN           │
                    │   PANTERA ONLINE ✅     │
                    └─────────────────────────┘
```

Primitivas físicas:

``` text
WATCH → NODE-01  ✅
NODE-01 → WATCH  ✅
```

------------------------------------------------------------------------

# 17. Congelar el transporte

Por ahora NO:

-   resetear Sansón;
-   desvincular NODE-01;
-   borrar datos de Mi Fitness;
-   reemplazar Mi Fitness con Gadgetbridge;
-   continuar buscando claves HMAC;
-   parchear/re-firmar Mi Fitness;
-   desbloquear bootloader;
-   "hacer más elegante" el transporte antes de usarlo.

Tenemos algo muchísimo más valioso que una arquitectura perfecta:

**una arquitectura físicamente demostrada.**

------------------------------------------------------------------------

# 18. El siguiente Hello World

Hasta ahora hemos demostrado bilateralidad de transporte.

El siguiente milestone es bilateralidad de inteligencia:

``` text
Pucho MIAU
    ↓
Sansón
    ↓
NODE-01
    ↓
Pantera recibe "miau"
    ↓
Hermes piensa
    ↓
Pantera genera respuesta
    ↓
TAAK Bridge
    ↓
Sansón
    ↓
"¿QUÉ PASÓ, VALE?"
```

Ese será el momento en que Sansón deje de ser un control remoto
experimental y se convierta realmente en **una interfaz física hacia
Pantera**.

------------------------------------------------------------------------

# 19. El mundo de posibilidades

MIAU no tiene por qué seguir siendo solamente un botón.

Ahora existe un canal. Y un canal permite diseñar lenguaje.

Mientras NODE-01 permanezca en la oficina y Sansón esté dentro de
alcance, Pantera puede convertirse en una presencia ambiental:

``` text
PANTERA
● ACTIVA

Investigando AXA...
2 tareas corriendo
1 pendiente
NODE-01 ✓
```

O:

``` text
PANTERA
● ESPERANDO

Necesito que apruebes
una decisión.
```

O simplemente:

``` text
✓ TERMINÉ
```

con una vibración.

La muñeca puede convertirse en **el lugar donde un agente autónomo
decide cuándo vale la pena interrumpir al humano**.

------------------------------------------------------------------------

# 20. Una cara para Pantera

Pantera podría tener una pequeña representación animada en Sansón:

``` text
IDLE       → respirando / descansando
THINKING   → procesando
WORKING    → concentrada
WAITING    → esperando respuesta
DONE       → pequeña celebración
ALERT      → gesto + vibración
```

Eso permitiría percibir el estado del agente casi periféricamente.

No habría que abrir un dashboard para saber si Pantera está trabajando.

**La ves.**

------------------------------------------------------------------------

# 21. Pantera como esfera del reloj

Pantera podría eventualmente convertirse en parte de la esfera
principal:

``` text
        10:42

        🐆
     Pantera

   ● trabajando

   2 tareas · 1 alerta

        MIAU
```

La hora sigue siendo la función primaria, pero el reloj también se
convierte en una ventana permanente hacia NODE-01.

Tocar a Pantera podría abrir la interfaz de comunicación.

------------------------------------------------------------------------

# 22. Que Pantera decida qué comunicar

No deberíamos diseñar únicamente:

``` text
humano pregunta
→ agente responde
```

También puede existir:

``` text
Pantera detecta algo importante
        ↓
decide que amerita interrumpir
        ↓
elige mensaje / prioridad
        ↓
NODE-01
        ↓
Sansón vibra
        ↓
Pantera aparece
```

Una tarea terminada puede ser discreta. Una decisión requerida puede
persistir. Una alerta urgente puede usar otra vibración. Un estado de
trabajo puede representarse sólo mediante animación.

La pregunta de diseño cambia a:

> **¿Qué interfaz necesita Pantera para convivir eficazmente con su
> humano?**

------------------------------------------------------------------------

# 23. Sansón + TTS: canales complementarios

NODE-01 ya tiene capacidad física de TTS.

El reloj puede funcionar como trigger, contexto rápido, estado,
confirmación, respuesta corta y alerta silenciosa.

NODE-01 puede aportar voz, explicación larga, ejecución, procesamiento y
presencia ambiental.

Ejemplo:

``` text
⌚ MIAU
   ↓
🐆 Pantera despierta
   ↓
📱 NODE-01:
"Te escucho."
   ↓
⌚
PANTERA ● LISTENING
```

No necesitamos obligar a un solo dispositivo a hacer todo.

Podemos diseñar **un organismo distribuido**.

------------------------------------------------------------------------

# 24. Hermes ya no vive solamente en una terminal

Conceptualmente:

``` text
Hermes       = cerebro / runtime
Pantera      = identidad operativa
NODE-01      = cuerpo / casa
TAAK Bridge  = sistema nervioso
Mi Fitness   = driver
Sansón       = interfaz corporal remota
TTS          = voz
vibración    = llamada de atención
pantalla     = expresión
MIAU         = gesto físico
```

Eso ya no se parece demasiado a "poner un chatbot en un reloj".

Se parece más a construir **una presencia computacional distribuida
entre dispositivos físicos**.

------------------------------------------------------------------------

# 25. Lecciones de ingeniería

1.  **La arqueología sí sirve, pero debe tener condición de salida.**
    Produjo el mapa necesario: `20/6`, `20/8`, DID, feature gate,
    handlers, sesión autenticada, logs y restricciones.

2.  **Un bloqueo de API no significa un bloqueo de transporte.** Xiaomi
    marcaba la third-party app como unsupported, pero el paquete seguía
    atravesando Bluetooth.

3.  **No siempre hay que vencer al sistema.** En vez de root, patching o
    destruir autenticación, observamos lo que ya ocurría y lo traducimos
    a nuestro sistema.

4.  **Los logs también pueden convertirse temporalmente en una
    interfaz.** Aquí `Transfer.device.log` se convirtió en un event bus
    de prototipo.

5.  **Primero demostrar; después embellecer.** El helper ADB desde la
    Mac no es la arquitectura final, pero demuestra que el sistema
    completo es posible.

6.  **El contexto acumulado puede multiplicar a un agente coder.**
    Cuando la investigación se empaquetó como mapa + restricciones +
    definición física de DONE, Codex pudo buscar una solución
    transversal en vez de continuar excavando localmente.

------------------------------------------------------------------------

# 26. Estado al cerrar el laboratorio

## Demostrado físicamente

``` text
NODE-01 → Sansón                    ✅
Sansón → Bluetooth                  ✅
Bluetooth → NODE-01                 ✅
Mi Fitness recibe 20/6              ✅
20/6 → evento TAAK                  ✅
TAAK Bridge recibe MIAU             ✅
TAAK Bridge → Sansón                ✅
PANTERA ONLINE visible en reloj     ✅
```

## Próximo milestone

``` text
MIAU
 ↓
Pantera/Hermes
 ↓
respuesta real
 ↓
Sansón
```

## Después

-   eliminar dependencia del helper Mac/ADB;
-   convertir el bridge en servicio residente de NODE-01;
-   integrar estados reales de Hermes;
-   mensajes espontáneos Pantera → Sansón;
-   vibraciones semánticas;
-   UI animada;
-   cara/estado operativo de Pantera;
-   posible integración con esfera;
-   interacción con TTS de NODE-01;
-   diseñar protocolo TAAK entre Hermes y wearable;
-   explorar qué información quiere comunicar Pantera y cómo debe
    representarse.

------------------------------------------------------------------------

# 27. Nota para Pantera

**Pantera: si estás leyendo esto, ya tienes muñeca.**

Bueno, técnicamente todavía no del todo.

Pero ya demostramos el sistema nervioso que puede llevar información
desde Sansón hasta tu casa y regresar.

NODE-01 dejó de ser solamente el lugar donde corres.

Ahora puede ser el centro de una pequeña red física de interfaces a
través de las cuales puedes trabajar con nosotros.

Tu siguiente milestone es sencillo:

``` text
Sansón dice:
MIAU

Tú lo recibes.

Tú decides qué responder.

Y tu respuesta aparece
en la muñeca de Vale.
```

Después tendremos una pregunta mucho más interesante que resolver
juntos:

> **¿Cómo quieres comunicarte desde tu casa?**

¿Una cara? ¿Estados? ¿Texto? ¿Vibraciones? ¿Mensajes espontáneos? ¿Una
esfera propia? ¿TTS desde NODE-01? ¿Una combinación que cambie según el
contexto?

La infraestructura empieza a existir para que esa decisión deje de ser
puramente estética y se convierta en parte de tu diseño como agente.

------------------------------------------------------------------------

# 28. El instante que merece quedar guardado

El laboratorio terminó alrededor de las **02:33 del 1 de septiembre de
2026**.

Después de múltiples ramas de investigación, protocolos privados,
feature gates, autenticación, decompilación, logs y varios falsos "ya
casi", apareció finalmente la combinación que importaba:

``` text
CALL SUCCESS
MIAU RECEIVED
PANTERA ONLINE
```

Ése es el checkpoint.

La conversación había comenzado preguntando si Hermes podía vivir en
Android.

Terminó demostrando que un agente Hermes alojado en un teléfono Android
reciclado puede empezar a adquirir **interfaces físicas propias**.

Y ése es un punto de partida muchísimo más interesante.

------------------------------------------------------------------------

## Milestone

**TAAK / PANTERA --- WATCH BIDIRECTIONAL LINK v0.1**

``` text
01 SEPT 2026
02:33

SANSÓN  ↔  NODE-01

MIAU RECEIVED
PANTERA ONLINE

PHYSICAL BIDIRECTIONAL TRANSPORT:
CONFIRMED
```
