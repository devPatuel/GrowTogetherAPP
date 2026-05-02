import 'package:flutter/material.dart';
import '../../core/utils/challenge_colors.dart';
import '../../core/utils/habit_icons.dart';
import 'package:growtogether_data/growtogether_data.dart';
import 'avatar_stack.dart';
import 'gema_puntos.dart';
import 'scale_on_tap.dart';

/// Card de presentación de un desafío en la lista. Muestra icono, nombre, descripción,
/// chip de frecuencia, avatares apilados de los participantes, barra de progreso
/// temporal del desafío y los puntos del usuario actual.
class DesafioCard extends StatelessWidget {
  final Desafio desafio;
  final int usuarioActualId;
  final VoidCallback onTap;

  const DesafioCard({
    super.key,
    required this.desafio,
    required this.usuarioActualId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final yo = desafio.participacionDe(usuarioActualId);
    final iconoDesafio = HabitIcons.getIcon(desafio.icono);
    final progresoTemporal = desafio.duracionDias <= 0
        ? 0.0
        : (desafio.diasTranscurridos / desafio.duracionDias).clamp(0.0, 1.0);
    final esNegativo = desafio.esNegativo;

    return ScaleOnTap(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: (esNegativo ? colorScheme.error : colorScheme.primary)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      iconoDesafio,
                      color: esNegativo ? colorScheme.error : colorScheme.primary,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          desafio.nombre,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          desafio.descripcion,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (yo != null)
                    GemaPuntos(puntos: yo.puntosGanados, tamano: 13),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  AvatarStack(
                    participantes: desafio.participantes
                        .where((p) => !p.abandonado)
                        .toList(),
                    maxVisible: 4,
                    radius: 14,
                  ),
                  const Spacer(),
                  _ChipFrecuencia(desafio: desafio),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progresoTemporal,
                  minHeight: 6,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    desafio.finalizado
                        ? colorScheme.outline
                        : ChallengeColors.gemaVerde,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    desafio.finalizado ? Icons.flag : Icons.timer_outlined,
                    size: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    desafio.finalizado
                        ? 'Finalizado'
                        : 'Quedan ${desafio.diasRestantes} días',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const Spacer(),
                  Text(
                    '${desafio.participantes.where((p) => !p.abandonado).length} participantes',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChipFrecuencia extends StatelessWidget {
  final Desafio desafio;
  const _ChipFrecuencia({required this.desafio});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final esDiario = desafio.frecuencia == 'DIARIO';
    final etiqueta = esDiario ? 'Diario' : 'Personalizado';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            esDiario ? Icons.calendar_today : Icons.event_repeat,
            size: 12,
            color: colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 4),
          Text(
            etiqueta,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
