import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/utils/habit_icons.dart';
import '../data/models/habito.dart';
import '../l10n/app_localizations.dart';
import '../providers/statistics_provider.dart';
import 'detalle_general_screen.dart';
import 'detalle_habito_screen.dart';
import 'widgets/heatmap_calendar.dart';
import 'widgets/scale_on_tap.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  bool _cargaIniciada = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_cargaIniciada) {
      _cargaIniciada = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.read<StatisticsProvider>().cargar();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<StatisticsProvider>();

    if (provider.cargando && provider.habitos.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.sinHabitos) {
      return _EstadoVacio(mensaje: l10n.sinDatosEstadisticas);
    }

    return RefreshIndicator(
      onRefresh: () => provider.cargar(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          // Heatmap general — ocupa todo el ancho
          _FadeSlideIn(
            delay: 0,
            child: _HeatmapGeneralCard(provider: provider),
          ),
          const SizedBox(height: 14),

          // 4 metricas en fila
          _FadeSlideIn(
            delay: 80,
            child: _MetricasRow(provider: provider),
          ),
          const SizedBox(height: 14),

          // Records de rachas con barras de progreso
          _FadeSlideIn(
            delay: 160,
            child: _RecordRachasCard(provider: provider),
          ),
          const SizedBox(height: 24),

          // Titulo seccion por habito
          _FadeSlideIn(
            delay: 240,
            child: Text(
              l10n.porHabito,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 12),

          // Cards por habito
          ...List.generate(provider.habitos.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _FadeSlideIn(
                delay: 300 + i * 60,
                child: _HabitoHeatmapCard(
                  habito: provider.habitos[i],
                  provider: provider,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Heatmap general (ancho completo)
// ─────────────────────────────────────────────────────────────

class _HeatmapGeneralCard extends StatelessWidget {
  final StatisticsProvider provider;
  const _HeatmapGeneralCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return ScaleOnTap(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DetalleGeneralScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primaryContainer.withValues(alpha: 0.55),
              colorScheme.surfaceContainerLow,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colorScheme.primary.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_graph, size: 18, color: colorScheme.primary),
                const SizedBox(width: 6),
                Text(
                  l10n.actividadGeneral,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                Icon(Icons.arrow_forward,
                    size: 14, color: colorScheme.onSurfaceVariant),
              ],
            ),
            const SizedBox(height: 14),
            // Heatmap full-width con etiquetas
            HeatmapCalendar(
              semanas: 16,
              cellGap: 3,
              colorBase: colorScheme.primary,
              nivelPorFecha: provider.nivelGlobal,
              mostrarLabelsDias: true,
              mostrarMeses: true,
              fullWidth: true,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Fila de 4 metricas
// ─────────────────────────────────────────────────────────────

class _MetricasRow extends StatelessWidget {
  final StatisticsProvider provider;
  const _MetricasRow({required this.provider});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: _MetricChip(
            icon: Icons.check_circle_outline,
            value: '${provider.totalCompletados}',
            label: AppLocalizations.of(context)!.totalCompletados,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MetricChip(
            icon: Icons.local_fire_department,
            value: '${provider.mejorRachaGlobal}',
            label: AppLocalizations.of(context)!.mejorRachaGlobal,
            color: Colors.orange.shade700,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MetricChip(
            icon: Icons.trending_up,
            value: provider.promedioDiario.toStringAsFixed(1),
            label: AppLocalizations.of(context)!.promedioDiario,
            color: colorScheme.secondary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MetricChip(
            icon: Icons.bolt,
            value: '${provider.habitos.length}',
            label: AppLocalizations.of(context)!.habitosActivos,
            color: colorScheme.tertiary,
          ),
        ),
      ],
    );
  }
}

class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _MetricChip({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: color,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: colorScheme.onSurfaceVariant,
              height: 1.1,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Records de rachas con barras de progreso
// ─────────────────────────────────────────────────────────────

class _RecordRachasCard extends StatelessWidget {
  final StatisticsProvider provider;
  const _RecordRachasCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final top = provider.topRachas.take(3).toList();
    final maxRacha = top.isEmpty ? 1 : top.first.rachaMaxima.clamp(1, 999);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.orange.withValues(alpha: 0.12),
            colorScheme.surfaceContainerLow,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.22),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events,
                  size: 18, color: Colors.orange.shade700),
              const SizedBox(width: 6),
              Text(
                l10n.recordsRachas,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (top.isEmpty)
            Text(
              l10n.sinRacha,
              style: TextStyle(
                  fontSize: 12, color: colorScheme.onSurfaceVariant),
            )
          else
            ...List.generate(top.length, (i) {
              return _RecordBar(
                posicion: i + 1,
                habito: top[i],
                maxRacha: maxRacha,
                isLast: i == top.length - 1,
              );
            }),
        ],
      ),
    );
  }
}

class _RecordBar extends StatelessWidget {
  final int posicion;
  final Habito habito;
  final int maxRacha;
  final bool isLast;

  const _RecordBar({
    required this.posicion,
    required this.habito,
    required this.maxRacha,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final medalColor = switch (posicion) {
      1 => Colors.amber.shade600,
      2 => Colors.blueGrey.shade400,
      3 => Colors.brown.shade400,
      _ => colorScheme.onSurfaceVariant,
    };
    final ratio = (habito.rachaMaxima / maxRacha).clamp(0.02, 1.0);

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        children: [
          // Medallon numerado
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: medalColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$posicion',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Nombre + barra de progreso
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  habito.nombre,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 6,
                    backgroundColor: medalColor.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation(medalColor),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Dias de racha
          Text(
            '${habito.rachaMaxima}d',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: medalColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Card de habito con heatmap estilo GitHub (full width)
// ─────────────────────────────────────────────────────────────

class _HabitoHeatmapCard extends StatelessWidget {
  final Habito habito;
  final StatisticsProvider provider;
  const _HabitoHeatmapCard({
    required this.habito,
    required this.provider,
  });

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
            builder: (_) => DetalleHabitoScreen(habito: habito),
          ),
        );
        if (cambios == true && context.mounted) {
          context.read<StatisticsProvider>().cargar();
        }
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: accent.withValues(alpha: 0.14),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera: icono + nombre + rachas + flecha
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    HabitIcons.getIcon(habito.icono),
                    color: accent,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habito.nombre,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.local_fire_department,
                              size: 12, color: Colors.orange.shade700),
                          const SizedBox(width: 2),
                          Flexible(
                            child: Text(
                              '${habito.rachaActual}',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.orange.shade700),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.emoji_events_outlined,
                              size: 12,
                              color: colorScheme.onSurfaceVariant),
                          const SizedBox(width: 2),
                          Flexible(
                            child: Text(
                              '${habito.rachaMaxima}',
                              style: TextStyle(
                                fontSize: 11,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Heatmap full-width con labels de dias y meses
            HeatmapCalendar(
              semanas: 16,
              cellGap: 3,
              colorBase: accent,
              nivelPorFecha: (fecha) =>
                  provider.nivelHabito(habito.id, fecha),
              mostrarLabelsDias: true,
              mostrarMeses: true,
              fullWidth: true,
            ),
            const SizedBox(height: 8),
            // Leyenda
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.ultimosDias(StatisticsProvider.diasHeatmap),
                  style: TextStyle(
                    fontSize: 10,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                HeatmapLegend(
                  colorBase: accent,
                  labelMenos: l10n.menos,
                  labelMas: l10n.mas,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Utilidades
// ─────────────────────────────────────────────────────────────

class _FadeSlideIn extends StatelessWidget {
  final int delay;
  final Widget child;

  const _FadeSlideIn({required this.delay, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 450 + delay),
      curve: Curves.easeOutCubic,
      builder: (_, t, widget) {
        final clamped = t.clamp(0.0, 1.0);
        return Opacity(
          opacity: clamped,
          child: Transform.translate(
            offset: Offset(0, (1 - clamped) * 14),
            child: widget,
          ),
        );
      },
      child: child,
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
                size: 72, color: colorScheme.onSurfaceVariant),
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
