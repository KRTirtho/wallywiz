import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:wallywiz/models/BingPOD.dart';
import 'package:wallywiz/models/NasaPOD.dart';
import 'package:wallywiz/providers/wallpaper-provider.dart';
import 'package:wallywiz/secrets.dart';

WallpaperService _wallpaperService = WallpaperService();

class WallpaperService {
  late Dio _dio;

  WallpaperService() {
    _dio = Dio(BaseOptions(responseType: ResponseType.json));
    _dio.interceptors.add(DioCacheManager(CacheConfig()).interceptor);
  }

  factory WallpaperService.getInstance() => _wallpaperService;

  Future<String> getWallpaperByProvider(RandomWallpaperAPI provider,
      [String? subreddit]) {
    switch (provider) {
      case RandomWallpaperAPI.bing:
        return getBingPOD();
      case RandomWallpaperAPI.nasa:
        return getNasaPOD();
      case RandomWallpaperAPI.pexels:
        return getPexelsRandom();
      case RandomWallpaperAPI.pixabay:
        return getPixabayRandom();
      case RandomWallpaperAPI.reddit:
        return getSubReddit(subreddit);
      case RandomWallpaperAPI.unsplash:
        return getUnsplashRandom();
    }
  }

  Future<String> getBingPOD() async {
    final res = await _dio.get<Map<String, dynamic>>("https://bing.biturl.top");
    final bingPod = BingPOD.fromJson(res.data!);
    return bingPod.url;
  }

  Future<String> getNasaPOD() async {
    final res = await _dio.get("https://api.nasa.gov/planetary/apod",
        queryParameters: {"api_key": nasaKey});

    return NasaPod.fromJson(res.data).hdurl;
  }

  Future<String> getUnsplashRandom() async {
    final res = await _dio.get<Map<String, dynamic>>(
      "https://api.unsplash.com/photos/random",
      queryParameters: {"orientation": "portrait"},
      options: Options(headers: {"Authorization": "Client-ID $unsplashKey"}),
    );

    return res.data!["urls"]["full"] as String;
  }

  Future<String> getPexelsRandom() async {
    final res = await _dio.get<Map<String, dynamic>>(
      "https://api.pexels.com/v1/curated",
      queryParameters: {"per_page": 1},
      options: Options(
        headers: {"Authorization": pexelKey},
      ),
    );
    return res.data!["photos"].first["src"]["portrait"] as String;
  }

  Future<String> getPixabayRandom() async {
    final categories = [
      "backgrounds",
      "fashion",
      "nature",
      "science",
      "education",
      "feelings",
      "health",
      "people",
      "religion",
      "places",
      "animals",
      "industry",
      "computer",
      "food",
      "sports",
      "transportation",
      "travel",
      "buildings",
      "business",
      "music"
    ]..shuffle();

    final imageTypes = ["photo", "illustration", "vector"]..shuffle();

    final res = await _dio.get("https://pixabay.com/api/", queryParameters: {
      "key": pixabayKey,
      "image_type": imageTypes.first,
      "orientation": "vertical",
      "safesearch": true,
      "category": categories.first,
      "order": "popular"
    });
    final List hits = res.data!["hits"];
    hits.shuffle();

    return hits.first["largeImageURL"];
  }

  Future<String> getSubReddit([String? subreddit]) async {
    subreddit ??= "Animewallpaper";
    final res = await _dio.get<Map<String, dynamic>>(
      "https://www.reddit.com/r/$subreddit/.json",
      queryParameters: {
        "q": "flair_name:\"Mobile\"",
        "restrict_sr": 1,
      },
    );
    final List onlyWallpaperThreads = (res.data!["data"] as List)
        .where((thread) =>
            (thread["data"]["url"] as String).startsWith("https://i.redd.it/"))
        .toList();

    onlyWallpaperThreads.shuffle();

    return onlyWallpaperThreads.first["data"]["url"];
  }
}
