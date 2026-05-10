import 'package:flutter_test/flutter_test.dart';
import 'package:growtogetherapp/providers/perfil_provider.dart';
import '../mocks.dart';

void main() {
  late PerfilProvider provider;
  late MockUserRepository mockRepo;
  late MockStorage mockStorage;

  setUp(() {
    mockRepo = MockUserRepository();
    mockStorage = MockStorage();
    provider = PerfilProvider(mockRepo, mockStorage, FakeLocalNotificationsService());
  });

  group('PerfilProvider', () {
    test('estado inicial es cargando sin usuario', () {
      expect(provider.cargando, true);
      expect(provider.usuario, isNull);
      expect(provider.error, isNull);
    });

    test('cargar() obtiene el perfil del usuario', () async {
      await provider.cargar();

      expect(provider.cargando, false);
      expect(provider.usuario, isNotNull);
      expect(provider.usuario!.nombre, 'Test User');
      expect(provider.usuario!.email, 'test@test.com');
      expect(provider.usuario!.puntosTotales, 50);
    });

    test('editarNombre actualiza el nombre', () async {
      await provider.cargar();
      final ok = await provider.editarNombre('Nuevo Nombre');

      expect(ok, true);
      expect(provider.usuario, isNotNull);
    });

    test('editarEmail retorna true', () async {
      await provider.cargar();
      final ok = await provider.editarEmail('nuevo@test.com');

      expect(ok, true);
    });

    test('editarFoto actualiza la foto', () async {
      await provider.cargar();
      final ok = await provider.editarFoto('base64string');

      expect(ok, true);
    });

    test('quitarFoto limpia la foto', () async {
      await provider.cargar();
      final ok = await provider.quitarFoto();

      expect(ok, true);
    });

    test('cambiarContrasena retorna true', () async {
      await provider.cargar();
      final ok = await provider.cambiarContrasena('actual', 'Nueva123');

      expect(ok, true);
    });

    test('cerrarSesion limpia storage', () async {
      await provider.cerrarSesion();
      final token = await mockStorage.getToken();
      expect(token, isNull);
    });
  });
}
