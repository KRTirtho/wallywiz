import 'package:dio/dio.dart';
import 'package:wallywiz/collections/env.dart';
import 'package:wallywiz/models/category.dart';
import 'package:wallywiz/models/wallpaper.dart';

typedef PagedData<T> = ({List<T> data, int? next});

class _ApiClient {
  Dio client;

  _ApiClient()
      : client = Dio(
          BaseOptions(
            baseUrl: Env.apiUrl,
            responseType: ResponseType.json,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': Env.apiKey,
            },
          ),
        );

  Future<PagedData<Category>> listCategoriesPaginated({
    int page = 1,
  }) async {
    final response = await client.get('/categories', queryParameters: {
      'page': page,
    });
    final data = response.data as List<dynamic>;
    return (
      data: data.map((e) => Category.fromJson(e)).toList(),
      next: data.length < 10 ? null : page + 1,
    );
  }

  Future<Category> getCategory(String id) async {
    final response = await client.get('/categories/$id');
    return Category.fromJson(response.data);
  }

  Future<List<Wallpaper>> listCategoryWallpapers(String id) async {
    final response = await client.get('/categories/$id/wallpapers');
    final data = response.data as List<dynamic>;
    return data.map((e) => Wallpaper.fromJson(e)).toList();
  }
}

final apiClient = _ApiClient();
