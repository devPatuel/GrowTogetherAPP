import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/utils/snack_helper.dart';
import 'package:growtogether_data/growtogether_data.dart';
import '../l10n/app_localizations.dart';
import '../providers/amistad_provider.dart';
import 'widgets/usuario_tile.dart';

class BuscarAmigosScreen extends StatefulWidget {
  const BuscarAmigosScreen({super.key});

  @override
  State<BuscarAmigosScreen> createState() => _BuscarAmigosScreenState();
}

class _BuscarAmigosScreenState extends State<BuscarAmigosScreen> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;
  List<Usuario> _resultados = [];
  final Set<int> _enviadas = {};
  final Set<int> _enviando = {};
  bool _buscando = false;
  bool _busquedaRealizada = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String texto) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => _buscar(texto));
  }

  Future<void> _buscar(String texto) async {
    if (texto.trim().isEmpty) {
      setState(() {
        _resultados = [];
        _busquedaRealizada = false;
      });
      return;
    }
    setState(() => _buscando = true);
    final provider = context.read<AmistadProvider>();
    final lista = await provider.buscar(texto);
    if (!mounted) return;
    setState(() {
      _resultados = lista;
      _buscando = false;
      _busquedaRealizada = true;
    });
  }

  Future<void> _enviar(Usuario usuario) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _enviando.add(usuario.id));
    final provider = context.read<AmistadProvider>();
    final ok = await provider.enviarSolicitud(usuario.id);
    if (!mounted) return;
    setState(() {
      _enviando.remove(usuario.id);
      if (ok) _enviadas.add(usuario.id);
    });
    if (ok) {
      context.showSnackSuccess(l10n.solicitudEnviada);
    } else {
      context.showSnackError(provider.error ?? l10n.errorGenerico);
      provider.limpiarError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.buscarAmigos)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: l10n.buscarPorNombreOId,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _onChanged,
            ),
          ),
          if (_buscando) const LinearProgressIndicator(minHeight: 2),
          Expanded(child: _buildContenido(l10n)),
        ],
      ),
    );
  }

  Widget _buildContenido(AppLocalizations l10n) {
    if (!_busquedaRealizada && _resultados.isEmpty) {
      return _centerText(l10n.usuarioEscribeParaBuscar);
    }
    if (_busquedaRealizada && _resultados.isEmpty) {
      return _centerText(l10n.sinResultadosBusqueda);
    }
    return ListView.separated(
      itemCount: _resultados.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final u = _resultados[i];
        final enviando = _enviando.contains(u.id);
        final enviada = _enviadas.contains(u.id);
        return UsuarioTile(
          nombre: u.nombre,
          fotoBase64: u.foto,
          subtitulo: l10n.idUsuario(u.id),
          trailing: enviando
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : enviada
                  ? Text(
                      l10n.solicitudEnviada,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    )
                  : FilledButton.tonal(
                      onPressed: () => _enviar(u),
                      child: Text(l10n.enviarSolicitud),
                    ),
        );
      },
    );
  }

  Widget _centerText(String texto) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            texto,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
}
