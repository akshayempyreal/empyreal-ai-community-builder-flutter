import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';

class ApiClient {
  static const String baseUrl = 'https://j6xnc2h8-3001.inc1.devtunnels.ms';
  
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
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

  Future<Response> get(String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    Duration? receiveTimeout,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: Options(
          headers: headers,
          receiveTimeout: receiveTimeout,
        ),
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }


  Future<Response> post(String path, {
    dynamic data,
    Map<String, dynamic>? headers,
    Duration? receiveTimeout,
  }) async {
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
          receiveTimeout: receiveTimeout,
        ),
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }


  Future<Response> put(String path, {
    dynamic data,
    Map<String, dynamic>? headers,
    Duration? receiveTimeout,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        options: Options(
          headers: headers,
          receiveTimeout: receiveTimeout,
        ),
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
