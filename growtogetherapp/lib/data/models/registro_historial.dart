class RegistroHistorial {
  final DateTime fecha;
  final String estado;

  RegistroHistorial({
    required this.fecha,
    required this.estado,
  });

  factory RegistroHistorial.fromJson(Map<String, dynamic> json) {
    return RegistroHistorial(
      fecha: DateTime.parse(json['fecha']),
      estado: json['estado'] ?? 'PENDIENTE',
    );
  }

  bool get completado => estado == 'COMPLETADO';
  bool get noCompletado => estado == 'NO_COMPLETADO';
  bool get pendiente => estado == 'PENDIENTE';
}
