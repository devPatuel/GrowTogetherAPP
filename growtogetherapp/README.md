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

La URL base de la API se configura en `lib/core/config/api_config.dart`:

```dart
// Emulador Android
static const String baseUrl = 'http://10.0.2.2:8081/api/v1';

// Dispositivo físico con túnel USB (recomendado)
// static const String baseUrl = 'http://localhost:8081/api/v1';

// Dispositivo físico en la misma red WiFi
// static const String baseUrl = 'http://192.168.X.X:8081/api/v1';

// Web
// static const String baseUrl = 'http://localhost:8081/api/v1';
```

### Dispositivo físico por USB (recomendado para desarrollo)

```bash
# Crea un túnel para que el móvil acceda al localhost del PC
adb reverse tcp:8081 tcp:8081

# Lanza la app
flutter run
```

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
├── main.dart                    # MultiProvider + MaterialApp
├── core/
│   ├── config/api_config.dart   # URL base y timeouts
│   ├── constants/               # Tips diarios por idioma
│   ├── l10n/                    # Controlador de idioma (ValueNotifier)
│   ├── theme/                   # 4 temas + controlador (ValueNotifier)
│   └── utils/                   # Validadores, iconos de hábitos, snack helper
├── data/
│   ├── api/                     # DioClient + AuthInterceptor (inyección JWT + gestión 401)
│   ├── local/                   # SecureStorageService (token, userId, nombre, email)
│   ├── models/                  # Usuario, Habito, RegistroHistorial
│   └── repositories/            # AuthRepository, HabitoRepository, UserRepository
├── providers/                   # ChangeNotifiers (Auth, Habitos, DetalleHabito, Perfil, Statistics)
├── screens/                     # Pantallas
│   └── widgets/                 # Widgets reutilizables (HeatmapCalendar, ProgressPainters, etc.)
└── l10n/                        # ARB generados por flutter gen-l10n
```

---

## Funcionalidades implementadas

- **Autenticación**: registro, login, cierre de sesión, cambio de contraseña con invalidación de token
- **Hábitos**: crear, editar, eliminar, marcar/desmarcar por fecha, historial interactivo
- **Hábitos PERSONALIZADO**: soporte para días de la semana específicos (lunes, miércoles, viernes…)
- **Rachas**: cálculo de racha actual y máxima, diferenciado para hábitos diarios y personalizados
- **Estadísticas**: heatmap general + por hábito (16 semanas), récords de racha, métricas globales
- **Perfil**: foto de perfil (cámara/galería), editar nombre y email, 4 temas de color, 3 idiomas
- **i18n**: español, inglés y catalán con sincronización de preferencias en servidor

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

## Decisiones de arquitectura

Las decisiones técnicas del proyecto (Flutter vs React Native, Provider vs Bloc, Navigator vs GoRouter, etc.) están documentadas en los Architecture Decision Records (ADRs), que se publicarán junto al proyecto en la entrega final.
