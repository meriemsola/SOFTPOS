// api_client.dart
import 'package:dio/dio.dart';
import 'package:hce_emv/core/network/api_response.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hce_emv/core/network/dio.dart';

part 'api_client.g.dart';

@riverpod
ApiClient apiClient(Ref ref) => ApiClient(ref.watch(dioProvider));

class ApiClient {
  final Dio _dio;

  ApiClient(this._dio);

  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(Object? json)? fromJson,
  }) async {
    final response = await _dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
    );

    return ApiResponse.fromJson(response.data, fromJson ?? (json) => json as T);
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(Object? json)? fromJson,
  }) async {
    final response = await _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );

    return ApiResponse.fromJson(response.data, fromJson ?? (json) => json as T);
  }

  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(Object? json)? fromJson,
  }) async {
    final response = await _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );

    return ApiResponse.fromJson(response.data, fromJson ?? (json) => json as T);
  }

  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(Object? json)? fromJson,
  }) async {
    final response = await _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );

    return ApiResponse.fromJson(response.data, fromJson ?? (json) => json as T);
  }
}
