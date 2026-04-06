import 'package:flutter/material.dart';
import '../../core/utils/habit_icons.dart';

class IconSelector extends StatelessWidget {
  final String? selectedIcon;
  final ValueChanged<String?> onChanged;

  const IconSelector({
    super.key,
    this.selectedIcon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final allKeys = HabitIcons.allKeys;

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: allKeys.map((key) {
        final seleccionado = selectedIcon == key;
        final icon = HabitIcons.getIcon(key);
        return GestureDetector(
          onTap: () => onChanged(seleccionado ? null : key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: seleccionado
                  ? colorScheme.primary.withValues(alpha: 0.2)
                  : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: seleccionado
                  ? Border.all(color: colorScheme.primary, width: 2.5)
                  : null,
            ),
            child: Icon(
              icon,
              size: 26,
              color: seleccionado ? colorScheme.primary : colorScheme.onSurfaceVariant,
            ),
          ),
        );
      }).toList(),
    );
  }
}
