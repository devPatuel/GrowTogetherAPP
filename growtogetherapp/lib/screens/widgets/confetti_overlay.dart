import 'dart:math' as math;

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

/// Overlay de confeti para celebrar el día completado.
///
/// Se monta una sola vez en el dashboard y se dispara desde fuera via
/// [GlobalKey<ConfettiOverlayState>] llamando a [ConfettiOverlayState.celebrar].
/// El emisor sale desde el centro superior con dispersión vertical hacia
/// abajo (PI/2) para que la lluvia caiga por toda la pantalla.
class ConfettiOverlay extends StatefulWidget {
  const ConfettiOverlay({super.key});

  @override
  State<ConfettiOverlay> createState() => ConfettiOverlayState();
}

class ConfettiOverlayState extends State<ConfettiOverlay> {
  late final ConfettiController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  /// Lanza una explosión de confeti. Llamar desde el padre via GlobalKey.
  void celebrar() {
    if (!mounted) return;
    _ctrl.play();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConfettiWidget(
          confettiController: _ctrl,
          blastDirection: math.pi / 2, // hacia abajo
          blastDirectionality: BlastDirectionality.explosive,
          maxBlastForce: 18,
          minBlastForce: 8,
          emissionFrequency: 0.05,
          numberOfParticles: 18,
          gravity: 0.25,
          shouldLoop: false,
          colors: const [
            Colors.green,
            Colors.blue,
            Colors.pink,
            Colors.orange,
            Colors.purple,
            Colors.amber,
          ],
        ),
      ),
    );
  }
}
