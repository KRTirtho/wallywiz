import 'package:flutter/material.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wallywiz/helpers/PersistedChangeNotifier.dart';

class UserPreferences extends PersistedChangeNotifier {
  int wallpaperLocation;
  ThemeMode themeMode;
  UserPreferences(
      {required this.wallpaperLocation, this.themeMode = ThemeMode.system})
      : super();

  @override
  void loadFromLocal(Map<String, dynamic> map) {
    wallpaperLocation = map["wallpaperLocation"] ?? wallpaperLocation;
    themeMode = ThemeMode.values[map["themeMode"] ?? themeMode.index];
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      "wallpaperLocation": wallpaperLocation,
      "themeMode": themeMode.index,
    };
  }

  void setWallpaperLocation(int newLocation) {
    wallpaperLocation = newLocation;
    updatePersistence();
    notifyListeners();
  }

  void setThemeMode(ThemeMode newThemeMode) {
    themeMode = newThemeMode;
    updatePersistence();
    notifyListeners();
  }
}

final userPreferencesProvider = ChangeNotifierProvider(
  (ref) {
    return UserPreferences(
      wallpaperLocation: WallpaperManager.BOTH_SCREEN,
    );
  },
);
