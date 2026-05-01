import 'package:dio/dio.dart';
import '../api/dio_client.dart';
import '../api/api_exceptions.dart';
import '../models/usuario.dart';
import '../models/solicitud_amistad.dart';

class AmistadRepository {
  final DioClient _client;

  AmistadRepository(this._client);

  Future<List<Usuario>> buscarUsuarios(String query) async {
    try {
      final response = await _client.dio.get(
        '/usuarios/buscar',
        queryParameters: {'q': query},
      );
      final lista = response.data as List;
      return lista.map((e) => Usuario.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _mapear(e, 'Error al buscar usuarios');
    }
  }

  Future<Usuario?> buscarPorId(int id) async {
    try {
      final response = await _client.dio.get('/usuarios/publico/$id');
      final data = response.data as Map<String, dynamic>;
      // El endpoint publico no devuelve email: rellenamos con cadena vacía para
      // reutilizar el modelo Usuario existente sin romper el fromJson.
      return Usuario.fromJson({
        'id': data['id'],
        'nombre': data['nombre'],
        'email': '',
        'foto': data['foto'],
        'puntosTotales': data['puntosTotales'] ?? 0,
      });
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw _mapear(e, 'Error al buscar el usuario');
    }
  }

  Future<List<Usuario>> listarAmigos() async {
    try {
      final response = await _client.dio.get('/usuarios/amigos');
      final lista = response.data as List;
      return lista.map((e) => Usuario.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _mapear(e, 'Error al cargar los amigos');
    }
  }

  Future<void> eliminarAmigo(int amigoId) async {
    try {
      await _client.dio.delete('/usuarios/amigos/$amigoId');
    } on DioException catch (e) {
      throw _mapear(e, 'Error al eliminar el amigo');
    }
  }

  Future<SolicitudAmistad> enviarSolicitud(int destinatarioId) async {
    try {
      final response = await _client.dio.post(
        '/usuarios/amistades/solicitudes/$destinatarioId',
      );
      return SolicitudAmistad.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapear(e, 'Error al enviar la solicitud');
    }
  }

  Future<List<SolicitudAmistad>> listarRecibidas() async {
    try {
      final response = await _client.dio.get(
        '/usuarios/amistades/solicitudes/recibidas',
      );
      final lista = response.data as List;
      return lista
          .map((e) => SolicitudAmistad.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapear(e, 'Error al cargar las peticiones recibidas');
    }
  }

  Future<List<SolicitudAmistad>> listarEnviadas() async {
    try {
      final response = await _client.dio.get(
        '/usuarios/amistades/solicitudes/enviadas',
      );
      final lista = response.data as List;
      return lista
          .map((e) => SolicitudAmistad.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapear(e, 'Error al cargar las peticiones enviadas');
    }
  }

  Future<void> aceptar(int solicitudId) async {
    try {
      await _client.dio.put('/usuarios/amistades/solicitudes/$solicitudId/aceptar');
    } on DioException catch (e) {
      throw _mapear(e, 'Error al aceptar la solicitud');
    }
  }

  Future<void> rechazar(int solicitudId) async {
    try {
      await _client.dio.put('/usuarios/amistades/solicitudes/$solicitudId/rechazar');
    } on DioException catch (e) {
      throw _mapear(e, 'Error al rechazar la solicitud');
    }
  }

  Future<void> cancelar(int solicitudId) async {
    try {
      await _client.dio.delete('/usuarios/amistades/solicitudes/$solicitudId');
    } on DioException catch (e) {
      throw _mapear(e, 'Error al cancelar la solicitud');
    }
  }

  ApiException _mapear(DioException e, String fallback) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.connectionError) {
      return NetworkException();
    }
    final status = e.response?.statusCode;
    if (status == 400) {
      final data = e.response?.data;
      String mensaje = fallback;
      if (data is Map) {
        final posibles = data['message'] ?? data['error'] ?? data.values.firstOrNull;
        if (posibles is String && posibles.isNotEmpty) mensaje = posibles;
      } else if (data is String && data.isNotEmpty) {
        mensaje = data;
      }
      return BadRequestException(mensaje);
    }
    if (status == 404) {
      return ApiException('Recurso no encontrado', statusCode: 404);
    }
    return ApiException(fallback, statusCode: status);
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
