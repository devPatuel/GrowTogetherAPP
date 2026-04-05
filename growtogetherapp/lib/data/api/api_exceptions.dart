class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});
  @override
  String toString() => message;
}

class UnauthorizedException extends ApiException {
  UnauthorizedException([String message = 'No autorizado']) : super(message, statusCode: 401);
}

class NetworkException extends ApiException {
  NetworkException([String message = 'Error de conexión']) : super(message);
}

class ServerException extends ApiException {
  ServerException([String message = 'Error del servidor']) : super(message, statusCode: 500);
}

class BadRequestException extends ApiException {
  BadRequestException(String message) : super(message, statusCode: 400);
}
