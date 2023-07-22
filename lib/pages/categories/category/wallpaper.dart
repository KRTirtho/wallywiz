import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:wallywiz/components/shared/page_window_title_bar.dart';
import 'package:wallywiz/models/category.dart';
import 'package:wallywiz/models/wallpaper.dart';
import 'package:wallywiz/services/queries.dart';
import 'package:wallywiz/utils/clean-title.dart';
import 'package:carousel_slider/carousel_slider.dart';

class WallpaperPage extends HookConsumerWidget {
  final Category category;
  const WallpaperPage({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final cleanedTitle = useMemoized(
      () => cleanTitle(category.title),
      [category.title],
    );

    final wallpaperQuery = useApi.listCategoryWallpapers(category.id);

    return Scaffold(
      appBar: PageWindowTitleBar(
        title: Text(cleanedTitle),
      ),
      body: LayoutBuilder(builder: (context, constrains) {
        return CarouselSlider(
          options: CarouselOptions(
            height: double.infinity,
          ),
          items: [
            for (final wallpaper in wallpaperQuery.data ?? <Wallpaper>[])
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
      }),
    );
  }
}
