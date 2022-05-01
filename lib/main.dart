import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:uuid/uuid.dart';
import 'package:wallywiz/components/Home/Home.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:wallywiz/providers/wallpaper-provider.dart';
import 'package:wallywiz/services/logger.dart';
import 'package:wallywiz/services/wallpaper.dart';
import 'package:duration/duration.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid || Platform.isIOS) await initializeService();
  runApp(const MyApp());
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will executed when app is in foreground or background in separated isolate
      onStart: onStart,

      // auto start service
      autoStart: true,
      isForegroundMode: true,
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
  service.startService();
}

// to ensure this executed
// run app from xcode, then from xcode menu, select Simulate Background Fetch
bool onIosBackground(ServiceInstance service) {
  WidgetsFlutterBinding.ensureInitialized();
  return true;
}

void onStart(ServiceInstance service) {
  Timer? timer;
  WallpaperService wallpaperService = WallpaperService.getInstance();
  const uuid = Uuid();
  final dio = Dio(BaseOptions(responseType: ResponseType.bytes));
  service.on("schedule").listen((event) {
    final logger = getLogger("BackgroundService -> schedule");
    if (event == null) return;
    if (timer?.isActive == true) timer?.cancel();
    final provider = RandomWallpaperAPI.values.byName(event["provider"]);
    logger.v("[selected provider] $provider");
    job([stamp]) async {
      logger.v("[Running Scheduled job] at ${DateTime.now()}");
      final String url = await wallpaperService.getWallpaperByProvider(
        provider,
        event["subreddit"],
      );

      logger.v("[Next Wallpaper] $url");

      final res = await dio.get<List<int>>(url);

      if (res.data == null) return;
      // unsplash uses hotlink so there's no requirement of file
      // extension thus its provided through queryParameters
      final extension = provider == RandomWallpaperAPI.unsplash
          ? Uri.parse(url).queryParameters["fm"] ?? "jpg"
          : path.extension(Uri.parse(url).path);
      final outputFile = File(path.join(
        event["tempDir"],
        "${uuid.v4()}.$extension",
      ));

      logger.v("[Wallpaper path] ${outputFile.path}");

      outputFile.createSync(recursive: true);

      outputFile.writeAsBytesSync(res.data!);

      final success = await WallpaperManager.setWallpaperFromFile(
        outputFile.path,
        event["location"],
      );

      logger.v("[Set Wallpaper Status] Success -> $success");
    }

    timer = Timer.periodic(parseTime(event["schedule"]), job);

    // run the job first time
    logger.v("[Initial First Run]");
    job();
  });
}

// list of wallpaper sources
// - unsplash
// - pexels
// - dicebear
// - pixabay
// - flickr
// - NASA picture of the day
// - Bing picture of the day (https://bing.biturl.top)
// - Anime wallpaper grabber

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const Home(),
      ),
    );
  }
}
