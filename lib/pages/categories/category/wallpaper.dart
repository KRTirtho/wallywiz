import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wallywiz/components/shared/WallpaperCarousel.dart';
import 'package:wallywiz/components/shared/page_window_title_bar.dart';
import 'package:wallywiz/models/category.dart';
import 'package:wallywiz/models/wallpaper.dart';
import 'package:wallywiz/services/queries.dart';
import 'package:wallywiz/utils/clean-title.dart';

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
      body: WallpaperCarousel(wallpapers: wallpaperQuery.data ?? <Wallpaper>[]),
    );
  }
}
