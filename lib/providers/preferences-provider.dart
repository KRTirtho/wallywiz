import 'package:flutter/material.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences extends ChangeNotifier {
  int wallpaperLocation;
  ThemeMode themeMode;
  late SharedPreferences _localStorage;
  UserPreferences(
      {required this.wallpaperLocation, this.themeMode = ThemeMode.system}) {
    SharedPreferences.getInstance().then((value) {
      _localStorage = value;
      initLocalState();
    });
  }

  void initLocalState() {
    final map = toMap().keys.fold<Map<String, dynamic>>(
      {},
      (acc, key) {
        acc[key] = _localStorage.get(key);
        return acc;
      },
    );
    wallpaperLocation = map["wallpaperLocation"];
    themeMode = map["themeMode"];
  }

  Map<String, dynamic> toMap() {
    return {
      "wallpaperLocation": wallpaperLocation,
      "themeMode": themeMode,
    };
  }

  Future<void> updatePersistence() async {
    for (final entry in toMap().entries) {
      if (entry.value is bool) {
        await _localStorage.setBool(entry.key, entry.value);
      } else if (entry.value is int) {
        await _localStorage.setInt(entry.key, entry.value);
      } else if (entry.value is double) {
        await _localStorage.setDouble(entry.key, entry.value);
      } else if (entry.value is String) {
        await _localStorage.setString(entry.key, entry.value);
      }
    }
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
