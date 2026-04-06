import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();

  static const _tokenKey = 'jwt_token';
  static const _userIdKey = 'user_id';
  static const _userNameKey = 'user_name';
  static const _userEmailKey = 'user_email';
  Future<void> saveToken(String token) => _storage.write(key: _tokenKey, value: token);
  Future<String?> getToken() => _storage.read(key: _tokenKey);

  Future<void> saveUserId(int id) => _storage.write(key: _userIdKey, value: id.toString());
  Future<int?> getUserId() async {
    final val = await _storage.read(key: _userIdKey);
    return val != null ? int.tryParse(val) : null;
  }

  Future<void> saveUserName(String name) => _storage.write(key: _userNameKey, value: name);
  Future<String?> getUserName() => _storage.read(key: _userNameKey);

  Future<void> saveUserEmail(String email) => _storage.write(key: _userEmailKey, value: email);
  Future<String?> getUserEmail() => _storage.read(key: _userEmailKey);

  Future<void> deleteAll() => _storage.deleteAll();

  Future<bool> hasToken() async => (await getToken()) != null;
}
