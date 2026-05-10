import 'package:flutter/material.dart';
import 'package:growtogether_data/growtogether_data.dart';
import 'package:provider/provider.dart';
import '../../core/utils/snack_helper.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/notificaciones_provider.dart';
import '../../services/local_notifications_service.dart';

/// Card que vive en el detalle de habito y permite gestionar el recordatorio
/// (1 por habito, MVP). Muestra hora, mensaje y switch activo. Si no hay
/// recordatorio, muestra solo un boton para crearlo.
class RecordatorioCard extends StatefulWidget {
  final Habito habito;
  const RecordatorioCard({super.key, required this.habito});

  @override
  State<RecordatorioCard> createState() => _RecordatorioCardState();
}

class _RecordatorioCardState extends State<RecordatorioCard> {
  bool _cargado = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_cargado) return;
    _cargado = true;
    Future.microtask(() {
      if (!mounted) return;
      context.read<NotificacionesProvider>().cargar(widget.habito.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<NotificacionesProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    final recordatorio = provider.recordatorio;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.notifications_active_outlined, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  l10n.recordatorio,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (provider.cargando)
              const Center(child: Padding(
                padding: EdgeInsets.all(8),
                child: CircularProgressIndicator(),
              ))
            else if (recordatorio == null)
              _SinRecordatorio(habito: widget.habito)
            else
              _ConRecordatorio(habito: widget.habito, recordatorio: recordatorio),
          ],
        ),
      ),
    );
  }
}

class _SinRecordatorio extends StatelessWidget {
  final Habito habito;
  const _SinRecordatorio({required this.habito});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.sinRecordatorio,
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            icon: const Icon(Icons.add_alarm),
            label: Text(l10n.anadirRecordatorio),
            onPressed: () => _abrirEditor(context, habito, null),
          ),
        ),
      ],
    );
  }
}

class _ConRecordatorio extends StatelessWidget {
  final Habito habito;
  final Notificacion recordatorio;
  const _ConRecordatorio({required this.habito, required this.recordatorio});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final hora = '${recordatorio.hora.toString().padLeft(2, '0')}:${recordatorio.minuto.toString().padLeft(2, '0')}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.schedule, size: 20, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(hora, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const Spacer(),
            Switch(
              value: recordatorio.activa,
              onChanged: (val) => _toggleActiva(context, habito, recordatorio, val),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          recordatorio.mensaje,
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.edit_outlined),
                label: Text(l10n.editar),
                onPressed: () => _abrirEditor(context, habito, recordatorio),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                icon: Icon(Icons.delete_outline, color: colorScheme.error),
                label: Text(
                  l10n.eliminarRecordatorio,
                  style: TextStyle(color: colorScheme.error),
                ),
                onPressed: () => _confirmarEliminar(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _toggleActiva(
    BuildContext context,
    Habito habito,
    Notificacion r,
    bool activa,
  ) async {
    if (activa && !await _asegurarPermisos(context)) return;
    if (!context.mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final ok = await context.read<NotificacionesProvider>().guardar(
          habito: habito,
          mensaje: r.mensaje,
          hora: r.hora,
          minuto: r.minuto,
          activa: activa,
        );
    if (!context.mounted) return;
    if (!ok) context.showSnackError(l10n.errorGenerico);
  }

  Future<void> _confirmarEliminar(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.eliminarRecordatorio),
        content: Text(l10n.confirmarEliminarRecordatorio),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancelar)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.eliminar),
          ),
        ],
      ),
    );
    if (confirmar != true || !context.mounted) return;
    final ok = await context.read<NotificacionesProvider>().eliminar();
    if (!context.mounted) return;
    if (ok) {
      context.showSnack(l10n.recordatorioEliminado, duration: const Duration(seconds: 1));
    } else {
      context.showSnackError(l10n.errorGenerico);
    }
  }
}

Future<bool> _asegurarPermisos(BuildContext context) async {
  final ok = await context.read<LocalNotificationsService>().pedirPermisos();
  if (!ok && context.mounted) {
    final l10n = AppLocalizations.of(context)!;
    context.showSnackError(l10n.permisoNotificacionesDenegado);
  }
  return ok;
}

Future<void> _abrirEditor(
  BuildContext context,
  Habito habito,
  Notificacion? existente,
) async {
  final l10n = AppLocalizations.of(context)!;
  final mensajeCtrl = TextEditingController(
    text: existente?.mensaje ?? '${l10n.recordatorioMensajePorDefecto} ${habito.nombre}',
  );
  TimeOfDay seleccionada = TimeOfDay(
    hour: existente?.hora ?? 8,
    minute: existente?.minuto ?? 0,
  );

  final guardado = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialog) => AlertDialog(
        title: Text(existente == null ? l10n.anadirRecordatorio : l10n.editarRecordatorio),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.schedule),
              title: Text(l10n.horaRecordatorio),
              subtitle: Text(seleccionada.format(ctx)),
              trailing: const Icon(Icons.edit_outlined),
              onTap: () async {
                final nueva = await showTimePicker(context: ctx, initialTime: seleccionada);
                if (nueva != null) setDialog(() => seleccionada = nueva);
              },
            ),
            const SizedBox(height: 8),
            TextField(
              controller: mensajeCtrl,
              decoration: InputDecoration(
                labelText: l10n.mensajeRecordatorio,
                border: const OutlineInputBorder(),
              ),
              maxLength: 120,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancelar)),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.guardar),
          ),
        ],
      ),
    ),
  );

  if (guardado != true || !context.mounted) return;
  if (!await _asegurarPermisos(context)) return;
  if (!context.mounted) return;
  final mensaje = mensajeCtrl.text.trim();
  if (mensaje.isEmpty) {
    context.showSnackError(l10n.mensajeRecordatorioObligatorio);
    return;
  }
  final ok = await context.read<NotificacionesProvider>().guardar(
        habito: habito,
        mensaje: mensaje,
        hora: seleccionada.hour,
        minuto: seleccionada.minute,
        activa: existente?.activa ?? true,
      );
  if (!context.mounted) return;
  if (ok) {
    context.showSnack(l10n.recordatorioGuardado, duration: const Duration(seconds: 1));
  } else {
    context.showSnackError(l10n.errorGenerico);
  }
}
