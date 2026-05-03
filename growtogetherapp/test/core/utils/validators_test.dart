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

  test('Validators.password aplica todas las reglas en orden', () {
    String? p(String v) => Validators.password(
          v,
          obligatoria: 'OB',
          minimo: 'MIN',
          mayuscula: 'MAY',
          minuscula: 'MNU',
          numero: 'NUM',
        );

    expect(p(''), 'OB');
    expect(p('aA1'), 'MIN');
    expect(p('abcdefg1'), 'MAY');
    expect(p('Abcdefgh'), 'NUM');
    expect(p('Prueba12'), isNull);
  });
}
