import 'package:dio/dio.dart';
import '../api/dio_client.dart';
import '../api/api_exceptions.dart';
import '../models/habito.dart';

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
  }) async {
    try {
      final data = <String, dynamic>{
        'nombre': nombre,
        'descripcion': descripcion,
        'frecuencia': frecuencia,
      };
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
  }) async {
    try {
      final data = <String, dynamic>{
        'nombre': nombre,
        'descripcion': descripcion,
      };
      if (frecuencia != null) data['frecuencia'] = frecuencia;
      if (diasSemana != null) data['diasSemana'] = diasSemana.toList();

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
