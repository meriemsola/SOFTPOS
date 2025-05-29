import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:hce_emv/shared/providers/global_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

class NetworkInterceptor extends Interceptor {
  final Ref ref;
  final Dio dio;
  final Logger logger;

  // Connection retry settings
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 1);

  const NetworkInterceptor(this.ref, this.dio, this.logger);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Add retry count to request metadata if not present
    options.extra['retryCount'] ??= 0;

    if (!await ref.read(isConnectedProvider.future)) {
      logger.w(
        'No network connection when attempting request: ${options.path}',
      );
      return handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          error: 'No internet connection',
        ),
      );
    }

    final storageRepository = ref.read(storageRepositoryProvider);
    final token = await storageRepository.getToken();
    if (token != null) {
      logger.d('Auth token: $token');
      options.headers['Authorization'] = 'Bearer $token';
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    logger.e(
      'API Error: ${err.requestOptions.path}',
      error: err,
      stackTrace: err.stackTrace,
    );

    bool shouldRetry = _shouldRetryRequest(err);

    if (shouldRetry) {
      return _retry(err.requestOptions, handler);
    }

    // Pass through other errors
    return handler.next(err);
  }

  // Add a new method to determine if a request should be retried
  bool _shouldRetryRequest(DioException err) {
    final path = err.requestOptions.path;
    final method = err.requestOptions.method;

    // Don't retry authentication or state-changing operations
    if (path.contains('/auth/signup') ||
        path.contains('/auth/login') ||
        path.contains('/auth/verify')) {
      return false;
    }

    // Don't retry POST requests generally (they change state)
    if (method == 'POST') {
      return false;
    }

    // Only retry for connection issues or server errors
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError) {
      return true;
    }

    // Retry for 5xx server errors
    if (err.response?.statusCode != null &&
        err.response!.statusCode! >= 500 &&
        err.response!.statusCode! < 600) {
      return true;
    }

    return false;
  }

  // Retry logic
  Future<void> _retry(
    RequestOptions requestOptions,
    ErrorInterceptorHandler handler,
  ) async {
    int retryCount = requestOptions.extra['retryCount'] ?? 0;

    if (retryCount < _maxRetries) {
      retryCount++;
      logger.i(
        'Retrying request ($retryCount/$_maxRetries): ${requestOptions.path}',
      );

      // Wait before retrying with exponential backoff
      await Future.delayed(_retryDelay * retryCount);

      // Create new request options
      final options = Options(
        method: requestOptions.method,
        headers: requestOptions.headers,
      );

      // Add retry count
      final newRequestOptions = requestOptions.copyWith();
      newRequestOptions.extra['retryCount'] = retryCount;

      try {
        final response = await dio.request<dynamic>(
          requestOptions.path,
          data: requestOptions.data,
          queryParameters: requestOptions.queryParameters,
          options: options,
        );

        // Pass successful retry response
        logger.i('Retry successful: ${requestOptions.path}');
        return handler.resolve(response);
      } catch (e) {
        // Continue with error handling if this retry failed
        if (e is DioException) {
          logger.w('Retry failed ($retryCount/$_maxRetries): ${e.message}');

          // If we still have retries left, let the onError handle it again
          if (retryCount < _maxRetries) {
            return handler.reject(e);
          }

          // Otherwise, add context that we exhausted retries
          final enhancedError = DioException(
            requestOptions: e.requestOptions,
            error: '${e.error} (after $_maxRetries retry attempts)',
            response: e.response,
            type: e.type,
            message: e.message,
          );
          return handler.reject(enhancedError);
        }

        logger.w('Retry failed with non-Dio exception: $e');
        return handler.reject(
          DioException(
            requestOptions: requestOptions,
            error: '$e (after retry attempt $retryCount)',
            type: DioExceptionType.unknown,
          ),
        );
      }
    } else {
      logger.w(
        'Max retries ($_maxRetries) reached for: ${requestOptions.path}',
      );
      // Create enhanced error that indicates max retries were reached
      final enhancedError = DioException(
        requestOptions: requestOptions,
        error: 'Request failed after $_maxRetries retry attempts',
        type: DioExceptionType.unknown,
        message: 'Max retries exceeded',
      );
      return handler.reject(enhancedError);
    }
  }
}

class DioErrorHandler {
  static final _logger = Logger();

  static String handleError(DioException error) {
    _logger.e(
      'API Error: ${error.message}',
      error: error,
      stackTrace: error.stackTrace,
    );

    // Log error details for debugging
    _logErrorDetails(error);

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timed out. Please try again later.';
      case DioExceptionType.sendTimeout:
        return 'Request timed out. Please check your connection and try again.';
      case DioExceptionType.receiveTimeout:
        return 'Server response timed out. Please try again later.';
      case DioExceptionType.connectionError:
        return 'No internet connection. Please check your network settings.';
      case DioExceptionType.badResponse:
        return _handleBadResponse(error.response);
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      default:
        return 'An unexpected error occurred. Please try again later.';
    }
  }

  static String _handleBadResponse(Response? response) {
    final statusCode = response?.statusCode;
    final responseData = response?.data;

    // Try to extract error message from response if available
    String? serverMessage;

    if (responseData is Map<String, dynamic>) {
      // First check for our standard error response format
      serverMessage = responseData['message'] as String?;

      // If not found, check other common error fields
      serverMessage ??= responseData['error'] as String?;
    } else if (responseData is String) {
      // Handle case where backend might still return plain string errors
      try {
        // Try to parse as JSON first
        final Map<String, dynamic> jsonData = json.decode(responseData);
        serverMessage = jsonData['message'] as String?;
      } catch (_) {
        // If it's not JSON, use the string directly
        serverMessage = responseData;
      }
    }

    // Return server-provided message if available
    if (serverMessage != null && serverMessage.isNotEmpty) {
      return serverMessage;
    }

    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check your information and try again.';
      case 401:
        return 'Please log in to continue.';
      case 403:
        return 'You don\'t have permission to access this resource.';
      case 404:
        return 'The requested resource was not found.';
      case 422:
        return 'Validation error. Please check your input.';
      case 429:
        return 'Too many requests. Please try again later.';
      case 500:
        return 'Server error. Our team has been notified.';
      case 502:
        return 'Server unavailable. Please try again later.';
      case 503:
        return 'Service temporarily unavailable. Please try again later.';
      default:
        return 'Error ${statusCode ?? "unknown"}. Please try again later.';
    }
  }

  static void _logErrorDetails(DioException error) {
    _logger.e(
      'API Error Details:\n'
      'URL: ${error.requestOptions.uri}\n'
      'Method: ${error.requestOptions.method}\n'
      'Status code: ${error.response?.statusCode}\n'
      'Headers: ${error.requestOptions.headers}\n'
      'Request data: ${error.requestOptions.data}\n'
      'Response data: ${error.response?.data}\n'
      'Type: ${error.type}\n'
      'Error: ${error.error}',
      error: error,
      stackTrace: error.stackTrace,
    );
  }
}
