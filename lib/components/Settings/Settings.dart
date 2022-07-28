import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wallywiz/components/Settings/SettingsTile.dart';
import 'package:wallywiz/models/ConfigurationSchema.dart';
import 'package:wallywiz/models/WallpaperSource.dart';
import 'package:wallywiz/providers/preferences.dart';
import 'package:wallywiz/providers/wallpaper-provider.dart';
import 'package:workmanager/workmanager.dart';

class Settings extends ConsumerWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final preferences = ref.watch(userPreferencesProvider);
    final wp = ref.watch(wallpaperProvider);
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
          ),
          ListTile(
            title: Text(
              "Stop background task",
              style: Theme.of(context).textTheme.bodyText1?.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            onTap: () async {
              await Workmanager().cancelAll();
            },
          ),
          ListTile(
            title: const Text("Import Configurations"),
            onTap: () async {
              final file = File(
                await FilePicker.platform
                    .pickFiles(
                      allowMultiple: false,
                      allowedExtensions: ["json", "jsonc"],
                      dialogTitle: "Pick WallyWiz configuration JSON file",
                      type: FileType.custom,
                    )
                    .then((s) => s!.paths.single!),
              );

              final errors = configurationSchema.validateWithErrors(
                file.readAsStringSync(),
                parseJson: true,
              );

              if (errors.isNotEmpty) {
                return showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text(
                        "The Configuration File is invalid",
                      ),
                      content: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: errors.length,
                          itemBuilder: (context, index) {
                            return Text(errors.elementAt(index).message);
                          },
                        ),
                      ),
                    );
                  },
                );
              }

              final sources = List.from(
                jsonDecode(file.readAsStringSync()),
              )
                  .map((source) => WallpaperSource.fromJson({
                        ...source,
                        "isOfficial": false,
                      }))
                  .toList();
              wp.addWallpaperSources(sources);
            },
          ),
          ListTile(
            title: const Text("Export Configurations"),
            subtitle: const Text(
              "Exports all credentials & API keys too",
            ),
            onTap: () async {
              final userWallpaperProvidersJson = jsonEncode(
                wp.wallpaperSources
                    .where((s) => !s.isOfficial)
                    .map((s) => s.toJson()..remove("isOfficial"))
                    .toList(),
              );
              final downloadsDir = Platform.isAndroid
                  ? Directory('/storage/emulated/0/Download')
                  : await getApplicationDocumentsDirectory();

              final outputFile = File(path.join(
                downloadsDir.path,
                "wallywiz-configurations-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}.json",
              ));

              if (!outputFile.existsSync()) {
                outputFile.createSync(recursive: true);
              }
              outputFile.writeAsStringSync(
                userWallpaperProvidersJson,
                flush: true,
                mode: FileMode.writeOnly,
              );

              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Text(
                  "Exported configurations to ${outputFile.path}",
                ),
              ));
            },
          ),
        ],
      ),
    );
  }
}
