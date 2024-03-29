import 'dart:async';
import 'dart:convert';

import 'package:duration/duration.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wallywiz/collections/env.dart';
import 'package:wallywiz/components/CreateWallpaperProvider/CreateWallpaperProviderView.dart';
import 'package:wallywiz/helpers/PersistedChangeNotifier.dart';
import 'package:wallywiz/main.dart';
import 'package:wallywiz/models/WallpaperSource.dart';
import 'package:wallywiz/providers/preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:collection/collection.dart';

enum RandomWallpaperAPI {
  reddit,
  unsplash,
  nasa,
  bing,
  pexels,
  pixabay,
  wallhaven,
}

class _WallpaperProvider extends PersistedChangeNotifier {
  RandomWallpaperAPI currentAPI;

  Duration schedule;

  ChangeNotifierProviderRef<_WallpaperProvider> ref;

  List<WallpaperSource> wallpaperSources;

  WallpaperSource? currentWallpaperSource;

  _WallpaperProvider({
    required this.currentAPI,
    required this.schedule,
    required this.ref,
    this.wallpaperSources = const [],
  }) : super();

  void addWallpaperSource(WallpaperSource source) {
    if (wallpaperSources.any((element) => element.id == source.id)) return;
    wallpaperSources = [...wallpaperSources, source];
    notifyListeners();
    updatePersistence();
  }

  void addWallpaperSources(List<WallpaperSource> rawSources) {
    final sources = rawSources.where((source) {
      return wallpaperSources.none((s) => s.id == source.id);
    });
    wallpaperSources = [...wallpaperSources, ...sources];
    notifyListeners();
    updatePersistence();
  }

  void updateWallpaperSource(String id, WallpaperSource source) {
    if (wallpaperSources.none((element) => element.id == source.id)) return;

    wallpaperSources =
        wallpaperSources.where((element) => element.id != source.id).toList();
    wallpaperSources = [...wallpaperSources, source];
    notifyListeners();
    updatePersistence();
  }

  void removeWallpaperSource(String srcId) {
    wallpaperSources =
        wallpaperSources.where((element) => element.id != srcId).toList();
    notifyListeners();
    updatePersistence();
  }

  void scheduleWallpaperChanger({
    required String tempDir,
    required WallpaperSource source,
    Duration? period,
  }) async {
    if (period != null) schedule = period;
    currentWallpaperSource = source;

    Workmanager().registerPeriodicTask(
      WALLPAPER_TASK_UNIQUE_NAME,
      WALLPAPER_TASK_NAME,
      existingWorkPolicy: ExistingWorkPolicy.replace,
      inputData: {
        "location": ref.read(userPreferencesProvider).wallpaperLocation,
        "source": jsonEncode(source.toJson()),
        "tempDir": tempDir,
      },
      constraints: Constraints(networkType: NetworkType.connected),
      frequency: schedule,
    );
    updatePersistence();
    notifyListeners();
  }

  void refreshWallpaper() async {
    await Workmanager().cancelAll();
    scheduleWallpaperChanger(
      tempDir: (await getTemporaryDirectory()).path,
      source: currentWallpaperSource!,
      period: schedule,
    );
  }

  void setCurrentWallpaperSource(WallpaperSource source) {
    currentWallpaperSource = source;
    notifyListeners();
    updatePersistence();
  }

  void setCurrentProvider(RandomWallpaperAPI api) {
    currentAPI = api;
    notifyListeners();
  }

  void setSchedule(Duration newSchedule) {
    schedule = newSchedule;
    notifyListeners();
  }

  @override
  FutureOr<void> loadFromLocal(Map<String, dynamic> map) {
    wallpaperSources = map["wallpaperSources"] != null
        ? (jsonDecode(map["wallpaperSources"]) as List)
            .map((e) => WallpaperSource.fromJson(e))
            .toList()
        : wallpaperSources;
    currentWallpaperSource = map["currentWallpaperSource"] != null
        ? WallpaperSource.fromJson(jsonDecode(map["currentWallpaperSource"]))
        : currentWallpaperSource;
    schedule = map["schedule"] != null ? parseTime(map["schedule"]) : schedule;
  }

  @override
  FutureOr<Map<String, dynamic>> toMap() {
    return {
      "wallpaperSources": jsonEncode(
        wallpaperSources.map((e) => e.toJson()).toList(),
      ),
      "currentWallpaperSource": currentWallpaperSource != null
          ? jsonEncode(currentWallpaperSource?.toJson())
          : null,
      "schedule": schedule.toString(),
    };
  }
}

final wallpaperProvider = ChangeNotifierProvider<_WallpaperProvider>(
  (ref) {
    return _WallpaperProvider(
        ref: ref,
        currentAPI: RandomWallpaperAPI.unsplash,
        // At 0 minutes past the hour, every 24 hours
        schedule: const Duration(hours: 2),
        wallpaperSources: [
          WallpaperSource(
            id: uuid.v4(),
            jsonAccessor: "hdurl",
            name: "Nasa",
            url: "https://api.nasa.gov/planetary/apod?api_key=${Env.nasaKey}",
            isOfficial: true,
            logoSource:
                "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e5/NASA_logo.svg/2449px-NASA_logo.svg.png",
          ),
          WallpaperSource(
            id: uuid.v4(),
            jsonAccessor: "url",
            name: "Bing",
            url: "https://bing.biturl.top",
            logoSource:
                "https://cdn.vox-cdn.com/thumbor/wBRCdEaZtpAd2bJBlOhtRC6euVk=/1400x1050/filters:format(jpeg)/cdn.vox-cdn.com/uploads/chorus_asset/file/21937385/binglogo.jpg",
            isOfficial: true,
          ),
          WallpaperSource(
            isOfficial: true,
            id: uuid.v4(),
            name: "Unsplash",
            url: "https://api.unsplash.com/photos/random?orientation=portrait",
            jsonAccessor: "urls.full",
            headers: {"Authorization": "Client-ID ${Env.unsplashKey}"},
            logoSource:
                "https://www.insightplatforms.com/wp-content/uploads/2021/03/Unsplash-Logo-Square-Insight-Platforms.png",
          ),
          WallpaperSource(
            id: uuid.v4(),
            isOfficial: true,
            name: "Pexels",
            url: "https://api.pexels.com/v1/curated",
            headers: {"Authorization": Env.pexelKey},
            jsonAccessor: "photos.\$.src.portrait",
            logoSource:
                "https://i.pinimg.com/564x/4a/45/76/4a4576e56a3ebf1a512aa38ce211dc93.jpg",
          ),
          WallpaperSource(
            id: uuid.v4(),
            isOfficial: true,
            name: "Pixabay",
            url:
                "https://pixabay.com/api?key=${Env.pixabayKey}&image_type=photo&orientation=vertical&safesearch=true&order=popular",
            jsonAccessor: "hits.\$.largeImageURL",
            logoSource:
                "https://cdn.pixabay.com/photo/2020/05/01/09/00/pixabay-5115964_960_720.png",
          ),
          WallpaperSource(
            id: uuid.v4(),
            isOfficial: true,
            name: "Wallhaven",
            url:
                "https://wallhaven.cc/api/v1/search?apiKey=${Env.wallHavenKey}&categories=100&sorting=views",
            jsonAccessor: "data.\$.path",
            logoSource:
                "https://repository-images.githubusercontent.com/190798434/716a9200-89e0-11e9-9a91-8bda5b8845a0",
          ),
        ]);
  },
);
