import 'participante_desafio.dart';

class Desafio {
  final int id;
  final String nombre;
  final String descripcion;
  final String? objetivo;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final bool activo;
  final String frecuencia;
  final Set<String> diasSemana;
  final String tipo;
  final String? icono;
  final int creadorId;
  final String creadorNombre;
  final List<ParticipanteDesafio> participantes;

  Desafio({
    required this.id,
    required this.nombre,
    required this.descripcion,
    this.objetivo,
    required this.fechaInicio,
    required this.fechaFin,
    this.activo = true,
    this.frecuencia = 'DIARIO',
    this.diasSemana = const {},
    this.tipo = 'POSITIVO',
    this.icono,
    required this.creadorId,
    required this.creadorNombre,
    this.participantes = const [],
  });

  bool get esNegativo => tipo == 'NEGATIVO';

  bool get finalizado => DateTime.now().isAfter(fechaFin);

  /// Días totales del desafío (incluyendo inicio y fin).
  int get duracionDias => fechaFin.difference(fechaInicio).inDays + 1;

  /// Días transcurridos desde el inicio hasta hoy o hasta fechaFin.
  int get diasTranscurridos {
    final hoy = DateTime.now();
    final tope = hoy.isBefore(fechaFin) ? hoy : fechaFin;
    if (tope.isBefore(fechaInicio)) return 0;
    return tope.difference(fechaInicio).inDays + 1;
  }

  /// Días que quedan desde hoy hasta fechaFin (0 si ya finalizó).
  int get diasRestantes {
    final hoy = DateTime.now();
    if (hoy.isAfter(fechaFin)) return 0;
    return fechaFin.difference(hoy).inDays;
  }

  /// Devuelve la participación del usuario indicado, si existe.
  ParticipanteDesafio? participacionDe(int usuarioId) {
    for (final p in participantes) {
      if (p.usuarioId == usuarioId) return p;
    }
    return null;
  }

  Desafio copyWith({
    int? id,
    String? nombre,
    String? descripcion,
    String? objetivo,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    bool? activo,
    String? frecuencia,
    Set<String>? diasSemana,
    String? tipo,
    String? icono,
    int? creadorId,
    String? creadorNombre,
    List<ParticipanteDesafio>? participantes,
  }) {
    return Desafio(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      objetivo: objetivo ?? this.objetivo,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      activo: activo ?? this.activo,
      frecuencia: frecuencia ?? this.frecuencia,
      diasSemana: diasSemana ?? this.diasSemana,
      tipo: tipo ?? this.tipo,
      icono: icono ?? this.icono,
      creadorId: creadorId ?? this.creadorId,
      creadorNombre: creadorNombre ?? this.creadorNombre,
      participantes: participantes ?? this.participantes,
    );
  }

  factory Desafio.fromJson(Map<String, dynamic> json) {
    final dias = json['diasSemana'];
    final parts = json['participantes'];
    return Desafio(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      objetivo: json['objetivo'],
      fechaInicio: _parseFecha(json['fechaInicio']),
      fechaFin: _parseFecha(json['fechaFin']),
      activo: json['activo'] ?? true,
      frecuencia: json['frecuencia'] ?? 'DIARIO',
      diasSemana: dias is List ? dias.map((e) => e.toString()).toSet() : const {},
      tipo: json['tipo'] ?? 'POSITIVO',
      icono: json['icono'],
      creadorId: json['creadorId'] ?? 0,
      creadorNombre: json['creadorNombre'] ?? '',
      participantes: parts is List
          ? parts.map((e) => ParticipanteDesafio.fromJson(e as Map<String, dynamic>)).toList()
          : const [],
    );
  }

  /// Acepta tanto millisegundos epoch (Date Java) como string ISO (LocalDate).
  static DateTime _parseFecha(dynamic raw) {
    if (raw == null) return DateTime.now();
    if (raw is int) return DateTime.fromMillisecondsSinceEpoch(raw);
    if (raw is String) return DateTime.parse(raw);
    return DateTime.now();
  }
}
