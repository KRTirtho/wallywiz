import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:wallywiz/components/Settings/SettingsTile.dart';
import 'package:wallywiz/components/shared/page_window_title_bar.dart';
import 'package:wallywiz/models/ConfigurationSchema.dart';
import 'package:wallywiz/models/WallpaperSource.dart';
import 'package:wallywiz/providers/preferences.dart';
import 'package:wallywiz/providers/wallpaper-provider.dart';
import 'package:workmanager/workmanager.dart';
import 'package:url_launcher/url_launcher.dart';

const license = """
BSD-4-Clause License

Copyright (c) 2022 Kingkor Roy Tirtho. All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
3. All advertising materials mentioning features or use of this software must display the following acknowledgement:
This product includes software developed by Kingkor Roy Tirtho.
4. Neither the name of the Software nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY KINGKOR ROY TIRTHO AND CONTRIBUTORS  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL KINGKOR ROY TIRTHO AND CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
""";

class Settings extends ConsumerWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final preferences = ref.watch(userPreferencesProvider);
    final wp = ref.watch(wallpaperProvider);
    return Scaffold(
      appBar: const PageWindowTitleBar(
        title: Text("Settings"),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text("Wallpaper Change Location"),
            leading: const Icon(Icons.wallpaper),
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
            leading: const Icon(Icons.format_paint_rounded),
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
            leading: const Icon(
              Icons.stop_circle_outlined,
              color: Colors.red,
            ),
            onTap: () async {
              await Workmanager().cancelAll();
            },
          ),
          ListTile(
            title: const Text("Import Configurations"),
            leading: const Icon(Icons.file_download_outlined),
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

              final validation = configurationSchema.validate(
                file.readAsStringSync(),
                parseJson: true,
              );

              if (validation.errors.isNotEmpty) {
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
                          itemCount: validation.errors.length,
                          itemBuilder: (context, index) {
                            return Text(
                                validation.errors.elementAt(index).message);
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
            leading: const Icon(Icons.file_upload_outlined),
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
          ListTile(
            leading: const Icon(Icons.bug_report_rounded),
            title: const Text("Report bugs/issues"),
            onTap: () {
              launchUrlString(
                "https://github.com/KRTirtho/wallywiz/issues/new?assignees=&labels=bug&template=bug_report.md&title=",
              );
            },
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 7),
            decoration: BoxDecoration(
              color: Colors.pink[100],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Material(
              type: MaterialType.transparency,
              child: ListTile(
                iconColor: Colors.pink,
                textColor: Colors.pink,
                title: const Text(
                  "Support Us",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                leading: const Icon(Icons.favorite_border_rounded),
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Support WallyWiz 💖"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: () {
                                    launchUrl(
                                      Uri.parse(
                                          "https://www.buymeacoffee.com/krtirtho"),
                                      mode: LaunchMode.externalApplication,
                                    );
                                  },
                                  child: SvgPicture.network(
                                    "https://img.buymeacoffee.com/button-api/?text=Buy me a coffee&emoji=&slug=krtirtho&button_colour=FF5F5F&font_colour=ffffff&font_family=Inter&outline_colour=000000&coffee_colour=FFDD00",
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: () {
                                    launchUrl(
                                      Uri.parse("https://patreon.com/krtirtho"),
                                      mode: LaunchMode.externalApplication,
                                    );
                                  },
                                  child: CachedNetworkImage(
                                    imageUrl:
                                        "https://user-images.githubusercontent.com/61944859/180249027-678b01b8-c336-451e-b147-6d84a5b9d0e7.png",
                                    width: 230,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      });
                },
              ),
            ),
          ),
          ListTile(
              title: const Text("About WallyWiz"),
              leading: const Icon(Icons.info_outline_rounded),
              onTap: () async {
                final packageInfo = await PackageInfo.fromPlatform();
                showAboutDialog(
                  context: context,
                  applicationIcon: SvgPicture.asset(
                    "assets/logo.svg",
                    width: 100,
                    height: 100,
                  ),
                  applicationLegalese: license,
                  applicationName: "WallyWiz",
                  applicationVersion: packageInfo.version,
                );
              }),
        ],
      ),
    );
  }
}
