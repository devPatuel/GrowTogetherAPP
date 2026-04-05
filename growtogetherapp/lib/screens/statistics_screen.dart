import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Text(
        l10n.holaPantallaAnalisis,
        style: const TextStyle(fontSize: 18),
      ),
    );
  }
}
