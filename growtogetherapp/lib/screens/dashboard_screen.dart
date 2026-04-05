import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/utils/daily_tip_service.dart';
import '../core/utils/habit_icons.dart';
import '../data/api/dio_client.dart';
import '../data/local/secure_storage_service.dart';
import '../data/models/habito.dart';
import '../data/repositories/habito_repository.dart';
import '../l10n/app_localizations.dart';
import 'detalle_habito_screen.dart';

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
  bool _tipChecked = false;

  /// Dia seleccionado en el carrusel (por defecto hoy)
  late DateTime _diaSeleccionado;

  static const int _diasCarrusel = 14;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _diaSeleccionado = DateTime(now.year, now.month, now.day);
    cargarDatos();
  }

  /// Muestra el consejo del dia si es un nuevo dia.
  Future<void> _mostrarConsejoDiario() async {
    if (_tipChecked) return;
    _tipChecked = true;

    final lang = Localizations.localeOf(context).languageCode;
    final tip = await DailyTipService.getTipIfNewDay(lang);
    if (tip == null || !mounted) return;

    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 32,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.consejoDia,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                tip,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(l10n.entendido),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

  bool get _esHoy {
    final now = DateTime.now();
    return _diaSeleccionado.year == now.year &&
        _diaSeleccionado.month == now.month &&
        _diaSeleccionado.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    // Mostrar consejo del dia tras la primera carga exitosa
    if (!_tipChecked && _error == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mostrarConsejoDiario();
      });
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
          const SizedBox(height: 16),
          _buildCarruselDias(l10n),
          const SizedBox(height: 20),
          _buildProgresoAnillo(l10n),
          const SizedBox(height: 20),
          _buildTituloHabitos(l10n),
          const SizedBox(height: 12),
          if (_habitos.isEmpty)
            _buildSinHabitos(l10n)
          else
            ..._habitos.map((h) => _buildHabitoCard(h, l10n)),
        ],
      ),
    );
  }

  // ─────────────────── SALUDO ───────────────────

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

  // ─────────────────── CARRUSEL DE DIAS ───────────────────

  Widget _buildCarruselDias(AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final hoy = DateTime(now.year, now.month, now.day);

    // Ultimos _diasCarrusel dias (incluyendo hoy)
    final dias = List.generate(
      _diasCarrusel,
      (i) => hoy.subtract(Duration(days: _diasCarrusel - 1 - i)),
    );

    final diasLetras = _getDiasLetras(l10n);

    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: dias.length,
        // Que empiece scrolleado al final (hoy visible)
        controller: ScrollController(
          initialScrollOffset: (_diasCarrusel - 5) * 56.0,
        ),
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final dia = dias[index];
          final esSeleccionado = dia.year == _diaSeleccionado.year &&
              dia.month == _diaSeleccionado.month &&
              dia.day == _diaSeleccionado.day;
          final esHoy = dia.year == hoy.year &&
              dia.month == hoy.month &&
              dia.day == hoy.day;

          // weekday: 1=lun ... 7=dom
          final letraDia = diasLetras[dia.weekday - 1];

          return GestureDetector(
            onTap: () {
              setState(() => _diaSeleccionado = dia);
              // TODO: cargar habitos de ese dia cuando la API lo soporte con fecha
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              decoration: BoxDecoration(
                color: esSeleccionado
                    ? colorScheme.primary
                    : esHoy
                        ? colorScheme.primaryContainer
                        : colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(16),
                border: esHoy && !esSeleccionado
                    ? Border.all(color: colorScheme.primary, width: 2)
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    letraDia,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: esSeleccionado
                          ? colorScheme.onPrimary
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${dia.day}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: esSeleccionado
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<String> _getDiasLetras(AppLocalizations l10n) {
    return [l10n.lun, l10n.mar, l10n.mie, l10n.jue, l10n.vie, l10n.sab, l10n.dom];
  }

  // ─────────────────── PROGRESO ───────────────────

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

  // ─────────────────── TITULO HABITOS ───────────────────

  Widget _buildTituloHabitos(AppLocalizations l10n) {
    return Text(
      _esHoy ? l10n.tusHabitosDeHoy : l10n.habitosDelDia,
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

  // ─────────────────── NAVEGACION AL DETALLE ───────────────────

  Future<void> _abrirDetalle(Habito habito) async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => DetalleHabitoScreen(habito: habito),
      ),
    );
    if (resultado == true || resultado == null) {
      cargarDatos();
    }
  }

  // ─────────────────── TARJETA DE HABITO (NUEVA) ───────────────────

  Widget _buildHabitoCard(Habito habito, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    final esNegativo = habito.esNegativo;

    // Colores de la tarjeta
    final cardColor = esNegativo
        ? Color.lerp(colorScheme.errorContainer, colorScheme.surface, 0.5)!
        : colorScheme.surface;
    final iconBgColor = esNegativo
        ? colorScheme.error.withValues(alpha: 0.12)
        : colorScheme.primary.withValues(alpha: 0.12);
    final iconColor = esNegativo
        ? colorScheme.error
        : colorScheme.primary;

    // Progreso mensual aproximado
    final progresoMensual = _calcularProgresoMensual(habito);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      color: cardColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _abrirDetalle(habito),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icono grande
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  HabitIcons.getIcon(habito.icono),
                  size: 28,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 14),

              // Contenido central
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre
                    Text(
                      habito.nombre,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        decoration: habito.completadoHoy ? TextDecoration.lineThrough : null,
                        color: habito.completadoHoy
                            ? colorScheme.onSurfaceVariant
                            : colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    // Frecuencia como chips
                    _buildFrecuenciaChips(habito, l10n),
                    const SizedBox(height: 10),

                    // Fila inferior: racha/dias-sin + progreso circular
                    Row(
                      children: [
                        // Racha o dias sin
                        if (esNegativo) ...[
                          Icon(Icons.shield_outlined, size: 16, color: colorScheme.error),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              l10n.diasSinHabito(habito.rachaActual, habito.nombre),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.error,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ] else if (habito.rachaActual > 0) ...[
                          const Icon(Icons.local_fire_department, size: 16, color: Colors.orange),
                          const SizedBox(width: 4),
                          Text(
                            '${habito.rachaActual}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                        const Spacer(),

                        // Mini grafico circular de progreso mensual
                        SizedBox(
                          width: 36,
                          height: 36,
                          child: CustomPaint(
                            painter: _MiniProgressPainter(
                              progress: progresoMensual,
                              color: esNegativo ? colorScheme.error : colorScheme.primary,
                              backgroundColor: colorScheme.outlineVariant.withValues(alpha: 0.3),
                            ),
                            child: Center(
                              child: Text(
                                '${(progresoMensual * 100).toInt()}',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: esNegativo ? colorScheme.error : colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Boton check
              _buildCheckButton(habito, colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFrecuenciaChips(Habito habito, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    final diasLetras = _getDiasLetras(l10n);
    final diasEnum = ['LUNES', 'MARTES', 'MIERCOLES', 'JUEVES', 'VIERNES', 'SABADO', 'DOMINGO'];

    if (habito.frecuencia == 'DIARIO') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          l10n.diario,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSecondaryContainer,
          ),
        ),
      );
    }

    // Chips de dias para frecuencia personalizada
    return Row(
      children: List.generate(7, (i) {
        final activo = habito.diasSemana.contains(diasEnum[i]);
        return Container(
          width: 22,
          height: 22,
          margin: const EdgeInsets.only(right: 3),
          decoration: BoxDecoration(
            color: activo
                ? colorScheme.primary.withValues(alpha: 0.2)
                : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              diasLetras[i],
              style: TextStyle(
                fontSize: 9,
                fontWeight: activo ? FontWeight.bold : FontWeight.normal,
                color: activo ? colorScheme.primary : colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCheckButton(Habito habito, ColorScheme colorScheme) {
    final esNegativo = habito.esNegativo;
    return GestureDetector(
      onTap: () => _toggleHabito(habito),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: habito.completadoHoy
              ? (esNegativo ? colorScheme.error : colorScheme.primary)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: habito.completadoHoy
                ? Colors.transparent
                : (esNegativo ? colorScheme.error : colorScheme.primary),
            width: 2,
          ),
        ),
        child: Icon(
          habito.completadoHoy ? Icons.check : (esNegativo ? Icons.close : Icons.check),
          size: 24,
          color: habito.completadoHoy
              ? (esNegativo ? colorScheme.onError : colorScheme.onPrimary)
              : (esNegativo ? colorScheme.error : colorScheme.primary),
        ),
      ),
    );
  }

  // ─────────────────── CALCULO PROGRESO MENSUAL ───────────────────

  /// Calculo aproximado del progreso mensual sin llamada extra a la API.
  /// Usa la racha actual como estimacion basica.
  double _calcularProgresoMensual(Habito habito) {
    final now = DateTime.now();
    final diaDelMes = now.day;

    if (diaDelMes == 0) return 0;

    int diasEsperados;
    if (habito.frecuencia == 'DIARIO') {
      diasEsperados = diaDelMes;
    } else {
      // Dias personalizados: cuantos dias del set caen hasta hoy en este mes
      diasEsperados = 0;
      for (int d = 1; d <= diaDelMes; d++) {
        final fecha = DateTime(now.year, now.month, d);
        final nombreDia = _weekdayToEnum(fecha.weekday);
        if (habito.diasSemana.contains(nombreDia)) {
          diasEsperados++;
        }
      }
    }

    if (diasEsperados == 0) return 0;

    // Estimacion: la racha actual como dias completados (es conservador)
    // Si completadoHoy, la racha incluye hoy. Es una aproximacion.
    final diasCompletadosEstimado = math.min(habito.rachaActual, diasEsperados);
    return (diasCompletadosEstimado / diasEsperados).clamp(0.0, 1.0);
  }

  String _weekdayToEnum(int weekday) {
    const map = {
      1: 'LUNES',
      2: 'MARTES',
      3: 'MIERCOLES',
      4: 'JUEVES',
      5: 'VIERNES',
      6: 'SABADO',
      7: 'DOMINGO',
    };
    return map[weekday] ?? 'LUNES';
  }

}

// ─────────────────── CUSTOM PAINTER: MINI PROGRESO CIRCULAR ───────────────────

class _MiniProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  _MiniProgressPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 3;

    // Fondo
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progreso
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_MiniProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
