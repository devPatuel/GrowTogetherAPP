import 'package:flutter/foundation.dart';
import 'package:growtogether_data/growtogether_data.dart';

class DetalleHabitoProvider extends ChangeNotifier {
  final HabitoRepository _repo;

  Habito _habito;
  List<RegistroHistorial> _historial = [];
  late DateTime _mesActual;
  bool _cargandoHistorial = true;
  bool _toggling = false;
  bool _huboCambios = false;

  DetalleHabitoProvider(this._repo, this._habito) {
    final now = DateTime.now();
    _mesActual = DateTime(now.year, now.month);
    cargarHistorial();
  }

  // Getters
  Habito get habito => _habito;
  List<RegistroHistorial> get historial => _historial;
  DateTime get mesActual => _mesActual;
  bool get cargandoHistorial => _cargandoHistorial;
  bool get toggling => _toggling;
  bool get huboCambios => _huboCambios;

  Future<void> cargarHistorial() async {
    _cargandoHistorial = true;
    notifyListeners();
    try {
      final inicio = DateTime(_mesActual.year, _mesActual.month, 1);
      final fin = DateTime(_mesActual.year, _mesActual.month + 1, 0);
      _historial = await _repo.obtenerHistorial(
        _habito.id,
        fechaInicio: inicio,
        fechaFin: fin,
      );
    } catch (_) {
      // Mantener historial anterior si falla
    }
    _cargandoHistorial = false;
    notifyListeners();
  }

  Future<bool> toggleCompletar({DateTime? fecha}) async {
    if (_toggling) return false;
    _toggling = true;
    notifyListeners();

    try {
      final esHoy = fecha == null || _esMismoDia(fecha, DateTime.now());
      final estaCompletado = esHoy
          ? _habito.completadoHoy
          : _historial.any((r) =>
              _esMismoDia(r.fecha, fecha) && r.estado == 'COMPLETADO');

      if (estaCompletado) {
        _habito = await _repo.descompletarHabito(_habito.id, fecha: fecha);
      } else {
        _habito = await _repo.completarHabito(_habito.id, fecha: fecha);
      }
      _huboCambios = true;
      _toggling = false;
      notifyListeners();
      cargarHistorial();
      return true;
    } catch (_) {
      _toggling = false;
      notifyListeners();
      return false;
    }
  }

  bool estaCompletadoEnFecha(DateTime fecha) {
    return _historial.any((r) =>
        _esMismoDia(r.fecha, fecha) && r.estado == 'COMPLETADO');
  }

  String estadoEnFecha(DateTime fecha) {
    final reg = _historial.where((r) => _esMismoDia(r.fecha, fecha));
    if (reg.isEmpty) return 'PENDIENTE';
    return reg.first.estado;
  }

  /// Establece explicitamente el estado de un dia pasado.
  /// - 'COMPLETADO'    → llama completarHabito
  /// - 'NO_COMPLETADO' → llama descompletarHabito + actualiza historial local
  /// - 'PENDIENTE'     → llama descompletarHabito + elimina del historial local
  Future<bool> setEstado(DateTime fecha, String nuevoEstado) async {
    if (_toggling) return false;
    _toggling = true;
    notifyListeners();

    try {
      if (nuevoEstado == 'COMPLETADO') {
        _habito = await _repo.completarHabito(_habito.id, fecha: fecha);
      } else {
        _habito = await _repo.descompletarHabito(_habito.id, fecha: fecha);
      }
      _huboCambios = true;

      // Actualizar historial local de forma optimista
      _historial.removeWhere((r) => _esMismoDia(r.fecha, fecha));
      if (nuevoEstado != 'PENDIENTE') {
        _historial.add(RegistroHistorial(fecha: fecha, estado: nuevoEstado));
      }

      _toggling = false;
      notifyListeners();
      cargarHistorial(); // Sincronizar con el servidor en background
      return true;
    } catch (_) {
      _toggling = false;
      notifyListeners();
      return false;
    }
  }

  static bool _esMismoDia(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Future<bool> editarHabito({
    required String nombre,
    required String descripcion,
    required String frecuencia,
    Set<String>? diasSemana,
    required String tipo,
    String? icono,
  }) async {
    try {
      _habito = await _repo.editarHabito(
        _habito.id,
        nombre: nombre,
        descripcion: descripcion,
        frecuencia: frecuencia,
        diasSemana: frecuencia == 'PERSONALIZADO' ? diasSemana : null,
        tipo: tipo,
        icono: icono,
      );
      _huboCambios = true;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> eliminarHabito() async {
    try {
      await _repo.eliminarHabito(_habito.id);
      _huboCambios = true;
      return true;
    } catch (_) {
      return false;
    }
  }

  void mesSiguiente() {
    final now = DateTime.now();
    if (_mesActual.year == now.year && _mesActual.month == now.month) return;
    _mesActual = DateTime(_mesActual.year, _mesActual.month + 1);
    cargarHistorial();
  }

  void mesAnterior() {
    _mesActual = DateTime(_mesActual.year, _mesActual.month - 1);
    cargarHistorial();
  }
}
