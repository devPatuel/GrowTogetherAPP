import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'crear_habito_screen.dart';
import 'dashboard_screen.dart';
import 'statistics_screen.dart';
import 'challenges_screen.dart';
import 'profile_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _indiceActual = 0;

  final _dashboardKey = GlobalKey<DashboardScreenState>();

  late final List<Widget> _pantallas = [
    DashboardScreen(key: _dashboardKey),
    const StatisticsScreen(),
    const ChallengesScreen(),
    const ProfileScreen(),
  ];

  Future<void> _abrirCrearHabito() async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const CrearHabitoScreen()),
    );

    if (resultado == true) {
      _dashboardKey.currentState?.cargarDatos();
      setState(() => _indiceActual = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    final titulos = [
      l10n.inicio,
      l10n.analisis,
      l10n.desafios,
      l10n.perfil,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(titulos[_indiceActual]),
        centerTitle: true,
      ),
      body: IndexedStack(
        index: _indiceActual,
        children: _pantallas,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirCrearHabito,
        tooltip: '',
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        height: 60,
        padding: EdgeInsets.zero,
        child: Row(
          children: [
            _buildNavItem(0, Icons.home_outlined, Icons.home, l10n.inicio),
            _buildNavItem(1, Icons.bar_chart_outlined, Icons.bar_chart, l10n.analisis),
            const Expanded(child: SizedBox()),
            _buildNavItem(2, Icons.emoji_events_outlined, Icons.emoji_events, l10n.desafios),
            _buildNavItem(3, Icons.person_outline, Icons.person, l10n.perfil),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int indice, IconData iconoInactivo, IconData iconoActivo, String etiqueta) {
    final seleccionado = _indiceActual == indice;
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _indiceActual = indice),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                seleccionado ? iconoActivo : iconoInactivo,
                color: seleccionado ? colorScheme.primary : Colors.grey,
                size: 24,
              ),
              const SizedBox(height: 2),
              Text(
                etiqueta,
                style: TextStyle(
                  color: seleccionado ? colorScheme.primary : Colors.grey,
                  fontSize: 11,
                  fontWeight: seleccionado ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
