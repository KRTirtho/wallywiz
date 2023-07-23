import 'dart:io';

import 'package:collection/collection.dart';
import 'package:desktop_wallpaper/desktop_wallpaper.dart' as desktop_wallpaper;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallywiz/models/wallpaper.dart';
import 'package:wallywiz/services/api_client.dart';
import 'package:wallywiz/utils/platform.dart';

class PeriodicTaskService {
  static final dio = Dio();
  static Future<void> setWallpaper(String wallpaperId, String url) async {
    final Wallpaper? wallpaper =
        await apiClient.getWallpaper(wallpaperId).catchError((e) => null);

    final downloadUrl = wallpaper?.url ?? url;

    final appDir = await getApplicationSupportDirectory();

    File? outputFile;
    if (appDir.listSync().none((file) => file.path.contains(wallpaperId))) {
      final downloadFile = await dio.get<List<int>>(
        downloadUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      if (downloadFile.data == null) return;

      final extension = downloadFile.headers.map["content-type"]?.first
              .split("/")
              .lastOrNull ??
          "png";
      outputFile = File("${appDir.path}/$wallpaperId.$extension");
      await outputFile.writeAsBytes(downloadFile.data!);
    } else {
      outputFile = File(
        appDir
            .listSync()
            .firstWhere(
              (file) => file.path.contains(wallpaperId),
            )
            .path,
      );
    }
    if (kIsMobile) {
      await WallpaperManager.setWallpaperFromFile(
        outputFile.path,
        WallpaperManager.BOTH_SCREEN,
      );
    } else {
      await desktop_wallpaper.Wallpaper.set(outputFile.path);
    }
  }

  static Future<void> periodicTaskJob(List<Wallpaper> wallpapers) async {
    try {
      final sharedPreferences = await SharedPreferences.getInstance();

      String? activeWallpaperRemoteId =
          sharedPreferences.getString("wallpaperRemoteId");
      Wallpaper? newWallpaper;

      if (activeWallpaperRemoteId == null ||
          !wallpapers.any(((w) => w.remoteId == w.remoteId)) ||
          activeWallpaperRemoteId == wallpapers.last.remoteId) {
        newWallpaper = wallpapers.first;
      } else {
        newWallpaper = wallpapers.elementAt(
          wallpapers.indexWhere((w) => w.remoteId == activeWallpaperRemoteId) +
              1,
        );
      }

      await setWallpaper(newWallpaper.id, newWallpaper.url);
    } catch (e) {
      debugPrint("[PeriodicTaskService] Error while setting wallpaper:\n$e");
    }
  }
}
