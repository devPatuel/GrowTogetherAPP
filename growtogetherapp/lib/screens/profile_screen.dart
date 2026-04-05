import 'package:flutter/material.dart';
import '../core/constants/app_strings.dart';
import '../core/utils/validators.dart';
import '../data/api/api_exceptions.dart';
import '../data/api/dio_client.dart';
import '../data/local/secure_storage_service.dart';
import '../data/models/usuario.dart';
import '../data/repositories/user_repository.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _storage = SecureStorageService();
  late final _repo = UserRepository(DioClient(_storage));

  Usuario? _usuario;
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  Future<void> _cargarPerfil() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final id = await _storage.getUserId();
      if (id == null) return;
      final usuario = await _repo.obtenerPerfil(id);
      if (mounted) setState(() => _usuario = usuario);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _irALogin({String? mensaje}) {
    _storage.deleteAll();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
    if (mensaje != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensaje)),
      );
    }
  }

  // --- Editar foto ---
  Future<void> _editarFoto() async {
    final controller = TextEditingController(text: _usuario?.foto ?? '');
    final resultado = await showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.cambiarFoto),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: AppStrings.urlFoto,
            hintText: 'https://...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          if (_usuario?.foto != null)
            TextButton(
              onPressed: () => Navigator.pop(ctx, ''),
              child: Text(AppStrings.quitarFoto, style: TextStyle(color: Colors.red.shade400)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(AppStrings.cancelar),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text(AppStrings.guardar),
          ),
        ],
      ),
    );

    if (resultado == null) return; // Canceló

    try {
      final id = await _storage.getUserId();
      if (id == null) return;
      final foto = resultado.isEmpty ? null : resultado;
      await _repo.editarPerfil(id, foto: foto ?? '');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.perfilActualizado)),
        );
      }
      _cargarPerfil();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  // --- Editar nombre ---
  Future<void> _editarNombre() async {
    final controller = TextEditingController(text: _usuario?.nombre ?? '');
    final resultado = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.editarNombre),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: AppStrings.nombre,
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(AppStrings.cancelar),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text(AppStrings.guardar),
          ),
        ],
      ),
    );

    if (resultado == null || resultado.isEmpty || resultado == _usuario?.nombre) return;

    try {
      final id = await _storage.getUserId();
      if (id == null) return;
      await _repo.editarPerfil(id, nombre: resultado);
      await _storage.saveUserName(resultado);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.perfilActualizado)),
        );
      }
      _cargarPerfil();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  // --- Editar email (cierra sesion porque invalida el JWT) ---
  Future<void> _editarEmail() async {
    final controller = TextEditingController(text: _usuario?.email ?? '');
    final nuevoEmail = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.editarEmail),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: AppStrings.email,
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(AppStrings.cancelar),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text(AppStrings.guardar),
          ),
        ],
      ),
    );

    if (nuevoEmail == null || nuevoEmail.isEmpty || nuevoEmail == _usuario?.email) return;

    final errorEmail = Validators.email(nuevoEmail);
    if (errorEmail != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorEmail)));
      }
      return;
    }

    // Confirmar que se cerrará sesión
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.editarEmail),
        content: const Text(AppStrings.confirmarCambioEmail),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(AppStrings.cancelar),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(AppStrings.continuar),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      final id = await _storage.getUserId();
      if (id == null) return;
      await _repo.editarPerfil(id, email: nuevoEmail);
      _irALogin(mensaje: AppStrings.sesionCerradaPorCambio);
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  // --- Cambiar contraseña (cierra sesion porque invalida el JWT via tokenVersion) ---
  Future<void> _cambiarContrasena() async {
    final resultado = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => const _DialogoCambiarContrasena(),
    );

    if (resultado == null) return;

    // Confirmar que se cerrará sesión
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.cambiarContrasena),
        content: const Text(AppStrings.confirmarCambioContrasena),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(AppStrings.cancelar),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(AppStrings.continuar),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      final id = await _storage.getUserId();
      if (id == null) return;
      await _repo.cambiarContrasena(id, resultado['actual']!, resultado['nueva']!);
      _irALogin(mensaje: AppStrings.sesionCerradaPorCambio);
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  // --- Cerrar sesion ---
  Future<void> _cerrarSesion() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.cerrarSesion),
        content: const Text(AppStrings.confirmarCerrarSesion),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(AppStrings.cancelar),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text(AppStrings.cerrarSesion),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      _irALogin();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _cargarPerfil,
              child: const Text(AppStrings.reintentar),
            ),
          ],
        ),
      );
    }

    final usuario = _usuario;
    if (usuario == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 16),

          // Avatar (tappable para editar)
          GestureDetector(
            onTap: _editarFoto,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: const Color(0xFF6B9F75).withValues(alpha: 0.2),
                  backgroundImage: usuario.foto != null && usuario.foto!.isNotEmpty
                      ? NetworkImage(usuario.foto!)
                      : null,
                  child: usuario.foto == null || usuario.foto!.isEmpty
                      ? const Icon(Icons.person, size: 48, color: Color(0xFF6B9F75))
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFF6B9F75),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Nombre
          Text(
            usuario.nombre,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),

          // Email
          Text(
            usuario.email,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),

          // Puntos
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF6B9F75).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: Color(0xFF6B9F75), size: 20),
                const SizedBox(width: 4),
                Text(
                  '${usuario.puntosTotales} ${AppStrings.puntos}',
                  style: const TextStyle(
                    color: Color(0xFF6B9F75),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Seccion: Informacion de cuenta
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              AppStrings.informacionCuenta,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          const SizedBox(height: 12),

          _buildOpcion(
            icono: Icons.person_outline,
            titulo: AppStrings.nombre,
            valor: usuario.nombre,
            onTap: _editarNombre,
          ),
          _buildOpcion(
            icono: Icons.email_outlined,
            titulo: AppStrings.email,
            valor: usuario.email,
            onTap: _editarEmail,
          ),
          _buildOpcion(
            icono: Icons.lock_outline,
            titulo: AppStrings.contrasena,
            valor: '••••••••',
            onTap: _cambiarContrasena,
          ),

          const SizedBox(height: 32),

          // Cerrar sesion
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: _cerrarSesion,
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text(AppStrings.cerrarSesion),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildOpcion({
    required IconData icono,
    required String titulo,
    required String valor,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icono, color: const Color(0xFF6B9F75)),
        title: Text(titulo, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        subtitle: Text(valor, style: const TextStyle(fontSize: 15)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

/// Dialogo para cambiar contraseña con 3 campos y toggles de visibilidad.
class _DialogoCambiarContrasena extends StatefulWidget {
  const _DialogoCambiarContrasena();

  @override
  State<_DialogoCambiarContrasena> createState() => _DialogoCambiarContrasenaState();
}

class _DialogoCambiarContrasenaState extends State<_DialogoCambiarContrasena> {
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
    final errorPassword = Validators.password(_nuevaController.text);
    if (errorPassword != null) {
      setState(() => _error = errorPassword);
      return;
    }
    if (_nuevaController.text != _confirmarController.text) {
      setState(() => _error = AppStrings.contrasenasNoCoinciden);
      return;
    }
    if (_actualController.text.isEmpty) {
      setState(() => _error = AppStrings.rellenaTodosLosCampos);
      return;
    }
    Navigator.pop(context, {
      'actual': _actualController.text,
      'nueva': _nuevaController.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AppStrings.cambiarContrasena),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(_error!, style: TextStyle(color: Colors.red.shade700, fontSize: 13)),
              ),
            TextField(
              controller: _actualController,
              obscureText: _ocultarActual,
              decoration: InputDecoration(
                labelText: AppStrings.contrasenaActual,
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
                labelText: AppStrings.nuevaContrasena,
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
                labelText: AppStrings.confirmarNuevaContrasena,
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_ocultarConfirmar ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _ocultarConfirmar = !_ocultarConfirmar),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(AppStrings.cancelar),
        ),
        ElevatedButton(
          onPressed: _validarYGuardar,
          child: const Text(AppStrings.guardar),
        ),
      ],
    );
  }
}
