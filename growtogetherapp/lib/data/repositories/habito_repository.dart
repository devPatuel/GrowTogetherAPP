import 'package:dio/dio.dart';
import '../api/dio_client.dart';
import '../api/api_exceptions.dart';
import '../models/habito.dart';
import '../models/registro_historial.dart';

class HabitoRepository {
  final DioClient _client;

  HabitoRepository(this._client);

  Future<List<Habito>> getHabitos(int usuarioId) async {
    try {
      final response = await _client.dio.get('/habitos/usuario/$usuarioId');
      final list = response.data as List;
      return list.map((json) => Habito.fromJson(json)).toList();
    } on DioException catch (e) {
      _handleError(e, 'Error al cargar hábitos');
    }
  }

  Future<Habito> crearHabito({
    required String nombre,
    required String descripcion,
    String frecuencia = 'DIARIO',
    Set<String>? diasSemana,
    String tipo = 'POSITIVO',
    String? icono,
  }) async {
    try {
      final data = <String, dynamic>{
        'nombre': nombre,
        'descripcion': descripcion,
        'frecuencia': frecuencia,
        'tipo': tipo,
      };
      if (icono != null) data['icono'] = icono;
      if (diasSemana != null && diasSemana.isNotEmpty) {
        data['diasSemana'] = diasSemana.toList();
      }

      final response = await _client.dio.post('/habitos', data: data);
      return Habito.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final errors = e.response?.data;
        if (errors is Map) {
          final msg = errors.values.first?.toString() ?? 'Datos inválidos';
          throw BadRequestException(msg);
        }
      }
      _handleError(e, 'Error al crear hábito');
    }
  }

  Future<Habito> editarHabito(int id, {
    required String nombre,
    required String descripcion,
    String? frecuencia,
    Set<String>? diasSemana,
    String? tipo,
    String? icono,
  }) async {
    try {
      final data = <String, dynamic>{
        'nombre': nombre,
        'descripcion': descripcion,
      };
      if (frecuencia != null) data['frecuencia'] = frecuencia;
      if (diasSemana != null) data['diasSemana'] = diasSemana.toList();
      if (tipo != null) data['tipo'] = tipo;
      if (icono != null) data['icono'] = icono;

      final response = await _client.dio.put('/habitos/$id', data: data);
      return Habito.fromJson(response.data);
    } on DioException catch (e) {
      _handleError(e, 'Error al editar hábito');
    }
  }

  Future<void> eliminarHabito(int id) async {
    try {
      await _client.dio.delete('/habitos/$id');
    } on DioException catch (e) {
      _handleError(e, 'Error al eliminar hábito');
    }
  }

  Future<Habito> completarHabito(int id) async {
    try {
      final response = await _client.dio.post('/habitos/$id/completar');
      return Habito.fromJson(response.data);
    } on DioException catch (e) {
      _handleError(e, 'Error al completar hábito');
    }
  }

  Future<Habito> descompletarHabito(int id) async {
    try {
      final response = await _client.dio.post('/habitos/$id/descompletar');
      return Habito.fromJson(response.data);
    } on DioException catch (e) {
      _handleError(e, 'Error al desmarcar hábito');
    }
  }

  Future<Habito> getProgreso(int id) async {
    try {
      final response = await _client.dio.get('/habitos/$id/progreso');
      return Habito.fromJson(response.data);
    } on DioException catch (e) {
      _handleError(e, 'Error al cargar progreso');
    }
  }

  Future<List<RegistroHistorial>> obtenerHistorial(
    int habitoId, {
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (fechaInicio != null) {
        queryParams['fechaInicio'] =
            '${fechaInicio.year}-${fechaInicio.month.toString().padLeft(2, '0')}-${fechaInicio.day.toString().padLeft(2, '0')}';
      }
      if (fechaFin != null) {
        queryParams['fechaFin'] =
            '${fechaFin.year}-${fechaFin.month.toString().padLeft(2, '0')}-${fechaFin.day.toString().padLeft(2, '0')}';
      }

      final response = await _client.dio.get(
        '/habitos/$habitoId/historial',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      final list = response.data as List;
      return list.map((json) => RegistroHistorial.fromJson(json)).toList();
    } on DioException catch (e) {
      _handleError(e, 'Error al cargar historial');
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
    throw ApiException(defaultMsg);
  }
}
