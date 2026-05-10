import 'dart:convert';
import 'package:growtogether_data/growtogether_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cache local del dashboard para que el usuario pueda abrir la app sin
/// internet y ver el ultimo estado conocido (habitos del dia y consejo).
///
/// La cache es por usuario (clave incluye userId) y solo guarda lecturas;
/// las acciones (toggle, crear) no se encolan offline a proposito (decision
/// del proyecto: la app es online-only para acciones, online-tolerante para
/// lectura).
class DashboardCache {
  static const _claveHabitos = 'cache_habitos_';
  static const _claveHabitosFecha = 'cache_habitos_fecha_';
  static const _claveConsejo = 'cache_consejo_dia';

  /// Guarda los habitos del dia de hoy del usuario indicado.
  static Future<void> guardarHabitos(int usuarioId, List<Habito> habitos) async {
    final prefs = await SharedPreferences.getInstance();
    final lista = habitos.map(_habitoToMap).toList();
    await prefs.setString('$_claveHabitos$usuarioId', jsonEncode(lista));
    await prefs.setString(
      '$_claveHabitosFecha$usuarioId',
      DateTime.now().toIso8601String(),
    );
  }

  /// Lee los habitos cacheados. Devuelve null si no hay cache.
  static Future<List<Habito>?> leerHabitos(int usuarioId) async {
    final prefs = await SharedPreferences.getInstance();
    final crudo = prefs.getString('$_claveHabitos$usuarioId');
    if (crudo == null) return null;
    try {
      final lista = jsonDecode(crudo) as List;
      return lista
          .map((e) => Habito.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return null;
    }
  }

  /// Devuelve la fecha en la que se cachearon los habitos por ultima vez.
  static Future<DateTime?> fechaCacheHabitos(int usuarioId) async {
    final prefs = await SharedPreferences.getInstance();
    final crudo = prefs.getString('$_claveHabitosFecha$usuarioId');
    if (crudo == null) return null;
    return DateTime.tryParse(crudo);
  }

  /// Guarda el consejo del dia para poder mostrarlo offline.
  static Future<void> guardarConsejo(Consejo consejo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_claveConsejo, jsonEncode(_consejoToMap(consejo)));
  }

  /// Lee el consejo cacheado, o null si no hay.
  static Future<Consejo?> leerConsejo() async {
    final prefs = await SharedPreferences.getInstance();
    final crudo = prefs.getString(_claveConsejo);
    if (crudo == null) return null;
    try {
      return Consejo.fromJson(
        Map<String, dynamic>.from(jsonDecode(crudo) as Map),
      );
    } catch (_) {
      return null;
    }
  }

  static Map<String, dynamic> _habitoToMap(Habito h) => {
        'id': h.id,
        'nombre': h.nombre,
        'descripcion': h.descripcion,
        'rachaActual': h.rachaActual,
        'rachaMaxima': h.rachaMaxima,
        'usuarioId': h.usuarioId,
        'completadoHoy': h.completadoHoy,
        'frecuencia': h.frecuencia,
        'diasSemana': h.diasSemana.toList(),
        'tipo': h.tipo,
        'icono': h.icono,
        'fechaInicio': h.fechaInicio?.toIso8601String(),
        'progresoMensual': h.progresoMensual,
      };

  static Map<String, dynamic> _consejoToMap(Consejo c) => {
        'id': c.id,
        'titulo': c.titulo,
        'descripcion': c.descripcion,
        'fechaPublicacion': c.fechaPublicacion?.toIso8601String(),
        'activo': c.activo,
        'creadorId': c.creadorId,
      };
}
