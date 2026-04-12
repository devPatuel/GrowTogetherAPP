import 'package:flutter/material.dart';

/// Widget reutilizable tipo "GitHub heatmap".
///
/// Pinta una rejilla de semanas (columnas) x 7 dias (filas), empezando
/// desde el lunes mas antiguo del rango. Cada celda se colorea segun el
/// nivel devuelto por [nivelPorFecha]:
///   -1 = no completado (rojo suave)
///    0 = sin datos o pendiente
///    1-4 = intensidad creciente del [colorBase]
///
/// [semanas] determina el ancho del heatmap.
/// [fullWidth] hace que el heatmap se expanda para ocupar todo el ancho
/// disponible calculando automaticamente el cellSize con LayoutBuilder.
/// [mostrarMeses] muestra etiquetas abreviadas del mes encima de las columnas.
/// [mostrarLabelsDias] muestra L / X / V a la izquierda de las filas.
class HeatmapCalendar extends StatelessWidget {
  final int semanas;
  final double cellSize;
  final double cellGap;
  final int Function(DateTime fecha) nivelPorFecha;
  final Color colorBase;
  final bool mostrarLabelsDias;
  final bool mostrarMeses;
  final bool fullWidth;

  const HeatmapCalendar({
    super.key,
    this.semanas = 16,
    this.cellSize = 12,
    this.cellGap = 3,
    required this.nivelPorFecha,
    required this.colorBase,
    this.mostrarLabelsDias = false,
    this.mostrarMeses = false,
    this.fullWidth = false,
  });

  // Precalcula el numero de columnas para poder usarlo en LayoutBuilder.
  int _columnasReales() {
    final hoy = _dateOnly(DateTime.now());
    final inicioRango = hoy.subtract(Duration(days: semanas * 7 - 1));
    final weekdayInicio = inicioRango.weekday;
    final inicioAlineado =
        inicioRango.subtract(Duration(days: weekdayInicio - 1));
    final totalDias = hoy.difference(inicioAlineado).inDays + 1;
    return (totalDias / 7).ceil();
  }

  @override
  Widget build(BuildContext context) {
    if (fullWidth) {
      final cols = _columnasReales();
      final labelAncho = mostrarLabelsDias ? 20.0 : 0.0;
      return LayoutBuilder(builder: (context, constraints) {
        final gridAncho = constraints.maxWidth - labelAncho;
        final cs = ((gridAncho - (cols - 1) * cellGap) / cols)
            .clamp(4.0, 20.0)
            .floorToDouble();
        return _buildContenido(context, cs);
      });
    }
    return _buildContenido(context, cellSize);
  }

  Widget _buildContenido(BuildContext context, double cs) {
    final colorScheme = Theme.of(context).colorScheme;
    final hoy = _dateOnly(DateTime.now());

    final inicioRango = hoy.subtract(Duration(days: semanas * 7 - 1));
    final weekdayInicio = inicioRango.weekday;
    final inicioAlineado =
        inicioRango.subtract(Duration(days: weekdayInicio - 1));
    final totalDias = hoy.difference(inicioAlineado).inDays + 1;
    final columnasReales = (totalDias / 7).ceil();

    final locale = Localizations.localeOf(context).languageCode;
    final mesLabels = mostrarMeses
        ? _buildMesLabels(inicioAlineado, columnasReales, locale)
        : List<String?>.filled(columnasReales, null);

    final grid = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(columnasReales, (col) {
        return Padding(
          padding: EdgeInsets.only(
              right: col == columnasReales - 1 ? 0 : cellGap),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Etiqueta de mes encima de la columna
              if (mostrarMeses)
                SizedBox(
                  height: cs * 1.5,
                  width: cs,
                  child: mesLabels[col] != null
                      ? Text(
                          mesLabels[col]!,
                          style: TextStyle(
                            fontSize: (cs * 0.85).clamp(8.0, 11.0),
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.clip,
                        )
                      : const SizedBox.shrink(),
                ),
              // 7 celdas (lunes..domingo)
              ...List.generate(7, (fila) {
                final fecha =
                    inicioAlineado.add(Duration(days: col * 7 + fila));
                final fueraRango =
                    fecha.isBefore(inicioRango) || fecha.isAfter(hoy);

                final color = fueraRango
                    ? colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.15)
                    : _colorParaNivel(
                        nivelPorFecha(fecha), colorBase, colorScheme);

                return Padding(
                  padding:
                      EdgeInsets.only(bottom: fila == 6 ? 0 : cellGap),
                  child: Container(
                    width: cs,
                    height: cs,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(cs * 0.25),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      }),
    );

    if (!mostrarLabelsDias) return grid;

    // Columna de etiquetas laterales (L / X / V)
    final labelStyle = TextStyle(
      fontSize: (cs * 0.85).clamp(8.0, 11.0),
      color: colorScheme.onSurfaceVariant,
      height: 1,
    );

    Widget filaLabel(String txt) => SizedBox(
          height: cs + cellGap,
          child: Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Text(txt, style: labelStyle),
            ),
          ),
        );

    Widget hueco() => SizedBox(height: cs + cellGap);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (mostrarMeses) SizedBox(height: cs * 1.5),
              filaLabel('L'),
              hueco(), // M
              filaLabel('X'),
              hueco(), // J
              filaLabel('V'),
              hueco(), // S
              SizedBox(height: cs), // D (ultimo, sin padding abajo)
            ],
          ),
        ),
        grid,
      ],
    );
  }

  /// Devuelve el mes abreviado para la primera columna de cada mes,
  /// null para el resto.
  static List<String?> _buildMesLabels(
      DateTime inicioAlineado, int numCols, String locale) {
    const mesesEs = ['En', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    const mesesEn = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    const mesesCa = ['Gen', 'Feb', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Oct', 'Nov', 'Des'];
    final meses = locale == 'en' ? mesesEn : locale == 'ca' ? mesesCa : mesesEs;
    final labels = List<String?>.filled(numCols, null);
    int? prevMonth;
    int? lastLabelCol;
    for (int col = 0; col < numCols; col++) {
      final fecha = inicioAlineado.add(Duration(days: col * 7));
      final month = fecha.month;
      if (month != prevMonth) {
        // Solo mostrar si hay al menos 3 columnas de separación con la etiqueta anterior
        if (lastLabelCol == null || (col - lastLabelCol) >= 3) {
          labels[col] = meses[month - 1];
          lastLabelCol = col;
        }
        prevMonth = month;
      }
    }
    return labels;
  }

  static Color _colorParaNivel(int nivel, Color base, ColorScheme scheme) {
    if (nivel < 0) return scheme.error.withValues(alpha: 0.4);
    if (nivel == 0) {
      return scheme.surfaceContainerHighest.withValues(alpha: 0.55);
    }
    if (nivel == 1) return base.withValues(alpha: 0.28);
    if (nivel == 2) return base.withValues(alpha: 0.5);
    if (nivel == 3) return base.withValues(alpha: 0.75);
    return base;
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}

/// Pequeña leyenda de colores del heatmap.
class HeatmapLegend extends StatelessWidget {
  final Color colorBase;
  final String labelMenos;
  final String labelMas;

  const HeatmapLegend({
    super.key,
    required this.colorBase,
    required this.labelMenos,
    required this.labelMas,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final labelStyle = TextStyle(
      fontSize: 11,
      color: scheme.onSurfaceVariant,
    );

    Widget celda(Color c) => Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: c,
            borderRadius: BorderRadius.circular(2.5),
          ),
        );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(labelMenos, style: labelStyle),
        const SizedBox(width: 6),
        celda(scheme.surfaceContainerHighest.withValues(alpha: 0.55)),
        celda(colorBase.withValues(alpha: 0.28)),
        celda(colorBase.withValues(alpha: 0.5)),
        celda(colorBase.withValues(alpha: 0.75)),
        celda(colorBase),
        const SizedBox(width: 6),
        Text(labelMas, style: labelStyle),
      ],
    );
  }
}
