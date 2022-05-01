import 'package:cached_network_image/cached_network_image.dart';
import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wallywiz/helpers/toCapitalCase.dart';
import 'package:wallywiz/hooks/usePaletteGenerator.dart';
import 'package:wallywiz/providers/wallpaper-provider.dart';
import 'package:wallywiz/providers/wallpaper-service.dart';

class WallpaperProviderView extends HookConsumerWidget {
  final RandomWallpaperAPI provider;
  final bool isPictureOfTheDay;
  const WallpaperProviderView({
    required this.provider,
    this.isPictureOfTheDay = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final wallpaperService = ref.watch(wallpaperServiceProvider);
    final bgWallpaper = useState<String?>(null);
    final palette = usePaletteGenerator(
      bgWallpaper.value ??
          "https://avatars.dicebear.com/api/human/wallywiz.png",
    );
    final wallpaper = ref.watch(wallpaperProvider);
    final tempSchedule = useState(wallpaper.schedule);
    final controller = useTextEditingController(text: "MobileWallpaper");
    useEffect(() {
      wallpaperService
          .getWallpaperByProvider(provider, controller.value.text)
          .then((url) => bgWallpaper.value = url);
      return null;
    }, []);

    return Scaffold(
      appBar: AppBar(title: Text(toCapitalCase(provider.name))),
      body: ListView(
        children: [
          if (bgWallpaper.value != null)
            LayoutBuilder(builder: (context, constrains) {
              return Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(
                      bgWallpaper.value!,
                      cacheKey: bgWallpaper.value!,
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Text(
                    toCapitalCase(provider.name),
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
            }),
          if (!isPictureOfTheDay)
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
          if (provider == RandomWallpaperAPI.reddit)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: "e.g. AnimeWallpaper",
                  labelText: "Subreddit",
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
                    onPressed: wallpaper.currentAPI != provider ||
                            wallpaper.schedule != tempSchedule.value
                        ? () async {
                            wallpaper.scheduleWallpaper(
                              provider: provider,
                              period: isPictureOfTheDay
                                  ? const Duration(hours: 12)
                                  : tempSchedule.value,
                              tempDir: (await getTemporaryDirectory()).path,
                              subreddit: controller.value.text,
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
