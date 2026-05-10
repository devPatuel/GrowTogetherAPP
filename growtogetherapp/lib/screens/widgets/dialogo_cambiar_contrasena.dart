import 'package:flutter/material.dart';
import '../../core/utils/validators.dart';
import '../../l10n/app_localizations.dart';

class DialogoCambiarContrasena extends StatefulWidget {
  const DialogoCambiarContrasena({super.key});

  @override
  State<DialogoCambiarContrasena> createState() => _DialogoCambiarContrasenaState();
}

class _DialogoCambiarContrasenaState extends State<DialogoCambiarContrasena> {
  final _actualController = TextEditingController();
  final _nuevaController = TextEditingController();
  final _confirmarController = TextEditingController();
  bool _ocultarActual = true;
  bool _ocultarNueva = true;
  bool _ocultarConfirmar = true;
  String? _error;

  @override
  void dispose() {
    _actualController.dispose();
    _nuevaController.dispose();
    _confirmarController.dispose();
    super.dispose();
  }

  void _validarYGuardar() {
    final l10n = AppLocalizations.of(context)!;
    final errorPassword = Validators.password(
      _nuevaController.text,
      obligatoria: l10n.validatorContrasenaObligatoria,
      requisitos: l10n.validatorContrasenaRequisitos,
    );
    if (errorPassword != null) {
      setState(() => _error = errorPassword);
      return;
    }
    if (_nuevaController.text != _confirmarController.text) {
      setState(() => _error = l10n.contrasenasNoCoinciden);
      return;
    }
    if (_actualController.text.isEmpty) {
      setState(() => _error = l10n.rellenaTodosLosCampos);
      return;
    }
    Navigator.pop(context, {
      'actual': _actualController.text,
      'nueva': _nuevaController.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.cambiarContrasena),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _actualController,
              obscureText: _ocultarActual,
              decoration: InputDecoration(
                labelText: l10n.contrasenaActual,
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_ocultarActual ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _ocultarActual = !_ocultarActual),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nuevaController,
              obscureText: _ocultarNueva,
              decoration: InputDecoration(
                labelText: l10n.nuevaContrasena,
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_ocultarNueva ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _ocultarNueva = !_ocultarNueva),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmarController,
              obscureText: _ocultarConfirmar,
              decoration: InputDecoration(
                labelText: l10n.confirmarNuevaContrasena,
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_ocultarConfirmar ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _ocultarConfirmar = !_ocultarConfirmar),
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, size: 16, color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancelar),
        ),
        ElevatedButton(
          onPressed: _validarYGuardar,
          child: Text(l10n.guardar),
        ),
      ],
    );
  }
}
