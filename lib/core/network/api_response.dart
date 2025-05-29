import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_response.freezed.dart';

@freezed
abstract class ApiResponse<T> with _$ApiResponse<T> {
  const factory ApiResponse({
    required String status,
    required String message,
    T? data,
    Object? metadata,
  }) = _ApiResponse;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return _ApiResponse<T>(
      status: json['status'] as String,
      message: json['message'] as String,
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      metadata: json['metadata'],
    );
  }
}
