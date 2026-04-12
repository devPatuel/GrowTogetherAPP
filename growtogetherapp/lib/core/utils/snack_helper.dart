import 'package:flutter/material.dart';

/// Extension on BuildContext para mostrar SnackBars con estilo consistente.
///
/// Uso:
///   context.showSnackSuccess(l10n.habitoCompletado);
///   context.showSnackError(l10n.errorGenerico);
///   context.showSnack(l10n.perfilActualizado);
extension SnackHelper on BuildContext {
  /// SnackBar de exito: fondo con el color primario del tema.
  void showSnackSuccess(String msg,
      {Duration duration = const Duration(seconds: 2)}) =>
      _show(msg, Theme.of(this).colorScheme.primary, duration);

  /// SnackBar de error: fondo rojo, duracion 3s por defecto.
  void showSnackError(String msg,
      {Duration duration = const Duration(seconds: 3)}) =>
      _show(msg, Colors.red, duration);

  /// SnackBar neutro: sin color de fondo extra (usa el del tema).
  void showSnack(String msg,
      {Duration duration = const Duration(seconds: 2)}) =>
      _show(msg, null, duration);

  void _show(String msg, Color? bg, Duration duration) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: bg,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
