import 'dart:async';
import 'dart:convert';

import 'package:duration/duration.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wallywiz/components/CreateWallpaperProvider/CreateWallpaperProviderView.dart';
import 'package:wallywiz/extensions/duration.dart';
import 'package:wallywiz/helpers/PersistedChangeNotifier.dart';
import 'package:wallywiz/models/WallpaperSource.dart';
import 'package:wallywiz/providers/preferences.dart';
import 'package:wallywiz/secrets.dart';

enum RandomWallpaperAPI {
  reddit,
  unsplash,
  nasa,
  bing,
  pexels,
  pixabay,
}

class _WallpaperProvider extends PersistedChangeNotifier {
  RandomWallpaperAPI currentAPI;

  Duration schedule;

  ChangeNotifierProviderRef<_WallpaperProvider> ref;

  List<WallpaperSource> wallpaperSources;

  WallpaperSource? currentWallpaperSource;

  _WallpaperProvider({
    required this.currentAPI,
    required this.schedule,
    required this.ref,
    this.wallpaperSources = const [],
  }) : super();

  void addWallpaperSource(WallpaperSource source) {
    if (wallpaperSources.any((element) => element.id == source.id)) return;
    wallpaperSources = [...wallpaperSources, source];
    notifyListeners();
    updatePersistence();
  }

  void removeWallpaperSource(String srcId) {
    wallpaperSources =
        wallpaperSources.where((element) => element.id != srcId).toList();
    notifyListeners();
    updatePersistence();
  }

  void scheduleWallpaper2({
    required String tempDir,
    required WallpaperSource source,
    Duration? period,
  }) {
    if (period != null) schedule = period;
    currentWallpaperSource = source;
    FlutterBackgroundService().invoke("schedule", {
      "schedule": schedule.toString(),
      "location": ref.read(userPreferencesProvider).wallpaperLocation,
      "source": source.toJson(),
      "tempDir": tempDir,
    });
    updatePersistence();
    notifyListeners();
  }

  void setCurrentWallpaperSource(WallpaperSource source) {
    currentWallpaperSource = source;
    notifyListeners();
    updatePersistence();
  }

  void setCurrentProvider(RandomWallpaperAPI api) {
    currentAPI = api;
    notifyListeners();
  }

  void setSchedule(Duration newSchedule) {
    schedule = newSchedule;
    notifyListeners();
  }

  get cronExpression => "${schedule.minute} */${schedule.hour} * * *";

  void scheduleWallpaper({
    required String tempDir,
    required RandomWallpaperAPI provider,
    Duration? period,
    String? subreddit,
  }) {
    if (period != null) schedule = period;
    currentAPI = provider;
    FlutterBackgroundService().invoke("schedule", {
      "schedule": schedule.toString(),
      "location": ref.read(userPreferencesProvider).wallpaperLocation,
      "provider": provider.name,
      "tempDir": tempDir,
      "subreddit": subreddit,
    });
    notifyListeners();
  }

  @override
  FutureOr<void> loadFromLocal(Map<String, dynamic> map) {
    wallpaperSources = map["wallpaperSources"] != null
        ? (jsonDecode(map["wallpaperSources"]) as List)
            .map((e) => WallpaperSource.fromJson(e))
            .toList()
        : wallpaperSources;
    currentWallpaperSource = map["currentWallpaperSource"] != null
        ? WallpaperSource.fromJson(jsonDecode(map["currentWallpaperSource"]))
        : currentWallpaperSource;
    schedule = map["schedule"] != null ? parseTime(map["schedule"]) : schedule;
  }

  @override
  FutureOr<Map<String, dynamic>> toMap() {
    return {
      "wallpaperSources": jsonEncode(
        wallpaperSources.map((e) => e.toJson()).toList(),
      ),
      "currentWallpaperSource": currentWallpaperSource != null
          ? jsonEncode(currentWallpaperSource?.toJson())
          : null,
      "schedule": schedule.toString(),
    };
  }
}

final wallpaperProvider = ChangeNotifierProvider(
  (ref) {
    return _WallpaperProvider(
        ref: ref,
        currentAPI: RandomWallpaperAPI.unsplash,
        // At 0 minutes past the hour, every 24 hours
        schedule: const Duration(hours: 2),
        wallpaperSources: [
          WallpaperSource(
            id: uuid.v4(),
            jsonAccessor: "hdurl",
            name: "Nasa",
            url: "https://api.nasa.gov/planetary/apod?api_key=$nasaKey",
          ),
          WallpaperSource(
            id: uuid.v4(),
            jsonAccessor: "url",
            name: "Bing",
            url: "https://bing.biturl.top",
          ),
          WallpaperSource(
              id: uuid.v4(),
              name: "Unsplash",
              url:
                  "https://api.unsplash.com/photos/random?orientation=portrait",
              jsonAccessor: "urls.full",
              headers: {"Authorization": "Client-ID $unsplashKey"}),
          WallpaperSource(
            id: uuid.v4(),
            name: "Pexels",
            url: "https://api.pexels.com/v1/curated",
            headers: {"Authorization": pexelKey},
            jsonAccessor: "photos.\$.src.portrait",
          ),
          WallpaperSource(
            id: uuid.v4(),
            name: "Pixabay",
            url:
                "https://pixabay.com/api?key=$pixabayKey&image_type=photo&orientation=vertical&safesearch=true&order=popular",
            jsonAccessor: "hits.\$.largeImageURL",
          ),
        ]);
  },
);
