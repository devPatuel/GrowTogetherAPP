class SolicitudAmistad {
  final int id;
  final int remitenteId;
  final String remitenteNombre;
  final String? remitenteFoto;
  final int destinatarioId;
  final String destinatarioNombre;
  final String? destinatarioFoto;
  final String estado;
  final DateTime fechaEnvio;
  final DateTime? fechaRespuesta;

  SolicitudAmistad({
    required this.id,
    required this.remitenteId,
    required this.remitenteNombre,
    this.remitenteFoto,
    required this.destinatarioId,
    required this.destinatarioNombre,
    this.destinatarioFoto,
    required this.estado,
    required this.fechaEnvio,
    this.fechaRespuesta,
  });

  factory SolicitudAmistad.fromJson(Map<String, dynamic> json) {
    return SolicitudAmistad(
      id: (json['id'] as num).toInt(),
      remitenteId: (json['remitenteId'] as num).toInt(),
      remitenteNombre: json['remitenteNombre'] ?? '',
      remitenteFoto: json['remitenteFoto'],
      destinatarioId: (json['destinatarioId'] as num).toInt(),
      destinatarioNombre: json['destinatarioNombre'] ?? '',
      destinatarioFoto: json['destinatarioFoto'],
      estado: json['estado'] ?? 'PENDIENTE',
      fechaEnvio: DateTime.parse(json['fechaEnvio'] as String),
      fechaRespuesta: json['fechaRespuesta'] != null
          ? DateTime.parse(json['fechaRespuesta'] as String)
          : null,
    );
  }
}
