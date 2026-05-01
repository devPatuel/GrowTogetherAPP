import 'package:flutter/foundation.dart';
import '../data/api/api_exceptions.dart';
import '../data/models/usuario.dart';
import '../data/models/solicitud_amistad.dart';
import '../data/repositories/amistad_repository.dart';

class AmistadProvider extends ChangeNotifier {
  final AmistadRepository _repo;

  List<Usuario> _amigos = [];
  List<SolicitudAmistad> _recibidas = [];
  List<SolicitudAmistad> _enviadas = [];

  bool _cargandoAmigos = false;
  bool _cargandoSolicitudes = false;
  String? _error;

  AmistadProvider(this._repo);

  List<Usuario> get amigos => _amigos;
  List<SolicitudAmistad> get recibidas => _recibidas;
  List<SolicitudAmistad> get enviadas => _enviadas;
  bool get cargandoAmigos => _cargandoAmigos;
  bool get cargandoSolicitudes => _cargandoSolicitudes;
  String? get error => _error;
  int get peticionesPendientes => _recibidas.length;

  void limpiarError() {
    _error = null;
    notifyListeners();
  }

  Future<void> cargarAmigos() async {
    _cargandoAmigos = true;
    _error = null;
    notifyListeners();
    try {
      _amigos = await _repo.listarAmigos();
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _cargandoAmigos = false;
      notifyListeners();
    }
  }

  Future<void> cargarSolicitudes() async {
    _cargandoSolicitudes = true;
    _error = null;
    notifyListeners();
    try {
      _recibidas = await _repo.listarRecibidas();
      _enviadas = await _repo.listarEnviadas();
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _cargandoSolicitudes = false;
      notifyListeners();
    }
  }

  Future<List<Usuario>> buscar(String query) async {
    try {
      final texto = query.trim();
      if (texto.isEmpty) return [];
      final id = int.tryParse(texto);
      if (id != null) {
        final u = await _repo.buscarPorId(id);
        return u != null ? [u] : [];
      }
      return await _repo.buscarUsuarios(texto);
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return [];
    }
  }

  Future<bool> enviarSolicitud(int destinatarioId) async {
    try {
      await _repo.enviarSolicitud(destinatarioId);
      await cargarSolicitudes();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> aceptar(int solicitudId) async {
    try {
      await _repo.aceptar(solicitudId);
      _recibidas = _recibidas.where((s) => s.id != solicitudId).toList();
      notifyListeners();
      await cargarAmigos();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> rechazar(int solicitudId) async {
    try {
      await _repo.rechazar(solicitudId);
      _recibidas = _recibidas.where((s) => s.id != solicitudId).toList();
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancelar(int solicitudId) async {
    try {
      await _repo.cancelar(solicitudId);
      _enviadas = _enviadas.where((s) => s.id != solicitudId).toList();
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> eliminarAmigo(int amigoId) async {
    try {
      await _repo.eliminarAmigo(amigoId);
      _amigos = _amigos.where((u) => u.id != amigoId).toList();
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }
}
