import 'package:dio/dio.dart';
import '../api/dio_client.dart';
import '../api/api_exceptions.dart';
import '../models/usuario.dart';

class UserRepository {
  final DioClient _client;

  UserRepository(this._client);

  Future<Usuario> obtenerPerfil(int id) async {
    try {
      final response = await _client.dio.get('/usuarios/perfil/$id');
      return Usuario.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw ApiException('Usuario no encontrado', statusCode: 404);
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw NetworkException();
      }
      throw ApiException('Error al obtener el perfil');
    }
  }

  Future<Usuario> editarPerfil(int id, {String? nombre, String? email, String? foto}) async {
    try {
      // Primero obtenemos el perfil actual para no perder campos
      final actual = await obtenerPerfil(id);
      final response = await _client.dio.put('/usuarios/perfil/$id', data: {
        'nombre': nombre ?? actual.nombre,
        'email': email ?? actual.email,
        'foto': foto ?? actual.foto,
      });
      return Usuario.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final errors = e.response?.data;
        if (errors is Map) {
          final msg = errors.values.first?.toString() ?? 'Datos inválidos';
          throw BadRequestException(msg);
        }
        throw BadRequestException('Datos inválidos');
      }
      if (e.response?.statusCode == 409) {
        throw BadRequestException('El email ya está en uso');
      }
      throw ApiException('Error al actualizar el perfil');
    }
  }

  Future<void> cambiarContrasena(int id, String actual, String nueva) async {
    try {
      await _client.dio.put('/usuarios/perfil/$id/contrasena', data: {
        'currentPassword': actual,
        'newPassword': nueva,
      });
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw BadRequestException('La contraseña actual no es correcta');
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw NetworkException();
      }
      throw ApiException('Error al cambiar la contraseña');
    }
  }
}
