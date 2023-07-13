import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wallywiz/components/Home/Home.dart';
import 'package:wallywiz/providers/preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:dio/dio.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:uuid/uuid.dart';
import 'package:wallywiz/models/WallpaperSource.dart';
import 'package:wallywiz/services/logger.dart';
import 'package:path/path.dart' as path;
import 'package:wallywiz/extensions/map.dart';
import 'package:wallywiz/extensions/list.dart';

@pragma("vm:entry-point")
void callbackDispatcher() {
  Workmanager().executeTask(
    (taskName, inputData) async {
      final logInstance = WallyWizLogger();
      final dio = Dio(BaseOptions(
        responseType: ResponseType.bytes,
        sendTimeout: const Duration(minutes: 1),
        receiveTimeout: const Duration(minutes: 3), // 3 minutes
      ));
      const uuid = Uuid();
      final logger = logInstance..owner = "BackgroundService -> schedule";
      try {
        if (taskName == WALLPAPER_TASK_NAME) {
          if (inputData == null) return false;
          final source =
              WallpaperSource.fromJson(jsonDecode(inputData["source"]));
          logger.v("[selected source] $source");
          logger.v("[Running Scheduled job] at ${DateTime.now()}");
          print("[Running Scheduled job] at ${DateTime.now()}");
          final res = (await dio.get(
            source.url,
            options: Options(
              headers: source.headers,
              responseType: ResponseType.json,
            ),
          ))
              .data;
          if (res == null) return false;
          final String url = res is Map
              ? Map.from(res).getNestedProperty(source.jsonAccessor)
              : List.from(res).getNestedProperty(source.jsonAccessor);
          logger.v("[Next Wallpaper] $url");
          print("[Next Wallpaper] $url");

          final imageBytes = await dio.get<List<int>>(url);

          if (imageBytes.data == null) return false;

          final outputFile = File(path.join(
            inputData["tempDir"],
            "${uuid.v4()}.${source.imageType.name}",
          ));

          logger.v("[Wallpaper path] ${outputFile.path}");
          print("[Wallpaper path] ${outputFile.path}");

          outputFile.createSync(recursive: true);

          outputFile.writeAsBytesSync(imageBytes.data!);

          final success = await WallpaperManager.setWallpaperFromFile(
            outputFile.path,
            inputData["location"],
          );

          logger.v("[Set Wallpaper Status] Success -> $success");
          print("[Set Wallpaper Status] Success -> $success");
          return true;
        }
        return false;
      } catch (e, stack) {
        logger.e("Failed to execute task", e, stack);
        rethrow;
      }
    },
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) {
    await Workmanager().initialize(callbackDispatcher);
  }
  runApp(const ProviderScope(child: MyApp()));
}

// ignore: constant_identifier_names
const WALLPAPER_TASK_NAME = "wallpaper-change-task";
// ignore: constant_identifier_names
const WALLPAPER_TASK_UNIQUE_NAME = "wallpaper-change-task";

class MyApp extends HookConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final preferences = ref.watch(userPreferencesProvider);
    return MaterialApp(
      title: 'WallyWiz',
      themeMode: preferences.themeMode,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primarySwatch: Colors.grey,
        scaffoldBackgroundColor: Colors.white,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.grey[700],
          ),
        ),
        listTileTheme: const ListTileThemeData(horizontalTitleGap: 0),
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
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          backgroundColor: Colors.grey[900],
          brightness: Brightness.dark,
          accentColor: Colors.grey,
          errorColor: Colors.red,
          primaryColorDark: Colors.grey,
          primarySwatch: Colors.grey,
          cardColor: Colors.grey[850],
        ),
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
