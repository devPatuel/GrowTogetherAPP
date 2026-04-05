import 'package:flutter/material.dart';
import '../data/api/api_exceptions.dart';
import '../data/api/dio_client.dart';
import '../data/local/secure_storage_service.dart';
import '../data/repositories/auth_repository.dart';
import '../l10n/app_localizations.dart';
import 'register_screen.dart';
import 'main_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _cargando = false;
  bool _ocultarPassword = true;
  String? _error;

  final _storage = SecureStorageService();
  late final _repo = AuthRepository(DioClient(_storage), _storage);

  @override
  void initState() {
    super.initState();
    _verificarSesion();
  }

  Future<void> _verificarSesion() async {
    final usuario = await _repo.getCurrentUser();
    if (usuario != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainLayout()),
      );
    }
  }

  Future<void> _iniciarSesion() async {
    final l10n = AppLocalizations.of(context)!;
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = l10n.rellenaTodosLosCampos);
      return;
    }

    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      await _repo.login(email, password);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainLayout()),
        );
      }
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Icon(Icons.eco_rounded, size: 64, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8),
              Text(
                l10n.appNombre,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),

              // Error
              if (_error != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(_error!, style: TextStyle(color: Colors.red.shade700)),
                ),

              // Email
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: l10n.email,
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Password
              TextField(
                controller: _passwordController,
                obscureText: _ocultarPassword,
                decoration: InputDecoration(
                  labelText: l10n.contrasena,
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_ocultarPassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _ocultarPassword = !_ocultarPassword),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Boton login
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _cargando ? null : _iniciarSesion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  child: _cargando
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(l10n.iniciarSesion, style: const TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),

              // Ir a registro
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  );
                },
                child: Text(l10n.noTienesCuenta),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
