import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class ChallengesScreen extends StatelessWidget {
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Text(
        l10n.holaPantallaDesafios,
        style: const TextStyle(fontSize: 18),
      ),
    );
  }
}
