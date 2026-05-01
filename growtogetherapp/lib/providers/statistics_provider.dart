import 'package:flutter/foundation.dart';
import 'package:growtogether_data/growtogether_data.dart';

/// Provider de la pantalla de Estadisticas.
///
/// Carga todos los habitos del usuario y el historial de los ultimos
/// [diasHeatmap] dias de cada uno. A partir de ahi expone datos agregados
/// pensados para pintar un heatmap general, un heatmap por habito y las
/// metricas globales (mejores rachas, total de completados, etc).
class StatisticsProvider extends ChangeNotifier {
  final HabitoRepository _repo;
  final SecureStorageService _storage;

  /// Ventana de historial que cargamos para el heatmap.
  /// 16 semanas * 7 dias = 112 dias (aprox 4 meses).
  static const int diasHeatmap = 112;

  List<Habito> _habitos = [];
  final Map<int, List<RegistroHistorial>> _historialPorHabito = {};
  bool _cargando = true;
  String? _error;

  StatisticsProvider(this._repo, this._storage);

  // Getters
  List<Habito> get habitos => _habitos;
  Map<int, List<RegistroHistorial>> get historialPorHabito =>
      _historialPorHabito;
  bool get cargando => _cargando;
  String? get error => _error;
  bool get sinHabitos => !_cargando && _habitos.isEmpty;

  /// Fecha inicio del heatmap (hace [diasHeatmap] dias, sin hora).
  DateTime get fechaInicio {
    final hoy = _dateOnly(DateTime.now());
    return hoy.subtract(const Duration(days: diasHeatmap - 1));
  }

  DateTime get fechaFin => _dateOnly(DateTime.now());

  /// Historial concreto de un habito (vacia si no se ha cargado).
  List<RegistroHistorial> historialDe(int habitoId) =>
      _historialPorHabito[habitoId] ?? const [];

  /// Devuelve cuantos habitos se completaron cada dia del rango.
  /// La clave es la fecha normalizada a dia (year-month-day a las 00:00).
  Map<DateTime, int> get completadosPorDia {
    final result = <DateTime, int>{};
    for (final historial in _historialPorHabito.values) {
      for (final r in historial) {
        if (!r.completado) continue;
        final dia = _dateOnly(r.fecha);
        result[dia] = (result[dia] ?? 0) + 1;
      }
    }
    return result;
  }

  /// Nivel del heatmap global para una fecha: 0-4 segun porcentaje
  /// de habitos completados ese dia.
  int nivelGlobal(DateTime fecha) {
    if (_habitos.isEmpty) return 0;
    final completados = completadosPorDia[_dateOnly(fecha)] ?? 0;
    if (completados == 0) return 0;
    final ratio = completados / _habitos.length;
    if (ratio >= 0.85) return 4;
    if (ratio >= 0.6) return 3;
    if (ratio >= 0.35) return 2;
    return 1;
  }

  /// Nivel del heatmap individual para un habito y fecha: 0 (sin datos o
  /// no completado) o 4 (completado). Los estados NO_COMPLETADO se
  /// reflejan como nivel -1 para poder pintarlos en otro color.
  int nivelHabito(int habitoId, DateTime fecha) {
    final historial = _historialPorHabito[habitoId];
    if (historial == null) return 0;
    final dia = _dateOnly(fecha);
    for (final r in historial) {
      if (_esMismoDia(r.fecha, dia)) {
        if (r.completado) return 4;
        if (r.noCompletado) return -1;
        return 0;
      }
    }
    return 0;
  }

  /// Habitos ordenados por mejor racha (para el card "Records").
  List<Habito> get topRachas {
    final lista = List<Habito>.from(_habitos);
    lista.sort((a, b) {
      final cmp = b.rachaMaxima.compareTo(a.rachaMaxima);
      if (cmp != 0) return cmp;
      return b.rachaActual.compareTo(a.rachaActual);
    });
    return lista;
  }

  /// Total de completados en los dias del rango.
  int get totalCompletados {
    int total = 0;
    for (final historial in _historialPorHabito.values) {
      for (final r in historial) {
        if (r.completado) total++;
      }
    }
    return total;
  }

  /// Mejor racha de todas (entre todos los habitos).
  int get mejorRachaGlobal {
    if (_habitos.isEmpty) return 0;
    return _habitos
        .map((h) => h.rachaMaxima)
        .reduce((a, b) => a > b ? a : b);
  }

  /// Promedio de completados por dia en el rango.
  double get promedioDiario {
    if (_habitos.isEmpty) return 0;
    return totalCompletados / diasHeatmap;
  }

  /// Carga los habitos y todos sus historiales en paralelo.
  Future<void> cargar() async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      final userId = await _storage.getUserId();
      if (userId == null) {
        _habitos = [];
        _historialPorHabito.clear();
        _cargando = false;
        notifyListeners();
        return;
      }

      _habitos = await _repo.getHabitos(userId);
      _historialPorHabito.clear();

      final inicio = fechaInicio;
      final fin = fechaFin;

      // Una peticion por habito, todas en paralelo.
      await Future.wait(
        _habitos.map((h) async {
          try {
            final hist = await _repo.obtenerHistorial(
              h.id,
              fechaInicio: inicio,
              fechaFin: fin,
            );
            _historialPorHabito[h.id] = hist;
          } catch (_) {
            _historialPorHabito[h.id] = const [];
          }
        }),
      );

      _cargando = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _cargando = false;
      notifyListeners();
    }
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static bool _esMismoDia(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
