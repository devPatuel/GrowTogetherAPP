import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_themes.dart';

/// Controlador de tema global. Usa ValueNotifier para notificar cambios
/// sin necesidad de Provider/Riverpod.
class ThemeController extends ValueNotifier<AppThemeType> {
  ThemeController._() : super(AppThemeType.claro);

  static final ThemeController instance = ThemeController._();

  static const _prefsKey = 'app_theme';

  /// Carga el tema guardado en SharedPreferences.
  /// Llamar antes de runApp o en el initState del widget raiz.
  Future<void> cargar() async {
    final prefs = await SharedPreferences.getInstance();
    final nombre = prefs.getString(_prefsKey);
    if (nombre != null) {
      try {
        value = AppThemeType.values.byName(nombre);
      } catch (_) {
        // Si el nombre guardado no es valido, se queda con claro
      }
    }
  }

  /// Cambia el tema y persiste la seleccion.
  Future<void> cambiar(AppThemeType tipo) async {
    value = tipo;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, tipo.name);
  }

  /// Atajo para obtener el ThemeData actual.
  ThemeData get themeData => AppThemes.fromType(value);
}
