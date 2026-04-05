import 'package:dio/dio.dart';
import '../../core/config/api_config.dart';
import '../local/secure_storage_service.dart';
import 'auth_interceptor.dart';

class DioClient {
  late final Dio dio;

  DioClient(SecureStorageService storage) {
    dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
    ));
    dio.interceptors.add(AuthInterceptor(storage));
  }
}
