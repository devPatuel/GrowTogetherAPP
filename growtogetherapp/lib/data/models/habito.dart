class Habito {
  final int id;
  final String nombre;
  final String descripcion;
  final int rachaActual;
  final int rachaMaxima;
  final int usuarioId;
  final bool completadoHoy;
  final String frecuencia;
  final Set<String> diasSemana;

  Habito({
    required this.id,
    required this.nombre,
    required this.descripcion,
    this.rachaActual = 0,
    this.rachaMaxima = 0,
    required this.usuarioId,
    this.completadoHoy = false,
    this.frecuencia = 'DIARIO',
    this.diasSemana = const {},
  });

  factory Habito.fromJson(Map<String, dynamic> json) {
    final dias = json['diasSemana'];
    return Habito(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      rachaActual: json['rachaActual'] ?? 0,
      rachaMaxima: json['rachaMaxima'] ?? 0,
      usuarioId: json['usuarioId'] ?? 0,
      completadoHoy: json['completadoHoy'] ?? false,
      frecuencia: json['frecuencia'] ?? 'DIARIO',
      diasSemana: dias is List ? dias.map((e) => e.toString()).toSet() : const {},
    );
  }
}
