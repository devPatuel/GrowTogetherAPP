import 'package:flutter/material.dart';
import '../core/utils/habit_icons.dart';
import '../data/api/dio_client.dart';
import '../data/local/secure_storage_service.dart';
import '../data/repositories/habito_repository.dart';
import '../l10n/app_localizations.dart';

class CrearHabitoScreen extends StatefulWidget {
  const CrearHabitoScreen({super.key});

  @override
  State<CrearHabitoScreen> createState() => _CrearHabitoScreenState();
}

class _CrearHabitoScreenState extends State<CrearHabitoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  String _frecuencia = 'DIARIO';
  final List<bool> _diasSeleccionados = [false, false, false, false, false, false, false];
  String _tipo = 'POSITIVO';
  String? _iconoSeleccionado;

  static const _diasEnumValues = ['LUNES', 'MARTES', 'MIERCOLES', 'JUEVES', 'VIERNES', 'SABADO', 'DOMINGO'];

  bool _guardando = false;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  List<String> _getDiasLabels(AppLocalizations l10n) {
    return [l10n.lun, l10n.mar, l10n.mie, l10n.jue, l10n.vie, l10n.sab, l10n.dom];
  }

  Set<String>? _getDiasSemana() {
    if (_frecuencia == 'DIARIO') return null;
    final dias = <String>{};
    for (int i = 0; i < 7; i++) {
      if (_diasSeleccionados[i]) dias.add(_diasEnumValues[i]);
    }
    return dias;
  }

  Future<void> _guardar() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    if (_frecuencia == 'PERSONALIZADO' && !_diasSeleccionados.contains(true)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.seleccionaAlMenosUnDia),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _guardando = true);

    try {
      final storage = SecureStorageService();
      final repo = HabitoRepository(DioClient(storage));
      await repo.crearHabito(
        nombre: _nombreCtrl.text.trim(),
        descripcion: _descCtrl.text.trim(),
        frecuencia: _frecuencia,
        diasSemana: _getDiasSemana(),
        tipo: _tipo,
        icono: _iconoSeleccionado,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.habitoCreado),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _guardando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final diasLabels = _getDiasLabels(l10n);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.nuevoHabito),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tipo de habito: Positivo / Negativo
              Text(
                l10n.tipoHabito,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              _buildTipoSelector(l10n, colorScheme),
              const SizedBox(height: 6),
              Text(
                _tipo == 'POSITIVO' ? l10n.tipoPositivoDesc : l10n.tipoNegativoDesc,
                style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 20),

              // Nombre
              TextFormField(
                controller: _nombreCtrl,
                decoration: InputDecoration(
                  labelText: l10n.nombreHabito,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.edit_outlined),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? l10n.nombreObligatorio : null,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),

              // Descripcion
              TextFormField(
                controller: _descCtrl,
                decoration: InputDecoration(
                  labelText: l10n.descripcionHabito,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.description_outlined),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? l10n.descripcionObligatoria : null,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 24),

              // Icono
              Text(
                l10n.iconoHabito,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              _buildIconGrid(colorScheme),
              const SizedBox(height: 24),

              // Frecuencia
              Text(
                l10n.frecuencia,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: [
                  ButtonSegment(value: 'DIARIO', label: Text(l10n.diario), icon: const Icon(Icons.calendar_today)),
                  ButtonSegment(value: 'PERSONALIZADO', label: Text(l10n.personalizado), icon: const Icon(Icons.tune)),
                ],
                selected: {_frecuencia},
                onSelectionChanged: (sel) => setState(() => _frecuencia = sel.first),
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: colorScheme.primary.withValues(alpha: 0.2),
                  selectedForegroundColor: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),

              // Dias de la semana (solo si personalizado)
              if (_frecuencia == 'PERSONALIZADO') ...[
                Text(
                  l10n.diasDeLaSemana,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(7, (i) {
                    return GestureDetector(
                      onTap: () => setState(() => _diasSeleccionados[i] = !_diasSeleccionados[i]),
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: _diasSeleccionados[i]
                            ? colorScheme.primary
                            : Colors.grey[200],
                        child: Text(
                          diasLabels[i],
                          style: TextStyle(
                            color: _diasSeleccionados[i] ? colorScheme.onPrimary : Colors.grey[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),
              ],

              // Boton crear
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  onPressed: _guardando ? null : _guardar,
                  icon: _guardando
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.add),
                  label: Text(_guardando ? '' : l10n.crear),
                  style: FilledButton.styleFrom(backgroundColor: colorScheme.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipoSelector(AppLocalizations l10n, ColorScheme colorScheme) {
    return SegmentedButton<String>(
      segments: [
        ButtonSegment(
          value: 'POSITIVO',
          label: Text(l10n.tipoPositivo),
          icon: const Icon(Icons.add_circle_outline),
        ),
        ButtonSegment(
          value: 'NEGATIVO',
          label: Text(l10n.tipoNegativo),
          icon: const Icon(Icons.remove_circle_outline),
        ),
      ],
      selected: {_tipo},
      onSelectionChanged: (sel) => setState(() => _tipo = sel.first),
      style: SegmentedButton.styleFrom(
        selectedBackgroundColor: _tipo == 'POSITIVO'
            ? colorScheme.primary.withValues(alpha: 0.2)
            : colorScheme.error.withValues(alpha: 0.2),
        selectedForegroundColor: _tipo == 'POSITIVO'
            ? colorScheme.primary
            : colorScheme.error,
      ),
    );
  }

  Widget _buildIconGrid(ColorScheme colorScheme) {
    final allKeys = HabitIcons.allKeys;
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: allKeys.map((key) {
        final seleccionado = _iconoSeleccionado == key;
        final icon = HabitIcons.getIcon(key);
        return GestureDetector(
          onTap: () {
            setState(() {
              _iconoSeleccionado = seleccionado ? null : key;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: seleccionado
                  ? colorScheme.primary.withValues(alpha: 0.2)
                  : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: seleccionado
                  ? Border.all(color: colorScheme.primary, width: 2.5)
                  : null,
            ),
            child: Icon(
              icon,
              size: 26,
              color: seleccionado ? colorScheme.primary : colorScheme.onSurfaceVariant,
            ),
          ),
        );
      }).toList(),
    );
  }
}
