import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:growtogether_data/growtogether_data.dart';
import '../providers/desafios_provider.dart';
import 'detalle_desafio_screen.dart';
import 'widgets/desafio_card.dart';
import 'widgets/error_banner.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  int? _usuarioId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final id = await context.read<SecureStorageService>().getUserId();
      if (!mounted) return;
      setState(() => _usuarioId = id);
      context.read<DesafiosProvider>().cargar();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DesafiosProvider>();
    if (provider.cargando && provider.desafios.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    final activos = provider.desafiosActivos;
    final finalizados = provider.desafiosFinalizados;

    return RefreshIndicator(
      onRefresh: () => provider.cargar(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
        children: [
          if (provider.error != null) ErrorBanner(mensaje: provider.error!),
          if (activos.isEmpty && finalizados.isEmpty)
            _EstadoVacio(),
          if (activos.isNotEmpty) ...[
            const _TituloSeccion(texto: 'Activos'),
            ...activos.map((d) => DesafioCard(
                  desafio: d,
                  usuarioActualId: _usuarioId ?? 0,
                  onTap: () => _abrirDetalle(d),
                )),
          ],
          if (finalizados.isNotEmpty) ...[
            const SizedBox(height: 16),
            const _TituloSeccion(texto: 'Finalizados'),
            ...finalizados.map((d) => DesafioCard(
                  desafio: d,
                  usuarioActualId: _usuarioId ?? 0,
                  onTap: () => _abrirDetalle(d),
                )),
          ],
        ],
      ),
    );
  }

  Future<void> _abrirDetalle(Desafio desafio) async {
    final huboCambios = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => DetalleDesafioScreen(desafio: desafio)),
    );
    if (huboCambios == true && mounted) {
      context.read<DesafiosProvider>().cargar();
    }
  }
}

class _TituloSeccion extends StatelessWidget {
  final String texto;
  const _TituloSeccion({required this.texto});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: Text(
        texto,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
      ),
    );
  }
}

class _EstadoVacio extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      child: Column(
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 80,
            color: colorScheme.primary.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'Aún no tienes desafíos',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pulsa + para crear un desafío e invitar a tus amigos',
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
