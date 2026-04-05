import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Controlador de idioma global. Usa ValueNotifier para notificar cambios
/// sin necesidad de Provider/Riverpod.
class LocaleController extends ValueNotifier<Locale> {
  LocaleController._() : super(const Locale('es'));

  static final LocaleController instance = LocaleController._();

  static const _prefsKey = 'app_locale';

  /// Locales soportados por la app.
  static const supportedLocales = [
    Locale('es'),
    Locale('en'),
    Locale('ca'),
  ];

  /// Carga el locale guardado en SharedPreferences.
  /// Llamar antes de runApp o en el initState del widget raiz.
  Future<void> cargar() async {
    final prefs = await SharedPreferences.getInstance();
    final codigo = prefs.getString(_prefsKey);
    if (codigo != null) {
      final locale = Locale(codigo);
      if (supportedLocales.contains(locale)) {
        value = locale;
      }
    }
  }

  /// Cambia el idioma y persiste la seleccion.
  Future<void> cambiar(Locale locale) async {
    value = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, locale.languageCode);
  }
}
