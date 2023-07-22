import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wallywiz/components/shared/WallpaperCarousel.dart';
import 'package:wallywiz/services/queries.dart';

class TrendingPage extends HookConsumerWidget {
  const TrendingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final wallpapersQuery = useApi.trendingCategoryWallpapers();

    final wallpapers = useMemoized(
        () => wallpapersQuery.pages.expand((page) => page).toList(),
        [wallpapersQuery.pages]);

    return Scaffold(
      body: WallpaperCarousel(
        wallpapers: wallpapers,
        onEndReached: () {
          if (wallpapersQuery.hasNextPage) {
            wallpapersQuery.fetchNext();
          }
        },
      ),
    );
  }
}
