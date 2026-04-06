import 'package:flutter/foundation.dart';
import '../data/api/api_exceptions.dart';
import '../data/models/usuario.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/user_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepo;
  final UserRepository _userRepo;

  bool _cargando = false;
  String? _error;

  AuthProvider(this._authRepo, this._userRepo);

  bool get cargando => _cargando;
  String? get error => _error;

  void limpiarError() {
    _error = null;
    notifyListeners();
  }

  /// Verifica si hay sesion activa y carga preferencias
  Future<Usuario?> verificarSesion() async {
    final usuario = await _authRepo.getCurrentUser();
    if (usuario != null) {
      try {
        final perfil = await _userRepo.obtenerPerfil(usuario.id);
        _authRepo.aplicarPreferenciasDesdeUsuario(perfil);
      } catch (_) {}
    }
    return usuario;
  }

  /// Login con email y password
  Future<bool> login(String email, String password) async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      await _authRepo.login(email, password);
      _cargando = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _cargando = false;
      notifyListeners();
      return false;
    }
  }

  /// Registro de nuevo usuario
  Future<bool> register(String nombre, String email, String password) async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      await _authRepo.register(nombre, email, password);
      _cargando = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _cargando = false;
      notifyListeners();
      return false;
    }
  }
}
