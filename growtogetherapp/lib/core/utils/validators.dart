class Validators {
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'El email es obligatorio';
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value.trim())) return 'Formato de email no válido';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'La contraseña es obligatoria';
    if (value.length < 8) return 'Mínimo 8 caracteres';
    if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Debe contener una mayúscula';
    if (!RegExp(r'[a-z]').hasMatch(value)) return 'Debe contener una minúscula';
    if (!RegExp(r'[0-9]').hasMatch(value)) return 'Debe contener un número';
    return null;
  }

  static String? notEmpty(String? value, [String fieldName = 'Este campo']) {
    if (value == null || value.trim().isEmpty) return '$fieldName es obligatorio';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return 'Confirma la contraseña';
    if (value != original) return 'Las contraseñas no coinciden';
    return null;
  }
}
