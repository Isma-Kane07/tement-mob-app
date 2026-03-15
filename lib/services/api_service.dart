import 'package:dio/dio.dart';
import 'package:tement_mobile/config/constants.dart';
import 'package:tement_mobile/services/storage_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  final StorageService _storage = StorageService();

  // Intercepteur pour ajouter le token
  void _addAuthInterceptor() {
    _dio.interceptors.clear();
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
            print('🔑 Token ajouté: $token');
          } else {
            print('⚠️ Pas de token disponible');
          }
          print('📤 ${options.method} ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('📥 ${response.statusCode} ${response.data}');
          return handler.next(response);
        },
        onError: (error, handler) async {
          print('❌ Erreur API: ${error.message}');
          if (error.response?.statusCode == 401) {
            print('🚫 Token expiré, déconnexion...');
            await _storage.clearAll();
          }
          return handler.next(error);
        },
      ),
    );
  }

  // GET
  Future<Response> get(String endpoint,
      {Map<String, dynamic>? queryParams}) async {
    try {
      _addAuthInterceptor();
      final response = await _dio.get(endpoint, queryParameters: queryParams);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POST
  Future<Response> post(String endpoint, {Map<String, dynamic>? data}) async {
    try {
      _addAuthInterceptor();
      final response = await _dio.post(endpoint, data: data);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT
  Future<Response> put(String endpoint, {Map<String, dynamic>? data}) async {
    try {
      _addAuthInterceptor();
      final response = await _dio.put(endpoint, data: data);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ✅ AJOUTER PATCH
  Future<Response> patch(String endpoint, {Map<String, dynamic>? data}) async {
    try {
      _addAuthInterceptor();
      final response = await _dio.patch(endpoint, data: data);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE
  Future<Response> delete(String endpoint) async {
    try {
      _addAuthInterceptor();
      final response = await _dio.delete(endpoint);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Gestion des erreurs
  String _handleError(DioException error) {
    if (error.response != null) {
      // Erreur avec réponse du serveur
      final data = error.response!.data;
      if (data is Map && data.containsKey('message')) {
        return data['message'];
      }
      return 'Erreur ${error.response!.statusCode}';
    } else if (error.type == DioExceptionType.connectionTimeout) {
      return 'Délai de connexion dépassé';
    } else if (error.type == DioExceptionType.receiveTimeout) {
      return 'Délai de réception dépassé';
    } else if (error.type == DioExceptionType.connectionError) {
      return 'Pas de connexion internet';
    }
    return 'Erreur inattendue: ${error.message}';
  }
}
