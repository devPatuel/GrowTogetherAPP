import 'package:flutter_test/flutter_test.dart';
import 'package:growtogether_data/growtogether_data.dart';
import 'package:growtogetherapp/providers/detalle_habito_provider.dart';
import 'package:mocktail/mocktail.dart';

class _MockHabitoRepo extends Mock implements HabitoRepository {}

Habito _habito({bool completadoHoy = false}) => Habito(
      id: 1,
      nombre: 'Leer',
      descripcion: '',
      usuarioId: 1,
      completadoHoy: completadoHoy,
    );

void main() {
  test('toggleCompletar marca el hábito como completado y registra cambios',
      () async {
    final repo = _MockHabitoRepo();
    when(() => repo.obtenerHistorial(any(),
            fechaInicio: any(named: 'fechaInicio'),
            fechaFin: any(named: 'fechaFin')))
        .thenAnswer((_) async => const []);
    when(() => repo.completarHabito(1, fecha: any(named: 'fecha')))
        .thenAnswer((_) async => _habito(completadoHoy: true));

    final provider = DetalleHabitoProvider(repo, _habito());
    final ok = await provider.toggleCompletar();

    expect(ok, isTrue);
    expect(provider.habito.completadoHoy, isTrue);
    expect(provider.huboCambios, isTrue);
  });
}
