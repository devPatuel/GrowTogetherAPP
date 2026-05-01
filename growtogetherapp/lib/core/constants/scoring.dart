/// Constantes de puntuación de desafíos.
/// Deben mantenerse sincronizadas con [Scoring.java] del backend.
/// Solo se usan en cliente para previsualizar puntos al usuario; el cálculo real lo hace el backend.
class Scoring {
  static const int puntosBase = 10;
  static const double bonusPorDiaRacha = 0.10;
  static const int topeRacha = 20;

  const Scoring._();

  /// Multiplicador para la racha indicada. Racha=1 → 1.0; Racha=10 → 1.9; Racha>=21 → 3.0 (tope).
  static double multiplicador(int racha) {
    if (racha <= 0) return 0;
    final diasBonus = racha - 1 < topeRacha ? racha - 1 : topeRacha;
    return 1.0 + diasBonus * bonusPorDiaRacha;
  }

  /// Puntos que otorga un día completado dado el valor de racha resultante.
  static int puntosDia(int racha) {
    if (racha <= 0) return 0;
    return (puntosBase * multiplicador(racha)).round();
  }
}
