import 'package:flutter/material.dart';
import '../../core/utils/challenge_colors.dart';

/// Píldora con un icono de gema verde y el número de puntos.
/// Estilo Playus: fondo oscuro semitransparente, icono verde, número en blanco.
class GemaPuntos extends StatelessWidget {
  final int puntos;
  final double tamano;
  final bool fondoOscuro;

  const GemaPuntos({
    super.key,
    required this.puntos,
    this.tamano = 14,
    this.fondoOscuro = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorTexto = fondoOscuro ? Colors.white : Colors.black87;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: tamano * 0.55, vertical: tamano * 0.25),
      decoration: BoxDecoration(
        color: fondoOscuro
            ? Colors.black.withValues(alpha: 0.7)
            : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(tamano * 1.4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$puntos',
            style: TextStyle(
              color: colorTexto,
              fontSize: tamano,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: tamano * 0.25),
          Icon(
            Icons.diamond,
            color: ChallengeColors.gemaVerde,
            size: tamano * 1.1,
          ),
        ],
      ),
    );
  }
}
