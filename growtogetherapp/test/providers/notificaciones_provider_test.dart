import 'package:flutter_test/flutter_test.dart';
import 'package:growtogether_data/growtogether_data.dart';
import 'package:growtogetherapp/providers/notificaciones_provider.dart';
import 'package:growtogetherapp/services/local_notifications_service.dart';
import 'package:mocktail/mocktail.dart';

class _MockNotifRepo extends Mock implements NotificacionRepository {}

class _FakeLocal extends Fake implements LocalNotificationsService {
  int programados = 0;
  int cancelados = 0;

  @override
  Future<void> programar(Notificacion n, Habito h) async {
    programados++;
  }

  @override
  Future<void> cancelar(int id) async {
    cancelados++;
  }
}

Habito _habito() => Habito(id: 10, nombre: 'Gym', descripcion: 'Pesas', usuarioId: 1);

Notificacion _notif({bool activa = true, int id = 99}) => Notificacion(
      id: id,
      mensaje: 'Toca gym',
      hora: 8,
      minuto: 30,
      activa: activa,
      habitoId: 10,
    );

void main() {
  late _MockNotifRepo repo;
  late _FakeLocal local;
  late NotificacionesProvider provider;

  setUp(() {
    repo = _MockNotifRepo();
    local = _FakeLocal();
    provider = NotificacionesProvider(repo, local);
  });

  test('cargar deja recordatorio en null si la API devuelve lista vacia', () async {
    when(() => repo.listarPorHabito(10)).thenAnswer((_) async => <Notificacion>[]);

    await provider.cargar(10);

    expect(provider.recordatorio, isNull);
    expect(provider.cargando, isFalse);
  });

  test('cargar coge la primera notificacion si hay varias', () async {
    when(() => repo.listarPorHabito(10)).thenAnswer((_) async => [_notif(id: 1), _notif(id: 2)]);

    await provider.cargar(10);

    expect(provider.recordatorio?.id, 1);
  });

  test('guardar sin recordatorio previo llama a crear y programa local', () async {
    final creada = _notif();
    when(() => repo.crear(
          habitoId: any(named: 'habitoId'),
          mensaje: any(named: 'mensaje'),
          hora: any(named: 'hora'),
          minuto: any(named: 'minuto'),
          activa: any(named: 'activa'),
        )).thenAnswer((_) async => creada);

    final ok = await provider.guardar(
      habito: _habito(),
      mensaje: 'Toca gym',
      hora: 8,
      minuto: 30,
      activa: true,
    );

    expect(ok, isTrue);
    expect(provider.recordatorio, creada);
    expect(local.programados, 1);
    expect(local.cancelados, 1); // siempre cancela antes de programar
  });

  test('guardar con recordatorio existente llama a actualizar y reprograma', () async {
    when(() => repo.listarPorHabito(10)).thenAnswer((_) async => [_notif()]);
    await provider.cargar(10);

    final actualizada = _notif().copyWith(mensaje: 'Cambiado');
    when(() => repo.actualizar(
          any(),
          habitoId: any(named: 'habitoId'),
          mensaje: any(named: 'mensaje'),
          hora: any(named: 'hora'),
          minuto: any(named: 'minuto'),
          activa: any(named: 'activa'),
        )).thenAnswer((_) async => actualizada);

    final ok = await provider.guardar(
      habito: _habito(),
      mensaje: 'Cambiado',
      hora: 9,
      minuto: 0,
      activa: true,
    );

    expect(ok, isTrue);
    expect(provider.recordatorio?.mensaje, 'Cambiado');
    expect(local.programados, 1);
  });

  test('guardar con activa=false cancela pero no programa', () async {
    when(() => repo.crear(
          habitoId: any(named: 'habitoId'),
          mensaje: any(named: 'mensaje'),
          hora: any(named: 'hora'),
          minuto: any(named: 'minuto'),
          activa: any(named: 'activa'),
        )).thenAnswer((_) async => _notif(activa: false));

    await provider.guardar(
      habito: _habito(),
      mensaje: 'Toca gym',
      hora: 8,
      minuto: 30,
      activa: false,
    );

    expect(local.cancelados, 1);
    expect(local.programados, 0);
  });

  test('eliminar borra del backend y cancela en local', () async {
    when(() => repo.listarPorHabito(10)).thenAnswer((_) async => [_notif()]);
    when(() => repo.eliminar(any())).thenAnswer((_) async {});
    await provider.cargar(10);

    final ok = await provider.eliminar();

    expect(ok, isTrue);
    expect(provider.recordatorio, isNull);
    expect(local.cancelados, 1);
  });

  test('cargar guarda mensaje de error si la API falla', () async {
    when(() => repo.listarPorHabito(10)).thenThrow(ApiException('Sin red'));

    await provider.cargar(10);

    expect(provider.error, 'Sin red');
    expect(provider.cargando, isFalse);
  });
}
