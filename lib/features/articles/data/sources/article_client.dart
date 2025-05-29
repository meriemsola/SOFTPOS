// lib/features/articles/data/datasources/article_client.dart
import 'package:hce_emv/core/network/api_client.dart';
import 'package:hce_emv/core/network/api_endpoints.dart';
import 'package:hce_emv/core/network/api_response.dart';
import 'package:hce_emv/features/articles/domain/models/article.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'article_client.g.dart';

@riverpod
ArticleClient articleClient(Ref ref) =>
    ArticleClient(ref.watch(apiClientProvider));

class ArticleClient {
  final ApiClient _apiClient;

  ArticleClient(this._apiClient);

  Future<ApiResponse<List<Article>>> getArticles() async {
    return _apiClient.get<List<Article>>(
      ApiEndpoints.getArticles,
      fromJson: (json) {
        if (json is List) {
          return json
              .map((item) => Article.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          throw FormatException('Expected List, got ${json.runtimeType}');
        }
      },
    );
  }
}
