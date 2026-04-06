import 'package:flutter/material.dart';

class ErrorBanner extends StatelessWidget {
  final String mensaje;

  const ErrorBanner({super.key, required this.mensaje});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Text(mensaje, style: TextStyle(color: Colors.red.shade700)),
    );
  }
}
