import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../core/utils/daily_tip_service.dart';
import '../core/utils/habit_icons.dart';
import '../data/local/secure_storage_service.dart';
import '../data/models/habito.dart';
import '../l10n/app_localizations.dart';
import '../core/utils/snack_helper.dart';
import '../providers/habitos_provider.dart';
import 'detalle_habito_screen.dart';
import 'widgets/progress_painters.dart';
import 'widgets/scale_on_tap.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  String _nombreUsuario = '';
  bool _tipChecked = false;
  static const int _maxDiasAtras = 30;

  late AnimationController _staggerController;
  late ScrollController _carruselController;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _carruselController = ScrollController();
    _cargarInicial();
  }

  void _scrollToToday() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_carruselController.hasClients) {
        _carruselController.jumpTo(_carruselController.position.maxScrollExtent);
      }
    });
  }

  Future<void> _cargarInicial() async {
    final storage = context.read<SecureStorageService>();
    final provider = context.read<HabitosProvider>();
    _nombreUsuario = await storage.getUserName() ?? '';
    await provider.cargar();
    if (mounted) {
      setState(() {});
      _staggerController.forward(from: 0);
      _scrollToToday();
    }
  }

  @override
  void dispose() {
    _staggerController.dispose();
    _carruselController.dispose();
    super.dispose();
  }

  Future<void> cargarDatos() async {
    final provider = context.read<HabitosProvider>();
    await provider.cargar();
    if (mounted) _staggerController.forward(from: 0);
  }

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [colorScheme.primary, colorScheme.tertiary]),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lightbulb_outline_rounded, size: 32, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(l10n.consejoDia, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
              const SizedBox(height: 16),
              Text(tip, textAlign: TextAlign.center, style: TextStyle(fontSize: 15, height: 1.5, color: colorScheme.onSurfaceVariant)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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

  Future<void> _toggleHabito(Habito habito) async {
    final l10n = AppLocalizations.of(context)!;
    final estabaCompletado = habito.completadoHoy;
    final ok = await context.read<HabitosProvider>().toggleHabito(habito);
    if (!mounted) return;
    if (ok) {
      if (estabaCompletado) {
        context.showSnack(l10n.habitoDesmarcado, duration: const Duration(seconds: 1));
      } else {
        context.showSnackSuccess(l10n.habitoCompletado, duration: const Duration(seconds: 1));
      }
    } else {
      context.showSnackError('Error al actualizar');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final estado = context.watch<HabitosProvider>();

    if (estado.cargando && estado.habitos.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!_tipChecked && estado.error == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _mostrarConsejoDiario());
    }
    if (estado.error != null && estado.habitos.isEmpty) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(estado.error!, style: const TextStyle(color: Colors.red)),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: cargarDatos, child: Text(l10n.reintentar)),
      ]));
    }

    return RefreshIndicator(
      onRefresh: cargarDatos,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _buildSaludo(l10n),
          const SizedBox(height: 20),
          _buildCarruselDias(l10n),
          const SizedBox(height: 24),
          _buildProgresoCard(l10n),
          const SizedBox(height: 24),
          _buildTituloHabitos(l10n),
          const SizedBox(height: 12),
          if (estado.habitos.isEmpty) _buildSinHabitos(l10n)
          else ...List.generate(estado.habitos.length, (i) => _buildAnimatedCard(estado.habitos[i], l10n, i)),
        ],
      ),
    );
  }

  // ─────────────────── SALUDO ───────────────────

  Widget _buildSaludo(AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).languageCode;
    final localeIntl = locale == 'ca' ? 'ca_ES' : locale == 'en' ? 'en_US' : 'es_ES';
    final hoy = DateFormat('EEEE, d MMMM', localeIntl).format(DateTime.now());
    final horaActual = DateTime.now().hour;
    final saludo = horaActual < 12 ? l10n.buenosDias : horaActual < 20 ? l10n.buenasTardes : l10n.buenasNoches;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$saludo,',
          style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant),
        ),
        Text(
          _nombreUsuario,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5),
        ),
        const SizedBox(height: 2),
        Text(
          hoy.isNotEmpty ? '${hoy[0].toUpperCase()}${hoy.substring(1)}' : '',
          style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7)),
        ),
      ],
    );
  }

  // ─────────────────── CARRUSEL ───────────────────

  Widget _buildCarruselDias(AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    final estado = context.watch<HabitosProvider>();
    final now = DateTime.now();
    final hoy = DateTime(now.year, now.month, now.day);
    final diasLetras = _getDiasLetras(l10n);

    return SizedBox(
      height: 80,
      child: ListView.separated(
        controller: _carruselController,
        scrollDirection: Axis.horizontal,
        itemCount: _maxDiasAtras,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          // index 0 = más antiguo (29 días atrás), index 29 = hoy
          final diasAtras = (_maxDiasAtras - 1) - index;
          final dia = hoy.subtract(Duration(days: diasAtras));
          final esSeleccionado = dia.year == estado.fechaSeleccionada.year &&
              dia.month == estado.fechaSeleccionada.month &&
              dia.day == estado.fechaSeleccionada.day;
          final esHoy = diasAtras == 0;
          final letraDia = diasLetras[dia.weekday - 1];

          final textColor = esSeleccionado
              ? colorScheme.onPrimary
              : colorScheme.onSurface;
          final subColor = esSeleccionado
              ? colorScheme.onPrimary.withValues(alpha: 0.8)
              : colorScheme.onSurfaceVariant.withValues(alpha: 0.6);

          return GestureDetector(
            onTap: () {
              context.read<HabitosProvider>().seleccionarDia(dia);
              _staggerController.forward(from: 0);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              width: 46,
              decoration: BoxDecoration(
                gradient: esSeleccionado
                    ? LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          colorScheme.primary,
                          colorScheme.primary.withValues(alpha: 0.7),
                        ],
                      )
                    : null,
                color: esSeleccionado
                    ? null
                    : esHoy
                        ? colorScheme.surfaceContainerHighest
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                border: esHoy && !esSeleccionado
                    ? Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.5),
                        width: 1.5)
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(letraDia,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: subColor)),
                  const SizedBox(height: 4),
                  Text('${dia.day}',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: textColor)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<String> _getDiasLetras(AppLocalizations l10n) => [l10n.lun, l10n.mar, l10n.mie, l10n.jue, l10n.vie, l10n.sab, l10n.dom];

  // ─────────────────── PROGRESO GLASSMORPHISM ───────────────────

  Widget _buildProgresoCard(AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final estado = context.watch<HabitosProvider>();

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                ? [colorScheme.primary.withValues(alpha: 0.15), colorScheme.tertiary.withValues(alpha: 0.08)]
                : [colorScheme.primary.withValues(alpha: 0.1), colorScheme.primaryContainer.withValues(alpha: 0.3)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: colorScheme.primary.withValues(alpha: isDark ? 0.2 : 0.1)),
          ),
          child: Row(
            children: [
              // Anillo premium
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: estado.progreso),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) => SizedBox(
                  width: 96,
                  height: 96,
                  child: CustomPaint(
                    painter: GradientProgressPainter(
                      progress: value,
                      startColor: colorScheme.primary,
                      endColor: colorScheme.tertiary,
                      bgColor: colorScheme.onSurface.withValues(alpha: 0.08),
                      strokeWidth: 10,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${(value * 100).toInt()}',
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: colorScheme.onSurface, height: 1),
                          ),
                          Text('%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.progresoDelDia, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: colorScheme.onSurface)),
                    const SizedBox(height: 8),
                    // Barra de progreso
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: estado.progreso),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: SizedBox(
                              height: 8,
                              child: Stack(
                                children: [
                                  Container(color: colorScheme.onSurface.withValues(alpha: 0.08)),
                                  FractionallySizedBox(
                                    widthFactor: value,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(colors: [colorScheme.primary, colorScheme.tertiary]),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.habitosContador(estado.completados, estado.habitos.length),
                            style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────── TITULO ───────────────────

  Widget _buildTituloHabitos(AppLocalizations l10n) {
    final estado = context.watch<HabitosProvider>();
    return Text(
      estado.esHoy ? l10n.tusHabitosDeHoy : l10n.habitosDelDia,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
    );
  }

  Widget _buildSinHabitos(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
      child: Column(
        children: [
          Icon(Icons.eco_outlined, size: 64, color: Colors.grey[600]),
          const SizedBox(height: 16),
          Text(l10n.sinHabitos, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text(l10n.sinHabitosMotivacion, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Future<void> _abrirDetalle(Habito habito) async {
    final resultado = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => DetalleHabitoScreen(habito: habito)));
    if (resultado == true || resultado == null) cargarDatos();
  }

  // ─────────────────── CARD STAGGER ───────────────────

  Widget _buildAnimatedCard(Habito habito, AppLocalizations l10n, int index) {
    final delay = (index * 0.08).clamp(0.0, 0.6);
    final end = (delay + 0.4).clamp(0.0, 1.0);
    final slide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _staggerController, curve: Interval(delay, end, curve: Curves.easeOutCubic)));
    final fade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _staggerController, curve: Interval(delay, end, curve: Curves.easeOut)));

    return SlideTransition(
      position: slide,
      child: FadeTransition(opacity: fade, child: _buildHabitoCard(habito, l10n)),
    );
  }

  // ─────────────────── TARJETA HABITO GLASSMORPHISM ───────────────────

  Widget _buildHabitoCard(Habito habito, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final esNegativo = habito.esNegativo;
    final accentColor = esNegativo ? colorScheme.error : colorScheme.primary;
    final progresoMensual = habito.progresoMensual;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Material(
            color: isDark
                ? (esNegativo
                    ? colorScheme.error.withValues(alpha: 0.06)
                    : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5))
                : (esNegativo
                    ? Color.lerp(colorScheme.errorContainer, colorScheme.surface, 0.5)!
                    : colorScheme.surface),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: accentColor.withValues(alpha: isDark ? 0.12 : 0.06)),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _abrirDetalle(habito),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    // Icono con gradiente
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [accentColor.withValues(alpha: 0.2), accentColor.withValues(alpha: 0.08)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(HabitIcons.getIcon(habito.icono), size: 26, color: accentColor),
                    ),
                    const SizedBox(width: 14),

                    // Centro
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            habito.nombre,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              decoration: habito.completadoHoy ? TextDecoration.lineThrough : null,
                              color: habito.completadoHoy ? colorScheme.onSurfaceVariant.withValues(alpha: 0.5) : colorScheme.onSurface,
                            ),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          // Racha + progreso en una fila compacta
                          Row(
                            children: [
                              Expanded(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _buildFrecuenciaChip(habito, l10n),
                                      const SizedBox(width: 8),
                                      if (habito.rachaActual > 0 && !esNegativo) _buildRachaPill(habito),
                                      if (esNegativo) ConstrainedBox(
                                        constraints: const BoxConstraints(maxWidth: 150),
                                        child: _buildDiasSinPill(habito, l10n),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Mini progreso
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: progresoMensual),
                                duration: const Duration(milliseconds: 600),
                                curve: Curves.easeOutCubic,
                                builder: (context, value, _) => SizedBox(
                                  width: 32, height: 32,
                                  child: CustomPaint(
                                    painter: MiniProgressPainter(progress: value, color: accentColor, backgroundColor: accentColor.withValues(alpha: 0.12)),
                                    child: Center(child: Text('${(value * 100).toInt()}', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: accentColor))),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Check
                    ScaleOnTap(
                      onTap: () => _toggleHabito(habito),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          gradient: habito.completadoHoy
                              ? LinearGradient(colors: [accentColor, accentColor.withValues(alpha: 0.7)])
                              : null,
                          color: habito.completadoHoy ? null : Colors.transparent,
                          borderRadius: BorderRadius.circular(13),
                          border: habito.completadoHoy ? null : Border.all(color: accentColor.withValues(alpha: 0.4), width: 2),
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            habito.completadoHoy ? Icons.check_rounded : (esNegativo ? Icons.close_rounded : Icons.check_rounded),
                            key: ValueKey(habito.completadoHoy),
                            size: 22,
                            color: habito.completadoHoy ? Colors.white : accentColor.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFrecuenciaChip(Habito habito, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    if (habito.frecuencia == 'DIARIO') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(l10n.diario, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: colorScheme.primary)),
      );
    }

    final diasLetras = _getDiasLetras(l10n);
    final diasEnum = ['LUNES', 'MARTES', 'MIERCOLES', 'JUEVES', 'VIERNES', 'SABADO', 'DOMINGO'];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(7, (i) {
        final activo = habito.diasSemana.contains(diasEnum[i]);
        return Container(
          width: 18, height: 18,
          margin: const EdgeInsets.only(right: 2),
          decoration: BoxDecoration(
            color: activo ? colorScheme.primary.withValues(alpha: 0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Center(child: Text(diasLetras[i], style: TextStyle(fontSize: 8, fontWeight: activo ? FontWeight.w700 : FontWeight.w400, color: activo ? colorScheme.primary : colorScheme.onSurfaceVariant.withValues(alpha: 0.4)))),
        );
      }),
    );
  }

  Widget _buildRachaPill(Habito habito) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.orange.withValues(alpha: 0.15), Colors.deepOrange.withValues(alpha: 0.1)]),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_fire_department_rounded, size: 14, color: Colors.deepOrange),
          const SizedBox(width: 2),
          Text('${habito.rachaActual}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.deepOrange)),
        ],
      ),
    );
  }

  Widget _buildDiasSinPill(Habito habito, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: colorScheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shield_rounded, size: 14, color: colorScheme.error),
          const SizedBox(width: 2),
          Text(
            '${habito.rachaActual}',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: colorScheme.error),
          ),
        ],
      ),
    );
  }
}
