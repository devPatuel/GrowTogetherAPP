import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/utils/challenge_colors.dart';
import '../../data/models/participante_desafio.dart';
import 'gema_puntos.dart';

/// Lista vertical del ranking del desafío. Cada fila tiene un borde con el color
/// asignado al participante (mismo color que en el podio y la gráfica).
/// Resalta sutilmente la fila del usuario actual.
class RankingDesafioList extends StatelessWidget {
  final List<ParticipanteDesafio> participantes;
  final Map<int, Color> coloresPorUsuario;
  final int usuarioActualId;

  const RankingDesafioList({
    super.key,
    required this.participantes,
    required this.coloresPorUsuario,
    required this.usuarioActualId,
  });

  @override
  Widget build(BuildContext context) {
    final activos = participantes.where((p) => !p.abandonado).toList()
      ..sort((a, b) => b.puntosGanados.compareTo(a.puntosGanados));
    return Column(
      children: [
        for (int i = 0; i < activos.length; i++)
          _FilaRanking(
            participante: activos[i],
            posicion: i + 1,
            color: coloresPorUsuario[activos[i].usuarioId] ?? ChallengeColors.gemaVerde,
            esYo: activos[i].usuarioId == usuarioActualId,
          ),
      ],
    );
  }
}

class _FilaRanking extends StatelessWidget {
  final ParticipanteDesafio participante;
  final int posicion;
  final Color color;
  final bool esYo;

  const _FilaRanking({
    required this.participante,
    required this.posicion,
    required this.color,
    required this.esYo,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: esYo ? 0.7 : 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.7), width: 2),
      ),
      child: Row(
        children: [
          Text(
            '#$posicion',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
            ),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: color.withValues(alpha: 0.2),
              backgroundImage: _decodificar(participante.foto),
              child: _decodificar(participante.foto) == null
                  ? Text(
                      participante.nombre.isNotEmpty
                          ? participante.nombre[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                          color: color, fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        participante.nombre,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (esYo) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'TÚ',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.local_fire_department,
                        size: 12, color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: 2),
                    Text(
                      'Racha ${participante.rachaActual}',
                      style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.emoji_events_outlined,
                        size: 12, color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: 2),
                    Text(
                      'Mejor ${participante.rachaMaxima}',
                      style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GemaPuntos(puntos: participante.puntosGanados, tamano: 13),
        ],
      ),
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
