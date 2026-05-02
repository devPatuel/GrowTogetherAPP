import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:growtogether_data/growtogether_data.dart';
import '../core/l10n/locale_controller.dart';
import '../core/theme/app_themes.dart';
import '../core/theme/theme_controller.dart';

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
        _aplicarPreferencias(perfil.tema, perfil.idioma);
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
      final usuario = await _authRepo.login(email, password);
      _aplicarPreferencias(usuario.tema, usuario.idioma);
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

  /// Aplica tema e idioma recibidos del servidor a los controladores locales.
  /// Si alguno es null o no reconocido, se respeta el valor actual.
  void _aplicarPreferencias(String? tema, String? idioma) {
    final themeType = AppThemes.fromApiString(tema);
    if (themeType != null) {
      ThemeController.instance.cambiar(themeType);
    }
    if (idioma != null && ['es', 'en', 'ca'].contains(idioma)) {
      LocaleController.instance.cambiar(Locale(idioma));
    }
  }
}
