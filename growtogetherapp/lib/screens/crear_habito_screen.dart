import 'package:flutter/material.dart';
import '../core/constants/app_strings.dart';
import '../data/api/dio_client.dart';
import '../data/local/secure_storage_service.dart';
import '../data/repositories/habito_repository.dart';

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

  static const _diasLabels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
  static const _diasEnumValues = ['LUNES', 'MARTES', 'MIERCOLES', 'JUEVES', 'VIERNES', 'SABADO', 'DOMINGO'];

  bool _guardando = false;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
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
    if (!_formKey.currentState!.validate()) return;

    if (_frecuencia == 'PERSONALIZADO' && !_diasSeleccionados.contains(true)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.seleccionaAlMenosUnDia),
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
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.habitoCreado),
          backgroundColor: Color(0xFF6B9F75),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.nuevoHabito),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(
                  labelText: AppStrings.nombreHabito,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.edit_outlined),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? AppStrings.nombreObligatorio : null,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(
                  labelText: AppStrings.descripcionHabito,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? AppStrings.descripcionObligatoria : null,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 24),

              // Frecuencia
              const Text(
                AppStrings.frecuencia,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'DIARIO', label: Text(AppStrings.diario), icon: Icon(Icons.calendar_today)),
                  ButtonSegment(value: 'PERSONALIZADO', label: Text(AppStrings.personalizado), icon: Icon(Icons.tune)),
                ],
                selected: {_frecuencia},
                onSelectionChanged: (sel) => setState(() => _frecuencia = sel.first),
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: const Color(0xFF6B9F75).withOpacity(0.2),
                  selectedForegroundColor: const Color(0xFF6B9F75),
                ),
              ),
              const SizedBox(height: 16),

              // Dias de la semana (solo si personalizado)
              if (_frecuencia == 'PERSONALIZADO') ...[
                const Text(
                  AppStrings.diasDeLaSemana,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
                            ? const Color(0xFF6B9F75)
                            : Colors.grey[200],
                        child: Text(
                          _diasLabels[i],
                          style: TextStyle(
                            color: _diasSeleccionados[i] ? Colors.white : Colors.grey[700],
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
                  label: Text(_guardando ? '' : AppStrings.crear),
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF6B9F75)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
