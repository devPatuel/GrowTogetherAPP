import 'package:flutter_test/flutter_test.dart';
import 'package:growtogether_data/growtogether_data.dart';
import 'package:growtogetherapp/providers/detalle_desafio_provider.dart';
import 'package:mocktail/mocktail.dart';

class _MockDesafioRepo extends Mock implements DesafioRepository {}

Desafio _desafio({List<ParticipanteDesafio>? participantes, int creadorId = 1}) {
  return Desafio(
    id: 9,
    nombre: 'Reto',
    descripcion: '',
    fechaInicio: DateTime.now().subtract(const Duration(days: 5)),
    fechaFin: DateTime.now().add(const Duration(days: 25)),
    creadorId: creadorId,
    creadorNombre: 'Jordi',
    participantes: participantes ?? const [],
  );
}

void main() {
  test('soyCreador y yo identifican al usuario actual', () {
    final repo = _MockDesafioRepo();
    when(() => repo.obtenerHistorial(any(),
            fechaInicio: any(named: 'fechaInicio'),
            fechaFin: any(named: 'fechaFin')))
        .thenAnswer((_) async => const []);

    final desafio = _desafio(
      creadorId: 7,
      participantes: [
        ParticipanteDesafio(id: 1, usuarioId: 7, nombre: 'Jordi', desafioId: 9),
      ],
    );
    final provider = DetalleDesafioProvider(repo, desafio, 7);

    expect(provider.soyCreador, isTrue);
    expect(provider.yo, isNotNull);
    expect(provider.yo!.usuarioId, 7);
  });
}
