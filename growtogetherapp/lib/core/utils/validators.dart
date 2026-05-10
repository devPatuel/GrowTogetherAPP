/// Mensajes de error de validacion. Se pasan desde la UI para permitir i18n.
class ValidatorMessages {
  final String emailObligatorio;
  final String emailInvalido;
  final String contrasenaObligatoria;
  final String contrasenaRequisitos;
  final String confirmarContrasena;
  final String contrasenasNoCoinciden;

  const ValidatorMessages({
    required this.emailObligatorio,
    required this.emailInvalido,
    required this.contrasenaObligatoria,
    required this.contrasenaRequisitos,
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
    required String requisitos,
  }) {
    if (value == null || value.isEmpty) return obligatoria;
    final cumple = value.length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(value) &&
        RegExp(r'[a-z]').hasMatch(value) &&
        RegExp(r'[0-9]').hasMatch(value) &&
        RegExp(r'[^A-Za-z0-9]').hasMatch(value);
    if (!cumple) return requisitos;
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
