import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  /// Para teléfono físico por USB: ejecutar `adb reverse tcp:8081 tcp:8081`
  /// Para emulador Android: cambiar a 'http://10.0.2.2:8081/api/v1'
  static String get baseUrl {
    const envUrl = String.fromEnvironment('API_URL');
    if (envUrl.isNotEmpty) return envUrl;

    return 'http://localhost:8081/api/v1';
  }

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
