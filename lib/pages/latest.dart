import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wallywiz/collections/ad_ids.dart';
import 'package:wallywiz/components/shared/WallpaperCarousel.dart';
import 'package:wallywiz/hooks/useBannerAd.dart';
import 'package:wallywiz/services/queries.dart';

class LatestPage extends HookConsumerWidget {
  const LatestPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final wallpapersQuery = useApi.latestCategoryWallpapers();

    final wallpapers = useMemoized(
        () => wallpapersQuery.pages.expand((page) => page).toList(),
        [wallpapersQuery.pages]);

    final (:bannerAd, :isAdLoaded) = useBannerAd(adUnitId: AdIds.bottomBanner);

    return Scaffold(
      body: WallpaperCarousel(
        wallpapers: wallpapers,
        isCollectionActive: false,
        onEndReached: () {
          if (wallpapersQuery.hasNextPage) {
            wallpapersQuery.fetchNext();
          }
        },
      ),
      bottomNavigationBar: isAdLoaded
          ? SizedBox(
              width: bannerAd!.size.width.toDouble(),
              height: bannerAd.size.height.toDouble(),
              child: StatefulBuilder(builder: (context, setState) {
                return AdWidget(ad: bannerAd);
              }),
            )
          : null,
    );
  }
}
