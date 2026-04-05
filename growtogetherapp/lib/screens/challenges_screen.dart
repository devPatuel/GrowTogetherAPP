import 'package:flutter/material.dart';
import '../core/constants/app_strings.dart';

class ChallengesScreen extends StatelessWidget {
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        AppStrings.holaPantallaDesafios,
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}
