class ParticipanteDesafio {
  final int id;
  final int usuarioId;
  final String nombre;
  final String? foto;
  final int puntosGanados;
  final int rachaActual;
  final int rachaMaxima;
  final bool completadoHoy;
  final int? posicion;
  final String estadoProgreso;
  final int desafioId;
  final int puntosSiguientes;
  final double multiplicadorSiguiente;

  ParticipanteDesafio({
    required this.id,
    required this.usuarioId,
    required this.nombre,
    this.foto,
    this.puntosGanados = 0,
    this.rachaActual = 0,
    this.rachaMaxima = 0,
    this.completadoHoy = false,
    this.posicion,
    this.estadoProgreso = 'ACTIVO',
    required this.desafioId,
    this.puntosSiguientes = 0,
    this.multiplicadorSiguiente = 0,
  });

  bool get activo => estadoProgreso == 'ACTIVO';
  bool get superado => estadoProgreso == 'SUPERADO';
  bool get abandonado => estadoProgreso == 'ABANDONADO';

  ParticipanteDesafio copyWith({
    int? id,
    int? usuarioId,
    String? nombre,
    String? foto,
    int? puntosGanados,
    int? rachaActual,
    int? rachaMaxima,
    bool? completadoHoy,
    int? posicion,
    String? estadoProgreso,
    int? desafioId,
    int? puntosSiguientes,
    double? multiplicadorSiguiente,
  }) {
    return ParticipanteDesafio(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      nombre: nombre ?? this.nombre,
      foto: foto ?? this.foto,
      puntosGanados: puntosGanados ?? this.puntosGanados,
      rachaActual: rachaActual ?? this.rachaActual,
      rachaMaxima: rachaMaxima ?? this.rachaMaxima,
      completadoHoy: completadoHoy ?? this.completadoHoy,
      posicion: posicion ?? this.posicion,
      estadoProgreso: estadoProgreso ?? this.estadoProgreso,
      desafioId: desafioId ?? this.desafioId,
      puntosSiguientes: puntosSiguientes ?? this.puntosSiguientes,
      multiplicadorSiguiente: multiplicadorSiguiente ?? this.multiplicadorSiguiente,
    );
  }

  factory ParticipanteDesafio.fromJson(Map<String, dynamic> json) {
    return ParticipanteDesafio(
      id: (json['id'] ?? 0) is int ? json['id'] ?? 0 : int.tryParse(json['id'].toString()) ?? 0,
      usuarioId: json['usuarioId'] ?? 0,
      nombre: json['usuarioNombre'] ?? '',
      foto: json['usuarioFoto'],
      puntosGanados: json['puntosGanadosEnDesafio'] ?? 0,
      rachaActual: json['rachaActual'] ?? 0,
      rachaMaxima: json['rachaMaxima'] ?? 0,
      completadoHoy: json['completadoHoy'] ?? false,
      posicion: json['posicion'],
      estadoProgreso: json['estadoProgreso'] ?? 'ACTIVO',
      desafioId: json['desafioId'] ?? 0,
      puntosSiguientes: json['puntosSiguientes'] ?? 0,
      multiplicadorSiguiente: (json['multiplicadorSiguiente'] as num?)?.toDouble() ?? 0,
    );
  }
}
