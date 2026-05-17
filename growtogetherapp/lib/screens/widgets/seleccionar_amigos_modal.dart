import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:growtogether_data/growtogether_data.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/amistad_provider.dart';
import 'usuario_tile.dart';

/// Bottom sheet con la lista de amigos del usuario en modo multi-select.
/// Devuelve un Set<int> con los IDs seleccionados al cerrar (o null si cancela).
class SeleccionarAmigosModal extends StatefulWidget {
  final Set<int> seleccionadosInicial;

  const SeleccionarAmigosModal({super.key, this.seleccionadosInicial = const {}});

  /// Helper para abrir el modal desde cualquier sitio.
  static Future<Set<int>?> mostrar(BuildContext context, {Set<int> inicial = const {}}) {
    return showModalBottomSheet<Set<int>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SeleccionarAmigosModal(seleccionadosInicial: inicial),
    );
  }

  @override
  State<SeleccionarAmigosModal> createState() => _SeleccionarAmigosModalState();
}

class _SeleccionarAmigosModalState extends State<SeleccionarAmigosModal> {
  late Set<int> _seleccionados;

  @override
  void initState() {
    super.initState();
    _seleccionados = {...widget.seleccionadosInicial};
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AmistadProvider>();
      if (provider.amigos.isEmpty) provider.cargarAmigos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final provider = context.watch<AmistadProvider>();
    final amigos = provider.amigos;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outline.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.seleccionarAmigos,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    Text(
                      l10n.seleccionadosContador(_seleccionados.length),
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: provider.cargandoAmigos
                    ? const Center(child: CircularProgressIndicator())
                    : amigos.isEmpty
                        ? const _SinAmigos()
                        : ListView.builder(
                            controller: scrollController,
                            itemCount: amigos.length,
                            itemBuilder: (_, i) {
                              final amigo = amigos[i];
                              final marcado = _seleccionados.contains(amigo.id);
                              return _ToggleAmigoTile(
                                usuario: amigo,
                                marcado: marcado,
                                onTap: () => _toggle(amigo.id),
                              );
                            },
                          ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(l10n.cancelar),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () => Navigator.pop(context, _seleccionados),
                          child: Text(l10n.confirmar),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _toggle(int id) {
    setState(() {
      if (_seleccionados.contains(id)) {
        _seleccionados.remove(id);
      } else {
        _seleccionados.add(id);
      }
    });
  }
}

class _ToggleAmigoTile extends StatelessWidget {
  final Usuario usuario;
  final bool marcado;
  final VoidCallback onTap;

  const _ToggleAmigoTile({
    required this.usuario,
    required this.marcado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return UsuarioTile(
      nombre: usuario.nombre,
      fotoBase64: usuario.foto,
      subtitulo: usuario.email.isEmpty ? null : usuario.email,
      trailing: Checkbox(value: marcado, onChanged: (_) => onTap()),
      onTap: onTap,
    );
  }
}

class _SinAmigos extends StatelessWidget {
  const _SinAmigos();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: colorScheme.outline),
          const SizedBox(height: 12),
          Text(
            l10n.sinAmigosParaInvitar,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
