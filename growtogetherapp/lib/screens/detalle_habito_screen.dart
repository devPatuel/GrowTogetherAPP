import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/utils/habit_icons.dart';
import '../data/models/habito.dart';
import '../data/models/registro_historial.dart';
import '../data/repositories/habito_repository.dart';
import '../l10n/app_localizations.dart';
import '../providers/detalle_habito_provider.dart';
import 'widgets/habit_type_selector.dart';
import 'widgets/icon_selector.dart';

class DetalleHabitoScreen extends StatelessWidget {
  final Habito habito;

  const DetalleHabitoScreen({super.key, required this.habito});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => DetalleHabitoProvider(
        ctx.read<HabitoRepository>(),
        habito,
      ),
      child: const _DetalleHabitoView(),
    );
  }
}

class _DetalleHabitoView extends StatelessWidget {
  const _DetalleHabitoView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final provider = context.watch<DetalleHabitoProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.detalleHabito),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _mostrarDialogoEditar(context),
            tooltip: l10n.editarHabito,
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: colorScheme.error),
            onPressed: () => _confirmarEliminar(context),
            tooltip: l10n.eliminarHabito,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _Cabecera(habito: provider.habito),
          const SizedBox(height: 20),
          _RachaCard(
            habito: provider.habito,
            toggling: provider.toggling,
            onToggle: () => _onToggle(context),
          ),
          const SizedBox(height: 20),
          _HistorialSection(
            historial: provider.historial,
            mesActual: provider.mesActual,
            cargando: provider.cargandoHistorial,
            toggling: provider.toggling,
            onMesAnterior: provider.mesAnterior,
            onMesSiguiente: provider.mesSiguiente,
            onDiaPulsado: (fecha) => _onToggleFecha(context, fecha),
          ),
        ],
      ),
    );
  }

  Future<void> _onToggle(BuildContext context) async {
    final provider = context.read<DetalleHabitoProvider>();
    final l10n = AppLocalizations.of(context)!;
    final estabaCompletado = provider.habito.completadoHoy;
    final ok = await provider.toggleCompletar();

    if (!context.mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(estabaCompletado ? l10n.habitoDesmarcado : l10n.habitoCompletado),
          backgroundColor: estabaCompletado ? null : Theme.of(context).colorScheme.primary,
          duration: const Duration(seconds: 1),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorGenerico), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _onToggleFecha(BuildContext context, DateTime fecha) async {
    final provider = context.read<DetalleHabitoProvider>();
    final l10n = AppLocalizations.of(context)!;
    final estabaCompletado = provider.estaCompletadoEnFecha(fecha);
    final ok = await provider.toggleCompletar(fecha: fecha);

    if (!context.mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(estabaCompletado ? l10n.habitoDesmarcado : l10n.habitoCompletado),
          backgroundColor: estabaCompletado ? null : Theme.of(context).colorScheme.primary,
          duration: const Duration(seconds: 1),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorGenerico), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _mostrarDialogoEditar(BuildContext context) async {
    final provider = context.read<DetalleHabitoProvider>();
    final habito = provider.habito;
    final l10n = AppLocalizations.of(context)!;
    final nombreCtrl = TextEditingController(text: habito.nombre);
    final descCtrl = TextEditingController(text: habito.descripcion);
    String frecuencia = habito.frecuencia;
    Set<String> diasSeleccionados = Set.from(habito.diasSemana);
    String tipo = habito.tipo;
    String? iconoSeleccionado = habito.icono;
    final formKey = GlobalKey<FormState>();

    final resultado = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: Text(l10n.editarHabito),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.tipoHabito, style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      HabitTypeSelector(
                        tipo: tipo,
                        onChanged: (val) => setDialogState(() => tipo = val),
                      ),
                      const SizedBox(height: 16),
                      Text(l10n.iconoHabito, style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      IconSelector(
                        selectedIcon: iconoSeleccionado,
                        onChanged: (val) => setDialogState(() => iconoSeleccionado = val),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: nombreCtrl,
                        decoration: InputDecoration(labelText: l10n.nombreHabito),
                        validator: (v) => (v == null || v.trim().isEmpty) ? l10n.nombreObligatorio : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: descCtrl,
                        decoration: InputDecoration(labelText: l10n.descripcionHabito),
                        maxLines: 2,
                        validator: (v) => (v == null || v.trim().isEmpty) ? l10n.descripcionObligatoria : null,
                      ),
                      const SizedBox(height: 16),
                      Text(l10n.frecuencia, style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      SegmentedButton<String>(
                        segments: [
                          ButtonSegment(value: 'DIARIO', label: Text(l10n.diario)),
                          ButtonSegment(value: 'PERSONALIZADO', label: Text(l10n.personalizado)),
                        ],
                        selected: {frecuencia},
                        onSelectionChanged: (sel) {
                          setDialogState(() => frecuencia = sel.first);
                        },
                      ),
                      if (frecuencia == 'PERSONALIZADO') ...[
                        const SizedBox(height: 12),
                        Text(l10n.diasDeLaSemana),
                        const SizedBox(height: 8),
                        _buildDiasSelector(l10n, diasSeleccionados, setDialogState),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(l10n.cancelar),
                ),
                FilledButton(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;
                    if (frecuencia == 'PERSONALIZADO' && diasSeleccionados.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.seleccionaAlMenosUnDia)),
                      );
                      return;
                    }
                    Navigator.pop(ctx, true);
                  },
                  child: Text(l10n.guardar),
                ),
              ],
            );
          },
        );
      },
    );

    if (resultado == true) {
      final ok = await provider.editarHabito(
        nombre: nombreCtrl.text.trim(),
        descripcion: descCtrl.text.trim(),
        frecuencia: frecuencia,
        diasSemana: frecuencia == 'PERSONALIZADO' ? diasSeleccionados : null,
        tipo: tipo,
        icono: iconoSeleccionado,
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? l10n.habitoActualizado : l10n.errorGenerico),
          backgroundColor: ok ? null : Colors.red,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Widget _buildDiasSelector(AppLocalizations l10n, Set<String> diasSeleccionados, StateSetter setDialogState) {
    final dias = [
      ('LUNES', l10n.lun),
      ('MARTES', l10n.mar),
      ('MIERCOLES', l10n.mie),
      ('JUEVES', l10n.jue),
      ('VIERNES', l10n.vie),
      ('SABADO', l10n.sab),
      ('DOMINGO', l10n.dom),
    ];
    return Wrap(
      spacing: 6,
      children: dias.map((d) {
        final seleccionado = diasSeleccionados.contains(d.$1);
        return FilterChip(
          label: Text(d.$2),
          selected: seleccionado,
          onSelected: (sel) {
            setDialogState(() {
              if (sel) {
                diasSeleccionados.add(d.$1);
              } else {
                diasSeleccionados.remove(d.$1);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Future<void> _confirmarEliminar(BuildContext context) async {
    final provider = context.read<DetalleHabitoProvider>();
    final l10n = AppLocalizations.of(context)!;
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.eliminarHabito),
        content: Text(l10n.confirmarEliminarHabito),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancelar),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.eliminarHabito),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      final ok = await provider.eliminarHabito();
      if (!context.mounted) return;
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.habitoEliminado), duration: const Duration(seconds: 1)),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorGenerico), backgroundColor: Colors.red),
        );
      }
    }
  }
}

// --- Widgets extraídos ---

class _Cabecera extends StatelessWidget {
  final Habito habito;
  const _Cabecera({required this.habito});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final esNegativo = habito.esNegativo;
    final iconColor = esNegativo ? colorScheme.error : colorScheme.primary;
    final iconBgColor = iconColor.withValues(alpha: 0.12);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(
            HabitIcons.getIcon(habito.icono),
            size: 34,
            color: iconColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      habito.nombre,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (esNegativo)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: colorScheme.error.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        l10n.tipoNegativo,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.error,
                        ),
                      ),
                    ),
                ],
              ),
              if (habito.descripcion.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  habito.descripcion,
                  style: TextStyle(fontSize: 15, color: colorScheme.onSurfaceVariant),
                ),
              ],
              const SizedBox(height: 12),
              _FrecuenciaChip(habito: habito),
            ],
          ),
        ),
      ],
    );
  }
}

class _FrecuenciaChip extends StatelessWidget {
  final Habito habito;
  const _FrecuenciaChip({required this.habito});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    String label;
    if (habito.frecuencia == 'DIARIO') {
      label = l10n.frecuenciaDiaria;
    } else {
      final diasCortos = {
        'LUNES': l10n.diasCortoLun,
        'MARTES': l10n.diasCortoMar,
        'MIERCOLES': l10n.diasCortoMie,
        'JUEVES': l10n.diasCortoJue,
        'VIERNES': l10n.diasCortoVie,
        'SABADO': l10n.diasCortoSab,
        'DOMINGO': l10n.diasCortoDom,
      };
      final dias = habito.diasSemana.map((d) => diasCortos[d] ?? d).join(', ');
      label = '${l10n.frecuenciaPersonalizada}: $dias';
    }

    return Chip(
      label: Text(label),
      backgroundColor: colorScheme.secondaryContainer,
      labelStyle: TextStyle(color: colorScheme.onSecondaryContainer),
      side: BorderSide.none,
    );
  }
}

class _RachaCard extends StatelessWidget {
  final Habito habito;
  final bool toggling;
  final VoidCallback onToggle;

  const _RachaCard({
    required this.habito,
    required this.toggling,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final esNegativo = habito.esNegativo;
    final accentColor = esNegativo ? colorScheme.error : colorScheme.primary;

    return Card(
      elevation: 0,
      color: (esNegativo ? colorScheme.errorContainer : colorScheme.primaryContainer)
          .withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    esNegativo ? Icons.shield_outlined : Icons.local_fire_department,
                    color: esNegativo ? colorScheme.error : Colors.orange.shade700,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        esNegativo ? l10n.diasSinLabel : l10n.rachaActual,
                        style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
                      ),
                      Text(
                        esNegativo
                            ? l10n.diasSinHabito(habito.rachaActual, habito.nombre)
                            : '${habito.rachaActual} ${l10n.dias}',
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.emoji_events_outlined, size: 18, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(
                  '${l10n.mejorRacha}: ${habito.rachaMaxima} ${l10n.dias}',
                  style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: toggling
                  ? const Center(child: CircularProgressIndicator())
                  : FilledButton.icon(
                      onPressed: onToggle,
                      icon: Icon(habito.completadoHoy ? Icons.close : Icons.check),
                      label: Text(
                        habito.completadoHoy ? l10n.habitoDesmarcado : l10n.habitoCompletado,
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: habito.completadoHoy ? colorScheme.error : accentColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistorialSection extends StatelessWidget {
  final List<RegistroHistorial> historial;
  final DateTime mesActual;
  final bool cargando;
  final bool toggling;
  final VoidCallback onMesAnterior;
  final VoidCallback onMesSiguiente;
  final ValueChanged<DateTime> onDiaPulsado;

  const _HistorialSection({
    required this.historial,
    required this.mesActual,
    required this.cargando,
    required this.toggling,
    required this.onMesAnterior,
    required this.onMesSiguiente,
    required this.onDiaPulsado,
  });

  List<String> _getMeses(AppLocalizations l10n) => [
    l10n.mesEnero, l10n.mesFebrero, l10n.mesMarzo, l10n.mesAbril,
    l10n.mesMayo, l10n.mesJunio, l10n.mesJulio, l10n.mesAgosto,
    l10n.mesSeptiembre, l10n.mesOctubre, l10n.mesNoviembre, l10n.mesDiciembre,
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.historial, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        _buildNavegacionMes(l10n, colorScheme),
        const SizedBox(height: 8),
        cargando
            ? const Center(child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ))
            : _buildCalendario(l10n, colorScheme),
        const SizedBox(height: 12),
        _buildLeyenda(l10n, colorScheme),
      ],
    );
  }

  Widget _buildNavegacionMes(AppLocalizations l10n, ColorScheme colorScheme) {
    final now = DateTime.now();
    final esMesActual = mesActual.year == now.year && mesActual.month == now.month;
    final meses = _getMeses(l10n);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(icon: const Icon(Icons.chevron_left), onPressed: onMesAnterior),
        Text(
          '${meses[mesActual.month - 1]} ${mesActual.year}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: esMesActual ? null : onMesSiguiente,
        ),
      ],
    );
  }

  Widget _buildCalendario(AppLocalizations l10n, ColorScheme colorScheme) {
    final diasDelMes = DateTime(mesActual.year, mesActual.month + 1, 0).day;
    final primerDia = DateTime(mesActual.year, mesActual.month, 1);
    final offsetInicio = primerDia.weekday - 1;

    final Map<String, String> estadoPorDia = {};
    for (final r in historial) {
      final key = '${r.fecha.year}-${r.fecha.month}-${r.fecha.day}';
      estadoPorDia[key] = r.estado;
    }

    final cabeceraDias = [l10n.lun, l10n.mar, l10n.mie, l10n.jue, l10n.vie, l10n.sab, l10n.dom];

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: cabeceraDias.map((d) => Expanded(
                child: Center(
                  child: Text(
                    d,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              )).toList(),
            ),
            const SizedBox(height: 8),
            ..._buildFilasCalendario(diasDelMes, offsetInicio, estadoPorDia, colorScheme),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFilasCalendario(
    int diasDelMes,
    int offsetInicio,
    Map<String, String> estadoPorDia,
    ColorScheme colorScheme,
  ) {
    final filas = <Widget>[];
    final totalCeldas = offsetInicio + diasDelMes;
    final numFilas = (totalCeldas / 7).ceil();
    final hoy = DateTime.now();

    for (int fila = 0; fila < numFilas; fila++) {
      final celdas = <Widget>[];
      for (int col = 0; col < 7; col++) {
        final indice = fila * 7 + col;
        final dia = indice - offsetInicio + 1;

        if (dia < 1 || dia > diasDelMes) {
          celdas.add(const Expanded(child: SizedBox(height: 40)));
          continue;
        }

        final fecha = DateTime(mesActual.year, mesActual.month, dia);
        final key = '${fecha.year}-${fecha.month}-${fecha.day}';
        final estado = estadoPorDia[key];
        final esHoy = fecha.year == hoy.year && fecha.month == hoy.month && fecha.day == hoy.day;
        final esFuturo = fecha.isAfter(hoy);

        Color bgColor;
        Color textColor;

        if (estado == 'COMPLETADO') {
          bgColor = Colors.green.shade400;
          textColor = Colors.white;
        } else if (estado == 'NO_COMPLETADO') {
          bgColor = Colors.red.shade300.withValues(alpha: 0.7);
          textColor = Colors.white;
        } else if (esFuturo) {
          bgColor = colorScheme.surfaceContainerHighest.withValues(alpha: 0.4);
          textColor = colorScheme.onSurfaceVariant.withValues(alpha: 0.5);
        } else {
          bgColor = colorScheme.surfaceContainerHighest.withValues(alpha: 0.6);
          textColor = colorScheme.onSurfaceVariant;
        }

        celdas.add(
          Expanded(
            child: GestureDetector(
              onTap: esFuturo || toggling ? null : () => onDiaPulsado(fecha),
              child: Container(
                height: 40,
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                  border: esHoy ? Border.all(color: colorScheme.primary, width: 2.5) : null,
                ),
                child: Center(
                  child: Text(
                    '$dia',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: esHoy ? FontWeight.bold : FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }
      filas.add(Row(children: celdas));
    }
    return filas;
  }

  Widget _buildLeyenda(AppLocalizations l10n, ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LeyendaItem(color: Colors.green.shade400, label: l10n.completado),
        const SizedBox(width: 16),
        _LeyendaItem(color: Colors.red.shade300.withValues(alpha: 0.7), label: l10n.noCompletado),
        const SizedBox(width: 16),
        _LeyendaItem(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
          label: l10n.pendiente,
        ),
      ],
    );
  }
}

class _LeyendaItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LeyendaItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
