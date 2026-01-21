import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../models/event_api_models.dart';
import '../models/session_models.dart';
import '../models/auth_models.dart';
import '../services/api_client.dart';

class EventRepository {
  final ApiClient _apiClient;

  EventRepository(this._apiClient);

  Future<CreateEventResponse> createEvent(CreateEventRequest request, String token) async {
    final response = await _apiClient.post(
      '/api/user/event/store',
      data: request.toJson(),
      headers: {'Authorization': 'Bearer $token'},
    );
    return CreateEventResponse.fromJson(response.data);
  }

  Future<GenerateSessionsResponse> generateSessions(String eventId, String token) async {
    final response = await _apiClient.get(
      '/api/user/event/generate-sessions/$eventId',
      headers: {'Authorization': 'Bearer $token'},
      receiveTimeout: const Duration(minutes: 4),
    );
    return GenerateSessionsResponse.fromJson(response.data);
  }

  Future<FileUploadResponse> uploadFile(XFile file, String token) async {
    FormData formData;
    
    if (kIsWeb) {
      final bytes = await file.readAsBytes();
      formData = FormData.fromMap({
        "files": MultipartFile.fromBytes(bytes, filename: file.name),
      });
    } else {
      formData = FormData.fromMap({
        "files": await MultipartFile.fromFile(file.path, filename: file.name),
      });
    }
    
    final response = await _apiClient.post(
      '/api/fileUpload', 
      data: formData,
      headers: {'Authorization': 'Bearer $token'},
    );
    return FileUploadResponse.fromJson(response.data);
  }
}
