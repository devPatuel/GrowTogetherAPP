import 'package:flutter/foundation.dart';
import 'package:growtogether_data/growtogether_data.dart';
import '../services/local_notifications_service.dart';

/// Estado y operaciones del recordatorio de un habito concreto.
///
/// MVP: 1 recordatorio por habito. Por eso el provider expone una sola
/// [Notificacion] (la primera del backend) en lugar de una lista. Cualquier
/// cambio se sincroniza tambien con el plugin de notificaciones locales.
class NotificacionesProvider extends ChangeNotifier {
  final NotificacionRepository _repo;
  final LocalNotificationsService _local;

  Notificacion? _recordatorio;
  bool _cargando = false;
  String? _error;

  NotificacionesProvider(this._repo, this._local);

  Notificacion? get recordatorio => _recordatorio;
  bool get cargando => _cargando;
  String? get error => _error;

  /// Carga el recordatorio existente del habito (o null si no hay) y lo deja
  /// en el estado del provider.
  Future<void> cargar(int habitoId) async {
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      final lista = await _repo.listarPorHabito(habitoId);
      _recordatorio = lista.isEmpty ? null : lista.first;
    } on ApiException catch (e) {
      _error = e.message;
    }
    _cargando = false;
    notifyListeners();
  }

  /// Crea o actualiza el recordatorio del habito y reprograma la notificacion
  /// local. Devuelve true si la operacion fue OK.
  Future<bool> guardar({
    required Habito habito,
    required String mensaje,
    required int hora,
    required int minuto,
    required bool activa,
  }) async {
    _error = null;
    notifyListeners();
    try {
      final frecuencia = habito.frecuencia;
      Notificacion guardada;
      if (_recordatorio == null) {
        guardada = await _repo.crear(
          habitoId: habito.id,
          mensaje: mensaje,
          hora: hora,
          minuto: minuto,
          frecuencia: frecuencia,
          activa: activa,
        );
      } else {
        guardada = await _repo.actualizar(
          _recordatorio!.id,
          habitoId: habito.id,
          mensaje: mensaje,
          hora: hora,
          minuto: minuto,
          frecuencia: frecuencia,
          activa: activa,
        );
      }
      _recordatorio = guardada;
      await _local.cancelar(guardada.id);
      if (guardada.activa) {
        await _local.programar(guardada, habito);
      }
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  /// Borra el recordatorio del habito y cancela la notificacion local.
  Future<bool> eliminar() async {
    final actual = _recordatorio;
    if (actual == null) return true;
    _error = null;
    notifyListeners();
    try {
      await _repo.eliminar(actual.id);
      await _local.cancelar(actual.id);
      _recordatorio = null;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }
}
