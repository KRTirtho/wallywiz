import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:wallywiz/components/shared/UnitDurationPickerDialog.dart';
import 'package:wallywiz/extensions/constrains.dart';
import 'package:wallywiz/models/wallpaper.dart';

class WallpaperCarousel extends HookWidget {
  final List<Wallpaper> wallpapers;
  final VoidCallback? onEndReached;
  const WallpaperCarousel({
    Key? key,
    required this.wallpapers,
    this.onEndReached,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = useMemoized(() => CarouselController(), []);
    final duration = useState<Duration>(Duration.zero);
    final durationController = useTextEditingController();

    final carouselSlider = CarouselSlider(
      carouselController: controller,
      options: CarouselOptions(
        height: double.infinity,
        enableInfiniteScroll: false,
        onPageChanged: (index, reason) {
          if (index == wallpapers.length - 1) {
            onEndReached?.call();
          }
        },
      ),
      items: [
        for (final wallpaper in wallpapers)
          Padding(
            padding: const EdgeInsets.all(10),
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                      imageUrl: wallpaper.hdUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: RichText(
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      text: TextSpan(
                        text: wallpaper.authorName,
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launchUrlString(
                              wallpaper.authorUrl,
                              mode: LaunchMode.externalApplication,
                            );
                          },
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                                // bottomLeft
                                offset: Offset(-1.5, -1.5),
                                color: Colors.black38),
                            Shadow(
                                // bottomRight
                                offset: Offset(1.5, -1.5),
                                color: Colors.black38),
                            Shadow(
                                // topRight
                                offset: Offset(1.5, 1.5),
                                color: Colors.black38),
                            Shadow(
                                // topLeft
                                offset: Offset(-1.5, 1.5),
                                color: Colors.black38),
                          ],
                        ),
                        children: [
                          TextSpan(
                            text: ' (${wallpaper.remoteApi})',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );

    onDurationPicker() async {
      final durationVal = await showDialog<Duration>(
        context: context,
        builder: (context) =>
            UnitDurationPickerDialog(initialDuration: duration.value),
      );
      if (durationVal == null) return;
      duration.value = durationVal;
      durationController.text =
          '${durationVal.inHours}h:${durationVal.inMinutes.remainder(60)}m';
    }

    ;

    return CallbackShortcuts(
      bindings: {
        LogicalKeySet(LogicalKeyboardKey.arrowLeft): () {
          controller.previousPage();
        },
        LogicalKeySet(LogicalKeyboardKey.arrowRight): () {
          controller.nextPage();
        },
      },
      child: Focus(
        autofocus: true,
        child: LayoutBuilder(builder: (context, constrains) {
          return Flex(
            direction: constrains.mdAndUp ? Axis.horizontal : Axis.vertical,
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: constrains.mdAndUp
                    ? constrains.maxHeight
                    : constrains.maxHeight - 100,
                width: constrains.mdAndUp
                    ? constrains.maxWidth * 0.7
                    : constrains.maxWidth,
                child: carouselSlider,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: (constrains.mdAndUp
                                  ? constrains.maxWidth -
                                      (constrains.maxWidth * 0.7)
                                  : constrains.maxWidth) -
                              70,
                          height: 40,
                          child: TextField(
                            controller: durationController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            readOnly: true,
                            onTap: onDurationPicker,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              labelText: 'Shuffle Duration',
                            ),
                          ),
                        ),
                        const SizedBox.square(dimension: 10),
                        IconButton.filledTonal(
                          icon: const Icon(Icons.timer_outlined),
                          style: IconButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: onDurationPicker,
                        )
                      ],
                    ),
                    const SizedBox(height: 10),
                    FilledButton.tonalIcon(
                      icon: const Icon(Icons.play_arrow_outlined),
                      label: const Text('Play'),
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: Size(
                          ((constrains.mdAndUp
                                  ? constrains.maxWidth -
                                      (constrains.maxWidth * 0.7)
                                  : constrains.maxWidth)) -
                              20,
                          40,
                        ),
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
