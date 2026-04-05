import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_strings.dart';
import '../data/api/dio_client.dart';
import '../data/local/secure_storage_service.dart';
import '../data/models/habito.dart';
import '../data/repositories/habito_repository.dart';

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
    try {
      if (habito.completadoHoy) {
        await _repo.descompletarHabito(habito.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.habitoDesmarcado),
            duration: Duration(seconds: 1),
          ),
        );
      } else {
        await _repo.completarHabito(habito.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.habitoCompletado),
            backgroundColor: const Color(0xFF6B9F75),
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
              child: const Text(AppStrings.reintentar),
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
          _buildSaludo(),
          const SizedBox(height: 24),
          _buildProgresoAnillo(),
          const SizedBox(height: 24),
          _buildTituloHabitos(),
          const SizedBox(height: 12),
          if (_habitos.isEmpty) _buildSinHabitos() else ..._habitos.map(_buildHabitoCard),
        ],
      ),
    );
  }

  Widget _buildSaludo() {
    final hoy = DateFormat('EEEE, d MMMM', 'es_ES').format(DateTime.now());
    final horaActual = DateTime.now().hour;
    final saludo = horaActual < 12
        ? 'Buenos días'
        : horaActual < 20
            ? 'Buenas tardes'
            : 'Buenas noches';

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

  Widget _buildProgresoAnillo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF6B9F75).withOpacity(0.1),
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
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF6B9F75)),
                ),
                Center(
                  child: Text(
                    '${(_progreso * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6B9F75),
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
                const Text(
                  AppStrings.progresoDelDia,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  '$_completados / ${_habitos.length} hábitos',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTituloHabitos() {
    return const Text(
      AppStrings.tusHabitosDeHoy,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
    );
  }

  Widget _buildSinHabitos() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        children: [
          Icon(Icons.eco_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            AppStrings.sinHabitos,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.sinHabitosMotivacion,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitoCard(Habito habito) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: IconButton(
          icon: Icon(
            habito.completadoHoy ? Icons.check_circle : Icons.radio_button_unchecked,
            color: habito.completadoHoy ? const Color(0xFF6B9F75) : Colors.grey,
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

  static const _diasCortos = {
    'LUNES': 'Lun',
    'MARTES': 'Mar',
    'MIERCOLES': 'Mié',
    'JUEVES': 'Jue',
    'VIERNES': 'Vie',
    'SABADO': 'Sáb',
    'DOMINGO': 'Dom',
  };

  Widget? _buildSubtitle(Habito habito) {
    final parts = <String>[];
    if (habito.descripcion.isNotEmpty) parts.add(habito.descripcion);
    if (habito.frecuencia == 'PERSONALIZADO' && habito.diasSemana.isNotEmpty) {
      final diasLegibles = habito.diasSemana
          .map((d) => _diasCortos[d] ?? d)
          .join(', ');
      parts.add(diasLegibles);
    }
    if (parts.isEmpty) return null;
    return Text(parts.join(' · '), maxLines: 1, overflow: TextOverflow.ellipsis);
  }
}
