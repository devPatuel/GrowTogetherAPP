import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'feedback_controller.dart';

/// Wrapper estatico para emitir feedback haptico de forma centralizada.
///
/// Reglas:
///  - Si el usuario ha desactivado el feedback en preferencias, no hace nada.
///  - En web (kIsWeb) HapticFeedback no esta soportado: tampoco hace nada.
///  - Cualquier excepcion al llamar al canal nativo se traga silenciosamente
///    para que un error de plataforma nunca rompa la UI.
class FeedbackService {
  FeedbackService._();

  /// Vibracion ligera para taps generales (ej: pulsar un boton secundario).
  static Future<void> tapLigero() => _ejecutar(HapticFeedback.lightImpact);

  /// Vibracion media para marcar/desmarcar un habito.
  static Future<void> marcarHabito() => _ejecutar(HapticFeedback.mediumImpact);

  /// Vibracion fuerte para hitos (dia completo, racha relevante).
  static Future<void> hito() => _ejecutar(HapticFeedback.heavyImpact);

  /// Comprueba precondiciones y ejecuta la accion haptica de forma segura.
  static Future<void> _ejecutar(Future<void> Function() accion) async {
    if (kIsWeb) return;
    if (!FeedbackController.instance.activo) return;
    try {
      await accion();
    } catch (_) {
      // El feedback haptico es accesorio: jamas debe romper la UI
    }
  }
}
