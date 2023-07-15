import 'dart:convert';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wallywiz/components/CreateWallpaperProvider/CreateWallpaperProviderView.dart';
import 'package:wallywiz/components/shared/page_window_title_bar.dart';
import 'package:wallywiz/helpers/toCapitalCase.dart';
import 'package:wallywiz/hooks/usePaletteGenerator.dart';
import 'package:wallywiz/models/WallpaperSource.dart';
import 'package:wallywiz/providers/futures.dart';
import 'package:wallywiz/providers/wallpaper-provider.dart';
import 'package:wallywiz/utils/NumericalRangeFormatter.dart';

class WallpaperSupplierView extends HookConsumerWidget {
  final WallpaperSource wallpaperSource;
  WallpaperSupplierView({Key? key, required this.wallpaperSource})
      : super(key: key);

  final formKey = GlobalKey<FormState>();

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

    const whiteText = TextStyle(color: Colors.white);
    const whiteOutlineInputBorder = OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.white,
        width: 1,
      ),
    );

    return Stack(
      children: [
        if (bgWallpaperSnapshot.asData?.value != null)
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: CachedNetworkImageProvider(
                  bgWallpaperSnapshot.asData!.value["image"] as String,
                  cacheKey: bgWallpaperSnapshot.asData!.value["image"],
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: SafeArea(
            child: Scaffold(
              backgroundColor:
                  Theme.of(context).backgroundColor.withOpacity(.2),
              appBar: PageWindowTitleBar(
                automaticallyImplyLeading: true,
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
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
                  IconButton(
                    icon: const Icon(Icons.delete_forever_outlined),
                    onPressed: () {
                      wallpaper.removeWallpaperSource(wallpaperSource.id);
                      Navigator.of(context).pop();
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
                              style: Theme.of(context)
                                  .textTheme
                                  .headline3
                                  ?.copyWith(
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
                      loading: () => const Center(
                        child: CircularProgressIndicator.adaptive(),
                      ),
                    );
                  }),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(children: [
                      const Text(
                        "Wallpaper change interval",
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      Form(
                        key: formKey,
                        child: Row(
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
                                  enabledBorder: whiteOutlineInputBorder,
                                  labelStyle: whiteText,
                                  hintStyle: whiteText,
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
                                  enabledBorder: whiteOutlineInputBorder,
                                  labelStyle: whiteText,
                                  hintStyle: whiteText,
                                  label: Text("Minute"),
                                  hintText: "between 0 to 59",
                                ),
                              ),
                            ),
                          ],
                        ),
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
                            onPressed: () async {
                              final tempSchedule = Duration(
                                hours: int.tryParse(
                                        hourController.value.text) ??
                                    int.tryParse(prevScheduleValues.first) ??
                                    0,
                                minutes:
                                    int.tryParse(minuteController.value.text) ??
                                        int.tryParse(prevScheduleValues[1]) ??
                                        0,
                              );
                              final isSameSchedule = wallpaper.schedule !=
                                      tempSchedule &&
                                  tempSchedule > const Duration(minutes: 15);
                              final isSameSource =
                                  wallpaper.currentWallpaperSource?.url !=
                                      wallpaperSource.url;

                              if (isSameSchedule || isSameSource) {
                                wallpaper.scheduleWallpaperChanger(
                                  source: wallpaperSource,
                                  period: tempSchedule,
                                  tempDir: (await getTemporaryDirectory()).path,
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    behavior: SnackBarBehavior.floating,
                                    content: Text(
                                      "Successfully set ${wallpaperSource.name} as default wallpaper provider",
                                    ),
                                  ),
                                );
                                formKey.currentState?.reset();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: Colors.red[400],
                                    behavior: SnackBarBehavior.floating,
                                    content: Text(
                                      tempSchedule <=
                                              const Duration(minutes: 15)
                                          ? "Interval must be more than 15 minutes"
                                          : isSameSource && !isSameSchedule
                                              ? "${wallpaperSource.name} is already set as default"
                                              : "New interval ${tempSchedule.toString().replaceAll(RegExp(r"\..*"), "")} is no different than old ${wallpaper.schedule.toString().replaceAll(RegExp(r"\..*"), "")} interval",
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
