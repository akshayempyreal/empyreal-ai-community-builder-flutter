import 'package:dio/dio.dart';
import '../models/auth_models.dart';
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

  Future<FileUploadResponse> uploadFile(String filePath, String token) async {
    String fileName = filePath.split('/').last;
    FormData formData = FormData.fromMap({
      "files": await MultipartFile.fromFile(filePath, filename: fileName),
    });
    
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
}
