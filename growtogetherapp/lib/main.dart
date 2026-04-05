import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/l10n/locale_controller.dart';
import 'core/theme/app_themes.dart';
import 'core/theme/theme_controller.dart';
import 'l10n/app_localizations.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeController.instance.cargar();
  await LocaleController.instance.cargar();
  runApp(const GrowTogetherApp());
}

class GrowTogetherApp extends StatelessWidget {
  const GrowTogetherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppThemeType>(
      valueListenable: ThemeController.instance,
      builder: (_, themeType, __) {
        return ValueListenableBuilder<Locale>(
          valueListenable: LocaleController.instance,
          builder: (_, locale, __) {
            return MaterialApp(
              title: 'GrowTogether',
              debugShowCheckedModeBanner: false,
              locale: locale,
              supportedLocales: LocaleController.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              theme: AppThemes.fromType(themeType),
              home: const LoginScreen(),
            );
          },
        );
      },
    );
  }
}
