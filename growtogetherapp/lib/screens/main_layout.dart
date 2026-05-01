import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/amistad_provider.dart';
import '../providers/desafios_provider.dart';
import '../providers/habitos_provider.dart';
import '../providers/statistics_provider.dart';
import 'amigos_screen.dart';
import 'buscar_amigos_screen.dart';
import 'crear_desafio_screen.dart';
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

  final List<Widget> _pantallas = const [
    DashboardScreen(),
    StatisticsScreen(),
    ChallengesScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AmistadProvider>().cargarSolicitudes();
    });
  }

  void _abrirBuscarAmigos() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BuscarAmigosScreen()),
    );
  }

  void _abrirListaAmigos() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AmigosScreen()),
    );
  }

  Future<void> _abrirCrearSegunPestana() async {
    if (_indiceActual == 2) {
      final ok = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => const CrearDesafioScreen()),
      );
      if (ok == true && mounted) {
        context.read<DesafiosProvider>().cargar();
      }
      return;
    }
    final provider = context.read<HabitosProvider>();
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const CrearHabitoScreen()),
    );

    if (resultado == true) {
      provider.cargar();
      if (mounted) {
        context.read<StatisticsProvider>().cargar();
        setState(() => _indiceActual = 0);
      }
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
        actions: _indiceActual == 2 ? _buildAccionesDesafios(l10n) : null,
      ),
      body: IndexedStack(
        index: _indiceActual,
        children: _pantallas,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirCrearSegunPestana,
        tooltip: '',
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: const CircleBorder(),
        child: Icon(
          _indiceActual == 2 ? Icons.emoji_events : Icons.add,
          size: 28,
        ),
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

  List<Widget> _buildAccionesDesafios(AppLocalizations l10n) {
    return [
      IconButton(
        icon: const Icon(Icons.person_add_alt_1_outlined),
        tooltip: l10n.buscarAmigos,
        onPressed: _abrirBuscarAmigos,
      ),
      Consumer<AmistadProvider>(
        builder: (_, provider, __) {
          final pendientes = provider.peticionesPendientes;
          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.people_alt_outlined),
                tooltip: l10n.misAmigos,
                onPressed: _abrirListaAmigos,
              ),
              if (pendientes > 0)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    child: Text(
                      pendientes > 9 ? '9+' : '$pendientes',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      const SizedBox(width: 4),
    ];
  }

  Widget _buildNavItem(int indice, IconData iconoInactivo, IconData iconoActivo, String etiqueta) {
    final seleccionado = _indiceActual == indice;
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: InkWell(
        onTap: () {
          if (indice == 1) context.read<StatisticsProvider>().cargar();
          setState(() => _indiceActual = indice);
        },
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
