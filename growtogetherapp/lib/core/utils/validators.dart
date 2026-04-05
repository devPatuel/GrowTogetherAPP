/// Mensajes de error de validacion. Se pasan desde la UI para permitir i18n.
class ValidatorMessages {
  final String emailObligatorio;
  final String emailInvalido;
  final String contrasenaObligatoria;
  final String contrasenaMinimo;
  final String contrasenaMayuscula;
  final String contrasenaMinuscula;
  final String contrasenaNumero;
  final String confirmarContrasena;
  final String contrasenasNoCoinciden;

  const ValidatorMessages({
    required this.emailObligatorio,
    required this.emailInvalido,
    required this.contrasenaObligatoria,
    required this.contrasenaMinimo,
    required this.contrasenaMayuscula,
    required this.contrasenaMinuscula,
    required this.contrasenaNumero,
    required this.confirmarContrasena,
    required this.contrasenasNoCoinciden,
  });
}

class Validators {
  static String? email(String? value, {
    required String obligatorio,
    required String invalido,
  }) {
    if (value == null || value.trim().isEmpty) return obligatorio;
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value.trim())) return invalido;
    return null;
  }

  static String? password(String? value, {
    required String obligatoria,
    required String minimo,
    required String mayuscula,
    required String minuscula,
    required String numero,
  }) {
    if (value == null || value.isEmpty) return obligatoria;
    if (value.length < 8) return minimo;
    if (!RegExp(r'[A-Z]').hasMatch(value)) return mayuscula;
    if (!RegExp(r'[a-z]').hasMatch(value)) return minuscula;
    if (!RegExp(r'[0-9]').hasMatch(value)) return numero;
    return null;
  }

  static String? notEmpty(String? value, String mensajeObligatorio) {
    if (value == null || value.trim().isEmpty) return mensajeObligatorio;
    return null;
  }

  static String? confirmPassword(String? value, String original, {
    required String confirmar,
    required String noCoinciden,
  }) {
    if (value == null || value.isEmpty) return confirmar;
    if (value != original) return noCoinciden;
    return null;
  }
}
