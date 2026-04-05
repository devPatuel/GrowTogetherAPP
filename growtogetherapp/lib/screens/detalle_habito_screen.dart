import 'package:flutter/material.dart';
import '../core/utils/habit_icons.dart';
import '../data/api/dio_client.dart';
import '../data/local/secure_storage_service.dart';
import '../data/models/habito.dart';
import '../data/models/registro_historial.dart';
import '../data/repositories/habito_repository.dart';
import '../l10n/app_localizations.dart';

class DetalleHabitoScreen extends StatefulWidget {
  final Habito habito;

  const DetalleHabitoScreen({super.key, required this.habito});

  @override
  State<DetalleHabitoScreen> createState() => _DetalleHabitoScreenState();
}

class _DetalleHabitoScreenState extends State<DetalleHabitoScreen> {
  final _storage = SecureStorageService();
  late final _repo = HabitoRepository(DioClient(_storage));

  late Habito _habito;
  List<RegistroHistorial> _historial = [];
  late DateTime _mesActual;
  bool _cargandoHistorial = true;
  bool _toggling = false;
  bool _huboCambios = false;

  @override
  void initState() {
    super.initState();
    _habito = widget.habito;
    final now = DateTime.now();
    _mesActual = DateTime(now.year, now.month);
    _cargarHistorial();
  }

  Future<void> _cargarHistorial() async {
    setState(() => _cargandoHistorial = true);
    try {
      final inicio = DateTime(_mesActual.year, _mesActual.month, 1);
      final fin = DateTime(_mesActual.year, _mesActual.month + 1, 0);
      final historial = await _repo.obtenerHistorial(
        _habito.id,
        fechaInicio: inicio,
        fechaFin: fin,
      );
      if (!mounted) return;
      setState(() {
        _historial = historial;
        _cargandoHistorial = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _cargandoHistorial = false);
    }
  }

  Future<void> _toggleCompletar() async {
    if (_toggling) return;
    setState(() => _toggling = true);
    final l10n = AppLocalizations.of(context)!;
    try {
      Habito actualizado;
      if (_habito.completadoHoy) {
        actualizado = await _repo.descompletarHabito(_habito.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.habitoDesmarcado), duration: const Duration(seconds: 1)),
        );
      } else {
        actualizado = await _repo.completarHabito(_habito.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.habitoCompletado),
            backgroundColor: Theme.of(context).colorScheme.primary,
            duration: const Duration(seconds: 1),
          ),
        );
      }
      setState(() {
        _habito = actualizado;
        _huboCambios = true;
      });
      _cargarHistorial();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _toggling = false);
    }
  }

  void _mesSiguiente() {
    setState(() {
      _mesActual = DateTime(_mesActual.year, _mesActual.month + 1);
    });
    _cargarHistorial();
  }

  void _mesAnterior() {
    setState(() {
      _mesActual = DateTime(_mesActual.year, _mesActual.month - 1);
    });
    _cargarHistorial();
  }

  Future<void> _mostrarDialogoEditar() async {
    final l10n = AppLocalizations.of(context)!;
    final nombreCtrl = TextEditingController(text: _habito.nombre);
    final descCtrl = TextEditingController(text: _habito.descripcion);
    String frecuencia = _habito.frecuencia;
    Set<String> diasSeleccionados = Set.from(_habito.diasSemana);
    String tipo = _habito.tipo;
    String? iconoSeleccionado = _habito.icono;
    final formKey = GlobalKey<FormState>();

    final resultado = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            final colorScheme = Theme.of(context).colorScheme;
            return AlertDialog(
              title: Text(l10n.editarHabito),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tipo
                      Text(l10n.tipoHabito, style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      SegmentedButton<String>(
                        segments: [
                          ButtonSegment(value: 'POSITIVO', label: Text(l10n.tipoPositivo)),
                          ButtonSegment(value: 'NEGATIVO', label: Text(l10n.tipoNegativo)),
                        ],
                        selected: {tipo},
                        onSelectionChanged: (sel) {
                          setDialogState(() => tipo = sel.first);
                        },
                      ),
                      const SizedBox(height: 16),

                      // Icono
                      Text(l10n.iconoHabito, style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: HabitIcons.allKeys.map((key) {
                          final sel = iconoSeleccionado == key;
                          return GestureDetector(
                            onTap: () {
                              setDialogState(() {
                                iconoSeleccionado = sel ? null : key;
                              });
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: sel
                                    ? colorScheme.primary.withValues(alpha: 0.2)
                                    : colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(10),
                                border: sel
                                    ? Border.all(color: colorScheme.primary, width: 2)
                                    : null,
                              ),
                              child: Icon(
                                HabitIcons.getIcon(key),
                                size: 22,
                                color: sel ? colorScheme.primary : colorScheme.onSurfaceVariant,
                              ),
                            ),
                          );
                        }).toList(),
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
                        _buildDiasSelector(diasSeleccionados, setDialogState),
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
      try {
        final actualizado = await _repo.editarHabito(
          _habito.id,
          nombre: nombreCtrl.text.trim(),
          descripcion: descCtrl.text.trim(),
          frecuencia: frecuencia,
          diasSemana: frecuencia == 'PERSONALIZADO' ? diasSeleccionados : null,
          tipo: tipo,
          icono: iconoSeleccionado,
        );
        if (!mounted) return;
        setState(() {
          _habito = actualizado;
          _huboCambios = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.habitoActualizado), duration: const Duration(seconds: 1)),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildDiasSelector(Set<String> diasSeleccionados, StateSetter setDialogState) {
    final l10n = AppLocalizations.of(context)!;
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

  Future<void> _confirmarEliminar() async {
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
      try {
        await _repo.eliminarHabito(_habito.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.habitoEliminado), duration: const Duration(seconds: 1)),
        );
        Navigator.pop(context, true);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop && _huboCambios) {
          // El resultado true indica que hay cambios
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.detalleHabito),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: _mostrarDialogoEditar,
              tooltip: l10n.editarHabito,
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: colorScheme.error),
              onPressed: _confirmarEliminar,
              tooltip: l10n.eliminarHabito,
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildCabecera(l10n, colorScheme),
            const SizedBox(height: 20),
            _buildRachaCard(l10n, colorScheme),
            const SizedBox(height: 20),
            _buildHistorialSection(l10n, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildCabecera(AppLocalizations l10n, ColorScheme colorScheme) {
    final esNegativo = _habito.esNegativo;
    final iconColor = esNegativo ? colorScheme.error : colorScheme.primary;
    final iconBgColor = iconColor.withValues(alpha: 0.12);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icono grande
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(
            HabitIcons.getIcon(_habito.icono),
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
                      _habito.nombre,
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
              if (_habito.descripcion.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  _habito.descripcion,
                  style: TextStyle(fontSize: 15, color: colorScheme.onSurfaceVariant),
                ),
              ],
              const SizedBox(height: 12),
              _buildFrecuenciaChip(l10n, colorScheme),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFrecuenciaChip(AppLocalizations l10n, ColorScheme colorScheme) {
    String label;
    if (_habito.frecuencia == 'DIARIO') {
      label = l10n.frecuenciaDiaria;
    } else {
      final diasCortos = _getDiasCortos(l10n);
      final dias = _habito.diasSemana.map((d) => diasCortos[d] ?? d).join(', ');
      label = '${l10n.frecuenciaPersonalizada}: $dias';
    }

    return Chip(
      label: Text(label),
      backgroundColor: colorScheme.secondaryContainer,
      labelStyle: TextStyle(color: colorScheme.onSecondaryContainer),
      side: BorderSide.none,
    );
  }

  Map<String, String> _getDiasCortos(AppLocalizations l10n) {
    return {
      'LUNES': l10n.diasCortoLun,
      'MARTES': l10n.diasCortoMar,
      'MIERCOLES': l10n.diasCortoMie,
      'JUEVES': l10n.diasCortoJue,
      'VIERNES': l10n.diasCortoVie,
      'SABADO': l10n.diasCortoSab,
      'DOMINGO': l10n.diasCortoDom,
    };
  }

  Widget _buildRachaCard(AppLocalizations l10n, ColorScheme colorScheme) {
    final esNegativo = _habito.esNegativo;
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
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        esNegativo
                            ? l10n.diasSinHabito(_habito.rachaActual, _habito.nombre)
                            : '${_habito.rachaActual} ${l10n.dias}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
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
                  '${l10n.mejorRacha}: ${_habito.rachaMaxima} ${l10n.dias}',
                  style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: _toggling
                  ? const Center(child: CircularProgressIndicator())
                  : FilledButton.icon(
                      onPressed: _toggleCompletar,
                      icon: Icon(
                        _habito.completadoHoy ? Icons.close : Icons.check,
                      ),
                      label: Text(
                        _habito.completadoHoy ? l10n.habitoDesmarcado : l10n.habitoCompletado,
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: _habito.completadoHoy
                            ? colorScheme.error
                            : accentColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistorialSection(AppLocalizations l10n, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.historial,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        _buildNavegacionMes(colorScheme),
        const SizedBox(height: 8),
        _cargandoHistorial
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

  Widget _buildNavegacionMes(ColorScheme colorScheme) {
    final now = DateTime.now();
    final esMesActual = _mesActual.year == now.year && _mesActual.month == now.month;

    final meses = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: _mesAnterior,
        ),
        Text(
          '${meses[_mesActual.month - 1]} ${_mesActual.year}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: esMesActual ? null : _mesSiguiente,
        ),
      ],
    );
  }

  Widget _buildCalendario(AppLocalizations l10n, ColorScheme colorScheme) {
    final diasDelMes = DateTime(_mesActual.year, _mesActual.month + 1, 0).day;
    final primerDia = DateTime(_mesActual.year, _mesActual.month, 1);
    final offsetInicio = primerDia.weekday - 1;

    final Map<String, String> estadoPorDia = {};
    for (final r in _historial) {
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
            ..._buildFilasCalendario(
              diasDelMes,
              offsetInicio,
              estadoPorDia,
              colorScheme,
            ),
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

        final fecha = DateTime(_mesActual.year, _mesActual.month, dia);
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
            child: Container(
              height: 40,
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(8),
                border: esHoy
                    ? Border.all(color: colorScheme.primary, width: 2.5)
                    : null,
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
        _buildLeyendaItem(Colors.green.shade400, l10n.completado),
        const SizedBox(width: 16),
        _buildLeyendaItem(Colors.red.shade300.withValues(alpha: 0.7), l10n.noCompletado),
        const SizedBox(width: 16),
        _buildLeyendaItem(
          colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
          l10n.pendiente,
        ),
      ],
    );
  }

  Widget _buildLeyendaItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
