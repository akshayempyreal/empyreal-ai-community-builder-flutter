import 'package:dio/dio.dart';

class ApiClient {
  static const String baseUrl = 'https://j6xnc2h8-3001.inc1.devtunnels.ms';
  
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
      final response = await _dio.post(path, data: data, options: Options(headers: headers));
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
