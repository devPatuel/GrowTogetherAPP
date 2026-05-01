import 'package:dio/dio.dart';
import '../api/dio_client.dart';
import '../api/api_exceptions.dart';
import '../models/desafio.dart';
import '../models/participante_desafio.dart';
import '../models/registro_desafio.dart';

class DesafioRepository {
  final DioClient _client;

  DesafioRepository(this._client);

  static String _formatDate(DateTime fecha) =>
      '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';

  Future<List<Desafio>> listarMisDesafios() async {
    try {
      final response = await _client.dio.get('/desafios/mios');
      final list = response.data as List;
      return list.map((json) => Desafio.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      _handleError(e, 'Error al cargar desafíos');
    }
  }

  Future<Desafio> obtenerDesafio(int id) async {
    try {
      final response = await _client.dio.get('/desafios/$id');
      return Desafio.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _handleError(e, 'Error al cargar el desafío');
    }
  }

  Future<List<ParticipanteDesafio>> obtenerRanking(int id) async {
    try {
      final response = await _client.dio.get('/desafios/$id/ranking');
      final list = response.data as List;
      return list.map((json) => ParticipanteDesafio.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      _handleError(e, 'Error al cargar el ranking');
    }
  }

  Future<List<RegistroDesafio>> obtenerHistorial(
    int id, {
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (fechaInicio != null) queryParams['fechaInicio'] = _formatDate(fechaInicio);
      if (fechaFin != null) queryParams['fechaFin'] = _formatDate(fechaFin);
      final response = await _client.dio.get(
        '/desafios/$id/historial',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      final list = response.data as List;
      return list.map((json) => RegistroDesafio.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      _handleError(e, 'Error al cargar el historial');
    }
  }

  Future<Desafio> crearDesafio({
    required String nombre,
    required String descripcion,
    String? objetivo,
    required DateTime fechaInicio,
    required DateTime fechaFin,
    String frecuencia = 'DIARIO',
    Set<String>? diasSemana,
    String tipo = 'POSITIVO',
    String? icono,
    List<int>? participantesIds,
  }) async {
    try {
      final data = <String, dynamic>{
        'nombre': nombre,
        'descripcion': descripcion,
        'fechaInicio': fechaInicio.millisecondsSinceEpoch,
        'fechaFin': fechaFin.millisecondsSinceEpoch,
        'frecuencia': frecuencia,
        'tipo': tipo,
      };
      if (objetivo != null) data['objetivo'] = objetivo;
      if (icono != null) data['icono'] = icono;
      if (diasSemana != null && diasSemana.isNotEmpty) {
        data['diasSemana'] = diasSemana.toList();
      }
      if (participantesIds != null && participantesIds.isNotEmpty) {
        data['participantesIds'] = participantesIds;
      }
      final response = await _client.dio.post('/desafios', data: data);
      return Desafio.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final errors = e.response?.data;
        if (errors is Map) {
          final msg = errors.values.first?.toString() ?? 'Datos inválidos';
          throw BadRequestException(msg);
        }
      }
      _handleError(e, 'Error al crear el desafío');
    }
  }

  Future<Desafio> editarDesafio(
    int id, {
    String? nombre,
    String? descripcion,
    String? objetivo,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    String? frecuencia,
    Set<String>? diasSemana,
    String? tipo,
    String? icono,
    List<int>? participantesIds,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (nombre != null) data['nombre'] = nombre;
      if (descripcion != null) data['descripcion'] = descripcion;
      if (objetivo != null) data['objetivo'] = objetivo;
      if (fechaInicio != null) data['fechaInicio'] = fechaInicio.millisecondsSinceEpoch;
      if (fechaFin != null) data['fechaFin'] = fechaFin.millisecondsSinceEpoch;
      if (frecuencia != null) data['frecuencia'] = frecuencia;
      if (diasSemana != null) data['diasSemana'] = diasSemana.toList();
      if (tipo != null) data['tipo'] = tipo;
      if (icono != null) data['icono'] = icono;
      if (participantesIds != null) data['participantesIds'] = participantesIds;
      final response = await _client.dio.put('/desafios/$id', data: data);
      return Desafio.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _handleError(e, 'Error al editar el desafío');
    }
  }

  Future<void> eliminarDesafio(int id) async {
    try {
      await _client.dio.delete('/desafios/$id');
    } on DioException catch (e) {
      _handleError(e, 'Error al eliminar el desafío');
    }
  }

  Future<void> abandonarDesafio(int id) async {
    try {
      await _client.dio.delete('/desafios/$id/abandonar');
    } on DioException catch (e) {
      _handleError(e, 'Error al abandonar el desafío');
    }
  }

  Future<ParticipanteDesafio> unirseADesafio(int id) async {
    try {
      final response = await _client.dio.post('/desafios/$id/unirse');
      return ParticipanteDesafio.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _handleError(e, 'Error al unirse al desafío');
    }
  }

  Future<ParticipanteDesafio> completarDesafio(int id, {DateTime? fecha}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (fecha != null) queryParams['fecha'] = _formatDate(fecha);
      final response = await _client.dio.post(
        '/desafios/$id/completar',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      return ParticipanteDesafio.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _handleError(e, 'Error al completar el desafío');
    }
  }

  Future<ParticipanteDesafio> descompletarDesafio(int id, {DateTime? fecha}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (fecha != null) queryParams['fecha'] = _formatDate(fecha);
      final response = await _client.dio.post(
        '/desafios/$id/descompletar',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      return ParticipanteDesafio.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _handleError(e, 'Error al desmarcar el desafío');
    }
  }

  Never _handleError(DioException e, String defaultMsg) {
    if (e.response?.statusCode == 401) {
      throw UnauthorizedException();
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.connectionError) {
      throw NetworkException('No se pudo conectar al servidor');
    }
    final data = e.response?.data;
    if (data is Map) {
      final mensaje = data['message'] ?? data.values.firstOrNull;
      if (mensaje is String && mensaje.isNotEmpty) {
        throw ApiException(mensaje, statusCode: e.response?.statusCode);
      }
    }
    throw ApiException(defaultMsg, statusCode: e.response?.statusCode);
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
