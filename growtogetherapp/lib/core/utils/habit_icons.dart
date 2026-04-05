import 'package:flutter/material.dart';

/// Mapeo de strings de icono a IconData de Material Icons.
/// Se usa tanto en el dashboard como en crear/editar habito.
class HabitIcons {
  HabitIcons._();

  static const Map<String, IconData> iconMap = {
    'fitness': Icons.fitness_center,
    'book': Icons.menu_book,
    'smoke': Icons.smoke_free,
    'meditation': Icons.self_improvement,
    'water': Icons.water_drop,
    'run': Icons.directions_run,
    'sleep': Icons.bedtime,
    'food': Icons.restaurant,
    'study': Icons.school,
    'music': Icons.music_note,
    'code': Icons.code,
    'walk': Icons.directions_walk,
    'yoga': Icons.spa,
    'bike': Icons.pedal_bike,
    'recycle': Icons.recycling,
    'plant': Icons.eco,
    'heart': Icons.favorite,
  };

  static const IconData defaultIcon = Icons.check_circle;

  /// Devuelve el IconData correspondiente al string, o el icono por defecto.
  static IconData getIcon(String? iconKey) {
    if (iconKey == null || iconKey.isEmpty) return defaultIcon;
    return iconMap[iconKey] ?? defaultIcon;
  }

  /// Lista ordenada de claves para mostrar en el selector.
  static List<String> get allKeys => iconMap.keys.toList();
}
