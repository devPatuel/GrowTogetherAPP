import 'package:flutter/material.dart';
import '../core/constants/app_strings.dart';
import '../core/utils/validators.dart';
import '../data/api/api_exceptions.dart';
import '../data/api/dio_client.dart';
import '../data/local/secure_storage_service.dart';
import '../data/repositories/auth_repository.dart';

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
  bool _cargando = false;
  bool _ocultarPassword = true;
  bool _ocultarConfirmar = true;
  String? _error;

  final _storage = SecureStorageService();
  late final _repo = AuthRepository(DioClient(_storage), _storage);

  Future<void> _registrar() async {
    final nombre = _nombreController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmar = _confirmarController.text;

    // Validaciones
    final errorNombre = Validators.notEmpty(nombre, 'El nombre');
    if (errorNombre != null) {
      setState(() => _error = errorNombre);
      return;
    }

    final errorEmail = Validators.email(email);
    if (errorEmail != null) {
      setState(() => _error = errorEmail);
      return;
    }

    final errorPassword = Validators.password(password);
    if (errorPassword != null) {
      setState(() => _error = errorPassword);
      return;
    }

    final errorConfirmar = Validators.confirmPassword(confirmar, password);
    if (errorConfirmar != null) {
      setState(() => _error = errorConfirmar);
      return;
    }

    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      await _repo.register(nombre, email, password);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.cuentaCreada)),
        );
        Navigator.pop(context);
      }
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _cargando = false);
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
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.crearCuenta)),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 16),

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

              // Nombre
              TextField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: AppStrings.nombre,
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Email
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: AppStrings.email,
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Password
              TextField(
                controller: _passwordController,
                obscureText: _ocultarPassword,
                decoration: InputDecoration(
                  labelText: AppStrings.contrasena,
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_ocultarPassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _ocultarPassword = !_ocultarPassword),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Confirmar password
              TextField(
                controller: _confirmarController,
                obscureText: _ocultarConfirmar,
                decoration: InputDecoration(
                  labelText: AppStrings.confirmarContrasena,
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_ocultarConfirmar ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _ocultarConfirmar = !_ocultarConfirmar),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Boton registro
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _cargando ? null : _registrar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B9F75),
                    foregroundColor: Colors.white,
                  ),
                  child: _cargando
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(AppStrings.crearCuenta, style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),

              // Volver a login
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(AppStrings.yaTienesCuenta),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
