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
          ListTile(
            title: const Text("Wallpaper Change Location"),
            onTap: () async {
              final value = await showDialog(
                context: context,
                builder: (context) {
                  return SimpleDialog(
                    title: const Text("Wallpaper Change Location"),
                    children: [
                      SimpleDialogOption(
                        child: const Text("Lock Screen"),
                        onPressed: () {
                          Navigator.pop(
                            context,
                            WallpaperManager.LOCK_SCREEN,
                          );
                        },
                      ),
                      SimpleDialogOption(
                        child: const Text("Home Screen"),
                        onPressed: () {
                          Navigator.pop(
                            context,
                            WallpaperManager.HOME_SCREEN,
                          );
                        },
                      ),
                      SimpleDialogOption(
                        child: const Text("Both Home & Lock Screen"),
                        onPressed: () {
                          Navigator.pop(
                            context,
                            WallpaperManager.BOTH_SCREEN,
                          );
                        },
                      ),
                    ],
                  );
                },
              );
              if (value == null) return;
              preferences.setWallpaperLocation(value);
            },
          ),
          SettingsTile(
            title: "Theme",
            trailing: DropdownButton<ThemeMode>(
              value: preferences.themeMode,
              items: const [
                DropdownMenuItem(
                  child: Text("Dark"),
                  value: ThemeMode.dark,
                ),
                DropdownMenuItem(
                  child: Text("Light"),
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
