import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Controlador global del feedback haptico y animaciones expresivas.
/// Usa ValueNotifier para notificar cambios sin necesidad de Provider.
///
/// Sigue el mismo patron que [ThemeController] y [LocaleController]:
/// instancia singleton, persistencia en SharedPreferences y carga al
/// arranque de la app.
class FeedbackController extends ValueNotifier<bool> {
  FeedbackController._() : super(true);

  static final FeedbackController instance = FeedbackController._();

  static const _prefsKey = 'feedback_haptico_activo';

  /// Indica si el usuario ha activado el feedback (vibracion + animaciones).
  bool get activo => value;

  /// Carga el valor guardado en SharedPreferences.
  /// Llamar antes de runApp o en el initState del widget raiz.
  Future<void> cargar() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final guardado = prefs.getBool(_prefsKey);
      if (guardado != null) {
        value = guardado;
      }
    } catch (_) {
      // Si SharedPreferences falla, se queda con el valor por defecto (true)
    }
  }

  /// Activa o desactiva el feedback y persiste la seleccion.
  Future<void> cambiar(bool nuevoValor) async {
    value = nuevoValor;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefsKey, nuevoValor);
    } catch (_) {
      // Persistencia best-effort: si falla, el valor sigue activo en memoria
    }
  }
}
