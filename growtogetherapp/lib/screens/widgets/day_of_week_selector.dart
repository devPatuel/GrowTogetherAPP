import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class DayOfWeekSelector extends StatelessWidget {
  final List<bool> diasSeleccionados;
  final ValueChanged<int> onToggle;

  static const diasEnumValues = [
    'LUNES', 'MARTES', 'MIERCOLES', 'JUEVES', 'VIERNES', 'SABADO', 'DOMINGO',
  ];

  const DayOfWeekSelector({
    super.key,
    required this.diasSeleccionados,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final labels = [l10n.lun, l10n.mar, l10n.mie, l10n.jue, l10n.vie, l10n.sab, l10n.dom];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(7, (i) {
        final activo = diasSeleccionados[i];
        return GestureDetector(
          onTap: () => onToggle(i),
          child: CircleAvatar(
            radius: 22,
            backgroundColor: activo ? colorScheme.primary : Colors.grey[200],
            child: Text(
              labels[i],
              style: TextStyle(
                color: activo ? colorScheme.onPrimary : Colors.grey[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }),
    );
  }

  /// Convierte la lista de booleans a Set<String> de enums para la API
  static Set<String>? toEnumSet(List<bool> dias) {
    final result = <String>{};
    for (int i = 0; i < 7; i++) {
      if (dias[i]) result.add(diasEnumValues[i]);
    }
    return result.isEmpty ? null : result;
  }
}
