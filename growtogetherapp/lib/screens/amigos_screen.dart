import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/utils/snack_helper.dart';
import '../data/models/solicitud_amistad.dart';
import '../data/models/usuario.dart';
import '../l10n/app_localizations.dart';
import '../providers/amistad_provider.dart';
import 'widgets/solicitud_tile.dart';
import 'widgets/usuario_tile.dart';

class AmigosScreen extends StatefulWidget {
  const AmigosScreen({super.key});

  @override
  State<AmigosScreen> createState() => _AmigosScreenState();
}

class _AmigosScreenState extends State<AmigosScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AmistadProvider>();
      provider.cargarAmigos();
      provider.cargarSolicitudes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.misAmigos),
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.amigos),
              Tab(
                child: Consumer<AmistadProvider>(
                  builder: (_, p, __) => Text(
                    p.peticionesPendientes > 0
                        ? l10n.peticionesConContador(p.peticionesPendientes)
                        : l10n.peticiones,
                  ),
                ),
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _AmigosTab(),
            _PeticionesTab(),
          ],
        ),
      ),
    );
  }
}

class _AmigosTab extends StatelessWidget {
  const _AmigosTab();

  Future<void> _confirmarEliminar(
      BuildContext context, Usuario amigo) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.eliminarAmigo),
        content: Text(l10n.confirmarEliminarAmigo(amigo.nombre)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.eliminarAmigo),
          ),
        ],
      ),
    );
    if (confirmado != true || !context.mounted) return;
    final provider = context.read<AmistadProvider>();
    final ok = await provider.eliminarAmigo(amigo.id);
    if (!context.mounted) return;
    if (!ok) {
      context.showSnackError(provider.error ?? l10n.eliminarAmigo);
      provider.limpiarError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<AmistadProvider>(
      builder: (_, provider, __) {
        if (provider.cargandoAmigos && provider.amigos.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.amigos.isEmpty) {
          return RefreshIndicator(
            onRefresh: provider.cargarAmigos,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    l10n.sinAmigosTodavia,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: provider.cargarAmigos,
          child: ListView.separated(
            itemCount: provider.amigos.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final a = provider.amigos[i];
              return UsuarioTile(
                nombre: a.nombre,
                fotoBase64: a.foto,
                subtitulo: 'ID ${a.id}',
                trailing: IconButton(
                  icon: const Icon(Icons.person_remove_outlined),
                  tooltip: l10n.eliminarAmigo,
                  onPressed: () => _confirmarEliminar(context, a),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _PeticionesTab extends StatefulWidget {
  const _PeticionesTab();

  @override
  State<_PeticionesTab> createState() => _PeticionesTabState();
}

class _PeticionesTabState extends State<_PeticionesTab> {
  final Set<int> _procesando = {};

  Future<void> _responder(
      Future<bool> Function(int) accion, SolicitudAmistad s) async {
    setState(() => _procesando.add(s.id));
    final provider = context.read<AmistadProvider>();
    final ok = await accion(s.id);
    if (!mounted) return;
    setState(() => _procesando.remove(s.id));
    if (!ok) {
      final l10n = AppLocalizations.of(context)!;
      context.showSnackError(provider.error ?? l10n.errorGenerico);
      provider.limpiarError();
    }
  }

  Future<void> _confirmarCancelar(SolicitudAmistad s) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.cancelarSolicitud),
        content: Text(l10n.confirmarCancelarSolicitud(s.destinatarioNombre)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.cancelarSolicitud),
          ),
        ],
      ),
    );
    if (confirmado != true || !mounted) return;
    await _responder(context.read<AmistadProvider>().cancelar, s);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<AmistadProvider>(
      builder: (_, provider, __) {
        if (provider.cargandoSolicitudes &&
            provider.recibidas.isEmpty &&
            provider.enviadas.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.recibidas.isEmpty && provider.enviadas.isEmpty) {
          return RefreshIndicator(
            onRefresh: provider.cargarSolicitudes,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    l10n.sinPeticionesPendientes,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: provider.cargarSolicitudes,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              if (provider.recibidas.isNotEmpty) ...[
                _SeccionHeader(titulo: l10n.peticionesRecibidas),
                ...provider.recibidas.map(
                  (s) => SolicitudTile(
                    key: ValueKey('recibida-${s.id}'),
                    solicitud: s,
                    cargando: _procesando.contains(s.id),
                    onAceptar: () => _responder(provider.aceptar, s),
                    onRechazar: () => _responder(provider.rechazar, s),
                  ),
                ),
              ],
              if (provider.enviadas.isNotEmpty) ...[
                _SeccionHeader(titulo: l10n.peticionesEnviadas),
                ...provider.enviadas.map(
                  (s) => SolicitudEnviadaTile(
                    key: ValueKey('enviada-${s.id}'),
                    solicitud: s,
                    cargando: _procesando.contains(s.id),
                    onCancelar: () => _confirmarCancelar(s),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _SeccionHeader extends StatelessWidget {
  final String titulo;
  const _SeccionHeader({required this.titulo});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        titulo,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: colorScheme.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
