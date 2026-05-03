import 'package:flutter/material.dart';

/// Gráfica multilínea custom estilo Playus.
/// Pinta una línea por participante con su color asignado, mostrando la evolución
/// acumulada de puntos por día. Usa Path.cubicTo para curvas suaves.
class MultilineChart extends StatelessWidget {
  /// Mapa usuarioId → lista de puntos acumulados por día (desde fechaInicio del desafío).
  final Map<int, List<double>> series;

  /// Mapa usuarioId → color asignado al participante (paleta cíclica de Playus).
  final Map<int, Color> coloresPorUsuario;

  /// Etiqueta de los días en el eje X (ej. `'1'`, `'5'`, `'10'`...).
  final List<String>? labelsX;

  const MultilineChart({
    super.key,
    required this.series,
    required this.coloresPorUsuario,
    this.labelsX,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (series.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'Sin datos todavía',
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ),
      );
    }
    // Calcular max Y
    double maxY = 0;
    for (final lista in series.values) {
      for (final v in lista) {
        if (v > maxY) maxY = v;
      }
    }
    if (maxY == 0) maxY = 10;
    return SizedBox(
      height: 220,
      child: CustomPaint(
        painter: _MultilinePainter(
          series: series,
          colores: coloresPorUsuario,
          maxY: maxY * 1.15,
          colorEjes: colorScheme.outline.withValues(alpha: 0.4),
          colorTextos: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _MultilinePainter extends CustomPainter {
  final Map<int, List<double>> series;
  final Map<int, Color> colores;
  final double maxY;
  final Color colorEjes;
  final Color colorTextos;

  _MultilinePainter({
    required this.series,
    required this.colores,
    required this.maxY,
    required this.colorEjes,
    required this.colorTextos,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const paddingLeft = 28.0;
    const paddingRight = 12.0;
    const paddingTop = 12.0;
    const paddingBottom = 24.0;
    final chartWidth = size.width - paddingLeft - paddingRight;
    final chartHeight = size.height - paddingTop - paddingBottom;

    // Determinar nº de días = longitud máxima de las series
    int dias = 0;
    for (final lista in series.values) {
      if (lista.length > dias) dias = lista.length;
    }
    if (dias <= 1) {
      _pintarMensajeVacio(canvas, size);
      return;
    }

    // Grid horizontal (4 líneas)
    final gridPaint = Paint()
      ..color = colorEjes
      ..strokeWidth = 0.6
      ..style = PaintingStyle.stroke;
    for (int i = 0; i <= 4; i++) {
      final y = paddingTop + chartHeight * i / 4;
      canvas.drawLine(
        Offset(paddingLeft, y),
        Offset(paddingLeft + chartWidth, y),
        gridPaint,
      );
      // Label Y
      final valor = (maxY * (4 - i) / 4).round();
      _pintarTexto(canvas, '$valor', Offset(0, y - 6), 10);
    }

    // Pintar cada serie
    for (final entry in series.entries) {
      final color = colores[entry.key] ?? Colors.grey;
      final lista = entry.value;
      if (lista.length < 2) continue;
      final paint = Paint()
        ..color = color
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      final path = Path();
      for (int i = 0; i < lista.length; i++) {
        final x = paddingLeft + chartWidth * i / (dias - 1);
        final y = paddingTop + chartHeight * (1 - lista[i] / maxY);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          // Curva suave entre puntos consecutivos
          final xPrev = paddingLeft + chartWidth * (i - 1) / (dias - 1);
          final yPrev = paddingTop + chartHeight * (1 - lista[i - 1] / maxY);
          final cp1x = xPrev + (x - xPrev) / 2;
          final cp2x = x - (x - xPrev) / 2;
          path.cubicTo(cp1x, yPrev, cp2x, y, x, y);
        }
      }
      canvas.drawPath(path, paint);

      // Punto al final de la línea
      final ultimoX = paddingLeft + chartWidth * (lista.length - 1) / (dias - 1);
      final ultimoY = paddingTop + chartHeight * (1 - lista.last / maxY);
      final puntoPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(ultimoX, ultimoY), 4, puntoPaint);
      final puntoBorde = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(Offset(ultimoX, ultimoY), 4, puntoBorde);
    }

    // Eje X: marcas en pasos
    int paso = (dias / 5).ceil().clamp(1, dias);
    for (int i = 0; i < dias; i += paso) {
      final x = paddingLeft + chartWidth * i / (dias - 1);
      _pintarTexto(canvas, '${i + 1}', Offset(x - 4, paddingTop + chartHeight + 4), 10);
    }
  }

  void _pintarTexto(Canvas canvas, String texto, Offset offset, double size) {
    final tp = TextPainter(
      text: TextSpan(text: texto, style: TextStyle(color: colorTextos, fontSize: size)),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, offset);
  }

  void _pintarMensajeVacio(Canvas canvas, Size size) {
    final tp = TextPainter(
      text: TextSpan(
        text: 'Sin datos suficientes',
        style: TextStyle(color: colorTextos, fontSize: 12),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset(size.width / 2 - tp.width / 2, size.height / 2));
  }

  @override
  bool shouldRepaint(_MultilinePainter old) =>
      old.series != series || old.maxY != maxY;
}
