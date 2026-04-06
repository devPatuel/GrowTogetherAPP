import 'package:growtogetherapp/data/api/api_exceptions.dart';
import 'package:growtogetherapp/data/local/secure_storage_service.dart';
import 'package:growtogetherapp/data/models/habito.dart';
import 'package:growtogetherapp/data/models/registro_historial.dart';
import 'package:growtogetherapp/data/models/usuario.dart';
import 'package:growtogetherapp/data/repositories/auth_repository.dart';
import 'package:growtogetherapp/data/repositories/habito_repository.dart';
import 'package:growtogetherapp/data/repositories/user_repository.dart';

/// Mock de SecureStorageService que guarda en memoria
class MockStorage implements SecureStorageService {
  final Map<String, String> _data = {'user_id': '1', 'user_name': 'Test User'};

  @override
  Future<void> saveToken(String token) async => _data['token'] = token;
  @override
  Future<String?> getToken() async => _data['token'];
  @override
  Future<void> saveUserId(int id) async => _data['user_id'] = id.toString();
  @override
  Future<int?> getUserId() async {
    final val = _data['user_id'];
    return val != null ? int.tryParse(val) : null;
  }
  @override
  Future<void> saveUserName(String name) async => _data['user_name'] = name;
  @override
  Future<String?> getUserName() async => _data['user_name'];
  @override
  Future<void> saveUserEmail(String email) async => _data['user_email'] = email;
  @override
  Future<String?> getUserEmail() async => _data['user_email'];
  @override
  Future<void> deleteAll() async => _data.clear();
  @override
  Future<bool> hasToken() async => _data.containsKey('token');
}

/// Habitos de prueba
final habitosPrueba = [
  Habito(id: 1, nombre: 'Gimnasio', descripcion: 'Entrenar', usuarioId: 1, completadoHoy: false, rachaActual: 3, rachaMaxima: 5, progresoMensual: 0.5),
  Habito(id: 2, nombre: 'Leer', descripcion: 'Leer 30 min', usuarioId: 1, completadoHoy: true, rachaActual: 2, rachaMaxima: 4, progresoMensual: 0.33),
  Habito(id: 3, nombre: 'Dejar de fumar', descripcion: 'Sin fumar', usuarioId: 1, completadoHoy: false, tipo: 'NEGATIVO', rachaActual: 5, rachaMaxima: 5, progresoMensual: 0.8),
];

/// Mock de HabitoRepository
class MockHabitoRepository implements HabitoRepository {
  List<Habito> habitos = List.from(habitosPrueba);
  bool fallar = false;

  @override
  Future<List<Habito>> getHabitos(int usuarioId, {DateTime? fecha}) async {
    if (fallar) throw ApiException('Error de red');
    return habitos;
  }

  @override
  Future<Habito> completarHabito(int id, {DateTime? fecha}) async {
    if (fallar) throw ApiException('Error');
    final idx = habitos.indexWhere((h) => h.id == id);
    habitos[idx] = habitos[idx].copyWith(completadoHoy: true);
    return habitos[idx];
  }

  @override
  Future<Habito> descompletarHabito(int id, {DateTime? fecha}) async {
    if (fallar) throw ApiException('Error');
    final idx = habitos.indexWhere((h) => h.id == id);
    habitos[idx] = habitos[idx].copyWith(completadoHoy: false);
    return habitos[idx];
  }

  @override
  Future<Habito> crearHabito({required String nombre, required String descripcion, String frecuencia = 'DIARIO', Set<String>? diasSemana, String tipo = 'POSITIVO', String? icono}) async {
    final nuevo = Habito(id: habitos.length + 1, nombre: nombre, descripcion: descripcion, usuarioId: 1);
    habitos.add(nuevo);
    return nuevo;
  }

  @override
  Future<Habito> editarHabito(int id, {required String nombre, required String descripcion, String? frecuencia, Set<String>? diasSemana, String? tipo, String? icono}) async {
    return habitos.firstWhere((h) => h.id == id);
  }

  @override
  Future<void> eliminarHabito(int id) async {
    habitos.removeWhere((h) => h.id == id);
  }

  @override
  Future<Habito> getProgreso(int id) async => habitos.firstWhere((h) => h.id == id);

  @override
  @override
  Future<List<RegistroHistorial>> obtenerHistorial(int habitoId, {DateTime? fechaInicio, DateTime? fechaFin}) async => [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Mock de AuthRepository
class MockAuthRepository implements AuthRepository {
  bool fallar = false;
  Usuario? usuarioLogueado;

  @override
  Future<Usuario> login(String email, String password) async {
    if (fallar) throw ApiException('Credenciales incorrectas');
    usuarioLogueado = Usuario(id: 1, nombre: 'Test', email: email);
    return usuarioLogueado!;
  }

  @override
  Future<bool> register(String nombre, String email, String password) async {
    if (fallar) throw ApiException('Email ya en uso');
    return true;
  }

  @override
  Future<Usuario?> getCurrentUser() async => usuarioLogueado;

  @override
  void aplicarPreferenciasDesdeUsuario(Usuario perfil) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Mock de UserRepository
class MockUserRepository implements UserRepository {
  @override
  Future<Usuario> obtenerPerfil(int id) async {
    return Usuario(id: id, nombre: 'Test User', email: 'test@test.com', puntosTotales: 50);
  }

  @override
  Future<Usuario> editarPerfil(int id, {String? nombre, String? email, String? foto}) async {
    return Usuario(id: id, nombre: nombre ?? 'Test User', email: email ?? 'test@test.com');
  }

  @override
  Future<void> actualizarPreferencias(int id, {String? tema, String? idioma}) async {}

  @override
  Future<void> cambiarContrasena(int id, String actual, String nueva) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
