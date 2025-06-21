import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:hce_emv/core/network/network_interceptor.dart';
import 'package:hce_emv/features/authentication/data/sources/auth_interceptor.dart';
import 'package:hce_emv/shared/providers/global_providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dio.g.dart';

@riverpod
Dio dio(Ref ref) {
  final logger = Logger();

  // Choose base URL based on platform
  final baseUrl =
      kIsWeb
          ? 'http://localhost:8080'
          : (defaultTargetPlatform == TargetPlatform.iOS
              ? 'http://localhost:8080'
              : 'http://192.168.100.16:8080');

  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      contentType: 'application/json',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      validateStatus: (status) {
        return status != null && (status >= 200 && status < 400);
      },
      followRedirects: true,
      maxRedirects: 5,
    ),
  );

  if (kDebugMode && !kIsWeb) {
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.badCertificateCallback = (cert, host, port) => true;
        return client;
      },
    );
  }

  if (kDebugMode) {
    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
        compact: true,
      ),
    );
  }

  dio.interceptors.add(NetworkInterceptor(ref, dio, logger));

  dio.interceptors.add(
    AuthInterceptor(
      ref: ref,
      dio: dio,
      logger: logger,
      storageRepository: ref.watch(storageRepositoryProvider),
    ),
  );

  return dio;
}
