import 'package:flutter/foundation.dart';
import 'package:growtogether_data/growtogether_data.dart';

class DesafiosProvider extends ChangeNotifier {
  final DesafioRepository _repo;

  List<Desafio> _desafios = [];
  bool _cargando = true;
  String? _error;

  DesafiosProvider(this._repo);

  List<Desafio> get desafios => _desafios;
  bool get cargando => _cargando;
  String? get error => _error;

  /// Desafíos cuya fecha fin es posterior a hoy y siguen activos.
  List<Desafio> get desafiosActivos =>
      _desafios.where((d) => d.activo && !d.finalizado).toList();

  /// Desafíos finalizados (fechaFin pasada) o desactivados.
  List<Desafio> get desafiosFinalizados =>
      _desafios.where((d) => !d.activo || d.finalizado).toList();

  Future<void> cargar() async {
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      _desafios = await _repo.listarMisDesafios();
    } catch (e) {
      _error = e.toString();
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<bool> crear({
    required String nombre,
    required String descripcion,
    String? objetivo,
    required DateTime fechaInicio,
    required DateTime fechaFin,
    String frecuencia = 'DIARIO',
    Set<String>? diasSemana,
    String tipo = 'POSITIVO',
    String? icono,
    List<int>? participantesIds,
  }) async {
    try {
      final nuevo = await _repo.crearDesafio(
        nombre: nombre,
        descripcion: descripcion,
        objetivo: objetivo,
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
        frecuencia: frecuencia,
        diasSemana: diasSemana,
        tipo: tipo,
        icono: icono,
        participantesIds: participantesIds,
      );
      _desafios = [nuevo, ..._desafios];
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> eliminar(int id) async {
    try {
      await _repo.eliminarDesafio(id);
      _desafios = _desafios.where((d) => d.id != id).toList();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> abandonar(int id) async {
    try {
      await _repo.abandonarDesafio(id);
      _desafios = _desafios.where((d) => d.id != id).toList();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void reemplazar(Desafio actualizado) {
    final idx = _desafios.indexWhere((d) => d.id == actualizado.id);
    if (idx != -1) {
      _desafios[idx] = actualizado;
      notifyListeners();
    }
  }

  void limpiarError() {
    _error = null;
    notifyListeners();
  }
}
