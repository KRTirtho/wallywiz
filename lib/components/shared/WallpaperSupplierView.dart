import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wallywiz/helpers/toCapitalCase.dart';
import 'package:wallywiz/hooks/usePaletteGenerator.dart';
import 'package:wallywiz/models/WallpaperSource.dart';
import 'package:wallywiz/providers/futures.dart';
import 'package:wallywiz/providers/wallpaper-provider.dart';

class WallpaperSupplierView extends HookConsumerWidget {
  final WallpaperSource wallpaperSource;
  const WallpaperSupplierView({Key? key, required this.wallpaperSource})
      : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final bgWallpaperSnapshot =
        ref.watch(wallpaperQuery(jsonEncode(wallpaperSource.toJson())));
    final palette = usePaletteGenerator(
      bgWallpaperSnapshot.asData?.value["image"] ??
          "https://avatars.dicebear.com/api/human/wallywiz.png",
    );
    final wallpaper = ref.watch(wallpaperProvider);
    final tempSchedule = useState(wallpaper.schedule);
    return Scaffold(
      appBar: AppBar(
        title: Text(wallpaperSource.name),
      ),
      body: ListView(
        children: [
          LayoutBuilder(builder: (context, constrains) {
            return bgWallpaperSnapshot.when(
              data: (bgWallpaper) {
                return Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(
                        bgWallpaper["image"] as String,
                        cacheKey: bgWallpaper["image"],
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Text(
                      toCapitalCase(wallpaperSource.name),
                      style: Theme.of(context).textTheme.headline3?.copyWith(
                            color: (palette.dominantColor?.color
                                            .computeLuminance() ??
                                        1) >
                                    0.5
                                ? palette.darkVibrantColor?.color
                                : palette.lightMutedColor?.color,
                          ),
                    ),
                  ),
                  width: constrains.biggest.width,
                  height: MediaQuery.of(context).size.height * .75,
                );
              },
              error: (error, stack) => throw error,
              loading: () => const CircularProgressIndicator.adaptive(),
            );
          }),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              title: const Text("Wallpaper change period"),
              trailing: TextButton(
                child: Text(
                  tempSchedule.value
                      .toString()
                      .split(":")
                      .sublist(0, 2)
                      .join(":"),
                ),
                onPressed: () async {
                  final duration = await showDurationPicker(
                    context: context,
                    initialTime: tempSchedule.value,
                    snapToMins: 10,
                  );
                  if (duration != null) tempSchedule.value = duration;
                },
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    child: const Text("Use"),
                    onPressed: wallpaper.currentWallpaperSource?.url !=
                                wallpaperSource.url ||
                            wallpaper.schedule != tempSchedule.value
                        ? () async {
                            wallpaper.scheduleWallpaper2(
                              source: wallpaperSource,
                              period: tempSchedule.value,
                              tempDir: (await getTemporaryDirectory()).path,
                            );
                          }
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
