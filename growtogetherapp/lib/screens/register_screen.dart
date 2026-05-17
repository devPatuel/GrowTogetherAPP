import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/utils/snack_helper.dart';
import '../core/utils/validators.dart';
import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import 'widgets/error_banner.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmarController = TextEditingController();
  bool _ocultarPassword = true;
  bool _ocultarConfirmar = true;
  String? _errorLocal;

  Future<void> _registrar() async {
    final l10n = AppLocalizations.of(context)!;
    final auth = context.read<AuthProvider>();
    final nombre = _nombreController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmar = _confirmarController.text;

    // Validaciones locales
    final errorNombre = Validators.notEmpty(nombre, l10n.validatorCampoObligatorio(l10n.nombre));
    if (errorNombre != null) { setState(() => _errorLocal = errorNombre); return; }

    final errorEmail = Validators.email(email, obligatorio: l10n.validatorEmailObligatorio, invalido: l10n.validatorEmailInvalido);
    if (errorEmail != null) { setState(() => _errorLocal = errorEmail); return; }

    final errorPassword = Validators.password(password, obligatoria: l10n.validatorContrasenaObligatoria, requisitos: l10n.validatorContrasenaRequisitos);
    if (errorPassword != null) { setState(() => _errorLocal = errorPassword); return; }

    final errorConfirmar = Validators.confirmPassword(confirmar, password, confirmar: l10n.validatorConfirmarContrasena, noCoinciden: l10n.validatorContrasenasNoCoinciden);
    if (errorConfirmar != null) { setState(() => _errorLocal = errorConfirmar); return; }

    setState(() => _errorLocal = null);

    final ok = await auth.register(nombre, email, password);
    if (ok && mounted) {
      context.showSnackSuccess(l10n.cuentaCreada);
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = context.watch<AuthProvider>();
    final errorMostrado = _errorLocal ?? auth.error;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.crearCuenta)),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 16),

              if (errorMostrado != null) ErrorBanner(mensaje: errorMostrado),

              TextField(
                controller: _nombreController,
                decoration: InputDecoration(labelText: l10n.nombre, prefixIcon: const Icon(Icons.person_outline), border: const OutlineInputBorder()),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: l10n.email, prefixIcon: const Icon(Icons.email_outlined), border: const OutlineInputBorder()),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _passwordController,
                obscureText: _ocultarPassword,
                decoration: InputDecoration(
                  labelText: l10n.contrasena, prefixIcon: const Icon(Icons.lock_outline), border: const OutlineInputBorder(),
                  suffixIcon: IconButton(icon: Icon(_ocultarPassword ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _ocultarPassword = !_ocultarPassword)),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _confirmarController,
                obscureText: _ocultarConfirmar,
                decoration: InputDecoration(
                  labelText: l10n.confirmarContrasena, prefixIcon: const Icon(Icons.lock_outline), border: const OutlineInputBorder(),
                  suffixIcon: IconButton(icon: Icon(_ocultarConfirmar ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _ocultarConfirmar = !_ocultarConfirmar)),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: auth.cargando ? null : _registrar,
                  style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Theme.of(context).colorScheme.onPrimary),
                  child: auth.cargando
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(l10n.crearCuenta, style: const TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),

              TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.yaTienesCuenta)),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
