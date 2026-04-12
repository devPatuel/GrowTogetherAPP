import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../core/l10n/locale_controller.dart';
import '../core/theme/app_themes.dart';
import '../core/theme/theme_controller.dart';
import '../core/utils/snack_helper.dart';
import '../core/utils/validators.dart';
import '../data/models/usuario.dart';
import '../l10n/app_localizations.dart';
import '../providers/perfil_provider.dart';
import 'login_screen.dart';
import 'widgets/dialogo_cambiar_contrasena.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PerfilProvider>().cargar();
  }

  void _irALogin({String? mensaje}) {
    context.read<PerfilProvider>().cerrarSesion();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
    if (mensaje != null) context.showSnack(mensaje);
  }

  // --- Editar foto ---
  Future<void> _editarFoto() async {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final perfil = context.read<PerfilProvider>();
    final tienePhoto = perfil.usuario?.foto != null && perfil.usuario!.foto!.isNotEmpty;

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
    // maxWidth 150 + quality 40 para mantener el base64 en ~3-5KB
    final picked = await picker.pickImage(source: source, maxWidth: 150, imageQuality: 40);
    if (picked == null) return;

    try {
      final bytes = await picked.readAsBytes();
      final base64Str = base64Encode(bytes);
      final ok = await perfil.editarFoto(base64Str);
      if (mounted) {
        if (ok) {
          context.showSnack(l10n.fotoActualizada);
        } else {
          context.showSnackError(perfil.error ?? l10n.errorGenerico);
        }
      }
    } catch (e) {
      if (mounted) context.showSnackError(e.toString());
    }
  }

  Future<void> _quitarFoto() async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await context.read<PerfilProvider>().quitarFoto();
    if (mounted && ok) context.showSnack(l10n.fotoEliminada);
  }

  // --- Editar nombre ---
  Future<void> _editarNombre() async {
    final l10n = AppLocalizations.of(context)!;
    final perfil = context.read<PerfilProvider>();
    final controller = TextEditingController(text: perfil.usuario?.nombre ?? '');
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

    if (resultado == null || resultado.isEmpty || resultado == perfil.usuario?.nombre) return;

    final ok = await perfil.editarNombre(resultado);
    if (mounted && ok) context.showSnack(l10n.perfilActualizado);
  }

  // --- Editar email (cierra sesion porque invalida el JWT) ---
  Future<void> _editarEmail() async {
    final l10n = AppLocalizations.of(context)!;
    final perfil = context.read<PerfilProvider>();
    final controller = TextEditingController(text: perfil.usuario?.email ?? '');
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

    if (nuevoEmail == null || nuevoEmail.isEmpty || nuevoEmail == perfil.usuario?.email) return;

    final errorEmail = Validators.email(
      nuevoEmail,
      obligatorio: l10n.validatorEmailObligatorio,
      invalido: l10n.validatorEmailInvalido,
    );
    if (errorEmail != null) {
      if (mounted) context.showSnack(errorEmail);
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

    final ok = await perfil.editarEmail(nuevoEmail);
    if (ok && mounted) {
      _irALogin(mensaje: l10n.sesionCerradaPorCambio);
    }
  }

  // --- Cambiar contrasena (cierra sesion porque invalida el JWT via tokenVersion) ---
  Future<void> _cambiarContrasena() async {
    final l10n = AppLocalizations.of(context)!;
    final resultado = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => const DialogoCambiarContrasena(),
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

    final ok = await context.read<PerfilProvider>().cambiarContrasena(resultado['actual']!, resultado['nueva']!);
    if (ok && mounted) {
      _irALogin(mensaje: l10n.sesionCerradaPorCambio);
    } else if (!ok && mounted) {
      context.showSnackError(context.read<PerfilProvider>().error ?? l10n.errorGenerico);
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
  void _sincronizarPreferenciasConApi({String? tema, String? idioma}) {
    context.read<PerfilProvider>().sincronizarPreferencias(tema: tema, idioma: idioma);
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
                  title: Text(switch (tipo) {
                    AppThemeType.claro => l10n.temaClaro,
                    AppThemeType.oscuro => l10n.temaOscuro,
                    AppThemeType.morado => l10n.temaMorado,
                    AppThemeType.naturaleza => l10n.temaNaturaleza,
                  }),
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

    final perfil = context.watch<PerfilProvider>();

    if (perfil.cargando && perfil.usuario == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (perfil.error != null && perfil.usuario == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(perfil.error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => perfil.cargar(),
              child: Text(l10n.reintentar),
            ),
          ],
        ),
      );
    }

    final usuario = perfil.usuario;
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
          const SizedBox(height: 24),

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
                switch (ThemeController.instance.value) {
                  AppThemeType.claro => l10n.temaClaro,
                  AppThemeType.oscuro => l10n.temaOscuro,
                  AppThemeType.morado => l10n.temaMorado,
                  AppThemeType.naturaleza => l10n.temaNaturaleza,
                },
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
    if (usuario.foto != null && usuario.foto!.isNotEmpty) {
      try {
        final bytes = base64Decode(usuario.foto!);
        return MemoryImage(bytes);
      } catch (_) {
        return null;
      }
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
