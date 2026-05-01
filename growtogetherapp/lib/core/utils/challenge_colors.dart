import 'package:flutter/material.dart';

/// Paleta cíclica de 6 colores vivos estilo Playus para identificar a cada participante
/// de forma consistente en card, podio, ranking y gráfica multilínea.
class ChallengeColors {
  static const List<Color> _paleta = [
    Color(0xFFEC4899), // rosa
    Color(0xFFF97316), // naranja
    Color(0xFFEAB308), // amarillo
    Color(0xFF84CC16), // verde lima
    Color(0xFF06B6D4), // cyan
    Color(0xFFA855F7), // púrpura
  ];

  /// Color asignado al participante según su índice en la lista de participantes.
  /// Garantiza que cada usuario tiene siempre el mismo color en toda la pantalla.
  static Color paraIndice(int indice) => _paleta[indice % _paleta.length];

  /// Verde gema usado para los puntos (estilo Playus).
  static const Color gemaVerde = Color(0xFF22C55E);

  /// Dorado de la corona del #1 del podio.
  static const Color coronaOro = Color(0xFFFFB300);
}
