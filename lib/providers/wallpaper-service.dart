import 'package:riverpod/riverpod.dart';
import 'package:wallywiz/services/wallpaper.dart';

final wallpaperServiceProvider = Provider<WallpaperService>((ref) {
  return WallpaperService.getInstance();
});
