// lib/features/articles/presentation/controllers/articles_controller.dart
import 'package:hce_emv/features/articles/application/article_service.dart';
import 'package:hce_emv/features/articles/domain/models/article.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'articles_controller.g.dart';

@riverpod
class ArticlesController extends _$ArticlesController {
  @override
  Future<List<Article>> build() async {
    state = const AsyncLoading();
    final articles = await AsyncValue.guard(() async {
      final result = await ref.read(articleServiceProvider).getArticles();
      return result.fold((error) => throw error, (articles) => articles);
    });
    state = articles;
    return articles.value!;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();

    try {
      final result = await ref.read(articleServiceProvider).getArticles();
      state = result.fold(
        (error) => AsyncError(error, StackTrace.current),
        (articles) => AsyncData(articles),
      );
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
    }
  }
}
