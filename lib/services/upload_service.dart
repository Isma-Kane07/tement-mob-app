import 'dart:io';
import 'package:dio/dio.dart';
import 'package:tement_mobile/config/constants.dart';
import 'package:tement_mobile/services/storage_service.dart';

class UploadService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  final StorageService _storage = StorageService();

  // Upload une seule photo
  Future<String> uploadPhoto(File imageFile) async {
    try {
      final token = await _storage.getToken();

      String fileName = imageFile.path.split('/').last;
      FormData formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      final response = await _dio.post(
        '/upload/photo',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      return response.data['url'];
    } catch (e) {
      print('❌ Erreur upload photo: $e');
      throw Exception('Impossible d\'uploader la photo');
    }
  }

  // ✅ VERSION CORRIGÉE - Upload plusieurs photos
  Future<List<String>> uploadMultiplePhotos(List<File> imageFiles) async {
    try {
      final token = await _storage.getToken();

      // Créer une liste pour stocker les MultipartFile
      List<MultipartFile> multipartFiles = [];

      for (int i = 0; i < imageFiles.length; i++) {
        final file = imageFiles[i];
        final fileName = file.path.split('/').last;

        print('📦 Préparation fichier ${i + 1}: $fileName');

        final multipartFile = await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        );
        multipartFiles.add(multipartFile);
      }

      // ✅ CORRECTION: Utiliser 'photos[]' ou une liste avec la même clé
      final formData = FormData.fromMap({
        'photos': multipartFiles, // Dio gère automatiquement le tableau
      });

      print('📤 Envoi de ${multipartFiles.length} fichiers...');

      final response = await _dio.post(
        '/upload/photos',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      print('📥 Réponse reçue: ${response.statusCode}');
      print('📥 Données: ${response.data}');

      // Extraire les URLs de la réponse
      if (response.data['urls'] != null) {
        return (response.data['urls'] as List)
            .map((item) => item['url'] as String)
            .toList();
      }

      return [];
    } catch (e) {
      print('❌ Erreur upload multiple: $e');
      if (e is DioException) {
        print('🔍 Détails: ${e.response?.data}');
      }
      throw Exception('Impossible d\'uploader les photos');
    }
  }

  // ✅ Version alternative avec upload séquentiel (plus fiable)
  Future<List<String>> uploadMultiplePhotosSequential(
      List<File> imageFiles) async {
    List<String> urls = [];

    for (int i = 0; i < imageFiles.length; i++) {
      try {
        print('📤 Upload photo ${i + 1}/${imageFiles.length}');
        final url = await uploadPhoto(imageFiles[i]);
        urls.add(url);
        print('✅ Photo ${i + 1} uploadée: $url');
      } catch (e) {
        print('❌ Erreur sur photo ${i + 1}: $e');
        throw Exception('Erreur lors de l\'upload de la photo ${i + 1}');
      }
    }

    return urls;
  }

  // Upload photo de profil
  Future<String> uploadProfilePhoto(File imageFile) async {
    try {
      final token = await _storage.getToken();

      String fileName = imageFile.path.split('/').last;
      FormData formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      final response = await _dio.post(
        '/upload/photo', // Réutilise la même route d'upload
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      return response.data['url'];
    } catch (e) {
      print('❌ Erreur upload photo de profil: $e');
      throw Exception('Impossible d\'uploader la photo');
    }
  }
}
