// lib/features/articles/application/article_service.dart
import 'package:hce_emv/features/articles/domain/models/article.dart';
import 'package:hce_emv/features/articles/domain/repositories/article_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'article_service.g.dart';

@riverpod
ArticleService articleService(Ref ref) =>
    ArticleService(ref.watch(articleRepositoryProvider));

class ArticleService {
  final ArticleRepository _repository;

  ArticleService(this._repository);

  Future<Either<String, List<Article>>> getArticles() {
    return _repository.getArticles();
  }
}
