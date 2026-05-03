import 'package:flutter_test/flutter_test.dart';
import 'package:growtogether_data/growtogether_data.dart';
import 'package:growtogetherapp/providers/statistics_provider.dart';
import 'package:mocktail/mocktail.dart';

class _MockHabitoRepo extends Mock implements HabitoRepository {}

class _MockStorage extends Mock implements SecureStorageService {}

void main() {
  test('cargar() sin userId guardado deja datos vacíos', () async {
    final repo = _MockHabitoRepo();
    final storage = _MockStorage();
    when(() => storage.getUserId()).thenAnswer((_) async => null);
    final provider = StatisticsProvider(repo, storage);

    await provider.cargar();

    expect(provider.habitos, isEmpty);
    expect(provider.sinHabitos, isTrue);
    expect(provider.cargando, isFalse);
  });
}
