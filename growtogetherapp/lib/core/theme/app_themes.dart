import 'package:flutter/material.dart';

/// Enum con los 4 temas disponibles en la app.
enum AppThemeType {
  claro,
  oscuro,
  morado,
  naturaleza,
}

/// Definiciones de los 4 ThemeData de la app.
class AppThemes {
  AppThemes._();

  // --- Claro (por defecto): verde 0xFF6B9F75, fondo claro ---
  static ThemeData get claro => ThemeData(
        colorSchemeSeed: const Color(0xFF6B9F75),
        brightness: Brightness.light,
        useMaterial3: true,
      );

  // --- Oscuro: fondo negro/gris oscuro, acentos teal/cyan ---
  static ThemeData get oscuro => ThemeData(
        colorSchemeSeed: const Color(0xFF00BCD4),
        brightness: Brightness.dark,
        useMaterial3: true,
      );

  // --- Morado/Neon: purpura-azul, acentos naranja/amarillo ---
  static ThemeData get morado => ThemeData(
        colorSchemeSeed: const Color(0xFF7C4DFF),
        brightness: Brightness.dark,
        useMaterial3: true,
      );

  // --- Naturaleza/Verde: verde-dorado, acentos tierra/naranja ---
  static ThemeData get naturaleza => ThemeData(
        colorSchemeSeed: const Color(0xFF8B6914),
        brightness: Brightness.light,
        useMaterial3: true,
      );

  /// Devuelve el ThemeData correspondiente al tipo.
  static ThemeData fromType(AppThemeType type) {
    switch (type) {
      case AppThemeType.claro:
        return claro;
      case AppThemeType.oscuro:
        return oscuro;
      case AppThemeType.morado:
        return morado;
      case AppThemeType.naturaleza:
        return naturaleza;
    }
  }

  /// Nombre visible para cada tema.
  static String label(AppThemeType type) {
    switch (type) {
      case AppThemeType.claro:
        return 'Claro';
      case AppThemeType.oscuro:
        return 'Oscuro';
      case AppThemeType.morado:
        return 'Morado';
      case AppThemeType.naturaleza:
        return 'Naturaleza';
    }
  }

  /// Icono representativo de cada tema.
  static IconData icon(AppThemeType type) {
    switch (type) {
      case AppThemeType.claro:
        return Icons.light_mode;
      case AppThemeType.oscuro:
        return Icons.dark_mode;
      case AppThemeType.morado:
        return Icons.auto_awesome;
      case AppThemeType.naturaleza:
        return Icons.forest;
    }
  }

  /// Mapea un string de la API (CLARO, OSCURO, MORADO, NATURALEZA) a AppThemeType.
  /// Devuelve null si el valor no es reconocido.
  static AppThemeType? fromApiString(String? apiValue) {
    if (apiValue == null) return null;
    switch (apiValue.toUpperCase()) {
      case 'CLARO':
        return AppThemeType.claro;
      case 'OSCURO':
        return AppThemeType.oscuro;
      case 'MORADO':
        return AppThemeType.morado;
      case 'NATURALEZA':
        return AppThemeType.naturaleza;
      default:
        return null;
    }
  }

  /// Mapea AppThemeType al string que espera la API.
  static String toApiString(AppThemeType type) {
    switch (type) {
      case AppThemeType.claro:
        return 'CLARO';
      case AppThemeType.oscuro:
        return 'OSCURO';
      case AppThemeType.morado:
        return 'MORADO';
      case AppThemeType.naturaleza:
        return 'NATURALEZA';
    }
  }

  /// Color preview para el selector.
  static Color previewColor(AppThemeType type) {
    switch (type) {
      case AppThemeType.claro:
        return const Color(0xFF6B9F75);
      case AppThemeType.oscuro:
        return const Color(0xFF00BCD4);
      case AppThemeType.morado:
        return const Color(0xFF7C4DFF);
      case AppThemeType.naturaleza:
        return const Color(0xFF8B6914);
    }
  }
}
