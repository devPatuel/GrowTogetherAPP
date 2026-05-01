import 'package:flutter/material.dart';
import '../../data/models/solicitud_amistad.dart';
import '../../l10n/app_localizations.dart';
import 'usuario_tile.dart';

class SolicitudTile extends StatelessWidget {
  final SolicitudAmistad solicitud;
  final VoidCallback onAceptar;
  final VoidCallback onRechazar;
  final bool cargando;

  const SolicitudTile({
    super.key,
    required this.solicitud,
    required this.onAceptar,
    required this.onRechazar,
    this.cargando = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return UsuarioTile(
      nombre: solicitud.remitenteNombre,
      fotoBase64: solicitud.remitenteFoto,
      trailing: cargando
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check_circle),
                  color: colorScheme.primary,
                  tooltip: MaterialLocalizations.of(context).okButtonLabel,
                  onPressed: onAceptar,
                ),
                IconButton(
                  icon: const Icon(Icons.cancel_outlined),
                  color: colorScheme.error,
                  tooltip: MaterialLocalizations.of(context).cancelButtonLabel,
                  onPressed: onRechazar,
                ),
              ],
            ),
    );
  }
}

class SolicitudEnviadaTile extends StatelessWidget {
  final SolicitudAmistad solicitud;
  final VoidCallback onCancelar;
  final bool cargando;

  const SolicitudEnviadaTile({
    super.key,
    required this.solicitud,
    required this.onCancelar,
    this.cargando = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    return UsuarioTile(
      nombre: solicitud.destinatarioNombre,
      fotoBase64: solicitud.destinatarioFoto,
      subtitulo: l10n.solicitudEnviada,
      trailing: cargando
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : IconButton(
              icon: const Icon(Icons.cancel_outlined),
              color: colorScheme.error,
              tooltip: l10n.cancelarSolicitud,
              onPressed: onCancelar,
            ),
    );
  }
}
