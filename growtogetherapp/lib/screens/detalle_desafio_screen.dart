import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/utils/challenge_colors.dart';
import '../core/utils/habit_icons.dart';
import '../core/utils/snack_helper.dart';
import 'package:growtogether_data/growtogether_data.dart';
import '../providers/desafios_provider.dart';
import '../providers/detalle_desafio_provider.dart';
import 'widgets/multiline_chart.dart';
import 'widgets/podium_widget.dart';
import 'widgets/ranking_desafio_list.dart';

/// Pantalla de detalle de un desafío. Muestra cabecera, podio top 3, ranking,
/// gráfica multilínea de evolución de puntos y permite marcar como hecho hoy.
class DetalleDesafioScreen extends StatelessWidget {
  final Desafio desafio;

  const DetalleDesafioScreen({super.key, required this.desafio});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int?>(
      future: context.read<SecureStorageService>().getUserId(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final usuarioId = snapshot.data ?? 0;
        return ChangeNotifierProvider(
          create: (ctx) => DetalleDesafioProvider(
            ctx.read<DesafioRepository>(),
            desafio,
            usuarioId,
          ),
          child: const _DetalleDesafioBody(),
        );
      },
    );
  }
}

class _DetalleDesafioBody extends StatelessWidget {
  const _DetalleDesafioBody();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DetalleDesafioProvider>();
    final desafio = provider.desafio;
    final yo = provider.yo;
    // Mapear cada participante a un color cíclico de la paleta Playus
    final ordenadosPorOrden = [...desafio.participantes];
    ordenadosPorOrden.sort((a, b) => a.id.compareTo(b.id));
    final coloresPorUsuario = <int, Color>{};
    for (int i = 0; i < ordenadosPorOrden.length; i++) {
      coloresPorUsuario[ordenadosPorOrden[i].usuarioId] = ChallengeColors.paraIndice(i);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(desafio.nombre),
        actions: [
          if (provider.soyCreador)
            IconButton(
              tooltip: 'Editar',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _mostrarDialogoEditar(context, provider),
            ),
          if (provider.soyCreador)
            IconButton(
              tooltip: 'Eliminar',
              icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
              onPressed: () => _confirmarEliminar(context, provider),
            )
          else if (yo != null && yo.activo)
            IconButton(
              tooltip: 'Abandonar',
              icon: const Icon(Icons.exit_to_app),
              onPressed: () => _confirmarAbandonar(context, provider),
            ),
        ],
      ),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          Navigator.pop(context, provider.huboCambios);
        },
        child: RefreshIndicator(
          onRefresh: () async {
            await provider.recargar();
            await provider.cargarHistorial();
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
            children: [
              _Cabecera(desafio: desafio),
              if (yo != null && yo.activo && !desafio.finalizado)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: _BotonMarcarHecho(provider: provider, yo: yo),
                ),
              if (desafio.participantes.isNotEmpty) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Podio',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: PodiumWidget(
                    participantes: desafio.participantes,
                    coloresPorUsuario: coloresPorUsuario,
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Evolución',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: MultilineChart(
                    series: provider.seriesPorParticipante(),
                    coloresPorUsuario: coloresPorUsuario,
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Ranking',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: RankingDesafioList(
                    participantes: desafio.participantes,
                    coloresPorUsuario: coloresPorUsuario,
                    usuarioActualId: provider.usuarioActualId,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _mostrarDialogoEditar(
      BuildContext context, DetalleDesafioProvider provider) async {
    final desafio = provider.desafio;
    final nombreCtrl = TextEditingController(text: desafio.nombre);
    final descCtrl = TextEditingController(text: desafio.descripcion);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar desafío'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreCtrl,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: 'Descripción'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Guardar')),
        ],
      ),
    );
    if (ok == true) {
      final res = await provider.editar(
        nombre: nombreCtrl.text.trim(),
        descripcion: descCtrl.text.trim(),
      );
      if (context.mounted) {
        if (res) {
          context.showSnackSuccess('Desafío actualizado');
        } else {
          context.showSnackError('No se pudo actualizar');
        }
      }
    }
  }

  Future<void> _confirmarEliminar(
      BuildContext context, DetalleDesafioProvider provider) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar desafío'),
        content: const Text('¿Seguro que quieres eliminar este desafío? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (ok == true) {
      final res = await provider.eliminar();
      if (context.mounted) {
        if (res) {
          // Refrescar lista antes de pop
          context.read<DesafiosProvider>().cargar();
          context.showSnackSuccess('Desafío eliminado');
          Navigator.pop(context, true);
        } else {
          context.showSnackError('No se pudo eliminar');
        }
      }
    }
  }

  Future<void> _confirmarAbandonar(
      BuildContext context, DetalleDesafioProvider provider) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Abandonar desafío'),
        content: const Text('¿Seguro que quieres abandonar este desafío? Tu histórico se conservará pero ya no podrás puntuar.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Abandonar')),
        ],
      ),
    );
    if (ok == true) {
      final res = await provider.abandonar();
      if (context.mounted) {
        if (res) {
          context.read<DesafiosProvider>().cargar();
          context.showSnackSuccess('Has abandonado el desafío');
          Navigator.pop(context, true);
        } else {
          context.showSnackError('No se pudo abandonar');
        }
      }
    }
  }
}

class _Cabecera extends StatelessWidget {
  final Desafio desafio;
  const _Cabecera({required this.desafio});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconoDesafio = HabitIcons.getIcon(desafio.icono);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primaryContainer.withValues(alpha: 0.4),
            colorScheme.surface,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(iconoDesafio,
                    color: colorScheme.primary, size: 30),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            desafio.nombre,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        if (desafio.esNegativo) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: colorScheme.error,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'NEGATIVO',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Por ${desafio.creadorNombre}',
                      style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (desafio.descripcion.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              desafio.descripcion,
              style: const TextStyle(fontSize: 14),
            ),
          ],
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Chip(
                icon: desafio.frecuencia == 'DIARIO'
                    ? Icons.calendar_today
                    : Icons.event_repeat,
                texto: desafio.frecuencia == 'DIARIO' ? 'Diario' : 'Personalizado',
              ),
              _Chip(
                icon: Icons.schedule,
                texto: desafio.finalizado
                    ? 'Finalizado'
                    : 'Quedan ${desafio.diasRestantes} días',
              ),
              _Chip(
                icon: Icons.group,
                texto: '${desafio.participantes.where((p) => !p.abandonado).length} participantes',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String texto;
  const _Chip({required this.icon, required this.texto});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            texto,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _BotonMarcarHecho extends StatelessWidget {
  final DetalleDesafioProvider provider;
  final ParticipanteDesafio yo;
  const _BotonMarcarHecho({required this.provider, required this.yo});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hecho = yo.completadoHoy;
    final puntosSiguientes = yo.puntosSiguientes;
    final multiplicador = yo.multiplicadorSiguiente;

    final color = hecho ? ChallengeColors.gemaVerde : colorScheme.primary;
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: provider.toggling
            ? null
            : () async {
                final ok = await provider.toggleCompletarHoy();
                if (context.mounted) {
                  if (ok) {
                    context.showSnackSuccess(
                        hecho ? 'Día desmarcado' : '¡+$puntosSiguientes! Sigue así');
                  } else {
                    context.showSnackError('No se pudo actualizar');
                  }
                }
              },
        icon: provider.toggling
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Icon(hecho ? Icons.check_circle : Icons.add_task),
        label: Text(
          hecho
              ? 'Hecho hoy · racha ${yo.rachaActual}'
              : 'Marcar hoy  +$puntosSiguientes  (x${multiplicador.toStringAsFixed(1)})',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
