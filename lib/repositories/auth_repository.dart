import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../models/auth_models.dart';
import '../models/notification.dart';
import '../services/api_client.dart';

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository(this._apiClient);

  Future<LoginResponse> login(LoginRequest request) async {
    final response = await _apiClient.post('/api/user/login', data: request.toJson());
    return LoginResponse.fromJson(response.data);
  }

  Future<VerifyOtpResponse> verifyOtp(VerifyOtpRequest request) async {
    final response = await _apiClient.post('/api/user/verify-otp', data: request.toJson());
    return VerifyOtpResponse.fromJson(response.data);
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

  Future<UpdateProfileResponse> updateProfile(String id, String name, String profilePic, String token) async {
    final response = await _apiClient.put(
      '/api/user/profile/$id',
      data: {
        "name": name,
        "profilePic": profilePic,
      },
      headers: {'Authorization': 'Bearer $token'},
    );
    return UpdateProfileResponse.fromJson(response.data);
  }

  Future<ProfileResponse> getProfile(String token) async {
    final response = await _apiClient.get(
      '/api/user/profile',
      headers: {'Authorization': 'Bearer $token'},
    );
    return ProfileResponse.fromJson(response.data);
  }

  Future<void> logout(String token) async {
    await _apiClient.get(
      '/api/user/logout',
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<NotificationResponse> getNotifications(String token, {int page = 1, int limit = 10}) async {
    final response = await _apiClient.get(
      '/api/user/notification?page=$page&limit=$limit',
      headers: {'Authorization': 'Bearer $token'},
    );
    return NotificationResponse.fromJson(response.data);
  }

  Future<UnreadCountResponse> getUnreadCount(String token) async {
    final response = await _apiClient.get(
      '/api/user/notification/unread-count',
      headers: {'Authorization': 'Bearer $token'},
    );
    return UnreadCountResponse.fromJson(response.data);
  }

  Future<void> markNotificationAsRead(String token, {String? id, bool readAll = false}) async {
    await _apiClient.put(
      '/api/user/notification/read',
      data: {
        "id": id,
        "readAll": readAll,
      },
      headers: {'Authorization': 'Bearer $token'},
    );
  }
}
