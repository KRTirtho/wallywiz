import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wallywiz/components/CreateWallpaperProvider/CreateWallpaperProviderView.dart';
import 'package:wallywiz/helpers/toCapitalCase.dart';
import 'package:wallywiz/hooks/usePaletteGenerator.dart';
import 'package:wallywiz/models/WallpaperSource.dart';
import 'package:wallywiz/providers/futures.dart';
import 'package:wallywiz/providers/wallpaper-provider.dart';
import 'package:wallywiz/utils/NumericalRangeFormatter.dart';

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

    final prevScheduleValues = wallpaper.schedule.toString().split(":");

    final hourController = useTextEditingController(text: "");
    final minuteController = useTextEditingController(text: "");

    final tempSchedule = Duration(
      hours: int.tryParse(hourController.value.text) ??
          int.tryParse(prevScheduleValues.first) ??
          0,
      minutes: int.tryParse(minuteController.value.text) ??
          int.tryParse(prevScheduleValues[1]) ??
          0,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(wallpaperSource.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) {
                  return CreateWallpaperProviderView(
                    wallpaperSource: wallpaperSource,
                  );
                },
              ));
            },
          ),
        ],
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
            child: Column(children: [
              const Text("Wallpaper change interval"),
              const SizedBox(height: 10),
              Row(
                children: [
                  Flexible(
                    child: TextFormField(
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(2),
                        NumericalRangeFormatter(max: 23, min: 0),
                      ],
                      keyboardType: TextInputType.number,
                      controller: hourController,
                      decoration: const InputDecoration(
                        label: Text("Hour"),
                        hintText: "between 0 to 23",
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: TextFormField(
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(2),
                        NumericalRangeFormatter(max: 59, min: 0),
                      ],
                      keyboardType: TextInputType.number,
                      controller: minuteController,
                      decoration: const InputDecoration(
                        label: Text("Minute"),
                        hintText: "between 0 to 59",
                      ),
                    ),
                  ),
                ],
              ),
            ]),
          ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    child: const Text("Use"),
                    onPressed: (wallpaper.schedule != tempSchedule &&
                                tempSchedule != Duration.zero) ||
                            wallpaper.currentWallpaperSource?.url !=
                                wallpaperSource.url
                        ? () async {
                            wallpaper.scheduleWallpaperChanger(
                              source: wallpaperSource,
                              period: tempSchedule,
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
