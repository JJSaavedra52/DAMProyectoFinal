// API provider for Flutter to interact with your Node/Express backend.
// Endpoints covered:
// - POST /api/usuarios            (register)
// - POST /api/usuarios/login      (login → JWT)
// - GET  /api/scans/me            (authenticated user scans)
// - POST /api/scans               (create scan; requires x-token)
// - GET  /api/scans/:id           (single scan)
// - DELETE /api/scans/:id         (delete scan; requires x-token)
//
// Adjust baseUrl depending on platform:
// - Android emulator: http://10.0.2.2:8081
// - iOS simulator / web: http://localhost:8081
// - Physical device: http://<PC_LAN_IP>:8081
//
// Dependencies needed in pubspec.yaml:
//   http: ^1.2.0
//   flutter_secure_storage: ^9.0.0 (optional, for token persistence)
// Or use shared_preferences if preferred.

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});
  @override
  String toString() => 'ApiException($statusCode): $message';
}

class User {
  final int id;
  final String nombre;
  final String correo;
  User({required this.id, required this.nombre, required this.correo});
  factory User.fromJson(Map<String, dynamic> j) =>
      User(id: j['id'], nombre: j['nombre'], correo: j['correo']);
}

class Scan {
  final int id;
  final String tipo;
  final String valor;
  final String? location;
  final int? usuarioId;
  Scan({
    required this.id,
    required this.tipo,
    required this.valor,
    this.location,
    this.usuarioId,
  });
  factory Scan.fromJson(Map<String, dynamic> j) => Scan(
    id: j['id'],
    tipo: j['tipo'] ?? '',
    valor: j['valor'] ?? '',
    location: j['location'],
    usuarioId: j['usuarioId'],
  );
}

class ApiConfig {
  /// Default API base URL (include the `/api` path if your backend exposes routes under /api)
  /// Change this value to point to Render deployment.
  static String apiBase = 'https://api-dam-c206.onrender.com/api';

  /// Optional helper to change base at runtime
  static void setApiBase(String url) {
    // keep it simple: use the provided value (caller should include /api if needed)
    apiBase = url;
  }
}

class ApiProvider with ChangeNotifier {
  ApiProvider._internal();
  static final ApiProvider _instance = ApiProvider._internal();
  factory ApiProvider() => _instance;

  // Secure storage (or replace with SharedPreferences)
  final FlutterSecureStorage _secure = const FlutterSecureStorage();

  /// Returns the current API base (includes '/api').
  String get baseUrl => ApiConfig.apiBase;

  /// Override the API base at runtime (e.g. after deployment).
  void setBaseUrl(String url) {
    ApiConfig.setApiBase(url);
    notifyListeners();
  }

  String? _token;
  User? _currentUser;

  String? get token => _token;
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _token != null;

  // Load token at app start
  Future<void> init() async {
    _token = await _secure.read(key: 'auth_token');
    if (_token != null) {
      // Optionally fetch user profile if endpoint exists
      notifyListeners();
    }
  }

  Map<String, String> _headers({bool auth = false}) {
    final h = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (auth && _token != null) {
      h['x-token'] = _token!;
    }
    return h;
  }

  // Generic response handler
  T _handle<T>(http.Response r, T Function(Map<String, dynamic>) parser) {
    final status = r.statusCode;
    Map<String, dynamic> body;
    try {
      body = json.decode(r.body.isEmpty ? '{}' : r.body);
    } catch (_) {
      throw ApiException('Invalid JSON response', statusCode: status);
    }
    if (status >= 200 && status < 300) {
      return parser(body);
    }
    final msg = body['msg'] ?? body['error'] ?? 'Error $status';
    throw ApiException(msg, statusCode: status);
  }

  // REGISTER
  Future<User> register({
    required String nombre,
    required String correo,
    required String password,
  }) async {
    final uri = Uri.parse('$baseUrl/usuarios');
    final resp = await http.post(
      uri,
      headers: _headers(),
      body: json.encode({
        'nombre': nombre,
        'correo': correo,
        'password': password,
      }),
    );
    return _handle(resp, (jsonMap) {
      final data = jsonMap['data'];
      if (data == null) throw ApiException('Missing user data');
      return User.fromJson(data);
    });
  }

  // LOGIN
  Future<User> login({required String correo, required String password}) async {
    final uri = Uri.parse('$baseUrl/usuarios/login');
    final resp = await http.post(
      uri,
      headers: _headers(),
      body: json.encode({'correo': correo, 'password': password}),
    );
    return _handle(resp, (jsonMap) {
      final data = jsonMap['data'];
      if (data == null) throw ApiException('Missing login data');
      final token = data['token'];
      final userJson = data['user'];
      if (token == null || userJson == null) {
        throw ApiException('Token or user missing in response');
      }
      _token = token;
      _currentUser = User.fromJson(userJson);
      _secure.write(key: 'auth_token', value: _token);
      notifyListeners();
      return _currentUser!;
    });
  }

  Future<void> logout() async {
    _token = null;
    _currentUser = null;
    await _secure.delete(key: 'auth_token');
    notifyListeners();
  }

  // CREATE SCAN (authenticated)
  Future<Scan> createScan({
    required String valor,
    String? location,
    String? tipo, // optional override
  }) async {
    if (!isAuthenticated) throw ApiException('Not authenticated');
    final uri = Uri.parse('$baseUrl/scans');
    final resp = await http.post(
      uri,
      headers: _headers(auth: true),
      body: json.encode({
        'valor': valor,
        if (location != null) 'location': location,
        if (tipo != null) 'tipo': tipo,
      }),
    );
    return _handle(resp, (jsonMap) {
      final data = jsonMap['data'];
      if (data == null) throw ApiException('Missing scan data');
      return Scan.fromJson(data);
    });
  }

  // GET MY SCANS
  Future<List<Scan>> getMyScans() async {
    if (!isAuthenticated) throw ApiException('Not authenticated');
    final uri = Uri.parse('$baseUrl/scans/me');
    final resp = await http.get(uri, headers: _headers(auth: true));
    return _handle(resp, (jsonMap) {
      final list = jsonMap['data'];
      if (list is! List) return <Scan>[];
      return list.map((e) => Scan.fromJson(e)).toList();
    });
  }

  // GET SCAN BY ID (public)
  Future<Scan> getScanById(int id) async {
    final uri = Uri.parse('$baseUrl/scans/$id');
    final resp = await http.get(uri, headers: _headers());
    return _handle(resp, (jsonMap) {
      final data = jsonMap['data'];
      if (data == null) throw ApiException('Scan not found');
      return Scan.fromJson(data);
    });
  }

  // DELETE SCAN (authenticated)
  Future<bool> deleteScan(int id) async {
    if (!isAuthenticated) throw ApiException('Not authenticated');
    final uri = Uri.parse('$baseUrl/scans/$id');
    final resp = await http.delete(uri, headers: _headers(auth: true));
    return _handle(resp, (jsonMap) => true);
  }

  // DISTANCE (optional)
  Future<Map<String, dynamic>> distanceBetween({
    String? startGeo,
    String? endGeo,
    int? startId,
    int? endId,
  }) async {
    final uri = Uri.parse('$baseUrl/scans/distance');
    final payload = <String, dynamic>{};
    if (startGeo != null) payload['start'] = startGeo;
    if (endGeo != null) payload['end'] = endGeo;
    if (startId != null) payload['startId'] = startId;
    if (endId != null) payload['endId'] = endId;

    final resp = await http.post(
      uri,
      headers: _headers(),
      body: json.encode(payload),
    );
    return _handle(resp, (jsonMap) => jsonMap);
  }

  // Helper to ensure token for manual calls
  Future<void> ensureAuth() async {
    if (!isAuthenticated) {
      final stored = await _secure.read(key: 'auth_token');
      if (stored != null) {
        _token = stored;
        notifyListeners();
      }
    }
  }
}
