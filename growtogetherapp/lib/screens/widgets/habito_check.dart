import 'package:flutter/material.dart';
import 'scale_on_tap.dart';

/// Check del hábito con animación de bounce al completar.
///
/// Cuando [completado] pasa de false a true dispara una escala
/// 1.0 -> 1.25 -> 1.0 sobre el icono y un cross-fade del color.
/// Al desmarcar simplemente vuelve al estado vacío sin bounce.
///
/// Mantiene la misma estética que el check anterior: contenedor
/// 44x44 con gradiente cuando está completado y borde cuando no.
class HabitoCheck extends StatefulWidget {
  final bool completado;
  final bool esNegativo;
  final Color accentColor;
  final VoidCallback onTap;

  const HabitoCheck({
    super.key,
    required this.completado,
    required this.esNegativo,
    required this.accentColor,
    required this.onTap,
  });

  @override
  State<HabitoCheck> createState() => _HabitoCheckState();
}

class _HabitoCheckState extends State<HabitoCheck>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounceCtrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.25), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.25, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(covariant HabitoCheck oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Solo bounce al pasar de no-completado a completado
    if (!oldWidget.completado && widget.completado) {
      _bounceCtrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accentColor;
    return ScaleOnTap(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          gradient: widget.completado
              ? LinearGradient(colors: [accent, accent.withValues(alpha: 0.7)])
              : null,
          color: widget.completado ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(13),
          border: widget.completado
              ? null
              : Border.all(color: accent.withValues(alpha: 0.4), width: 2),
        ),
        child: ScaleTransition(
          scale: _scale,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: Icon(
              widget.completado
                  ? Icons.check_rounded
                  : (widget.esNegativo
                      ? Icons.close_rounded
                      : Icons.check_rounded),
              key: ValueKey(widget.completado),
              size: 22,
              color: widget.completado
                  ? Colors.white
                  : accent.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }
}
