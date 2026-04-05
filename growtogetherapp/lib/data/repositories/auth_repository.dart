import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../core/l10n/locale_controller.dart';
import '../../core/theme/app_themes.dart';
import '../../core/theme/theme_controller.dart';
import '../api/dio_client.dart';
import '../api/api_exceptions.dart';
import '../local/secure_storage_service.dart';
import '../models/usuario.dart';

class AuthRepository {
  final DioClient _client;
  final SecureStorageService _storage;

  AuthRepository(this._client, this._storage);

  Future<Usuario> login(String email, String password) async {
    try {
      final response = await _client.dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      final data = response.data as Map<String, dynamic>;
      final token = data['token'] as String;
      final userId = data['usuarioId'] as int;
      final nombre = data['nombre'] as String;
      final userEmail = data['email'] as String;

      await _storage.saveToken(token);
      await _storage.saveUserId(userId);
      await _storage.saveUserName(nombre);
      await _storage.saveUserEmail(userEmail);

      // Aplicar preferencias de tema e idioma del servidor
      _aplicarPreferencias(data['tema'] as String?, data['idioma'] as String?);

      return Usuario(id: userId, nombre: nombre, email: userEmail);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw BadRequestException('Credenciales incorrectas');
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw NetworkException('No se pudo conectar al servidor');
      }
      throw ApiException('Error al iniciar sesión');
    }
  }

  Future<bool> register(String nombre, String email, String password) async {
    try {
      await _client.dio.post('/auth/registrar', data: {
        'nombre': nombre,
        'email': email,
        'password': password,
      });
      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final errors = e.response?.data;
        if (errors is Map) {
          final msg = errors.values.first?.toString() ?? 'Datos inválidos';
          throw BadRequestException(msg);
        }
        throw BadRequestException('Datos de registro inválidos');
      }
      if (e.response?.statusCode == 409) {
        throw BadRequestException('El email ya está registrado');
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw NetworkException('No se pudo conectar al servidor');
      }
      throw ApiException('Error al registrarse');
    }
  }

  Future<void> logout() async {
    await _storage.deleteAll();
  }

  /// Aplica tema e idioma recibidos del servidor a los controladores locales.
  /// Si alguno es null o no reconocido, se deja el valor actual (fallback local).
  void _aplicarPreferencias(String? tema, String? idioma) {
    final themeType = AppThemes.fromApiString(tema);
    if (themeType != null) {
      ThemeController.instance.cambiar(themeType);
    }

    if (idioma != null && ['es', 'en', 'ca'].contains(idioma)) {
      LocaleController.instance.cambiar(Locale(idioma));
    }
  }

  /// Aplica preferencias desde un objeto Usuario (para auto-login).
  void aplicarPreferenciasDesdeUsuario(Usuario usuario) {
    _aplicarPreferencias(usuario.tema, usuario.idioma);
  }

  Future<bool> isLoggedIn() async {
    return await _storage.hasToken();
  }

  Future<Usuario?> getCurrentUser() async {
    final id = await _storage.getUserId();
    final name = await _storage.getUserName();
    final email = await _storage.getUserEmail();
    if (id == null || name == null || email == null) return null;
    return Usuario(id: id, nombre: name, email: email);
  }
}
