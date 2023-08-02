import 'dart:io';

import 'package:collection/collection.dart';
import 'package:desktop_wallpaper/desktop_wallpaper.dart' as desktop_wallpaper;
import 'package:dio/dio.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallywiz/models/wallpaper.dart';
import 'package:wallywiz/services/api_client.dart';
import 'package:wallywiz/utils/platform.dart';

typedef TaskWallpaper = ({String remoteId, String id, String url});

const kLastChanged = "lastChanged";
const kWallpaperRemoteId = "wallpaperRemoteId";

class PeriodicTaskService {
  final ApiClient apiClient;
  final Logger logger;
  final Dio dio;

  PeriodicTaskService({required this.apiClient})
      : logger = Logger("PeriodicTaskService"),
        dio = Dio();

  Future<void> setWallpaper(String wallpaperId, String url) async {
    logger.info("Fetching wallpaper");

    final Wallpaper? wallpaper = await apiClient
        .getWallpaper(wallpaperId)
        .then((value) => Future<Wallpaper?>.value(value))
        .catchError((e) {
      logger.info("Error while fetching wallpaper:\n$e");
      logger.info("Using default wallpaper");
      return null;
    });

    final downloadUrl = wallpaper?.url ?? url;

    final appDir = await getApplicationSupportDirectory();

    File? outputFile;
    if (appDir.listSync().none((file) => file.path.contains(wallpaperId))) {
      logger.info("Downloading wallpaper");

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
      logger.info("Wallpaper already downloaded");
      outputFile = File(
        appDir
            .listSync()
            .firstWhere(
              (file) => file.path.contains(wallpaperId),
            )
            .path,
      );
    }

    logger.info("Setting wallpaper for path: ${outputFile.path}");

    if (kIsMobile) {
      await WallpaperManager.setWallpaperFromFile(
        outputFile.path,
        WallpaperManager.BOTH_SCREEN,
      );
    } else {
      await desktop_wallpaper.Wallpaper.set(outputFile.path);
    }

    logger.info("Wallpaper set");
  }

  Future<void> resetCache() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.remove(kLastChanged);
    sharedPreferences.remove(kWallpaperRemoteId);
  }

  Future<void> periodicTaskJob(
    Duration interval,
    List<TaskWallpaper> wallpapers,
  ) async {
    try {
      final sharedPreferences = await SharedPreferences.getInstance();
      final lastChanged =
          DateTime.tryParse(sharedPreferences.getString(kLastChanged) ?? "");

      final currentTime = DateTime.now();

      if (lastChanged != null &&
          currentTime.difference(lastChanged) < interval) {
        logger.info("Not changing wallpaper");
        logger.info("Last changed: ${lastChanged.toIso8601String()}");
        return;
      }

      String? activeWallpaperRemoteId =
          sharedPreferences.getString(kWallpaperRemoteId);
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

      sharedPreferences.setString(kWallpaperRemoteId, newWallpaper.remoteId);
      sharedPreferences.setString(kLastChanged, currentTime.toIso8601String());

      logger.info(
        "Setting wallpaper: ${newWallpaper.id} ${newWallpaper.url}",
      );

      await setWallpaper(newWallpaper.id, newWallpaper.url);
    } catch (e) {
      logger.severe("Error while setting wallpaper:\n$e");
    }
  }
}

final periodicTasksService = PeriodicTaskService(apiClient: apiClient);
