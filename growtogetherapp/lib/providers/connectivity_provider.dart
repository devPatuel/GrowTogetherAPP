import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Provider que escucha cambios en la conectividad de red.
///
/// Expone [hayInternet] para que las pantallas reaccionen y muestren un banner
/// cuando el dispositivo pierde la conexion. Solo distingue entre "hay alguna
/// interfaz activa" y "no hay ninguna"; no comprueba si el servidor responde.
class ConnectivityProvider extends ChangeNotifier {
  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscripcion;
  bool _hayInternet = true;

  ConnectivityProvider({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity() {
    _inicializar();
  }

  bool get hayInternet => _hayInternet;
  bool get sinInternet => !_hayInternet;

  Future<void> _inicializar() async {
    final estado = await _connectivity.checkConnectivity();
    _actualizar(estado);
    _subscripcion = _connectivity.onConnectivityChanged.listen(_actualizar);
  }

  void _actualizar(List<ConnectivityResult> resultados) {
    final hayConexion = resultados.any((r) => r != ConnectivityResult.none);
    if (hayConexion != _hayInternet) {
      _hayInternet = hayConexion;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscripcion?.cancel();
    super.dispose();
  }
}
