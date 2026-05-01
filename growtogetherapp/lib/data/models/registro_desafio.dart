class RegistroDesafio {
  final int usuarioId;
  final DateTime fecha;
  final String estado;
  final int puntosGanados;

  RegistroDesafio({
    required this.usuarioId,
    required this.fecha,
    required this.estado,
    this.puntosGanados = 0,
  });

  bool get completado => estado == 'COMPLETADO';
  bool get noCompletado => estado == 'NO_COMPLETADO';
  bool get pendiente => estado == 'PENDIENTE';

  factory RegistroDesafio.fromJson(Map<String, dynamic> json) {
    return RegistroDesafio(
      usuarioId: json['usuarioId'] ?? 0,
      fecha: DateTime.parse(json['fecha']),
      estado: json['estado'] ?? 'PENDIENTE',
      puntosGanados: json['puntosGanados'] ?? 0,
    );
  }
}
