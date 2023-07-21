import 'package:fl_query/fl_query.dart';
import 'package:fl_query_hooks/fl_query_hooks.dart';
import 'package:wallywiz/models/category.dart';
import 'package:wallywiz/models/wallpaper.dart';
import 'package:wallywiz/services/api_client.dart';

class _UseQueries {
  InfiniteQuery<PagedData<Category>, dynamic, int> listInfiniteCategories() {
    final query = useInfiniteQuery<PagedData<Category>, dynamic, int>(
      'categories',
      (page) => apiClient.listCategoriesPaginated(page: page),
      initialPage: 1,
      nextPage: (lastPage, lastPageData) => lastPageData.next,
      retryConfig: DefaultConstants.retryConfig.copyWith(
        maxRetries: 2,
        retryDelay: const Duration(seconds: 5),
      ),
    );

    return query;
  }

  Query<Category, dynamic> getCategory(String id) {
    final query = useQuery<Category, dynamic>(
      'category/$id',
      () => apiClient.getCategory(id),
    );

    return query;
  }

  Query<List<Wallpaper>, dynamic> listCategoryWallpapers(String id) {
    final query = useQuery<List<Wallpaper>, dynamic>(
      'category/$id/wallpapers',
      () => apiClient.listCategoryWallpapers(id),
    );

    return query;
  }
}

final useApi = _UseQueries();
