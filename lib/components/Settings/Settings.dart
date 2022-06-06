import 'package:flutter/material.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wallywiz/components/Settings/SettingsTile.dart';
import 'package:wallywiz/providers/preferences.dart';

class Settings extends ConsumerWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final preferences = ref.watch(userPreferencesProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          SettingsTile(
            title: "Wallpaper Change Location",
            trailing: DropdownButton<int>(
              items: [
                DropdownMenuItem(
                  child: const Text(
                    "Home Screen Only",
                  ),
                  value: WallpaperManager.HOME_SCREEN,
                ),
                DropdownMenuItem(
                  child: const Text(
                    "Lock Screen Only",
                  ),
                  value: WallpaperManager.LOCK_SCREEN,
                ),
                DropdownMenuItem(
                  child: const Text("Both Lock & Home Screen"),
                  value: WallpaperManager.BOTH_SCREEN,
                ),
              ],
              value: preferences.wallpaperLocation,
              onChanged: (value) {
                if (value != null) {
                  preferences.setWallpaperLocation(value);
                }
              },
            ),
          ),
          SettingsTile(
            title: "Theme",
            trailing: DropdownButton<ThemeMode>(
              value: preferences.themeMode,
              items: const [
                DropdownMenuItem(
                  child: Text(
                    "Dark",
                  ),
                  value: ThemeMode.dark,
                ),
                DropdownMenuItem(
                  child: Text(
                    "Light",
                  ),
                  value: ThemeMode.light,
                ),
                DropdownMenuItem(
                  child: Text("System"),
                  value: ThemeMode.system,
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  preferences.setThemeMode(value);
                }
              },
            ),
          )
        ],
      ),
    );
  }
}
