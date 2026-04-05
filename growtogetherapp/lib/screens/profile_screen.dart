import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../core/l10n/locale_controller.dart';
import '../core/theme/app_themes.dart';
import '../core/theme/theme_controller.dart';
import '../core/utils/validators.dart';
import '../data/api/api_exceptions.dart';
import '../data/api/dio_client.dart';
import '../data/local/secure_storage_service.dart';
import '../data/models/usuario.dart';
import '../data/repositories/user_repository.dart';
import '../l10n/app_localizations.dart';
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
  String? _fotoLocalPath;

  @override
  void initState() {
    super.initState();
    _cargarFotoLocal();
    _cargarPerfil();
  }

  Future<void> _cargarFotoLocal() async {
    final path = await _storage.getProfilePhotoPath();
    if (path != null && File(path).existsSync()) {
      if (mounted) setState(() => _fotoLocalPath = path);
    } else if (path != null) {
      await _storage.deleteProfilePhotoPath();
    }
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
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final tienePhoto = _fotoLocalPath != null ||
        (_usuario?.foto != null && _usuario!.foto!.isNotEmpty);

    final accion = await showModalBottomSheet<_FotoAccion>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.cambiarFoto,
                style: Theme.of(ctx).textTheme.titleMedium,
              ),
            ),
            ListTile(
              leading: Icon(Icons.camera_alt, color: colorScheme.primary),
              title: Text(l10n.tomarFoto),
              onTap: () => Navigator.pop(ctx, _FotoAccion.camara),
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: colorScheme.primary),
              title: Text(l10n.elegirDeGaleria),
              onTap: () => Navigator.pop(ctx, _FotoAccion.galeria),
            ),
            if (tienePhoto)
              ListTile(
                leading: Icon(Icons.delete_outline, color: Colors.red.shade400),
                title: Text(
                  l10n.quitarFoto,
                  style: TextStyle(color: Colors.red.shade400),
                ),
                onTap: () => Navigator.pop(ctx, _FotoAccion.quitar),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (accion == null) return;

    if (accion == _FotoAccion.quitar) {
      await _quitarFoto();
      return;
    }

    final source = accion == _FotoAccion.camara
        ? ImageSource.camera
        : ImageSource.gallery;

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, maxWidth: 800, imageQuality: 85);
    if (picked == null) return;

    try {
      final appDir = await getApplicationDocumentsDirectory();
      final destino = '${appDir.path}/profile_photo.jpg';
      await File(picked.path).copy(destino);

      await _storage.saveProfilePhotoPath(destino);
      if (mounted) setState(() => _fotoLocalPath = destino);

      final id = await _storage.getUserId();
      if (id != null) {
        await _repo.editarPerfil(id, foto: 'local_photo');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.fotoActualizada)),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    }
  }

  Future<void> _quitarFoto() async {
    final l10n = AppLocalizations.of(context)!;
    if (_fotoLocalPath != null) {
      final file = File(_fotoLocalPath!);
      if (file.existsSync()) await file.delete();
      await _storage.deleteProfilePhotoPath();
    }

    setState(() => _fotoLocalPath = null);

    try {
      final id = await _storage.getUserId();
      if (id != null) {
        await _repo.editarPerfil(id, foto: '');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.fotoEliminada)),
        );
      }
      _cargarPerfil();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    }
  }

  // --- Editar nombre ---
  Future<void> _editarNombre() async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: _usuario?.nombre ?? '');
    final resultado = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.editarNombre),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: l10n.nombre,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancelar),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(l10n.guardar),
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
          SnackBar(content: Text(l10n.perfilActualizado)),
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
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: _usuario?.email ?? '');
    final nuevoEmail = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.editarEmail),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: l10n.email,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancelar),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(l10n.guardar),
          ),
        ],
      ),
    );

    if (nuevoEmail == null || nuevoEmail.isEmpty || nuevoEmail == _usuario?.email) return;

    final errorEmail = Validators.email(
      nuevoEmail,
      obligatorio: l10n.validatorEmailObligatorio,
      invalido: l10n.validatorEmailInvalido,
    );
    if (errorEmail != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorEmail)));
      }
      return;
    }

    // Confirmar que se cerrara sesion
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.editarEmail),
        content: Text(l10n.confirmarCambioEmail),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancelar),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.continuar),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      final id = await _storage.getUserId();
      if (id == null) return;
      await _repo.editarPerfil(id, email: nuevoEmail);
      _irALogin(mensaje: l10n.sesionCerradaPorCambio);
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  // --- Cambiar contrasena (cierra sesion porque invalida el JWT via tokenVersion) ---
  Future<void> _cambiarContrasena() async {
    final l10n = AppLocalizations.of(context)!;
    final resultado = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => const _DialogoCambiarContrasena(),
    );

    if (resultado == null) return;

    // Confirmar que se cerrara sesion
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.cambiarContrasena),
        content: Text(l10n.confirmarCambioContrasena),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancelar),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.continuar),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      final id = await _storage.getUserId();
      if (id == null) return;
      await _repo.cambiarContrasena(id, resultado['actual']!, resultado['nueva']!);
      _irALogin(mensaje: l10n.sesionCerradaPorCambio);
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  // --- Cerrar sesion ---
  Future<void> _cerrarSesion() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.cerrarSesion),
        content: Text(l10n.confirmarCerrarSesion),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancelar),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: Text(l10n.cerrarSesion),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      _irALogin();
    }
  }

  /// Sincroniza preferencias (tema y/o idioma) con la API.
  /// Si falla, se ignora silenciosamente — el valor local ya esta guardado.
  Future<void> _sincronizarPreferenciasConApi({String? tema, String? idioma}) async {
    try {
      final id = await _storage.getUserId();
      if (id == null) return;
      await _repo.actualizarPreferencias(id, tema: tema, idioma: idioma);
    } catch (_) {
      // Fallo silencioso: la preferencia local ya se aplico
    }
  }

  // --- Selector de tema ---
  void _mostrarSelectorTema() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  l10n.elegirTema,
                  style: Theme.of(ctx).textTheme.titleMedium,
                ),
              ),
              ...AppThemeType.values.map((tipo) {
                final seleccionado = ThemeController.instance.value == tipo;
                return ListTile(
                  leading: Icon(
                    AppThemes.icon(tipo),
                    color: AppThemes.previewColor(tipo),
                  ),
                  title: Text(AppThemes.label(tipo)),
                  trailing: seleccionado
                      ? Icon(Icons.check, color: Theme.of(ctx).colorScheme.primary)
                      : null,
                  onTap: () {
                    ThemeController.instance.cambiar(tipo);
                    Navigator.pop(ctx);
                    _sincronizarPreferenciasConApi(
                      tema: AppThemes.toApiString(tipo),
                    );
                  },
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  // --- Selector de idioma ---
  void _mostrarSelectorIdioma() {
    final l10n = AppLocalizations.of(context)!;
    final localeActual = LocaleController.instance.value;

    final opciones = [
      (locale: const Locale('es'), label: l10n.castellano, icon: '🇪🇸'),
      (locale: const Locale('en'), label: l10n.ingles, icon: '🇬🇧'),
      (locale: const Locale('ca'), label: l10n.valenciano, icon: '🏳️'),
    ];

    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  l10n.elegirIdioma,
                  style: Theme.of(ctx).textTheme.titleMedium,
                ),
              ),
              ...opciones.map((opcion) {
                final seleccionado = localeActual == opcion.locale;
                return ListTile(
                  leading: Text(opcion.icon, style: const TextStyle(fontSize: 24)),
                  title: Text(opcion.label),
                  trailing: seleccionado
                      ? Icon(Icons.check, color: Theme.of(ctx).colorScheme.primary)
                      : null,
                  onTap: () {
                    LocaleController.instance.cambiar(opcion.locale);
                    Navigator.pop(ctx);
                    _sincronizarPreferenciasConApi(
                      idioma: opcion.locale.languageCode,
                    );
                  },
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  String _getNombreIdiomaActual(AppLocalizations l10n) {
    final code = LocaleController.instance.value.languageCode;
    switch (code) {
      case 'en':
        return l10n.ingles;
      case 'ca':
        return l10n.valenciano;
      default:
        return l10n.castellano;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

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
              child: Text(l10n.reintentar),
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
                  backgroundColor: colorScheme.primary.withValues(alpha: 0.2),
                  backgroundImage: _resolverImagenAvatar(usuario),
                  child: _resolverImagenAvatar(usuario) == null
                      ? Icon(Icons.person, size: 48, color: colorScheme.primary)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
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
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, color: colorScheme.primary, size: 20),
                const SizedBox(width: 4),
                Text(
                  '${usuario.puntosTotales} ${l10n.puntos}',
                  style: TextStyle(
                    color: colorScheme.primary,
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
              l10n.informacionCuenta,
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
            titulo: l10n.nombre,
            valor: usuario.nombre,
            onTap: _editarNombre,
          ),
          _buildOpcion(
            icono: Icons.email_outlined,
            titulo: l10n.email,
            valor: usuario.email,
            onTap: _editarEmail,
          ),
          _buildOpcion(
            icono: Icons.lock_outline,
            titulo: l10n.contrasena,
            valor: '••••••••',
            onTap: _cambiarContrasena,
          ),

          const SizedBox(height: 32),

          // Seccion: Ajustes
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              l10n.ajustes,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          const SizedBox(height: 12),

          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Icon(Icons.palette_outlined, color: colorScheme.primary),
              title: Text(l10n.tema, style: const TextStyle(fontSize: 13, color: Colors.grey)),
              subtitle: Text(
                AppThemes.label(ThemeController.instance.value),
                style: const TextStyle(fontSize: 15),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _mostrarSelectorTema,
            ),
          ),

          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Icon(Icons.language, color: colorScheme.primary),
              title: Text(l10n.idioma, style: const TextStyle(fontSize: 13, color: Colors.grey)),
              subtitle: Text(
                _getNombreIdiomaActual(l10n),
                style: const TextStyle(fontSize: 15),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _mostrarSelectorIdioma,
            ),
          ),

          const SizedBox(height: 32),

          // Cerrar sesion
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: _cerrarSesion,
              icon: const Icon(Icons.logout, color: Colors.red),
              label: Text(l10n.cerrarSesion),
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

  ImageProvider? _resolverImagenAvatar(Usuario usuario) {
    if (_fotoLocalPath != null && File(_fotoLocalPath!).existsSync()) {
      return FileImage(File(_fotoLocalPath!));
    }
    if (usuario.foto != null &&
        usuario.foto!.isNotEmpty &&
        usuario.foto != 'local_photo') {
      return NetworkImage(usuario.foto!);
    }
    return null;
  }

  Widget _buildOpcion({
    required IconData icono,
    required String titulo,
    required String valor,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icono, color: colorScheme.primary),
        title: Text(titulo, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        subtitle: Text(valor, style: const TextStyle(fontSize: 15)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

enum _FotoAccion { camara, galeria, quitar }

/// Dialogo para cambiar contrasena con 3 campos y toggles de visibilidad.
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
    final l10n = AppLocalizations.of(context)!;
    final errorPassword = Validators.password(
      _nuevaController.text,
      obligatoria: l10n.validatorContrasenaObligatoria,
      minimo: l10n.validatorContrasenaMinimo,
      mayuscula: l10n.validatorContrasenaMayuscula,
      minuscula: l10n.validatorContrasenaMinuscula,
      numero: l10n.validatorContrasenaNumero,
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
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(_error!, style: TextStyle(color: Colors.red.shade700, fontSize: 13)),
              ),
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
