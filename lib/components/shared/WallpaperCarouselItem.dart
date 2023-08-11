import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:wallywiz/models/wallpaper.dart';

class WallpaperCarouselItem extends HookConsumerWidget {
  final VoidCallback onLongPress;
  final Wallpaper wallpaper;
  const WallpaperCarouselItem({
    Key? key,
    required this.onLongPress,
    required this.wallpaper,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final mediaQuery = MediaQuery.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: CachedNetworkImage(
                  imageUrl: wallpaper.remoteApi == "unsplash"
                      ? wallpaper.hdUrl +
                          '&w=${mediaQuery.size.width > 1080 ? 1080 : mediaQuery.size.width}'
                      : wallpaper.hdUrl,
                  fit: BoxFit.cover,
                  progressIndicatorBuilder: (context, url, progress) {
                    return Stack(
                      children: [
                        Positioned.fill(
                          child: CachedNetworkImage(
                            imageUrl: wallpaper.thumbnail,
                            fit: BoxFit.cover,
                          ),
                        ),
                        if (progress.progress != null)
                          Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: SizedBox.square(
                                dimension: 60,
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 10,
                                    sigmaY: 10,
                                  ),
                                  child: CircularProgressIndicator(
                                    value: progress.progress,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        Center(
                          child: Text(
                            '${((progress.progress ?? 0) * 100).round()}%',
                            style: const TextStyle(shadows: [
                              Shadow(
                                blurRadius: 1,
                                color: Colors.white,
                                offset: Offset(-1, -1),
                              ),
                            ]),
                          ),
                        ),
                      ],
                    );
                  },
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
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
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
    );
  }
}
