import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/api/dio_client.dart';
import '../data/local/secure_storage_service.dart';
import '../data/models/habito.dart';
import '../data/repositories/habito_repository.dart';
import '../l10n/app_localizations.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  final _storage = SecureStorageService();
  late final _repo = HabitoRepository(DioClient(_storage));

  List<Habito> _habitos = [];
  String _nombreUsuario = '';
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final nombre = await _storage.getUserName() ?? '';
      final userId = await _storage.getUserId();
      if (userId == null) return;

      final habitos = await _repo.getHabitos(userId);

      if (!mounted) return;
      setState(() {
        _nombreUsuario = nombre;
        _habitos = habitos;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _cargando = false;
      });
    }
  }

  Future<void> _toggleHabito(Habito habito) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      if (habito.completadoHoy) {
        await _repo.descompletarHabito(habito.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.habitoDesmarcado),
            duration: const Duration(seconds: 1),
          ),
        );
      } else {
        await _repo.completarHabito(habito.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.habitoCompletado),
            backgroundColor: Theme.of(context).colorScheme.primary,
            duration: const Duration(seconds: 1),
          ),
        );
      }
      await cargarDatos();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  int get _completados => _habitos.where((h) => h.completadoHoy).length;
  double get _progreso => _habitos.isEmpty ? 0 : _completados / _habitos.length;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: cargarDatos,
              child: Text(l10n.reintentar),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: cargarDatos,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSaludo(l10n),
          const SizedBox(height: 24),
          _buildProgresoAnillo(l10n),
          const SizedBox(height: 24),
          _buildTituloHabitos(l10n),
          const SizedBox(height: 12),
          if (_habitos.isEmpty) _buildSinHabitos(l10n) else ..._habitos.map(_buildHabitoCard),
        ],
      ),
    );
  }

  Widget _buildSaludo(AppLocalizations l10n) {
    final locale = Localizations.localeOf(context).languageCode;
    final localeIntl = locale == 'ca' ? 'ca_ES' : locale == 'en' ? 'en_US' : 'es_ES';
    final hoy = DateFormat('EEEE, d MMMM', localeIntl).format(DateTime.now());
    final horaActual = DateTime.now().hour;
    final saludo = horaActual < 12
        ? l10n.buenosDias
        : horaActual < 20
            ? l10n.buenasTardes
            : l10n.buenasNoches;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$saludo, $_nombreUsuario',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          hoy.isNotEmpty ? '${hoy[0].toUpperCase()}${hoy.substring(1)}' : '',
          style: TextStyle(fontSize: 15, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildProgresoAnillo(AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: _progreso,
                  strokeWidth: 8,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation(colorScheme.primary),
                ),
                Center(
                  child: Text(
                    '${(_progreso * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.progresoDelDia,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.habitosContador(_completados, _habitos.length),
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTituloHabitos(AppLocalizations l10n) {
    return Text(
      l10n.tusHabitosDeHoy,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
    );
  }

  Widget _buildSinHabitos(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        children: [
          Icon(Icons.eco_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            l10n.sinHabitos,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.sinHabitosMotivacion,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitoCard(Habito habito) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: IconButton(
          icon: Icon(
            habito.completadoHoy ? Icons.check_circle : Icons.radio_button_unchecked,
            color: habito.completadoHoy ? colorScheme.primary : Colors.grey,
            size: 32,
          ),
          onPressed: () => _toggleHabito(habito),
        ),
        title: Text(
          habito.nombre,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            decoration: habito.completadoHoy ? TextDecoration.lineThrough : null,
            color: habito.completadoHoy ? Colors.grey : null,
          ),
        ),
        subtitle: _buildSubtitle(habito),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (habito.rachaActual > 0) ...[
              const Icon(Icons.local_fire_department, color: Colors.orange, size: 20),
              const SizedBox(width: 4),
              Text(
                '${habito.rachaActual}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Map<String, String> _getDiasCortos() {
    final l10n = AppLocalizations.of(context)!;
    return {
      'LUNES': l10n.diasCortoLun,
      'MARTES': l10n.diasCortoMar,
      'MIERCOLES': l10n.diasCortoMie,
      'JUEVES': l10n.diasCortoJue,
      'VIERNES': l10n.diasCortoVie,
      'SABADO': l10n.diasCortoSab,
      'DOMINGO': l10n.diasCortoDom,
    };
  }

  Widget? _buildSubtitle(Habito habito) {
    final parts = <String>[];
    if (habito.descripcion.isNotEmpty) parts.add(habito.descripcion);
    if (habito.frecuencia == 'PERSONALIZADO' && habito.diasSemana.isNotEmpty) {
      final diasCortos = _getDiasCortos();
      final diasLegibles = habito.diasSemana
          .map((d) => diasCortos[d] ?? d)
          .join(', ');
      parts.add(diasLegibles);
    }
    if (parts.isEmpty) return null;
    return Text(parts.join(' · '), maxLines: 1, overflow: TextOverflow.ellipsis);
  }
}
