import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/utils/habit_icons.dart';
import 'package:growtogether_data/growtogether_data.dart';
import '../l10n/app_localizations.dart';
import '../providers/statistics_provider.dart';
import 'detalle_habito_screen.dart';
import 'widgets/heatmap_calendar.dart';
import 'widgets/scale_on_tap.dart';

/// Detalle "general" de todos los habitos: heatmap grande, metricas
/// agregadas y lista resumen de habitos. Se abre desde el card del
/// heatmap general en [StatisticsScreen].
class DetalleGeneralScreen extends StatelessWidget {
  const DetalleGeneralScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final provider = context.watch<StatisticsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.detalleGeneral),
      ),
      body: provider.cargando
          ? const Center(child: CircularProgressIndicator())
          : provider.sinHabitos
              ? _EstadoVacio(mensaje: l10n.sinDatosEstadisticas)
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _HeatmapGrande(provider: provider),
                    const SizedBox(height: 20),
                    _MetricasGrid(provider: provider),
                    const SizedBox(height: 20),
                    _ChartsSection(provider: provider),
                    const SizedBox(height: 20),
                    _ResumenHabitos(provider: provider),
                    const SizedBox(height: 16),
                  ],
                ),
      backgroundColor: colorScheme.surface,
    );
  }
}

class _HeatmapGrande extends StatelessWidget {
  final StatisticsProvider provider;
  const _HeatmapGrande({required this.provider});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
      builder: (_, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, (1 - t) * 12),
          child: child,
        ),
      ),
      child: Card(
        elevation: 0,
        color: colorScheme.surfaceContainerLow,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_graph, color: colorScheme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.actividadGeneral,
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                l10n.ultimosDias(StatisticsProvider.diasHeatmap),
                style: TextStyle(
                    fontSize: 12, color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              HeatmapCalendar(
                semanas: StatisticsProvider.diasHeatmap ~/ 7,
                cellGap: 3,
                mostrarLabelsDias: true,
                mostrarMeses: true,
                fullWidth: true,
                colorBase: colorScheme.primary,
                nivelPorFecha: provider.nivelGlobal,
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: HeatmapLegend(
                  colorBase: colorScheme.primary,
                  labelMenos: l10n.menos,
                  labelMas: l10n.mas,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricasGrid extends StatelessWidget {
  final StatisticsProvider provider;
  const _MetricasGrid({required this.provider});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    final metricas = <_Metrica>[
      _Metrica(
        icono: Icons.check_circle_outline,
        label: l10n.totalCompletados,
        valor: provider.totalCompletados.toString(),
        color: colorScheme.primary,
      ),
      _Metrica(
        icono: Icons.local_fire_department,
        label: l10n.mejorRachaGlobal,
        valor: '${provider.mejorRachaGlobal}',
        sufijo: l10n.dias,
        color: Colors.orange.shade700,
      ),
      _Metrica(
        icono: Icons.trending_up,
        label: l10n.promedioDiario,
        valor: '${(provider.promedioDiario * 100).toStringAsFixed(0)}%',
        color: colorScheme.tertiary,
      ),
      _Metrica(
        icono: Icons.track_changes,
        label: l10n.habitosActivos,
        valor: provider.habitos.length.toString(),
        color: colorScheme.secondary,
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        for (int i = 0; i < metricas.length; i++)
          TweenAnimationBuilder<double>(
            key: ValueKey('metrica_$i'),
            tween: Tween(begin: 0, end: 1),
            duration: Duration(milliseconds: 350 + i * 80),
            curve: Curves.easeOutCubic,
            builder: (_, t, child) => Opacity(
              opacity: t.clamp(0, 1),
              child: Transform.translate(
                offset: Offset(0, (1 - t) * 10),
                child: child,
              ),
            ),
            child: _MetricaCard(metrica: metricas[i]),
          ),
      ],
    );
  }
}

class _Metrica {
  final IconData icono;
  final String label;
  final String valor;
  final String? sufijo;
  final Color color;
  _Metrica({
    required this.icono,
    required this.label,
    required this.valor,
    this.sufijo,
    required this.color,
  });
}

class _MetricaCard extends StatelessWidget {
  final _Metrica metrica;
  const _MetricaCard({required this.metrica});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: metrica.color.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(metrica.icono, color: metrica.color, size: 22),
          Text(
            metrica.label,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Flexible(
                  child: Text(
                    metrica.valor,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w800),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (metrica.sufijo != null) ...[
                  const SizedBox(width: 4),
                  Text(
                    metrica.sufijo!,
                    style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResumenHabitos extends StatelessWidget {
  final StatisticsProvider provider;
  const _ResumenHabitos({required this.provider});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final habitos = provider.topRachas;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.resumenGeneral,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        ...List.generate(habitos.length, (i) {
          final habito = habitos[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: Duration(milliseconds: 350 + i * 60),
              curve: Curves.easeOutCubic,
              builder: (_, t, child) => Opacity(
                opacity: t.clamp(0, 1),
                child: Transform.translate(
                  offset: Offset((1 - t) * 16, 0),
                  child: child,
                ),
              ),
              child: _HabitoFila(habito: habito, provider: provider),
            ),
          );
        }),
      ],
    );
  }
}

class _HabitoFila extends StatelessWidget {
  final Habito habito;
  final StatisticsProvider provider;
  const _HabitoFila({required this.habito, required this.provider});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final accent =
        habito.esNegativo ? colorScheme.error : colorScheme.primary;

    return ScaleOnTap(
      onTap: () async {
        final cambios = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
              builder: (_) => DetalleHabitoScreen(habito: habito)),
        );
        if (cambios == true && context.mounted) {
          context.read<StatisticsProvider>().cargar();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                HabitIcons.getIcon(habito.icono),
                color: accent,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habito.nombre,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${l10n.rachaActual}: ${habito.rachaActual}  ·  ${l10n.mejorRacha}: ${habito.rachaMaxima}',
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Seccion de graficos
// ─────────────────────────────────────────────────────────────

class _ChartsSection extends StatelessWidget {
  final StatisticsProvider provider;
  const _ChartsSection({required this.provider});

  /// Completados por semana: indice 0 = mas antigua, 15 = esta semana.
  List<int> _porSemana() {
    final hoy = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final data = List<int>.filled(16, 0);
    for (final entry in provider.completadosPorDia.entries) {
      final dias = hoy.difference(entry.key).inDays;
      final semana = 15 - (dias ~/ 7);
      if (semana >= 0 && semana < 16) {
        data[semana] += entry.value;
      }
    }
    return data;
  }

  /// Promedio de completados por dia de la semana (1=Lun...7=Dom).
  Map<int, double> _promediosPorDia() {
    final agrupado = <int, List<int>>{};
    for (final entry in provider.completadosPorDia.entries) {
      final wd = entry.key.weekday;
      agrupado.putIfAbsent(wd, () => []).add(entry.value);
    }
    return {
      for (int d = 1; d <= 7; d++)
        d: agrupado[d] != null && agrupado[d]!.isNotEmpty
            ? agrupado[d]!.reduce((a, b) => a + b) / agrupado[d]!.length
            : 0.0,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final semanales = _porSemana();
    final diarios = _promediosPorDia();

    final maxSemanal =
        semanales.reduce((a, b) => a > b ? a : b).clamp(1, 9999);
    final maxDiario =
        diarios.values.reduce((a, b) => a > b ? a : b).clamp(0.1, 9999.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tendencia semanal
        _ChartCard(
          titulo: l10n.tendenciaSemanal,
          icono: Icons.bar_chart_rounded,
          color: colorScheme.primary,
          child: SizedBox(
            height: 80,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(16, (i) {
                final ratio = semanales[i] / maxSemanal;
                final esUltima = i == 15;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: i == 15 ? 0 : 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: AnimatedContainer(
                            duration:
                                Duration(milliseconds: 300 + i * 30),
                            curve: Curves.easeOutCubic,
                            height: (ratio * 72).clamp(3, 72),
                            decoration: BoxDecoration(
                              color: esUltima
                                  ? colorScheme.primary
                                  : colorScheme.primary
                                      .withValues(alpha: 0.45 + ratio * 0.45),
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          footer: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.hace16Semanas,
                  style: TextStyle(
                      fontSize: 10,
                      color: colorScheme.onSurfaceVariant)),
              Text(l10n.estaSemana,
                  style: TextStyle(
                      fontSize: 10,
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Por dia de la semana
        _ChartCard(
          titulo: l10n.porDiaSemana,
          icono: Icons.calendar_view_week_rounded,
          color: colorScheme.secondary,
          child: SizedBox(
            height: 80,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final dia = i + 1; // 1=Lun...7=Dom
                final avg = diarios[dia] ?? 0.0;
                final ratio = avg / maxDiario;
                final labels = [l10n.lun, l10n.mar, l10n.mie, l10n.jue, l10n.vie, l10n.sab, l10n.dom];
                final esFinDeSemana = dia >= 6;

                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: i == 6 ? 0 : 6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: AnimatedContainer(
                            duration:
                                Duration(milliseconds: 300 + i * 60),
                            curve: Curves.easeOutCubic,
                            height: (ratio * 60).clamp(3, 60),
                            decoration: BoxDecoration(
                              color: esFinDeSemana
                                  ? colorScheme.secondary
                                      .withValues(alpha: 0.5)
                                  : colorScheme.secondary,
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(5)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          labels[i],
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: esFinDeSemana
                                ? colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.5)
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          footer: Text(
            l10n.promedioHabitosDia,
            style: TextStyle(
                fontSize: 10, color: colorScheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String titulo;
  final IconData icono;
  final Color color;
  final Widget child;
  final Widget footer;

  const _ChartCard({
    required this.titulo,
    required this.icono,
    required this.color,
    required this.child,
    required this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border:
            Border.all(color: color.withValues(alpha: 0.12), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icono, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                titulo,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
          const SizedBox(height: 8),
          footer,
        ],
      ),
    );
  }
}

class _EstadoVacio extends StatelessWidget {
  final String mensaje;
  const _EstadoVacio({required this.mensaje});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.insights_outlined,
                size: 64, color: colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
