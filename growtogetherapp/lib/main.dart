import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/l10n/locale_controller.dart';
import 'core/theme/app_themes.dart';
import 'core/theme/theme_controller.dart';
import 'data/api/dio_client.dart';
import 'data/local/secure_storage_service.dart';
import 'data/repositories/amistad_repository.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/desafio_repository.dart';
import 'data/repositories/habito_repository.dart';
import 'data/repositories/user_repository.dart';
import 'l10n/app_localizations.dart';
import 'providers/amistad_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/desafios_provider.dart';
import 'providers/habitos_provider.dart';
import 'providers/perfil_provider.dart';
import 'providers/statistics_provider.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeController.instance.cargar();
  await LocaleController.instance.cargar();

  // Inyeccion de dependencias centralizada
  final storage = SecureStorageService();
  final dioClient = DioClient(storage);
  final authRepo = AuthRepository(dioClient, storage);
  final habitoRepo = HabitoRepository(dioClient);
  final userRepo = UserRepository(dioClient);
  final amistadRepo = AmistadRepository(dioClient);
  final desafioRepo = DesafioRepository(dioClient);

  runApp(
    MultiProvider(
      providers: [
        Provider<SecureStorageService>.value(value: storage),
        Provider<DioClient>.value(value: dioClient),
        Provider<AuthRepository>.value(value: authRepo),
        Provider<HabitoRepository>.value(value: habitoRepo),
        Provider<UserRepository>.value(value: userRepo),
        Provider<AmistadRepository>.value(value: amistadRepo),
        Provider<DesafioRepository>.value(value: desafioRepo),
        ChangeNotifierProvider(create: (_) => HabitosProvider(habitoRepo, storage)),
        ChangeNotifierProvider(create: (_) => AuthProvider(authRepo, userRepo)),
        ChangeNotifierProvider(create: (_) => PerfilProvider(userRepo, storage)),
        ChangeNotifierProvider(create: (_) => StatisticsProvider(habitoRepo, storage)),
        ChangeNotifierProvider(create: (_) => AmistadProvider(amistadRepo)),
        ChangeNotifierProvider(create: (_) => DesafiosProvider(desafioRepo)),
      ],
      child: const GrowTogetherApp(),
    ),
  );
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
