// auth_interceptor.dart
import 'package:dio/dio.dart';
import 'package:hce_emv/core/network/api_endpoints.dart';
import 'package:hce_emv/features/authentication/presentation/states/auth_state.dart';
import 'package:hce_emv/shared/repository/storage_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'dart:convert';

class AuthInterceptor extends Interceptor {
  final Ref ref;
  final Dio dio;
  final Logger logger;
  final StorageRepository storageRepository;
  bool _isRefreshing = false;
  List<RequestOptions> _pendingRequests = [];

  AuthInterceptor({
    required this.ref,
    required this.dio,
    required this.logger,
    required this.storageRepository,
  });

  bool _isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final Map<String, dynamic> data = json.decode(decoded);

      if (!data.containsKey('exp')) return true;

      final expiryTimestamp = data['exp'] as int;
      final expiryDateTime = DateTime.fromMillisecondsSinceEpoch(
        expiryTimestamp * 1000,
      );

      final now = DateTime.now();
      return now.isAfter(expiryDateTime) ||
          now.isAfter(expiryDateTime.subtract(const Duration(minutes: 5)));
    } catch (e) {
      logger.e('Error parsing JWT: $e');
      return true;
    }
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.path == ApiEndpoints.signIn ||
        options.path == ApiEndpoints.signUp ||
        options.path == ApiEndpoints.verify ||
        options.path == ApiEndpoints.refreshToken) {
      return handler.next(options);
    }

    final token = await storageRepository.getToken();

    if (token != null) {
      if (_isTokenExpired(token)) {
        logger.i('Token is expired or about to expire, attempting refresh');
        try {
          final refreshed = await _refreshToken();
          if (refreshed) {
            // Get the new token and add it to the request
            final newToken = await storageRepository.getToken();
            if (newToken != null) {
              options.headers['Authorization'] = 'Bearer $newToken';
              return handler.next(options);
            }
          }
          await storageRepository.deleteToken();
          await storageRepository.deleteRefreshToken();
          ref.read(authStateProvider.notifier).setUnauthenticated();
          return handler.reject(
            DioException(
              requestOptions: options,
              error: 'Session expired. Please log in again.',
              type: DioExceptionType.unknown,
            ),
          );
        } catch (e) {
          logger.e('Token refresh failed: $e');
          await storageRepository.deleteToken();
          await storageRepository.deleteRefreshToken();
          ref.read(authStateProvider.notifier).setUnauthenticated();
          return handler.reject(
            DioException(
              requestOptions: options,
              error: 'Authentication error. Please log in again.',
              type: DioExceptionType.unknown,
            ),
          );
        }
      } else {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } else {
      logger.w('No token available for authenticated request');
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      logger.i('Received 401, attempting token refresh');
      _pendingRequests.add(err.requestOptions);
      if (!_isRefreshing) {
        _isRefreshing = true;

        try {
          final refreshed = await _refreshToken();
          if (refreshed) {
            logger.i('Token refreshed successfully, retrying requests');
            final token = await storageRepository.getToken();
            for (final request in _pendingRequests) {
              request.headers['Authorization'] = 'Bearer $token';
              try {
                final response = await dio.fetch(request);
                handler.resolve(response);
              } catch (e) {
                logger.e('Request retry failed: $e');
                handler.reject(
                  DioException(
                    requestOptions: request,
                    error: e,
                    type: DioExceptionType.unknown,
                  ),
                );
              }
            }
            _pendingRequests = [];
            _isRefreshing = false;
            return;
          }
        } catch (e) {
          logger.e('Token refresh failed: $e');
        }

        _isRefreshing = false;
        _pendingRequests = [];

        await storageRepository.deleteToken();
        await storageRepository.deleteRefreshToken();
        ref.read(authStateProvider.notifier).setUnauthenticated();
      }
    }

    return handler.next(err);
  }

  Future<bool> _refreshToken() async {
    final refreshToken = await storageRepository.getRefreshToken();
    if (refreshToken == null) {
      logger.w('No refresh token available');
      return false;
    }

    try {
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: dio.options.baseUrl,
          connectTimeout: dio.options.connectTimeout,
          receiveTimeout: dio.options.receiveTimeout,
        ),
      );

      final response = await refreshDio.post(
        ApiEndpoints.refreshToken,
        options: Options(
          headers: {
            'Authorization': 'Bearer $refreshToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;

        if (data['status'] == 'success' && data['data'] != null) {
          final newToken = data['data']['token'];
          final newRefreshToken = data['data']['refreshToken'];
          final tokenExpiration = data['data']['tokenExpiration'];

          await storageRepository.storeToken(newToken);
          await storageRepository.storeRefreshToken(newRefreshToken);
          await storageRepository.storeTokenExpiration(tokenExpiration);

          logger.i('Tokens refreshed successfully');
          return true;
        }
      }

      logger.w(
        'Token refresh failed: ${response.statusCode}, ${response.data}',
      );
      return false;
    } catch (e) {
      logger.e('Token refresh request failed: $e');
      return false;
    }
  }
}
