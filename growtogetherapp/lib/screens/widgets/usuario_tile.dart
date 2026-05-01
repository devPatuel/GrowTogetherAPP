import 'dart:convert';
import 'package:flutter/material.dart';

class UsuarioTile extends StatelessWidget {
  final String nombre;
  final String? fotoBase64;
  final String? subtitulo;
  final Widget? trailing;
  final VoidCallback? onTap;

  const UsuarioTile({
    super.key,
    required this.nombre,
    this.fotoBase64,
    this.subtitulo,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: colorScheme.primary.withValues(alpha: 0.15),
        backgroundImage: _resolverImagen(),
        child: _resolverImagen() == null
            ? Text(
                nombre.isNotEmpty ? nombre[0].toUpperCase() : '?',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
      ),
      title: Text(nombre, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: subtitulo != null ? Text(subtitulo!) : null,
      trailing: trailing,
      onTap: onTap,
    );
  }

  ImageProvider? _resolverImagen() {
    final foto = fotoBase64;
    if (foto == null || foto.isEmpty) return null;
    try {
      return MemoryImage(base64Decode(foto));
    } catch (_) {
      return null;
    }
  }
}
