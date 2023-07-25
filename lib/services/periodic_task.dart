import 'dart:io';

import 'package:collection/collection.dart';
import 'package:desktop_wallpaper/desktop_wallpaper.dart' as desktop_wallpaper;
import 'package:dio/dio.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallywiz/models/wallpaper.dart';
import 'package:wallywiz/services/api_client.dart';
import 'package:wallywiz/services/logger.dart';
import 'package:wallywiz/utils/platform.dart';

typedef TaskWallpaper = ({String remoteId, String id, String url});

class PeriodicTaskService {
  final ApiClient apiClient;
  final WallyWizLogger logger;
  final Dio dio;

  PeriodicTaskService({required this.apiClient})
      : logger = WallyWizLogger("PeriodicTaskService"),
        dio = Dio();

  Future<void> setWallpaper(String wallpaperId, String url) async {
    logger.i("Fetching wallpaper");

    final Wallpaper? wallpaper = await apiClient
        .getWallpaper(wallpaperId)
        .then((value) => Future<Wallpaper?>.value(value))
        .catchError((e) {
      logger.i("Error while fetching wallpaper:\n$e");
      logger.i("Using default wallpaper");
      return null;
    });

    final downloadUrl = wallpaper?.url ?? url;

    final appDir = await getApplicationSupportDirectory();

    File? outputFile;
    if (appDir.listSync().none((file) => file.path.contains(wallpaperId))) {
      logger.i("Downloading wallpaper");

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
      logger.i("Wallpaper already downloaded");
      outputFile = File(
        appDir
            .listSync()
            .firstWhere(
              (file) => file.path.contains(wallpaperId),
            )
            .path,
      );
    }

    logger.i("Setting wallpaper for path: ${outputFile.path}");

    if (kIsMobile) {
      await WallpaperManager.setWallpaperFromFile(
        outputFile.path,
        WallpaperManager.BOTH_SCREEN,
      );
    } else {
      await desktop_wallpaper.Wallpaper.set(outputFile.path);
    }

    logger.i("Wallpaper set");
  }

  Future<void> periodicTaskJob(List<TaskWallpaper> wallpapers) async {
    try {
      final sharedPreferences = await SharedPreferences.getInstance();

      String? activeWallpaperRemoteId =
          sharedPreferences.getString("wallpaperRemoteId");
      TaskWallpaper? newWallpaper;

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

      sharedPreferences.setString("wallpaperRemoteId", newWallpaper.remoteId);

      logger.i(
        "Setting wallpaper: ${newWallpaper.id} ${newWallpaper.url}",
      );

      await setWallpaper(newWallpaper.id, newWallpaper.url);
    } catch (e) {
      logger.i("Error while setting wallpaper:\n$e");
    }
  }
}

final periodicTasksService = PeriodicTaskService(apiClient: apiClient);
