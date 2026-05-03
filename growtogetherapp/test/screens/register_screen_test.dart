import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:growtogetherapp/l10n/app_localizations.dart';
import 'package:growtogetherapp/providers/auth_provider.dart';
import 'package:growtogetherapp/screens/register_screen.dart';
import 'package:provider/provider.dart';

import '../mocks.dart';

void main() {
  testWidgets('RegisterScreen pinta los 4 campos (nombre, email, contraseña, confirmar)',
      (tester) async {
    final auth = AuthProvider(MockAuthRepository(), MockUserRepository());

    await tester.pumpWidget(
      ChangeNotifierProvider<AuthProvider>.value(
        value: auth,
        child: const MaterialApp(
          locale: Locale('es'),
          supportedLocales: [Locale('es'), Locale('en'), Locale('ca')],
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: RegisterScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsNWidgets(4));
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}
