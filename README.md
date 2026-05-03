# GrowTogether — App móvil

App de seguimiento de hábitos con componente social. Proyecto final de DAM 2026 — Jordi Patuel Pons.

Inspirada en *Atomic Habits* de James Clear: construye hábitos consistentes, visualiza tu progreso y compite con amigos en desafíos.

---

## Stack

| Capa | Tecnología |
|------|-----------|
| Framework | Flutter 3.x + Dart |
| State management | Provider 6.x (ChangeNotifier) |
| HTTP | Dio 5.x + interceptor JWT |
| Capa de datos | Paquete local `growtogether_data` (compartido con el panel admin) |
| Almacenamiento seguro | flutter_secure_storage 9.x |
| Imágenes | image_picker |
| i18n | Flutter ARB (es / en / ca) |

---

## Requisitos previos

- Flutter SDK 3.19+ ([instalación](https://docs.flutter.dev/get-started/install))
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
│   ├── constants/scoring.dart   # Puntos por hábito completado
│   ├── l10n/                    # Controlador de idioma (ValueNotifier)
│   ├── theme/                   # 4 temas + controlador (ValueNotifier)
│   └── utils/                   # Validadores, iconos de hábitos, colores de desafíos, snack helper
├── providers/                   # ChangeNotifiers (Auth, Habitos, DetalleHabito, Perfil, Statistics, Amistad, Desafios)
├── screens/                     # Pantallas
│   └── widgets/                 # Widgets reutilizables (HeatmapCalendar, ProgressPainters, etc.)
└── l10n/                        # ARB generados por flutter gen-l10n
```

> Los modelos, el cliente HTTP (Dio + interceptor JWT), el almacenamiento seguro
> y los repositorios viven en el paquete local `growtogether_data` (referenciado
> por path desde `pubspec.yaml`). Es el mismo paquete que consume el panel admin
> web, así garantizamos un único contrato con la API.

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

Cobertura actual: 24 tests unitarios sobre `AuthProvider`, `HabitosProvider` y `PerfilProvider`.

---

## Generar documentación API

```bash
dart doc .
```

Salida en `doc/api/`. Por defecto está incluida en `.gitignore` (quita la línea
`**/doc/api/` si quieres versionarla o publicarla a GitHub Pages).

---

## Decisiones de arquitectura

Las decisiones técnicas del proyecto (Flutter vs React Native, Provider vs Bloc, Navigator vs GoRouter, etc.) están documentadas en los Architecture Decision Records (ADRs), que se publicarán junto al proyecto en la entrega final.
