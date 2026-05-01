import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/utils/challenge_colors.dart';
import 'package:growtogether_data/growtogether_data.dart';
import 'gema_puntos.dart';

/// Podio top 3 estilo Playus: tres barras de colores con alturas distintas,
/// avatar circular sobre cada barra y corona dorada sobre el #1.
class PodiumWidget extends StatelessWidget {
  final List<ParticipanteDesafio> participantes;
  final Map<int, Color> coloresPorUsuario;

  const PodiumWidget({
    super.key,
    required this.participantes,
    required this.coloresPorUsuario,
  });

  @override
  Widget build(BuildContext context) {
    if (participantes.isEmpty) return const SizedBox.shrink();
    // Top 3 ordenados por puntos
    final activos = participantes.where((p) => !p.abandonado).toList()
      ..sort((a, b) => b.puntosGanados.compareTo(a.puntosGanados));
    final top = activos.take(3).toList();
    if (top.isEmpty) return const SizedBox.shrink();

    final segundo = top.length > 1 ? top[1] : null;
    final primero = top[0];
    final tercero = top.length > 2 ? top[2] : null;

    return SizedBox(
      height: 230,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: _BarraPodio(
              participante: segundo,
              color: segundo != null
                  ? coloresPorUsuario[segundo.usuarioId] ?? ChallengeColors.gemaVerde
                  : Colors.grey,
              altura: 130,
              corona: false,
              posicion: 2,
            ),
          ),
          Expanded(
            child: _BarraPodio(
              participante: primero,
              color: coloresPorUsuario[primero.usuarioId] ?? ChallengeColors.gemaVerde,
              altura: 180,
              corona: true,
              posicion: 1,
            ),
          ),
          Expanded(
            child: _BarraPodio(
              participante: tercero,
              color: tercero != null
                  ? coloresPorUsuario[tercero.usuarioId] ?? ChallengeColors.gemaVerde
                  : Colors.grey,
              altura: 90,
              corona: false,
              posicion: 3,
            ),
          ),
        ],
      ),
    );
  }
}

class _BarraPodio extends StatelessWidget {
  final ParticipanteDesafio? participante;
  final Color color;
  final double altura;
  final bool corona;
  final int posicion;

  const _BarraPodio({
    required this.participante,
    required this.color,
    required this.altura,
    required this.corona,
    required this.posicion,
  });

  @override
  Widget build(BuildContext context) {
    if (participante == null) {
      return SizedBox(height: altura);
    }
    final p = participante!;
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          height: altura,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: altura - 32,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (corona)
                const Icon(Icons.emoji_events,
                    size: 30, color: ChallengeColors.coronaOro),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: color, width: 3),
                    ),
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: color.withValues(alpha: 0.2),
                      backgroundImage: _decodificar(p.foto),
                      child: _decodificar(p.foto) == null
                          ? Text(
                              p.nombre.isNotEmpty
                                  ? p.nombre[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            )
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: -8,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: GemaPuntos(puntos: p.puntosGanados, tamano: 11),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 8,
          child: Text(
            p.nombre,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  ImageProvider? _decodificar(String? foto) {
    if (foto == null || foto.isEmpty) return null;
    try {
      return MemoryImage(base64Decode(foto));
    } catch (_) {
      return null;
    }
  }
}
