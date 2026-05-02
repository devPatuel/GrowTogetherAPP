import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:growtogether_data/growtogether_data.dart';

/// Apila los avatares circulares de los participantes con un offset negativo.
/// Si hay más de [maxVisible], muestra el último círculo con "+N".
class AvatarStack extends StatelessWidget {
  final List<ParticipanteDesafio> participantes;
  final int maxVisible;
  final double radius;

  const AvatarStack({
    super.key,
    required this.participantes,
    this.maxVisible = 4,
    this.radius = 16,
  });

  @override
  Widget build(BuildContext context) {
    if (participantes.isEmpty) {
      return const SizedBox.shrink();
    }
    final visibles = participantes.take(maxVisible).toList();
    final restantes = participantes.length - visibles.length;
    final mostrarContador = restantes > 0;
    final totalCirculos = visibles.length + (mostrarContador ? 1 : 0);
    final ancho = radius * 2 + (totalCirculos - 1) * radius * 1.3;

    return SizedBox(
      width: ancho,
      height: radius * 2,
      child: Stack(
        children: [
          for (int i = 0; i < visibles.length; i++)
            Positioned(
              left: i * radius * 1.3,
              child: _avatar(context, visibles[i], radius),
            ),
          if (mostrarContador)
            Positioned(
              left: visibles.length * radius * 1.3,
              child: _contador(context, restantes, radius),
            ),
        ],
      ),
    );
  }

  Widget _avatar(BuildContext context, ParticipanteDesafio p, double r) {
    final colorScheme = Theme.of(context).colorScheme;
    final imagen = _decodificarFoto(p.foto);
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: colorScheme.surface, width: 2),
      ),
      child: CircleAvatar(
        radius: r,
        backgroundColor: colorScheme.primary.withValues(alpha: 0.18),
        backgroundImage: imagen,
        child: imagen == null
            ? Text(
                p.nombre.isNotEmpty ? p.nombre[0].toUpperCase() : '?',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: r * 0.8,
                ),
              )
            : null,
      ),
    );
  }

  Widget _contador(BuildContext context, int n, double r) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: colorScheme.surface, width: 2),
      ),
      child: CircleAvatar(
        radius: r,
        backgroundColor: colorScheme.surfaceContainerHighest,
        child: Text(
          '+$n',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: r * 0.7,
          ),
        ),
      ),
    );
  }

  ImageProvider? _decodificarFoto(String? foto) {
    if (foto == null || foto.isEmpty) return null;
    try {
      return MemoryImage(base64Decode(foto));
    } catch (_) {
      return null;
    }
  }
}
