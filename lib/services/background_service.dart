import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:duration/duration.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:uuid/uuid.dart';
import 'package:wallywiz/models/WallpaperSource.dart';
import 'package:wallywiz/services/logger.dart';
import 'package:path/path.dart' as path;
import 'package:wallywiz/extensions/map.dart';

Future<void> initBackgroundService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will executed when app is in foreground or background in separated isolate
      onStart: onStart,

      // auto start service
      autoStart: true,
      isForegroundMode: true,
      foregroundServiceNotificationTitle: "WallyWiz",
      foregroundServiceNotificationContent:
          "Wallpaper schedular running (RAM 2MB, CPU% 0.01%)",
    ),
    iosConfiguration: IosConfiguration(
      // auto start service
      autoStart: true,

      // this will executed when app is in foreground in separated isolate
      onForeground: onStart,

      // you have to enable background fetch capability on xcode project
      onBackground: onIosBackground,
    ),
  );
  await service.startService();
}

// to ensure this executed
// run app from xcode, then from xcode menu, select Simulate Background Fetch
bool onIosBackground(ServiceInstance service) {
  WidgetsFlutterBinding.ensureInitialized();
  return true;
}

void onStart(ServiceInstance service) async {
  Timer? timer;
  const uuid = Uuid();
  final dio = Dio(BaseOptions(responseType: ResponseType.bytes));
  final logInstance = WallyWizLogger();

  service.on("schedule").listen((event) {
    if (event == null) return;
    if (timer?.isActive == true) timer?.cancel();
    final logger = logInstance..owner = "BackgroundService -> schedule";
    final source = WallpaperSource.fromJson(event["source"]);
    logger.v("[selected source] $source");
    job([stamp]) async {
      logger.v("[Running Scheduled job] at ${DateTime.now()}");
      print("[Running Scheduled job] at ${DateTime.now()}");
      final res = (await dio.get(
        source.url,
        options: Options(
          headers: source.headers,
          responseType: ResponseType.json,
        ),
      ))
          .data as Map?;
      if (res == null) return;
      final String url = res.getNestedProperty(source.jsonAccessor);
      logger.v("[Next Wallpaper] $url");
      print("[Next Wallpaper] $url");

      final imageBytes = await dio.get<List<int>>(url);

      if (imageBytes.data == null) return;

      final outputFile = File(path.join(
        event["tempDir"],
        "${uuid.v4()}.${source.imageType.name}",
      ));

      logger.v("[Wallpaper path] ${outputFile.path}");
      print("[Wallpaper path] ${outputFile.path}");

      outputFile.createSync(recursive: true);

      outputFile.writeAsBytesSync(imageBytes.data!);

      final success = await WallpaperManager.setWallpaperFromFile(
        outputFile.path,
        event["location"],
      );

      logger.v("[Set Wallpaper Status] Success -> $success");
      print("[Set Wallpaper Status] Success -> $success");
    }

    timer = Timer.periodic(parseTime(event["schedule"]), job);

    // run the job first time
    logger.v("[Initial First Run]");
    job();
  });
}
