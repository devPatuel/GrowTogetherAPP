class Usuario {
  final int id;
  final String nombre;
  final String email;
  final String? foto;
  final String? rol;
  final int puntosTotales;

  Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    this.foto,
    this.rol,
    this.puntosTotales = 0,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] ?? json['usuarioId'] ?? 0,
      nombre: json['nombre'] ?? '',
      email: json['email'] ?? '',
      foto: json['foto'],
      rol: json['rol'],
      puntosTotales: json['puntosTotales'] ?? 0,
    );
  }
}
