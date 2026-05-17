# GrowTogether — App móvil

App de seguimiento de hábitos con componente social. Proyecto final de DAM 2026 — Jordi Patuel Pons.

Inspirada en *Atomic Habits* de James Clear: construye hábitos consistentes, visualiza tu progreso y compite con amigos en desafíos.

---

## Stack

| Capa | Tecnología |
|------|-----------|
| Framework | Flutter 3.27+ (Dart 3.10+) |
| State management | Provider 6.x (`ChangeNotifier` + `MultiProvider`) |
| Capa de datos | Paquete `growtogether_data` v0.5.0 (referenciado por git, compartido con el panel admin) |
| HTTP | Dio 5.x con interceptor JWT *(vía `growtogether_data`)* |
| Almacenamiento seguro | `flutter_secure_storage` 9.x *(vía `growtogether_data`)* |
| Conectividad | `connectivity_plus` 6.x (banner sin red) |
| Notificaciones locales | `flutter_local_notifications` 17.x + `permission_handler` 11.x |
| Imágenes | `image_picker` 1.x (cámara / galería) |
| Efectos visuales | `confetti` 0.7.x (celebración día completo) |
| i18n | Flutter ARB (es / en / ca) |

---

## Requisitos previos

- Flutter SDK 3.27+ con Dart 3.10+ ([instalación](https://docs.flutter.dev/get-started/install))
- Android Studio o VS Code con extensión Flutter
- Dispositivo Android (API 23+) o emulador
- **GrowTogetherAPI** corriendo en puerto 8081 (ver su README)

Verifica la instalación:

```bash
flutter doctor
```

---

## Instalación

```bash
# 1. Clona el repositorio
git clone <url-del-repo>
cd GrowTogetherAPP/growtogetherapp

# 2. Instala dependencias
flutter pub get

# 3. Genera los archivos de localización
flutter gen-l10n
```

---

## Configuración

La URL base de la API se inyecta en compile time vía `--dart-define=API_URL=...`.
El `main.dart` la lee con `ApiConfig.fromEnv(fallback: 'http://localhost:8081/api/v1')`,
así que sin flag se usa el fallback de localhost.

| Escenario | Comando |
|---|---|
| Emulador Android (default) | `flutter run --dart-define=API_URL=http://10.0.2.2:8081/api/v1` |
| Dispositivo físico (USB + adb reverse) | `adb reverse tcp:8081 tcp:8081 && flutter run` |
| Dispositivo en LAN | `flutter run --dart-define=API_URL=http://192.168.X.X:8081/api/v1` |
| Chrome (web) | `flutter run -d chrome --dart-define=API_URL=http://localhost:8081/api/v1` |

---

## Ejecución

```bash
# Listar dispositivos disponibles
flutter devices

# Lanzar en un dispositivo concreto
flutter run -d <device-id>

# Lanzar en Chrome (web)
flutter run -d chrome
```

---

## Credenciales de prueba

| Rol | Email | Contraseña |
|-----|-------|-----------|
| Admin | admin@growtogether.com | Prueba123 |
| Usuario estándar | usuario@growtogether.com | Prueba123 |

---

## Estructura del proyecto

```
lib/
├── main.dart                    # MultiProvider + MaterialApp + bootstrap de repos
├── core/
│   ├── feedback/                # FeedbackController + FeedbackService (vibración + animaciones)
│   ├── l10n/                    # Controlador de idioma (ValueNotifier)
│   ├── theme/                   # 4 temas + controlador (ValueNotifier)
│   └── utils/                   # Validadores, iconos de hábitos, colores de desafíos, snack helper, dashboard cache
├── providers/                   # ChangeNotifiers (Auth, Habitos, DetalleHabito, Perfil, Statistics, Amistad, Desafios, Notificaciones, Connectivity, DetalleDesafio)
├── services/                    # Servicios de capa OS (LocalNotificationsService sobre flutter_local_notifications)
├── screens/                     # Pantallas
│   └── widgets/                 # Widgets reutilizables (HeatmapCalendar, ProgressPainters, MultilineChart, etc.)
└── l10n/                        # ARB generados por flutter gen-l10n
```

> Los modelos, el cliente HTTP (Dio + interceptor JWT), el almacenamiento seguro
> y los repositorios viven en el paquete `growtogether_data` (referenciado por
> git ref desde GitHub, ver `pubspec.yaml`). Es el mismo paquete que consume el
> panel admin web, así garantizamos un único contrato con la API.

---

## Funcionalidades implementadas

- **Autenticación**: registro, login, cierre de sesión, cambio de contraseña con invalidación de token
- **Hábitos**: crear, editar, eliminar, marcar/desmarcar por fecha, historial interactivo
- **Hábitos PERSONALIZADO**: soporte para días de la semana específicos (lunes, miércoles, viernes…)
- **Rachas**: cálculo de racha actual y máxima, diferenciado para hábitos diarios y personalizados
- **Estadísticas**: heatmap general + por hábito (16 semanas), récords de racha, métricas globales
- **Perfil**: foto de perfil (cámara/galería), editar nombre y email, 4 temas de color, 3 idiomas
- **i18n**: español, inglés y catalán con sincronización de preferencias en servidor
- **Consejo del día**: el dashboard muestra el consejo asignado a la fecha de hoy
  desde la API (`GET /usuarios/consejo/hoy`). Lo gestiona el panel admin, no
  está hardcoded.
- **Recordatorios locales**: cada hábito puede tener un recordatorio que se programa
  como notificación local con `flutter_local_notifications`. La configuración vive en
  el backend; al login la app reprograma todas las alarmas según el hábito asociado
  (diario o días específicos).
- **Tolerancia a red**: banner persistente cuando se pierde la conexión y caché
  del dashboard (hábitos del día + consejo) en `SharedPreferences`. Las acciones
  siguen requiriendo conexión, las lecturas se sirven del caché si la API falla.

---

## Temas disponibles

| Nombre | Descripción |
|--------|------------|
| Claro | Fondo blanco, acentos rosa/lavanda |
| Oscuro | Fondo negro, acentos teal/cyan |
| Morado | Gradiente púrpura-azul, acentos naranja |
| Naturaleza | Gradiente verde-dorado, acentos tierra |

El tema e idioma se sincronizan con el servidor y se restauran en cada inicio de sesión.

---

## Tests

```bash
flutter test
```

Cobertura actual: 42 tests entre unitarios y de widget. Cubren los 10 providers (Auth, Habitos, DetalleHabito, Perfil, Statistics, Amistad, Desafios, DetalleDesafio, Notificaciones), los validadores de formularios (`Validators`) y las pantallas de login y registro.

---

## Generar documentación API

```bash
dart doc .
```

Salida en `doc/api/`. Por defecto está incluida en `.gitignore` (quita la línea
`**/doc/api/` si quieres versionarla o publicarla a GitHub Pages).

---

## Decisiones de arquitectura

Las decisiones técnicas (Flutter vs React Native, Provider vs Bloc,
Navigator vs GoRouter, política offline, recordatorios locales…) están
documentadas en [`docs/DECISIONS.md`](docs/DECISIONS.md). Las del
paquete de datos compartido viven en `GrowTogetherDATA/docs/DECISIONS.md`
y las del backend en `GrowTogetherAPI/docs/DECISIONS.md`.
