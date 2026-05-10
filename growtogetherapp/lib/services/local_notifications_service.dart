import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:growtogether_data/growtogether_data.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Resultado de pedir los permisos de notificaciones al usuario.
///
/// Distinguimos entre denegado normal (donde se puede volver a pedir el
/// permiso) y denegado permanentemente (Android marca el permiso como
/// "no volver a preguntar" y la unica salida es ir a ajustes).
enum PermisoNotificacionEstado {
  concedido,
  denegado,
  denegadoPermanentemente,
}

/// Servicio que envuelve flutter_local_notifications para programar los
/// recordatorios de habitos en el dispositivo.
///
/// Las notificaciones viven en el backend (entidad Notificacion). Este servicio
/// solo se encarga de:
/// - Inicializar el plugin nativo y la zona horaria.
/// - Pedir los permisos de Android (POST_NOTIFICATIONS y SCHEDULE_EXACT_ALARM).
/// - Traducir cada Notificacion + Habito a una o varias entradas programadas
///   segun la frecuencia (DIARIO o por dias de la semana).
///
/// Para que los IDs no colisionen entre dias de un mismo recordatorio personalizado,
/// el id local que se pasa al plugin se calcula como `notificacionId * 10 + diaIdx`,
/// usando 0 para los recordatorios diarios.
class LocalNotificationsService {
  static const String _channelId = 'recordatorios_habitos';
  static const String _channelName = 'Recordatorios de habitos';
  static const String _channelDesc =
      'Avisos para no olvidarte de tus habitos diarios';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _inicializado = false;

  /// Inicializa el plugin y la base de datos de zonas horarias. Debe llamarse
  /// una sola vez antes de runApp en main.dart.
  Future<void> inicializar() async {
    if (_inicializado) return;
    tz.initializeTimeZones();
    // Hardcodeamos Europe/Madrid: GrowTogether es una app pensada para Espana
    // en la entrega DAM. Si en el futuro se internacionaliza, sustituir por
    // flutter_timezone para detectar la zona del dispositivo.
    tz.setLocalLocation(tz.getLocation('Europe/Madrid'));

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _plugin.initialize(initSettings);
    _inicializado = true;
  }

  /// Pide al usuario los permisos necesarios para mostrar y programar
  /// notificaciones exactas.
  ///
  /// Distingue tres casos para que la UI pueda reaccionar:
  /// - [PermisoNotificacionEstado.concedido] → todo OK
  /// - [PermisoNotificacionEstado.denegado] → el usuario rechazo, se puede
  ///   volver a preguntar la proxima vez
  /// - [PermisoNotificacionEstado.denegadoPermanentemente] → Android marco
  ///   "no volver a preguntar". Hay que mandar al usuario a ajustes con
  ///   [abrirAjustes] para que lo cambie a mano.
  ///
  /// Solo bloqueamos por POST_NOTIFICATIONS: SCHEDULE_EXACT_ALARM se
  /// considera best-effort porque en algunos dispositivos no se puede
  /// otorgar (queda en denegado para siempre) y no queremos romper el flujo.
  Future<PermisoNotificacionEstado> pedirPermisos() async {
    final post = await Permission.notification.request();
    await Permission.scheduleExactAlarm.request();
    if (post.isGranted) return PermisoNotificacionEstado.concedido;
    if (post.isPermanentlyDenied) {
      return PermisoNotificacionEstado.denegadoPermanentemente;
    }
    return PermisoNotificacionEstado.denegado;
  }

  /// Abre la pantalla de ajustes de la app del sistema para que el usuario
  /// pueda cambiar manualmente los permisos denegados permanentemente.
  Future<void> abrirAjustes() async {
    await openAppSettings();
  }

  /// Programa una notificacion local (o varias, si la frecuencia es por dias
  /// de la semana). Si la notificacion no esta activa, no se programa.
  Future<void> programar(Notificacion notificacion, Habito habito) async {
    if (!notificacion.activa) return;

    final esPersonalizado =
        habito.frecuencia == 'PERSONALIZADO' && habito.diasSemana.isNotEmpty;

    if (!esPersonalizado) {
      await _programarDiario(notificacion, habito);
      return;
    }

    for (final dia in habito.diasSemana) {
      final diaSemana = _diaSemanaToInt(dia);
      if (diaSemana == null) continue;
      await _programarSemanal(notificacion, habito, diaSemana);
    }
  }

  /// Cancela todas las entradas programadas asociadas a una notificacion (las 7
  /// posibles + la diaria) sin tener que conocer la frecuencia anterior.
  Future<void> cancelar(int notificacionId) async {
    await _plugin.cancel(_idLocal(notificacionId, 0));
    for (var d = 1; d <= 7; d++) {
      await _plugin.cancel(_idLocal(notificacionId, d));
    }
  }

  /// Cancela todas las notificaciones programadas. Usado al cerrar sesion o
  /// antes de re-sincronizar.
  Future<void> cancelarTodas() async {
    await _plugin.cancelAll();
  }

  /// Reemplaza el conjunto de notificaciones locales por las recibidas del
  /// backend. Cancela todo y reprograma las activas. Pensado para llamar tras
  /// login o auto-login con la lista del endpoint /notificaciones/usuario.
  Future<void> sincronizarUsuario(
    List<Notificacion> notificaciones,
    List<Habito> habitos,
  ) async {
    await cancelarTodas();
    final habitosPorId = {for (final h in habitos) h.id: h};
    for (final n in notificaciones) {
      final habito = habitosPorId[n.habitoId];
      if (habito == null) continue;
      await programar(n, habito);
    }
  }

  /// Helper que descarga notificaciones y habitos del backend en paralelo y
  /// reprograma todo. Silencioso ante errores: si la red falla, las notificaciones
  /// locales previas siguen vigentes hasta el proximo intento.
  Future<void> sincronizarConBackend({
    required NotificacionRepository notificacionRepo,
    required HabitoRepository habitoRepo,
    required int usuarioId,
  }) async {
    try {
      final results = await Future.wait([
        notificacionRepo.listarDelUsuarioAutenticado(),
        habitoRepo.getHabitos(usuarioId),
      ]);
      final notificaciones = results[0] as List<Notificacion>;
      final habitos = results[1] as List<Habito>;
      await sincronizarUsuario(notificaciones, habitos);
    } catch (_) {
      // Silencioso: si falla la sincronizacion no debe romper el login.
    }
  }

  Future<void> _programarDiario(Notificacion n, Habito habito) async {
    await _plugin.zonedSchedule(
      _idLocal(n.id, 0),
      habito.nombre,
      n.mensaje,
      _proximaInstancia(n.hora, n.minuto),
      _detallesAndroid(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> _programarSemanal(
    Notificacion n,
    Habito habito,
    int diaSemana,
  ) async {
    await _plugin.zonedSchedule(
      _idLocal(n.id, diaSemana),
      habito.nombre,
      n.mensaje,
      _proximaInstanciaEnDia(n.hora, n.minuto, diaSemana),
      _detallesAndroid(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  NotificationDetails _detallesAndroid() => const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.high,
          priority: Priority.high,
        ),
      );

  /// Devuelve la primera instancia de hora:minuto que sea posterior a ahora.
  tz.TZDateTime _proximaInstancia(int hora, int minuto) {
    final ahora = tz.TZDateTime.now(tz.local);
    var fecha = tz.TZDateTime(tz.local, ahora.year, ahora.month, ahora.day, hora, minuto);
    if (!fecha.isAfter(ahora)) {
      fecha = fecha.add(const Duration(days: 1));
    }
    return fecha;
  }

  /// Devuelve la primera instancia de hora:minuto en el dia de la semana indicado
  /// (1 = lunes, 7 = domingo) que sea posterior a ahora.
  tz.TZDateTime _proximaInstanciaEnDia(int hora, int minuto, int diaSemana) {
    var fecha = _proximaInstancia(hora, minuto);
    while (fecha.weekday != diaSemana) {
      fecha = fecha.add(const Duration(days: 1));
    }
    return fecha;
  }

  int _idLocal(int notificacionId, int diaSemana) =>
      notificacionId * 10 + diaSemana;

  int? _diaSemanaToInt(String dia) {
    switch (dia.toUpperCase()) {
      case 'LUNES':
        return DateTime.monday;
      case 'MARTES':
        return DateTime.tuesday;
      case 'MIERCOLES':
      case 'MIÉRCOLES':
        return DateTime.wednesday;
      case 'JUEVES':
        return DateTime.thursday;
      case 'VIERNES':
        return DateTime.friday;
      case 'SABADO':
      case 'SÁBADO':
        return DateTime.saturday;
      case 'DOMINGO':
        return DateTime.sunday;
      default:
        return null;
    }
  }
}
