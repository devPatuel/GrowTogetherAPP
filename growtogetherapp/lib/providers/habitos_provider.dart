import 'package:flutter/foundation.dart';
import '../data/models/habito.dart';
import '../data/repositories/habito_repository.dart';
import '../data/local/secure_storage_service.dart';

class HabitosProvider extends ChangeNotifier {
  final HabitoRepository _repo;
  final SecureStorageService _storage;

  List<Habito> _habitos = [];
  bool _cargando = true;
  String? _error;
  late DateTime _fechaSeleccionada;

  HabitosProvider(this._repo, this._storage) {
    final now = DateTime.now();
    _fechaSeleccionada = DateTime(now.year, now.month, now.day);
  }

  // Mapeo DateTime.weekday (1=Lun, 7=Dom) → nombre usado en la app y la API
  static const _weekdayNames = [
    'LUNES', 'MARTES', 'MIERCOLES', 'JUEVES', 'VIERNES', 'SABADO', 'DOMINGO',
  ];

  // Getters
  /// Habitos filtrados por dia de la semana:
  /// los PERSONALIZADO solo aparecen si el dia seleccionado esta en su lista.
  List<Habito> get habitos {
    final weekdayStr = _weekdayNames[_fechaSeleccionada.weekday - 1];
    return _habitos.where((h) {
      if (h.frecuencia != 'PERSONALIZADO') return true;
      return h.diasSemana.contains(weekdayStr);
    }).toList();
  }

  bool get cargando => _cargando;
  String? get error => _error;
  DateTime get fechaSeleccionada => _fechaSeleccionada;

  bool get esHoy {
    final now = DateTime.now();
    return _fechaSeleccionada.year == now.year &&
        _fechaSeleccionada.month == now.month &&
        _fechaSeleccionada.day == now.day;
  }

  int get completados => habitos.where((h) => h.completadoHoy).length;
  double get progreso {
    final h = habitos;
    return h.isEmpty ? 0 : h.where((x) => x.completadoHoy).length / h.length;
  }

  /// Carga los habitos del usuario para la fecha seleccionada
  Future<void> cargar() async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      final userId = await _storage.getUserId();
      if (userId == null) return;
      final fecha = esHoy ? null : _fechaSeleccionada;
      _habitos = await _repo.getHabitos(userId, fecha: fecha);
      _cargando = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _cargando = false;
      notifyListeners();
    }
  }

  /// Cambia el dia seleccionado y recarga
  void seleccionarDia(DateTime dia) {
    _fechaSeleccionada = dia;
    cargar();
  }

  /// Toggle optimistic: actualiza local al instante, API en background
  Future<bool> toggleHabito(Habito habito) async {
    final index = _habitos.indexWhere((h) => h.id == habito.id);
    if (index == -1) return false;

    // Guardar estado original por si falla
    final listaOriginal = List<Habito>.from(_habitos);

    // Actualizar localmente al instante
    _habitos[index] = habito.copyWith(completadoHoy: !habito.completadoHoy);
    notifyListeners();

    // Llamar API en background
    try {
      final fecha = esHoy ? null : _fechaSeleccionada;
      if (habito.completadoHoy) {
        await _repo.descompletarHabito(habito.id, fecha: fecha);
      } else {
        await _repo.completarHabito(habito.id, fecha: fecha);
      }
      // Sincronizar datos reales (racha, progreso)
      await cargar();
      return true;
    } catch (e) {
      // Revertir si falla
      _habitos = listaOriginal;
      notifyListeners();
      return false;
    }
  }
}
