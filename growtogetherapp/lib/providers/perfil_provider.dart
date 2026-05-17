import 'package:flutter/foundation.dart';
import 'package:growtogether_data/growtogether_data.dart';
import '../services/local_notifications_service.dart';

class PerfilProvider extends ChangeNotifier {
  final UserRepository _repo;
  final SecureStorageService _storage;
  final LocalNotificationsService _localNotifs;

  Usuario? _usuario;
  bool _cargando = true;
  String? _error;

  PerfilProvider(this._repo, this._storage, this._localNotifs);

  Usuario? get usuario => _usuario;
  bool get cargando => _cargando;
  String? get error => _error;

  Future<void> cargar() async {
    _cargando = true;
    _error = null;
    // No llamar notifyListeners() aquí de forma síncrona: puede
    // dispararse durante la fase de build y provocar el error
    // "setState called during build". El estado de carga ya se
    // notifica cuando termina la operación asíncrona.

    try {
      final id = await _storage.getUserId();
      if (id == null) return;
      _usuario = await _repo.obtenerPerfil(id);
      _cargando = false;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      _cargando = false;
      notifyListeners();
    }
  }

  Future<bool> editarNombre(String nombre) async {
    try {
      final id = await _storage.getUserId();
      if (id == null) return false;
      await _repo.editarPerfil(id, nombre: nombre);
      await _storage.saveUserName(nombre);
      await cargar();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> editarEmail(String email) async {
    try {
      final id = await _storage.getUserId();
      if (id == null) return false;
      await _repo.editarPerfil(id, email: email);
      await cargar();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> editarFoto(String fotoBase64) async {
    try {
      final id = await _storage.getUserId();
      if (id == null) return false;
      await _repo.editarPerfil(id, foto: fotoBase64);
      await cargar();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      // Captura errores genéricos (ej. payload demasiado grande en web)
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> quitarFoto() async {
    try {
      final id = await _storage.getUserId();
      if (id == null) return false;
      await _repo.editarPerfil(id, foto: '');
      await cargar();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> cambiarContrasena(String actual, String nueva) async {
    try {
      final id = await _storage.getUserId();
      if (id == null) return false;
      await _repo.cambiarContrasena(id, actual, nueva);
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<void> sincronizarPreferencias({String? tema, String? idioma}) async {
    try {
      final id = await _storage.getUserId();
      if (id == null) return;
      await _repo.actualizarPreferencias(id, tema: tema, idioma: idioma);
    } catch (_) {}
  }

  /// Cierra sesion borrando credenciales locales y cancelando todas las
  /// notificaciones programadas. El cancelarTodas evita que recordatorios del
  /// usuario que cierra sesion sigan disparandose si otra cuenta inicia
  /// sesion en el mismo dispositivo.
  Future<void> cerrarSesion() async {
    await _localNotifs.cancelarTodas();
    await _storage.deleteAll();
  }
}
