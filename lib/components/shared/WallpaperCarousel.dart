import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:url_launcher/url_launcher_string.dart';
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
        child: LayoutBuilder(
          builder: (context, constrains) {
            return CarouselSlider(
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
                  Container(
                    width: double.infinity,
                    height: constrains.maxHeight,
                    margin: const EdgeInsets.all(10),
                    child: Stack(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: double.infinity,
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
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
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
          },
        ),
      ),
    );
  }
}
