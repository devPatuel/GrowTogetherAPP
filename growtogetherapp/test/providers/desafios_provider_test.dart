import 'package:flutter_test/flutter_test.dart';
import 'package:growtogether_data/growtogether_data.dart';
import 'package:growtogetherapp/providers/desafios_provider.dart';
import 'package:mocktail/mocktail.dart';

class _MockDesafioRepo extends Mock implements DesafioRepository {}

Desafio _desafio({int id = 1}) => Desafio(
      id: id,
      nombre: 'Reto $id',
      descripcion: '',
      fechaInicio: DateTime.now().subtract(const Duration(days: 5)),
      fechaFin: DateTime.now().add(const Duration(days: 25)),
      creadorId: 1,
      creadorNombre: 'Jordi',
    );

void main() {
  late _MockDesafioRepo repo;
  late DesafiosProvider provider;

  setUp(() {
    repo = _MockDesafioRepo();
    provider = DesafiosProvider(repo);
  });

  test('cargar() rellena la lista y deja cargando=false', () async {
    when(() => repo.listarMisDesafios())
        .thenAnswer((_) async => [_desafio(id: 1), _desafio(id: 2)]);

    await provider.cargar();

    expect(provider.desafios, hasLength(2));
    expect(provider.cargando, isFalse);
    expect(provider.error, isNull);
  });

  test('cargar() guarda mensaje de error si el repositorio falla', () async {
    when(() => repo.listarMisDesafios()).thenThrow(ApiException('Sin conexión'));

    await provider.cargar();

    expect(provider.desafios, isEmpty);
    expect(provider.error, contains('Sin conexión'));
  });
}
