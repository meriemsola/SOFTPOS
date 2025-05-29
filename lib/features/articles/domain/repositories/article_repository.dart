// lib/features/articles/domain/repositories/article_repository.dart
import 'package:hce_emv/features/articles/data/repositories/article_repository_impl.dart';
import 'package:hce_emv/features/articles/data/sources/article_client.dart';
import 'package:hce_emv/features/articles/domain/models/article.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'article_repository.g.dart';

@riverpod
ArticleRepository articleRepository(Ref ref) =>
    ArticleRepositoryImpl(ref.watch(articleClientProvider));

abstract class ArticleRepository {
  Future<Either<String, List<Article>>> getArticles();
}
