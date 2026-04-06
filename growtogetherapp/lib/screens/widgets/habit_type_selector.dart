import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class HabitTypeSelector extends StatelessWidget {
  final String tipo;
  final ValueChanged<String> onChanged;

  const HabitTypeSelector({
    super.key,
    required this.tipo,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return SegmentedButton<String>(
      segments: [
        ButtonSegment(
          value: 'POSITIVO',
          label: Text(l10n.tipoPositivo),
          icon: const Icon(Icons.add_circle_outline),
        ),
        ButtonSegment(
          value: 'NEGATIVO',
          label: Text(l10n.tipoNegativo),
          icon: const Icon(Icons.remove_circle_outline),
        ),
      ],
      selected: {tipo},
      onSelectionChanged: (sel) => onChanged(sel.first),
      style: SegmentedButton.styleFrom(
        selectedBackgroundColor: tipo == 'POSITIVO'
            ? colorScheme.primary.withValues(alpha: 0.2)
            : colorScheme.error.withValues(alpha: 0.2),
        selectedForegroundColor: tipo == 'POSITIVO'
            ? colorScheme.primary
            : colorScheme.error,
      ),
    );
  }
}
