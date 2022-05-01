import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wallywiz/extensions/duration.dart';

enum RandomWallpaperAPI {
  reddit,
  unsplash,
  nasa,
  bing,
  pexels,
  pixabay,
}

class _WallpaperProvider extends ChangeNotifier {
  RandomWallpaperAPI currentAPI;

  Duration schedule;

  int location;

  _WallpaperProvider({
    required this.currentAPI,
    required this.schedule,
    required this.location,
  });

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
    int? location,
    String? subreddit,
  }) {
    if (period != null) schedule = period;
    if (location != null) this.location = location;
    currentAPI = provider;
    FlutterBackgroundService().invoke("schedule", {
      "schedule": schedule.toString(),
      "location": this.location,
      "provider": provider.name,
      "tempDir": tempDir,
      "subreddit": subreddit,
    });
    notifyListeners();
  }
}

final wallpaperProvider = ChangeNotifierProvider(
  (ref) {
    return _WallpaperProvider(
      location: WallpaperManager.BOTH_SCREEN,
      currentAPI: RandomWallpaperAPI.unsplash,
      // At 0 minutes past the hour, every 24 hours
      schedule: const Duration(hours: 2),
    );
  },
);
