import 'package:desktop_wallpaper/desktop_wallpaper.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:wallywiz/utils/platform.dart';

enum WallpaperLocation {
  home(1),
  lock(2),
  both(3);

  final int value;
  const WallpaperLocation(this.value);
}

class WallpaperService {
  static Future<void> set(String path,
      {WallpaperLocation location = WallpaperLocation.both}) async {
    if (kIsDesktop) {
      await Wallpaper.set(path);
    } else if (kIsAndroid) {
      await WallpaperManager.setWallpaperFromFile(
        path,
        location.value,
      );
    }
  }
}
