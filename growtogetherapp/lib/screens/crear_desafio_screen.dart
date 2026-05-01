import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/utils/snack_helper.dart';
import '../data/models/participante_desafio.dart';
import '../data/models/usuario.dart';
import '../l10n/app_localizations.dart';
import '../providers/amistad_provider.dart';
import '../providers/desafios_provider.dart';
import 'widgets/avatar_stack.dart';
import 'widgets/day_of_week_selector.dart';
import 'widgets/habit_type_selector.dart';
import 'widgets/icon_selector.dart';
import 'widgets/seleccionar_amigos_modal.dart';

/// Pantalla de creación de un desafío. Reutiliza los widgets del formulario de hábitos
/// (IconSelector, DayOfWeekSelector, HabitTypeSelector) y añade selector de fecha fin
/// y selector multi-select de amigos participantes.
class CrearDesafioScreen extends StatefulWidget {
  const CrearDesafioScreen({super.key});

  @override
  State<CrearDesafioScreen> createState() => _CrearDesafioScreenState();
}

class _CrearDesafioScreenState extends State<CrearDesafioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  String _frecuencia = 'DIARIO';
  final List<bool> _diasSeleccionados = [false, false, false, false, false, false, false];
  String _tipo = 'POSITIVO';
  String? _iconoSeleccionado;
  DateTime? _fechaFin;
  Set<int> _participantesIds = {};

  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AmistadProvider>();
      if (provider.amigos.isEmpty) provider.cargarAmigos();
    });
  }

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

  Future<void> _seleccionarFecha() async {
    final hoy = DateTime.now();
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaFin ?? hoy.add(const Duration(days: 30)),
      firstDate: hoy.add(const Duration(days: 1)),
      lastDate: hoy.add(const Duration(days: 365)),
    );
    if (fecha != null) {
      setState(() => _fechaFin = fecha);
    }
  }

  Future<void> _seleccionarAmigos() async {
    final resultado = await SeleccionarAmigosModal.mostrar(
      context,
      inicial: _participantesIds,
    );
    if (resultado != null) {
      setState(() => _participantesIds = resultado);
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_fechaFin == null) {
      context.showSnackError('Selecciona una fecha fin');
      return;
    }
    if (_participantesIds.isEmpty) {
      context.showSnackError('Selecciona al menos un amigo');
      return;
    }

    if (_frecuencia == 'PERSONALIZADO') {
      final count = _diasSeleccionados.where((d) => d).length;
      if (count == 0 || count == 7) {
        setState(() => _frecuencia = 'DIARIO');
      }
    }

    setState(() => _guardando = true);
    final provider = context.read<DesafiosProvider>();
    final ok = await provider.crear(
      nombre: _nombreCtrl.text.trim(),
      descripcion: _descCtrl.text.trim(),
      fechaInicio: DateTime.now(),
      fechaFin: _fechaFin!,
      frecuencia: _frecuencia,
      diasSemana: _getDiasSemana(),
      tipo: _tipo,
      icono: _iconoSeleccionado,
      participantesIds: _participantesIds.toList(),
    );

    if (!mounted) return;
    if (ok) {
      context.showSnackSuccess('Desafío creado');
      Navigator.pop(context, true);
    } else {
      setState(() => _guardando = false);
      context.showSnackError(provider.error ?? 'Error al crear el desafío');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final amistad = context.watch<AmistadProvider>();
    final amigosSeleccionados = amistad.amigos
        .where((a) => _participantesIds.contains(a.id))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo desafío'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.tipoHabito,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              HabitTypeSelector(
                tipo: _tipo,
                onChanged: (val) => setState(() => _tipo = val),
              ),
              const SizedBox(height: 6),
              Text(
                _tipo == 'POSITIVO' ? l10n.tipoPositivoDesc : l10n.tipoNegativoDesc,
                style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre del desafío',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.edit_outlined),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l10n.nombreObligatorio : null,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l10n.descripcionObligatoria : null,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 24),
              Text(
                l10n.iconoHabito,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              IconSelector(
                selectedIcon: _iconoSeleccionado,
                onChanged: (val) => setState(() => _iconoSeleccionado = val),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.frecuencia,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: [
                  ButtonSegment(
                      value: 'DIARIO',
                      label: Text(l10n.diario),
                      icon: const Icon(Icons.calendar_today)),
                  ButtonSegment(
                      value: 'PERSONALIZADO',
                      label: Text(l10n.personalizado),
                      icon: const Icon(Icons.tune)),
                ],
                selected: {_frecuencia},
                onSelectionChanged: (sel) => setState(() => _frecuencia = sel.first),
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: colorScheme.primary.withValues(alpha: 0.2),
                  selectedForegroundColor: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              if (_frecuencia == 'PERSONALIZADO') ...[
                Text(
                  l10n.diasDeLaSemana,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                DayOfWeekSelector(
                  diasSeleccionados: _diasSeleccionados,
                  onToggle: (i) => setState(
                      () => _diasSeleccionados[i] = !_diasSeleccionados[i]),
                ),
                const SizedBox(height: 24),
              ],
              const Text(
                'Fecha fin',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              _SelectorFecha(
                fecha: _fechaFin,
                onTap: _seleccionarFecha,
              ),
              const SizedBox(height: 24),
              const Text(
                'Participantes',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              _SelectorParticipantes(
                seleccionados: amigosSeleccionados,
                onTap: _seleccionarAmigos,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  onPressed: _guardando ? null : _guardar,
                  icon: _guardando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.emoji_events),
                  label: Text(_guardando ? '' : 'Crear desafío'),
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

class _SelectorFecha extends StatelessWidget {
  final DateTime? fecha;
  final VoidCallback onTap;

  const _SelectorFecha({required this.fecha, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final etiqueta = fecha == null
        ? 'Selecciona una fecha'
        : '${fecha!.day.toString().padLeft(2, '0')}/${fecha!.month.toString().padLeft(2, '0')}/${fecha!.year}';
    final dias = fecha == null
        ? null
        : fecha!.difference(DateTime.now()).inDays + 1;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outline),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_month, color: colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(etiqueta, style: const TextStyle(fontSize: 16)),
                  if (dias != null && dias > 0)
                    Text(
                      '$dias días de duración',
                      style: TextStyle(
                          fontSize: 12, color: colorScheme.onSurfaceVariant),
                    ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: colorScheme.outline),
          ],
        ),
      ),
    );
  }
}

class _SelectorParticipantes extends StatelessWidget {
  final List<Usuario> seleccionados;
  final VoidCallback onTap;

  const _SelectorParticipantes({required this.seleccionados, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outline),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.people_alt, color: colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: seleccionados.isEmpty
                  ? const Text(
                      'Selecciona amigos',
                      style: TextStyle(fontSize: 16),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${seleccionados.length} seleccionados',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          height: 28,
                          child: AvatarStack(
                            participantes: seleccionados.map(_aPreview).toList(),
                            maxVisible: 5,
                            radius: 14,
                          ),
                        ),
                      ],
                    ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: colorScheme.outline),
          ],
        ),
      ),
    );
  }

  /// Adapta un Usuario a una ParticipanteDesafio mock para el preview de AvatarStack.
  /// Los puntos y rachas no aplican aquí porque aún no se ha creado el desafío.
  static ParticipanteDesafio _aPreview(Usuario u) {
    return ParticipanteDesafio(
      id: 0,
      usuarioId: u.id,
      nombre: u.nombre,
      foto: u.foto,
      desafioId: 0,
    );
  }
}
