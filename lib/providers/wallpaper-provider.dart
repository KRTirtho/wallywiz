import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wallywiz/extensions/duration.dart';
import 'package:wallywiz/providers/preferences-provider.dart';

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

  ChangeNotifierProviderRef<_WallpaperProvider> ref;

  _WallpaperProvider({
    required this.currentAPI,
    required this.schedule,
    required this.ref,
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
