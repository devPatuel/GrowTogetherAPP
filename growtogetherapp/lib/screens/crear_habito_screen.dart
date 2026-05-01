import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/utils/snack_helper.dart';
import 'package:growtogether_data/growtogether_data.dart';
import '../l10n/app_localizations.dart';
import 'widgets/day_of_week_selector.dart';
import 'widgets/habit_type_selector.dart';
import 'widgets/icon_selector.dart';

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

  bool _guardando = false;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Set<String>? _getDiasSemana() {
    if (_frecuencia == 'DIARIO') return null;
    return DayOfWeekSelector.toEnumSet(_diasSeleccionados);
  }

  Future<void> _guardar() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    // Normalizar: todos los dias o ninguno → DIARIO
    if (_frecuencia == 'PERSONALIZADO') {
      final count = _diasSeleccionados.where((d) => d).length;
      if (count == 0 || count == 7) {
        setState(() => _frecuencia = 'DIARIO');
      }
    }

    setState(() => _guardando = true);

    try {
      final repo = context.read<HabitoRepository>();
      await repo.crearHabito(
        nombre: _nombreCtrl.text.trim(),
        descripcion: _descCtrl.text.trim(),
        frecuencia: _frecuencia,
        diasSemana: _getDiasSemana(),
        tipo: _tipo,
        icono: _iconoSeleccionado,
      );

      if (!mounted) return;
      context.showSnackSuccess(l10n.habitoCreado);
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _guardando = false);
      context.showSnackError(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
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
              HabitTypeSelector(tipo: _tipo, onChanged: (val) => setState(() => _tipo = val)),
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
              IconSelector(selectedIcon: _iconoSeleccionado, onChanged: (val) => setState(() => _iconoSeleccionado = val)),
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
                DayOfWeekSelector(
                  diasSeleccionados: _diasSeleccionados,
                  onToggle: (i) => setState(() => _diasSeleccionados[i] = !_diasSeleccionados[i]),
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

}
