import 'package:flutter_test/flutter_test.dart';
import 'package:growtogetherapp/providers/auth_provider.dart';
import '../mocks.dart';

void main() {
  late AuthProvider provider;
  late MockAuthRepository mockAuthRepo;
  late MockUserRepository mockUserRepo;

  setUp(() {
    mockAuthRepo = MockAuthRepository();
    mockUserRepo = MockUserRepository();
    provider = AuthProvider(mockAuthRepo, mockUserRepo);
  });

  group('AuthProvider', () {
    test('estado inicial no carga y sin error', () {
      expect(provider.cargando, false);
      expect(provider.error, isNull);
    });

    test('login exitoso retorna true', () async {
      final ok = await provider.login('test@test.com', 'Prueba123');

      expect(ok, true);
      expect(provider.cargando, false);
      expect(provider.error, isNull);
    });

    test('login fallido retorna false con error', () async {
      mockAuthRepo.fallar = true;
      final ok = await provider.login('test@test.com', 'mal');

      expect(ok, false);
      expect(provider.error, 'Credenciales incorrectas');
    });

    test('register exitoso retorna true', () async {
      final ok = await provider.register('Test', 'test@test.com', 'Prueba123');

      expect(ok, true);
      expect(provider.error, isNull);
    });

    test('register fallido retorna false con error', () async {
      mockAuthRepo.fallar = true;
      final ok = await provider.register('Test', 'test@test.com', 'Prueba123');

      expect(ok, false);
      expect(provider.error, 'Email ya en uso');
    });

    test('verificarSesion retorna null sin sesion activa', () async {
      final usuario = await provider.verificarSesion();
      expect(usuario, isNull);
    });

    test('verificarSesion retorna usuario con sesion activa', () async {
      await provider.login('test@test.com', 'Prueba123');
      final usuario = await provider.verificarSesion();
      expect(usuario, isNotNull);
      expect(usuario!.email, 'test@test.com');
    });

    test('limpiarError borra el error', () async {
      mockAuthRepo.fallar = true;
      await provider.login('test@test.com', 'mal');
      expect(provider.error, isNotNull);

      provider.limpiarError();
      expect(provider.error, isNull);
    });
  });
}
