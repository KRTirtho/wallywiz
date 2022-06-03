import 'dart:async';
import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:uuid/uuid.dart';
import 'package:wallywiz/components/Home/Home.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:wallywiz/providers/preferences-provider.dart';
import 'package:wallywiz/providers/wallpaper-provider.dart';
import 'package:wallywiz/services/logger.dart';
import 'package:wallywiz/services/wallpaper.dart';
import 'package:duration/duration.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid || Platform.isIOS) await initializeService();
  AwesomeNotifications().initialize(
    // set the icon to null if you want to use the default app icon
    null,
    [
      NotificationChannel(
        channelGroupKey: 'wallywiz_channel_group',
        channelKey: 'wallywiz_channel',
        channelName: 'Wallywiz notifications',
        channelDescription:
            'Notification channel for Wallywiz wallpaper change notification',
        playSound: true,
      )
    ],
    // Channel groups are only visual and are not required
    channelGroups: [
      NotificationChannelGroup(
        channelGroupkey: 'wallywiz_channel_group',
        channelGroupName: 'Wallywiz Group',
      )
    ],
    debug: kDebugMode,
  );
  runApp(const ProviderScope(child: MyApp()));
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
      print("[Running Scheduled job] at ${DateTime.now()}");
      final String url = await wallpaperService.getWallpaperByProvider(
        provider,
        event["subreddit"],
      );

      logger.v("[Next Wallpaper] $url");
      print("[Next Wallpaper] $url");

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
      print("[Wallpaper path] ${outputFile.path}");

      outputFile.createSync(recursive: true);

      outputFile.writeAsBytesSync(res.data!);

      final success = await WallpaperManager.setWallpaperFromFile(
        outputFile.path,
        event["location"],
      );

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 10,
          channelKey: 'wallywiz_channel',
          title: 'New Wallpaper',
          body: 'Wallpaper Changed to $url',
          category: NotificationCategory.Social,
          autoDismissible: true,
          bigPicture: url,
        ),
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

// list of wallpaper sources
// - unsplash
// - pexels
// - dicebear
// - pixabay
// - flickr
// - NASA picture of the day
// - Bing picture of the day (https://bing.biturl.top)
// - Anime wallpaper grabber

class MyApp extends HookConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    useEffect(() {
      AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
        if (!isAllowed) {
          // This is just a basic example. For real apps, you must show some
          // friendly dialog box before call the request method.
          // This is very important to not harm the user experience
          AwesomeNotifications().requestPermissionToSendNotifications();
        }
      });

      return null;
    }, []);

    final preferences = ref.watch(userPreferencesProvider);
    return MaterialApp(
      title: 'Flutter Demo',
      themeMode: preferences.themeMode,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        inputDecorationTheme: const InputDecorationTheme(
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: .5),
            ),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue, width: 2)),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red, width: 2),
            )),
      ),
      darkTheme: ThemeData.dark().copyWith(
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[900],
        ),
        scaffoldBackgroundColor: Colors.grey[900],
        inputDecorationTheme: const InputDecorationTheme(
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white, width: .5),
          ),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue, width: 2)),
          errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red, width: 2)),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 2),
          ),
        ),
      ),
      home: const Home(),
    );
  }
}
