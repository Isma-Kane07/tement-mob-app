// lib/services/upload_service.dart
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

  // Upload d'une seule photo (profile ou logement)
  Future<String> uploadPhoto(File imageFile) async {
    try {
      final token = await _storage.getToken();
      if (token == null) throw Exception('Non authentifié');

      final fileName = imageFile.path.split('/').last;

      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      print('📤 Upload photo: $fileName (${await imageFile.length()} bytes)');

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

      print('✅ Photo uploadée: ${response.data['url']}');
      return response.data['url'];
    } on DioException catch (e) {
      print('❌ Erreur upload photo: ${e.response?.data}');
      throw Exception('Impossible d\'uploader la photo: ${e.message}');
    } catch (e) {
      print('❌ Erreur upload photo: $e');
      throw Exception('Impossible d\'uploader la photo');
    }
  }

  // Upload multiple de photos
  Future<List<String>> uploadMultiplePhotos(List<File> imageFiles) async {
    try {
      final token = await _storage.getToken();
      if (token == null) throw Exception('Non authentifié');

      print('📦 Préparation de ${imageFiles.length} fichiers...');

      // Créer la liste des MultipartFile
      final multipartFiles = <MultipartFile>[];

      for (int i = 0; i < imageFiles.length; i++) {
        final file = imageFiles[i];
        final fileName = file.path.split('/').last;

        print('  - Fichier ${i + 1}: $fileName (${await file.length()} bytes)');

        multipartFiles.add(
          await MultipartFile.fromFile(
            file.path,
            filename: fileName,
          ),
        );
      }

      final formData = FormData.fromMap({
        'photos': multipartFiles,
      });

      print('📤 Envoi de ${multipartFiles.length} fichiers vers Cloudinary...');

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

      if (response.data['urls'] != null) {
        final urls = (response.data['urls'] as List)
            .map((item) => item['url'] as String)
            .toList();
        print('✅ ${urls.length} photos uploadées avec succès');
        return urls;
      }

      return [];
    } on DioException catch (e) {
      print('❌ Erreur upload multiple: ${e.response?.data}');
      throw Exception('Impossible d\'uploader les photos: ${e.message}');
    } catch (e) {
      print('❌ Erreur upload multiple: $e');
      throw Exception('Impossible d\'uploader les photos');
    }
  }

  // Upload photo de profil (alias pour uploadPhoto)
  Future<String> uploadProfilePhoto(File imageFile) async {
    return await uploadPhoto(imageFile);
  }

  // Upload séquentiel (plus fiable pour beaucoup de photos)
  Future<List<String>> uploadMultiplePhotosSequential(
      List<File> imageFiles) async {
    final List<String> urls = [];
    int successCount = 0;

    for (int i = 0; i < imageFiles.length; i++) {
      try {
        print('📤 Upload photo ${i + 1}/${imageFiles.length}');
        final url = await uploadPhoto(imageFiles[i]);
        urls.add(url);
        successCount++;
        print('✅ Photo ${i + 1} uploadée');
      } catch (e) {
        print('❌ Erreur sur photo ${i + 1}: $e');
        // Continue avec les autres photos
      }
    }

    print('✅ $successCount/${imageFiles.length} photos uploadées');

    if (urls.isEmpty) {
      throw Exception('Aucune photo n\'a pu être uploadée');
    }

    return urls;
  }
}
