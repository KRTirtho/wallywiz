import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cron/cron.dart';

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

  Schedule schedule;

  _WallpaperProvider({
    required this.currentAPI,
    required this.schedule,
  });

  setCurrentProvider(RandomWallpaperAPI api) {
    currentAPI = api;
    notifyListeners();
  }

  setSchedule(Schedule newSchedule) {
    schedule = newSchedule;
    notifyListeners();
  }
}

final wallpaperProvider = ChangeNotifierProvider(
  (ref) {
    return _WallpaperProvider(
      currentAPI: RandomWallpaperAPI.bing,
      // At 0 minutes past the hour, every 24 hours
      schedule: Schedule.parse("0 0 */23 * * *"),
    );
  },
);
