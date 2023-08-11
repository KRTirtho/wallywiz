import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wallywiz/components/shared/WallpaperCarousel.dart';
import 'package:wallywiz/components/shared/WallpaperForm.dart';
import 'package:wallywiz/components/shared/page_window_title_bar.dart';
import 'package:wallywiz/models/category.dart';
import 'package:wallywiz/models/wallpaper.dart';
import 'package:wallywiz/providers/shuffler.dart';
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

    final shuffleSource = ref.watch(shufflerProvider);
    final isActive = useMemoized(
      () => shuffleSource.sources.any((s) => s.categoryId == category.id),
      [shuffleSource.sources, category.id],
    );

    final selectedWallpapers = useState<Set<Wallpaper>>({});

    return Scaffold(
      appBar: PageWindowTitleBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(cleanedTitle),
            if (isActive)
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(50),
                ),
                margin: const EdgeInsets.only(left: 3),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                child: const Text(
                  'active',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1,
                  ),
                ),
              ),
          ],
        ),
      ),
      body: WallpaperCarousel(
        wallpapers: wallpaperQuery.data ?? <Wallpaper>[],
        isCollectionActive: isActive,
        selectedWallpapers: selectedWallpapers,
        form: WallpaperForm(
          isCollectionActive: isActive,
          selectedWallpapers: selectedWallpapers.value,
          wallpapers: wallpaperQuery.data ?? <Wallpaper>[],
        ),
      ),
    );
  }
}
