import 'dart:async';
import 'dart:convert';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wallywiz/extensions/duration.dart';
import 'package:wallywiz/helpers/PersistedChangeNotifier.dart';
import 'package:wallywiz/models/WallpaperSource.dart';
import 'package:wallywiz/providers/preferences-provider.dart';

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

  _WallpaperProvider({
    required this.currentAPI,
    required this.schedule,
    required this.ref,
  })  : wallpaperSources = [],
        super();

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
    wallpaperSources = (jsonDecode(map["wallpaperSources"] ?? "[]") as List)
        .map((e) => WallpaperSource.fromJson(e))
        .toList();
  }

  @override
  FutureOr<Map<String, dynamic>> toMap() {
    return {
      "wallpaperSources": jsonEncode(
        wallpaperSources.map((e) => e.toJson()).toList(),
      )
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
    );
  },
);
