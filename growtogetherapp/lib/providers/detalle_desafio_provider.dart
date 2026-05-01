import 'package:flutter/foundation.dart';
import '../data/models/desafio.dart';
import '../data/models/participante_desafio.dart';
import '../data/models/registro_desafio.dart';
import '../data/repositories/desafio_repository.dart';

class DetalleDesafioProvider extends ChangeNotifier {
  final DesafioRepository _repo;
  final int _usuarioActualId;

  Desafio _desafio;
  List<RegistroDesafio> _historial = [];
  bool _cargandoHistorial = true;
  bool _toggling = false;
  bool _huboCambios = false;
  bool _disposed = false;

  DetalleDesafioProvider(this._repo, this._desafio, this._usuarioActualId) {
    cargarHistorial();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _notify() {
    if (_disposed) return;
    notifyListeners();
  }

  Desafio get desafio => _desafio;
  List<RegistroDesafio> get historial => _historial;
  bool get cargandoHistorial => _cargandoHistorial;
  bool get toggling => _toggling;
  bool get huboCambios => _huboCambios;
  int get usuarioActualId => _usuarioActualId;

  /// Participación del usuario actual en este desafío. Null si no participa.
  ParticipanteDesafio? get yo => _desafio.participacionDe(_usuarioActualId);

  /// Indica si el usuario actual es el creador del desafío.
  bool get soyCreador => _desafio.creadorId == _usuarioActualId;

  Future<void> recargar() async {
    try {
      _desafio = await _repo.obtenerDesafio(_desafio.id);
      _notify();
    } catch (_) {
      // Mantener desafío anterior si falla
    }
  }

  Future<void> cargarHistorial() async {
    _cargandoHistorial = true;
    _notify();
    try {
      _historial = await _repo.obtenerHistorial(
        _desafio.id,
        fechaInicio: _desafio.fechaInicio,
        fechaFin: _desafio.fechaFin,
      );
    } catch (_) {
      // Mantener historial anterior si falla
    }
    _cargandoHistorial = false;
    _notify();
  }

  /// Marca el desafío como hecho hoy (o lo desmarca si ya estaba).
  /// Optimistic update: cambia el estado local primero, luego sincroniza.
  Future<bool> toggleCompletarHoy() async {
    if (_toggling) return false;
    final yoActual = yo;
    if (yoActual == null) return false;
    _toggling = true;
    _notify();

    final desafioOriginal = _desafio;
    final yaCompletado = yoActual.completadoHoy;
    try {
      if (yaCompletado) {
        await _repo.descompletarDesafio(_desafio.id);
      } else {
        await _repo.completarDesafio(_desafio.id);
      }
      // Recargar todo para tener racha y puntos consistentes con backend
      _desafio = await _repo.obtenerDesafio(_desafio.id);
      _huboCambios = true;
      _toggling = false;
      _notify();
      cargarHistorial();
      return true;
    } catch (_) {
      _desafio = desafioOriginal;
      _toggling = false;
      _notify();
      return false;
    }
  }

  Future<bool> editar({
    String? nombre,
    String? descripcion,
    String? frecuencia,
    Set<String>? diasSemana,
    String? tipo,
    String? icono,
    DateTime? fechaFin,
  }) async {
    try {
      _desafio = await _repo.editarDesafio(
        _desafio.id,
        nombre: nombre,
        descripcion: descripcion,
        frecuencia: frecuencia,
        diasSemana: diasSemana,
        tipo: tipo,
        icono: icono,
        fechaFin: fechaFin,
      );
      _huboCambios = true;
      _notify();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> eliminar() async {
    try {
      await _repo.eliminarDesafio(_desafio.id);
      _huboCambios = true;
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> abandonar() async {
    try {
      await _repo.abandonarDesafio(_desafio.id);
      _huboCambios = true;
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Devuelve un mapa usuarioId → lista de puntos acumulados por día desde fechaInicio
  /// hasta min(hoy, fechaFin). Usado por la gráfica multilínea.
  Map<int, List<double>> seriesPorParticipante() {
    final fechaTope = DateTime.now().isBefore(_desafio.fechaFin)
        ? DateTime.now()
        : _desafio.fechaFin;
    final inicio = DateTime(_desafio.fechaInicio.year, _desafio.fechaInicio.month, _desafio.fechaInicio.day);
    final tope = DateTime(fechaTope.year, fechaTope.month, fechaTope.day);
    final dias = tope.difference(inicio).inDays + 1;
    if (dias <= 0) return {};

    final Map<int, List<double>> resultado = {};
    for (final p in _desafio.participantes) {
      resultado[p.usuarioId] = List<double>.filled(dias, 0);
    }
    // Acumular puntos de cada participante por día
    final ordenado = List<RegistroDesafio>.from(_historial)
      ..sort((a, b) => a.fecha.compareTo(b.fecha));
    for (final reg in ordenado) {
      if (reg.estado != 'COMPLETADO') continue;
      final indice = DateTime(reg.fecha.year, reg.fecha.month, reg.fecha.day)
          .difference(inicio)
          .inDays;
      if (indice < 0 || indice >= dias) continue;
      final serie = resultado[reg.usuarioId];
      if (serie == null) continue;
      // Sumar puntos a todas las posiciones desde indice hacia adelante (acumulado)
      final puntos = reg.puntosGanados.toDouble();
      for (int i = indice; i < dias; i++) {
        serie[i] += puntos;
      }
    }
    return resultado;
  }
}
