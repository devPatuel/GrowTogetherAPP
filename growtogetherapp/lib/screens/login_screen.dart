import 'package:flutter/material.dart';
import 'package:growtogether_data/growtogether_data.dart';
import 'package:provider/provider.dart';
import '../core/utils/snack_helper.dart';
import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../services/local_notifications_service.dart';
import 'register_screen.dart';
import 'main_layout.dart';
import 'widgets/error_banner.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _ocultarPassword = true;

  @override
  void initState() {
    super.initState();
    _verificarSesion();
  }

  Future<void> _verificarSesion() async {
    final auth = context.read<AuthProvider>();
    final usuario = await auth.verificarSesion();
    if (usuario != null && mounted) {
      await _sincronizarNotificaciones(usuario.id);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainLayout()),
      );
    }
  }

  Future<void> _sincronizarNotificaciones(int usuarioId) async {
    final localNotifs = context.read<LocalNotificationsService>();
    final notificacionRepo = context.read<NotificacionRepository>();
    final habitoRepo = context.read<HabitoRepository>();
    await localNotifs.sincronizarConBackend(
      notificacionRepo: notificacionRepo,
      habitoRepo: habitoRepo,
      usuarioId: usuarioId,
    );
  }

  Future<void> _iniciarSesion() async {
    final l10n = AppLocalizations.of(context)!;
    final auth = context.read<AuthProvider>();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      auth.limpiarError();
      setState(() {});
      context.showSnackError(l10n.rellenaTodosLosCampos);
      return;
    }

    final ok = await auth.login(email, password);
    if (ok && mounted) {
      final authRepo = context.read<AuthRepository>();
      final usuario = await authRepo.getCurrentUser();
      if (!mounted) return;
      if (usuario != null) {
        await _sincronizarNotificaciones(usuario.id);
        if (!mounted) return;
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainLayout()),
      );
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
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/branding/logo_full.png',
                height: 140,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 8),
              Text(l10n.appNombre, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),

              if (auth.error != null) ErrorBanner(mensaje: auth.error!),

              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: l10n.email,
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _passwordController,
                obscureText: _ocultarPassword,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) {
                  if (!auth.cargando) _iniciarSesion();
                },
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

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: auth.cargando ? null : _iniciarSesion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  child: auth.cargando
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(l10n.iniciarSesion, style: const TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),

              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                child: Text(l10n.noTienesCuenta),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
