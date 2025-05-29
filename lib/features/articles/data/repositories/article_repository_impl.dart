import 'package:dio/dio.dart';
import 'package:hce_emv/core/network/network_interceptor.dart';
import 'package:hce_emv/features/articles/data/sources/article_client.dart';
import 'package:hce_emv/features/articles/domain/models/article.dart';
import 'package:hce_emv/features/articles/domain/repositories/article_repository.dart';
import 'package:fpdart/fpdart.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final ArticleClient _articleClient;

  ArticleRepositoryImpl(this._articleClient);

  @override
  Future<Either<String, List<Article>>> getArticles() async {
    try {
      final response = await _articleClient.getArticles();
      if (response.status == 'success' && response.data != null) {
        return right(response.data!);
      }
      return left(response.message);
    } on DioException catch (e) {
      final errorMessage = DioErrorHandler.handleError(e);
      return left(errorMessage);
    } catch (e) {
      return left(e.toString());
    }
  }
}
