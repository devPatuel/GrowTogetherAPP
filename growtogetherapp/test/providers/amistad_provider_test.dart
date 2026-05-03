import 'package:flutter_test/flutter_test.dart';
import 'package:growtogether_data/growtogether_data.dart';
import 'package:growtogetherapp/providers/amistad_provider.dart';
import 'package:mocktail/mocktail.dart';

class _MockAmistadRepo extends Mock implements AmistadRepository {}

void main() {
  late _MockAmistadRepo repo;
  late AmistadProvider provider;

  setUp(() {
    repo = _MockAmistadRepo();
    provider = AmistadProvider(repo);
  });

  test('cargarAmigos rellena la lista de amigos', () async {
    when(() => repo.listarAmigos()).thenAnswer((_) async => [
          Usuario(id: 1, nombre: 'Ana', email: 'ana@x.com'),
          Usuario(id: 2, nombre: 'Luis', email: 'luis@x.com'),
        ]);

    await provider.cargarAmigos();

    expect(provider.amigos, hasLength(2));
    expect(provider.cargandoAmigos, isFalse);
  });

  test('cargarAmigos guarda error si la API falla', () async {
    when(() => repo.listarAmigos()).thenThrow(ApiException('Sin red'));

    await provider.cargarAmigos();

    expect(provider.error, 'Sin red');
  });
}
