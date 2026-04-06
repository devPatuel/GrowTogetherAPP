import 'package:flutter_test/flutter_test.dart';
import 'package:growtogetherapp/providers/habitos_provider.dart';
import '../mocks.dart';

void main() {
  late HabitosProvider provider;
  late MockHabitoRepository mockRepo;
  late MockStorage mockStorage;

  setUp(() {
    mockRepo = MockHabitoRepository();
    mockStorage = MockStorage();
    provider = HabitosProvider(mockRepo, mockStorage);
  });

  group('HabitosProvider', () {
    test('estado inicial es cargando sin habitos', () {
      expect(provider.cargando, true);
      expect(provider.habitos, isEmpty);
      expect(provider.error, isNull);
    });

    test('cargar() obtiene habitos del repositorio', () async {
      await provider.cargar();

      expect(provider.cargando, false);
      expect(provider.habitos.length, 3);
      expect(provider.habitos[0].nombre, 'Gimnasio');
      expect(provider.habitos[1].nombre, 'Leer');
      expect(provider.error, isNull);
    });

    test('cargar() maneja errores correctamente', () async {
      mockRepo.fallar = true;
      await provider.cargar();

      expect(provider.cargando, false);
      expect(provider.error, isNotNull);
    });

    test('progreso se calcula correctamente', () async {
      await provider.cargar();

      // 1 de 3 completado (Leer)
      expect(provider.completados, 1);
      expect(provider.progreso, closeTo(0.333, 0.01));
    });

    test('toggleHabito actualiza estado optimisticamente', () async {
      await provider.cargar();
      final habito = provider.habitos[0]; // Gimnasio, no completado

      expect(habito.completadoHoy, false);

      await provider.toggleHabito(habito);

      // Despues del toggle, deberia estar completado
      // (el mock recarga despues del toggle)
      expect(provider.habitos[0].completadoHoy, true);
    });

    test('toggleHabito revierte si falla la API', () async {
      await provider.cargar();
      final habito = provider.habitos[0]; // Gimnasio, no completado

      mockRepo.fallar = true;
      final ok = await provider.toggleHabito(habito);

      expect(ok, false);
      expect(provider.habitos[0].completadoHoy, false); // Revertido
    });

    test('seleccionarDia cambia la fecha y recarga', () async {
      await provider.cargar();
      final ayer = DateTime.now().subtract(const Duration(days: 1));

      provider.seleccionarDia(ayer);

      expect(provider.fechaSeleccionada.day, ayer.day);
      expect(provider.esHoy, false);
    });

    test('esHoy es true para la fecha de hoy', () {
      expect(provider.esHoy, true);
    });
  });
}
