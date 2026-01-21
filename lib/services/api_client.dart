import 'package:dio/dio.dart';

class ApiClient {
  static const String baseUrl = 'https://team3api.empyreal.in';
  
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  ApiClient() {
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  Future<Response> get(String path, {Map<String, dynamic>? headers}) async {
    try {
      final response = await _dio.get(path, options: Options(headers: headers));
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? headers}) async {
    try {
      // If data is FormData, remove Content-Type header to let Dio set it automatically
      Map<String, dynamic>? finalHeaders = headers;
      if (data is FormData) {
        finalHeaders = {...?headers};
        // Don't set Content-Type for FormData - Dio will set multipart/form-data with boundary
        finalHeaders.remove('Content-Type');
      }
      
      final response = await _dio.post(
        path, 
        data: data, 
        options: Options(
          headers: finalHeaders,
          contentType: data is FormData ? null : Headers.jsonContentType,
        ),
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> put(String path, {dynamic data, Map<String, dynamic>? headers}) async {
    try {
      final response = await _dio.put(
        path, 
        data: data, 
        options: Options(headers: headers),
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    String message = 'Something went wrong';
    if (e.response?.data != null && e.response?.data is Map) {
      message = e.response?.data['message'] ?? message;
    } else {
      message = e.message ?? message;
    }
    return Exception(message);
  }
}
