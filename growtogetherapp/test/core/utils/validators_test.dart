import 'package:flutter_test/flutter_test.dart';
import 'package:growtogetherapp/core/utils/validators.dart';

void main() {
  test('Validators.email distingue vacío, formato inválido y válido', () {
    expect(Validators.email('', obligatorio: 'OBLIG', invalido: 'INV'), 'OBLIG');
    expect(Validators.email('jordi', obligatorio: 'OBLIG', invalido: 'INV'), 'INV');
    expect(
      Validators.email('jordi@example.com', obligatorio: 'OBLIG', invalido: 'INV'),
      isNull,
    );
  });

  test('Validators.password devuelve un unico mensaje de requisitos cuando falla', () {
    String? p(String v) => Validators.password(
          v,
          obligatoria: 'OB',
          requisitos: 'REQ',
        );

    expect(p(''), 'OB');
    expect(p('aA1!'), 'REQ');
    expect(p('abcdefg1!'), 'REQ');
    expect(p('Abcdefgh!'), 'REQ');
    expect(p('PRUEBA12!'), 'REQ');
    expect(p('Prueba12'), 'REQ');
    expect(p('Prueba12!'), isNull);
  });
}
