# Architecture Decision Records — GrowTogetherAPP

Decisiones de arquitectura específicas de la app móvil Flutter.

**Proyecto**: GrowTogether — DAM 2026
**Autor**: Jordi Patuel Pons

> Las decisiones del paquete de datos compartido están en
> `GrowTogetherDATA/docs/DECISIONS.md` y las del backend en
> `GrowTogetherAPI/docs/DECISIONS.md`. Aquí solo se documentan las que
> son específicas del cliente móvil.

---

## Índice

| # | Decisión | Estado |
|---|----------|--------|
| [ADR-001](#adr-001-flutter-como-framework-de-app-mvil) | Flutter como framework de app móvil | Aceptado |
| [ADR-002](#adr-002-provider-para-state-management) | Provider para state management | Aceptado |
| [ADR-003](#adr-003-navigator-clsico-para-la-navegacin) | Navigator clásico para la navegación | Aceptado |
| [ADR-004](#adr-004-indexedstack-para-el-bottom-navigation) | IndexedStack para el bottom navigation | Aceptado |
| [ADR-005](#adr-005-heatmap-estilo-github-para-estadsticas) | Heatmap estilo GitHub para estadísticas | Aceptado |
| [ADR-006](#adr-006-extension-buildcontext-para-snackbars) | Extension `BuildContext` para SnackBars | Aceptado |
| [ADR-007](#adr-007-online-only-para-acciones-tolerante-a-red-para-lectura) | Online-only para acciones, tolerante a red para lectura | Aceptado |
| [ADR-008](#adr-008-recordatorios-locales-con-flutter_local_notifications) | Recordatorios locales con `flutter_local_notifications` | Aceptado |

---

## ADR-001: Flutter como framework de app móvil

**Fecha**: 2026-03-01

### Contexto

GrowTogether requiere una aplicación móvil con UI fluida, integración con
una API REST y soporte para Android como plataforma principal, con
posibilidad de extenderse a iOS y Web.

### Decisión

**Flutter (Dart)** es el framework elegido para el desarrollo móvil.

### Alternativas descartadas

**React Native (JavaScript/TypeScript)**
Multiplataforma y con gran comunidad, pero su arquitectura basada en un
puente JavaScript-nativo introduce latencia en operaciones de UI
intensivas como animaciones y gestos. Partir desde cero en JS suponía
una curva de aprendizaje equivalente a Dart sin las ventajas de
rendimiento.

**Kotlin / Android nativo**
La opción más natural viniendo del currículo Java de DAM. No cubre iOS,
y Kotlin Multiplatform Mobile estaba en alpha para la capa de UI cuando
se tomó la decisión.

**Ionic / Capacitor (WebView)**
Híbrido basado en WebView. El más rápido de arrancar pero el rendimiento
visual en animaciones complejas (heatmap, carrusel, glassmorphism) es
notablemente inferior. Tampoco da acceso sencillo a APIs nativas como
cámara o almacenamiento seguro.

### Razones de la decisión

1. **Base de conocimiento**: Flutter era el framework estudiado en
   clase, lo que reducía el tiempo de arranque.
2. **Multiplataforma real**: un único codebase compila para Android, iOS
   y Web sin duplicar lógica ni UI.
3. **Rendimiento cercano a nativo**: Flutter compila a código ARM nativo
   sin puente intermedio, garantizando 60/120 fps que React Native no
   iguala fácilmente.
4. **Ecosistema maduro**: pub.dev ofrece paquetes estables para todas
   las necesidades (Dio, Provider, flutter_secure_storage, image_picker,
   flutter_local_notifications, connectivity_plus).

### Consecuencias

- Un único desarrollador mantiene Android e iOS simultáneamente.
- Hot reload acelera el ciclo de desarrollo.
- El tamaño base del APK (~7-10 MB) es mayor que el de una app nativa
  equivalente.
- Dart tiene menor adopción que JavaScript o Kotlin, lo que reduce la
  oferta de recursos externos.

---

## ADR-002: Provider para state management

**Fecha**: 2026-03-01

### Contexto

La app necesita gestionar estado compartido entre pantallas: lista de
hábitos, sesión del usuario, estadísticas, perfil, conectividad,
recordatorios. Era necesario elegir solución antes de la primera
pantalla.

### Decisión

**Provider 6.x (`ChangeNotifier` + `MultiProvider`)** es la solución
elegida.

### Alternativas descartadas

**Bloc / flutter_bloc**
La solución más robusta y testeable para apps grandes: separa eventos,
estados y transformaciones. Boilerplate considerable (event class, state
class, bloc class por feature) y curva alta para la escala de
GrowTogether.

**Riverpod**
Corrige limitaciones de Provider (no depende del árbol de widgets, más
seguro en compile-time). API basada en `ref` y providers declarativos
suponía un cambio de paradigma respecto a `ChangeNotifier`. No era parte
del currículo.

**GetX**
Opinionado y muy productivo, pero mezcla routing, DI y state management
en un único paquete. Dificulta el testing y acopla la app al framework.

**`setState` puro**
Viable solo para apps de una pantalla. Con estado compartido entre tabs
genera prop-drilling inmanejable.

### Razones de la decisión

1. **Currículo**: Provider era la solución estudiada en clase.
2. **Sencillez adecuada a la escala**: `ChangeNotifier` + `context.watch`
   / `read` es suficiente para los providers actuales sin
   sobreingeniería.
3. **Recomendación oficial**: el equipo de Flutter recomienda Provider
   para escala media.
4. **Testeable**: los `ChangeNotifier` son clases Dart puras, fáciles de
   testear sin dependencias de framework.

### Consecuencias

- DI centralizada en `main.dart` con `MultiProvider`. Grafo de
  dependencias explícito y visible.
- Todo estado de negocio en `ChangeNotifier`; `setState` reservado para
  estado UI local (toggles, animaciones).
- Si la app escala mucho más, migrar a Riverpod o Bloc sería el
  siguiente paso natural.

---

## ADR-003: Navigator clásico para la navegación

**Fecha**: 2026-03-01

### Contexto

La app tiene un flujo de navegación definido: login → main layout
(bottom nav) → pantallas de detalle. Era necesario elegir routing.

### Decisión

**Navigator 1.0** (`push` / `pop` / `pushReplacement`) es el sistema
elegido.

### Alternativas descartadas

**GoRouter**
Recomendado actualmente por el equipo de Flutter para apps con deep
links, URLs compartibles (especialmente en web) y guards de
autenticación declarativos. Esas características no eran necesarias en
GrowTogether: sin deep links, web secundaria, los guards de auth se
gestionan con `SecureStorage` en el arranque. GoRouter habría añadido
una capa (rutas nombradas, ShellRoute para bottom nav) sin valor real.

**`auto_route` (code generation)**
Genera el boilerplate de routing. Requiere `build_runner` y conocimiento
de sus convenciones. Coste de aprendizaje desproporcionado para el
caso de uso.

**GetX routing**
Mismo motivo que GetX para state management: acoplamiento a framework
todo-en-uno.

### Razones de la decisión

1. **Sin deep links ni URLs web**: el flujo es lineal (stack), sin
   rutas que necesiten ser compartidas o bookmarkeadas.
2. **No era parte del currículo**: aprender un sistema adicional sin
   beneficio proporcional.
3. **Simplicidad**: `Navigator.push`, `pop` y `pushReplacement` cubren
   el 100% de la app con código que cualquier desarrollador Flutter
   entiende.

### Consecuencias

- Si en el futuro se hace versión web con URLs compartibles, migrar a
  GoRouter.
- El paso de parámetros entre pantallas se hace por constructores,
  explícito pero verboso si se pasan muchos datos.

---

## ADR-004: IndexedStack para el bottom navigation

**Fecha**: 2026-03-01

### Contexto

La app tiene un bottom navigation con 4 tabs (Inicio, Análisis,
Desafíos, Perfil). Cómo se gestiona el estado de cada tab al cambiar
entre ellos.

### Decisión

**`IndexedStack`** es el widget contenedor del bottom navigation.

### Alternativas descartadas

**Reconstruir la pantalla en cada cambio (`if/else` o `switch`)**
La pantalla se destruye y reconstruye al cambiar de tab: datos
recargados de la API, scroll al inicio, estado local perdido.
Inaceptable para una app con datos que tardan en cargar.

**`PageView` con `PageController`**
Mantiene las pantallas en memoria igual que `IndexedStack` y añade
soporte para swipe entre tabs. El swipe entre tabs no es un patrón
habitual en apps con bottom nav (puede causar navegación accidental) y
`PageView` añade complejidad para deshabilitar el gesto.

### Razones de la decisión

1. **Preservación de estado**: las 4 pantallas se crean una sola vez y
   permanecen en memoria. Al volver a un tab, scroll, datos cargados y
   estado local se mantienen exactamente como el usuario los dejó.
2. **Rendimiento**: se evitan reconstrucciones y llamadas a la API
   redundantes al navegar entre tabs ya visitados.
3. **Simplicidad**: `IndexedStack` con un `_indiceActual` es más directo
   que `PageView` con controller y gestión de swipe.

### Consecuencias

- Las 4 pantallas están en memoria simultáneamente, mayor consumo de
  RAM. A esta escala no es problema.
- Inicialización al arrancar `MainLayout`, no al visitar el tab por
  primera vez. Mitigado cargando datos lazy en `initState`.

---

## ADR-005: Heatmap estilo GitHub para estadísticas

**Fecha**: 2026-03-20

### Contexto

La pantalla de estadísticas necesita mostrar el historial de actividad
del usuario de forma visual y motivadora, cubriendo varios meses.

### Decisión

**Heatmap de semanas × días** estilo contribution graph de GitHub: 16
semanas (~4 meses) con niveles de intensidad 0-4 según el porcentaje
de hábitos completados ese día.

### Alternativas descartadas

**Gráfica de barras (por día o semana)**
Tendencias claras en períodos cortos pero no permite ver 4 meses de un
vistazo. Comparar semanas distantes es difícil.

**Gráfica de líneas**
Útil para tendencias continuas (peso, distancia), menos intuitiva para
actividad discreta (hice / no hice el hábito).

**Calendario mensual clásico**
Muestra un mes completo con claridad pero requiere navegar mes a mes.
No da sensación de "cuánta actividad he tenido en los últimos meses" de
un vistazo.

**Lista de registros**
El menos visual.

### Razones de la decisión

1. **Densidad de información**: 16 semanas × 7 días = 112 días en una
   pantalla, sin scroll horizontal.
2. **Motivación visual**: ver los cuadrados acumularse es intrínsecamente
   motivador, en línea con *Atomic Habits* (no romper la cadena).
3. **Patrón reconocible**: el contribution graph de GitHub es
   ampliamente conocido por el público técnico.
4. **Escalable a múltiples hábitos**: heatmap global + heatmaps
   individuales por hábito en la misma pantalla.

### Consecuencias

- `HeatmapCalendar` se implementó desde cero (no se usó paquete externo)
  para tener control sobre colores, tamaños y la distinción entre
  `NO_COMPLETADO` y días futuros.
- El cálculo de `cellSize` con `LayoutBuilder` garantiza adaptación a
  cualquier ancho de pantalla.

---

## ADR-006: Extension `BuildContext` para SnackBars

**Fecha**: 2026-04-12

### Contexto

La app mostraba SnackBars en 4 pantallas con el mismo bloque de 8
líneas repetido ~20 veces. Cualquier cambio visual exigía editar todos
los bloques.

### Decisión

**Extension `SnackHelper` sobre `BuildContext`** en
`lib/core/utils/snack_helper.dart` con tres métodos:
`showSnackSuccess`, `showSnackError`, `showSnack`.

```dart
context.showSnackError(l10n.errorGenerico);
context.showSnackSuccess(l10n.habitoCompletado);
context.showSnack(l10n.perfilActualizado);
```

### Alternativas descartadas

**Método estático en clase utilitaria**
Más verboso (hay que pasar `context` explícitamente) y no sigue el
patrón idiomático de Flutter.

**Widget wrapper sobre Scaffold**
Excesivo: una capa de indirección innecesaria y obligaría a cambiar
todos los `Scaffold` del proyecto.

**Mantener los bloques repetidos**
Descartado.

### Razones de la decisión

1. **Único punto de control**: el estilo de los SnackBars de la app se
   define en un único archivo.
2. **Legibilidad**: `context.showSnackError(msg)` comunica la intención
   en una línea frente a 8.
3. **Patrón idiomático**: las extensiones sobre `BuildContext` son el
   mecanismo estándar para añadir utilidades contextuales en Flutter.

### Consecuencias

- Los tres métodos aceptan un parámetro `duration` opcional para casos
  específicos (1 segundo en toggles).
- Las llamadas en dialogs o bottom sheets usan el `context` del widget
  padre (acceso al `ScaffoldMessenger` correcto). Si se usa el `context`
  del builder del dialog, puede no encontrar el Scaffold.

---

## ADR-007: Online-only para acciones, tolerante a red para lectura

**Fecha**: 2026-05-10

### Contexto

GrowTogether es una app social: amigos, desafíos, ranking. Sin red el
componente social no tiene sentido. Pero abrir la app en el metro y ver
una pantalla vacía con "Error de conexión" da sensación de app rota.

### Decisión

**Política mixta**:

- **Lectura tolerante a red**: el dashboard cachea hábitos del día y el
  consejo del día en `SharedPreferences`. Sin red, la app abre y
  muestra los últimos datos vistos con un chip "Mostrando datos
  guardados · fecha". Banner rojo persistente arriba mientras no haya
  red (`ConnectivityProvider` + `connectivity_plus`).
- **Acciones online-only**: marcar hábito, crear, editar, etc. siguen
  fallando sin red con `SnackBar` de error. NO hay cola offline.

### Alternativas descartadas

**Sync offline completo (cola de operaciones)**
Implica reconciliación de IDs locales↔servidor, conflictos
multi-dispositivo, errores diferidos. Para un TFG es mucho curro y el
caso de uso es flojo: marcar un hábito puede esperar 2 minutos a que
vuelva el wifi.

**App estrictamente online-only**
La que había antes. Profesional y simple, pero la primera impresión sin
red era una pantalla vacía con error.

**App offline-first (BD local con `sqflite`/`hive`)**
Requiere replicar el modelo entero localmente y sincronizar. Para una
app social donde la fuente de verdad es el backend, no aporta valor
proporcional al coste.

### Razones de la decisión

1. **ROI alto**: pocas líneas de código (un provider, un helper de
   caché, un banner) para un cambio de percepción grande en defensa.
2. **Defensible en TFG**: "asumimos online por ser app social, pero
   gestionamos red caída con feedback claro al usuario y caché de
   lectura".
3. **Sin complejidad de sync**: cero reconciliación, cero IDs locales,
   cero conflictos.

### Consecuencias

- `lib/core/utils/dashboard_cache.dart` mantiene la serialización
  manual de `Habito` y `Consejo` (los modelos de DATA no exportan
  `toJson`).
- Solo cacheamos datos del día de hoy. Días pasados sin red muestran
  error (no creemos que merezca la pena).
- Si en el futuro DATA expone `toJson`, se puede simplificar el helper.

---

## ADR-008: Recordatorios locales con `flutter_local_notifications`

**Fecha**: 2026-05-10

### Contexto

Los hábitos necesitan recordatorios. Hay dos enfoques: notificaciones
push gestionadas por servidor (FCM) o notificaciones locales programadas
en el dispositivo.

### Decisión

**Notificaciones locales** con `flutter_local_notifications` 17.x. La
configuración del recordatorio (mensaje, hora, hábito) la persiste el
backend (entidad `Notificacion`); el cliente las descarga al login y
las programa localmente con el plugin. La frecuencia efectiva la
deriva del hábito asociado: DIARIO → una alarma diaria, PERSONALIZADO
→ hasta 7 alarmas semanales según `habito.diasSemana`.

### Alternativas descartadas

**FCM (Firebase Cloud Messaging)**
El estándar para notificaciones push en producción. Permite envío desde
servidor sin que la app esté abierta. Requiere setup completo de
Firebase, gestionar tokens de dispositivo en backend y un servicio que
empuje los recordatorios. Sobreingeniería para un TFG donde los
recordatorios siguen una hora fija decidida por el usuario.

**Solo persistir en backend, sin entrega real**
La opción inicial: el CRUD de notificaciones existía, pero no había
nada que las disparase en el dispositivo. Inservible para el usuario.

### Razones de la decisión

1. **Sin infraestructura adicional**: no requiere FCM ni servicio
   externo.
2. **Suficiente para el caso de uso**: el recordatorio es una hora
   fija decidida por el usuario, no un evento server-driven.
3. **Sincronización automática**: tras login, la app pide
   `GET /notificaciones/usuario` y reprograma todas las alarmas
   locales con `LocalNotificationsService.sincronizarConBackend`.
4. **Edición en cliente**: cuando el usuario edita un hábito (cambia
   frecuencia o días), `_resincronizarNotificaciones` reprograma las
   alarmas para que reflejen el nuevo plan.
5. **Logout limpio**: `PerfilProvider.cerrarSesion` cancela todas las
   notificaciones locales para que el siguiente usuario en el mismo
   móvil no reciba recordatorios del anterior.

### Consecuencias

- IDs locales únicos por (notificación + día) calculados como
  `notificacionId * 10 + diaIdx` para que cancelar/reprogramar no
  colisione entre días de un mismo recordatorio personalizado.
- Timezone hardcoded a `Europe/Madrid` (proyecto pensado para España).
  Si se internacionaliza, sustituir por `flutter_timezone` para
  detectar la zona del dispositivo.
- En Android 13+ se pide `POST_NOTIFICATIONS` en runtime con
  `permission_handler`. Si el usuario lo deniega permanentemente,
  ofrecemos abrir ajustes con `openAppSettings()`.
- Los receivers `ScheduledNotificationReceiver` y
  `ScheduledNotificationBootReceiver` están declarados en
  `AndroidManifest.xml` para que las alarmas sobrevivan a reinicios
  del dispositivo.
- En dispositivos OEM agresivos (Xiaomi, Huawei, Oppo) las alarmas
  pueden no llegar por matar de procesos. No solucionable a nivel
  código; mencionar en la memoria del TFG si aparece como issue.
