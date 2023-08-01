import 'package:supabase/supabase.dart';
import 'package:wallywiz/collections/env.dart';
import 'package:wallywiz/models/category.dart';
import 'package:wallywiz/models/wallpaper.dart';

typedef PagedData<T> = ({List<T> data, int? next});

class ApiClient {
  SupabaseClient supabase;

  ApiClient() : supabase = SupabaseClient(Env.apiUrl, Env.apiKey);

  Future<PagedData<Category>> listCategoriesPaginated({
    int page = 1,
  }) async {
    final data = await supabase
        .from("Categories")
        .select<PostgrestList>("*,Wallpapers(thumbnail)")
        .range(
          page == 0 ? 0 : ((page - 1) * 10) + 1,
          page * 10,
        )
        .limit(1, foreignTable: 'Wallpapers');

    return (
      data: data
          .map((e) => Category.fromJson({
                ...e,
                "thumbnails": [e["Wallpapers"][0]["thumbnail"]]
              }))
          .toList(),
      next: data.length < 10 ? null : page + 1,
    );
  }

  Future<Category> getCategory(String id) async {
    final data = await supabase
        .from("Categories")
        .select<PostgrestMap>("*")
        .eq("id", id)
        .single();
    return Category.fromJson(data);
  }

  Future<Wallpaper> getWallpaper(String id) async {
    final response = await supabase
        .from("Wallpapers")
        .select<PostgrestMap>("*")
        .eq("id", id)
        .single();
    return Wallpaper.fromJson(response);
  }

  Future<List<Wallpaper>> listCategoryWallpapers(String id) async {
    final data = await supabase
        .from("Wallpapers")
        .select<PostgrestList>("*")
        .eq("category_id", id);

    return data.map((e) => Wallpaper.fromJson(e)).toList();
  }

  Future<List<Wallpaper>> trendingCategoryWallpapers([int page = 1]) async {
    final data = await supabase
        .from("Wallpapers")
        .select<PostgrestList>("*")
        .eq("Categories.remote_id", "trending")
        .range(
          page == 0 ? 0 : ((page - 1) * 10) + 1,
          page * 10,
        );

    return data.map((e) => Wallpaper.fromJson(e)).toList();
  }

  Future<List<Wallpaper>> latestCategoryWallpapers([int page = 1]) async {
    final data = await supabase
        .from("Wallpapers")
        .select<PostgrestList>("*")
        .eq("Categories.remote_id", "latest")
        .range(
          page == 0 ? 0 : ((page - 1) * 10) + 1,
          page * 10,
        );

    return data.map((e) => Wallpaper.fromJson(e)).toList();
  }
}

final apiClient = ApiClient();
