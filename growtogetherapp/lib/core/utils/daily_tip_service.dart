import 'package:shared_preferences/shared_preferences.dart';
import '../constants/daily_tips.dart';

/// Servicio que gestiona el consejo diario.
/// Avanza el índice de forma circular cada nuevo día.
class DailyTipService {
  static const _keyLastDate = 'daily_tip_last_date';
  static const _keyIndex = 'daily_tip_index';

  /// Devuelve el consejo del día para el idioma dado, o null si ya se mostró hoy.
  static Future<String?> getTipIfNewDay(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10); // yyyy-MM-dd
    final lastDate = prefs.getString(_keyLastDate);

    if (lastDate == today) {
      return null; // Ya se mostró hoy
    }

    final tips = DailyTips.getTips(languageCode);
    final currentIndex = prefs.getInt(_keyIndex) ?? 0;
    final tip = tips[currentIndex % tips.length];

    // Guardar fecha y avanzar índice
    await prefs.setString(_keyLastDate, today);
    await prefs.setInt(_keyIndex, (currentIndex + 1) % tips.length);

    return tip;
  }
}
