import 'dart:convert';
import 'dart:io';

import 'package:desktop_wallpaper/desktop_wallpaper.dart';
import 'package:fl_query/fl_query.dart';
import 'package:fl_query_connectivity_plus_adapter/fl_query_connectivity_plus_adapter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wallywiz/collections/routes.dart';
import 'package:wallywiz/providers/preferences.dart';
import 'package:wallywiz/services/api_client.dart';
import 'package:wallywiz/services/periodic_task.dart';
import 'package:wallywiz/utils/logger.dart';
import 'package:wallywiz/utils/persisted_state_notifier.dart';
import 'package:wallywiz/utils/platform.dart';
import 'package:workmanager/workmanager.dart';
import 'package:window_manager/window_manager.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:package_info_plus/package_info_plus.dart';

@pragma("vm:entry-point")
void callbackDispatcher() {
  initLogger();
  Workmanager().executeTask(
    (taskName, inputData) async {
      if (inputData == null) return false;
      Logger.root.info("Native called background task: $taskName");
      final taskService = PeriodicTaskService(apiClient: ApiClient());
      await taskService.periodicTaskJob(
        Duration(seconds: inputData["interval"]),
        (jsonDecode(inputData["data"]) as List)
            .map(
              (source) => (
                remoteId: source["remoteId"] as String,
                id: source["id"] as String,
                url: source["url"] as String,
              ),
            )
            .toList(),
      );
      return true;
    },
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final packageInfo = await PackageInfo.fromPlatform();

  initLogger();

  await QueryClient.initialize(
    cachePrefix: 'dev.krtirtho.wallywiz',
    connectivity: FlQueryConnectivityPlusAdapter(),
    cacheDir: (await getApplicationSupportDirectory()).path,
  );
  await PersistedStateNotifier.initializeBoxes(
    path: (await getApplicationSupportDirectory()).path,
  );

  if (kAdPlatform) {
    await MobileAds.instance.initialize();
  }

  if (kIsAndroid) {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true,
    );
  }
  if (kIsDesktop) {
    if (kReleaseMode) {
      launchAtStartup.setup(
        appName: packageInfo.appName,
        appPath: Platform.resolvedExecutable,
      );
      if (!await launchAtStartup.isEnabled()) {
        await launchAtStartup.enable();
      }
    }
    Wallpaper.initialize();
    await windowManager.ensureInitialized();
    const windowOptions = WindowOptions(
      size: Size(800, 600),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
      title: "WallyWiz",
      minimumSize: Size(400, 300),
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(
    ProviderScope(
      child: QueryClientProvider(
        retryDelay: const Duration(seconds: 20),
        maxRetries: 2,
        child: const MyApp(),
      ),
    ),
  );
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
    return MaterialApp.router(
      title: 'WallyWiz',
      themeMode: preferences.themeMode,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
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
        listTileTheme: const ListTileThemeData(horizontalTitleGap: 10),
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
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        navigationBarTheme: const NavigationBarThemeData(
          height: 60,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }
}
