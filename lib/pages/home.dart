import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wallywiz/collections/ad_ids.dart';
import 'package:wallywiz/components/CreateWallpaperProvider/CreateWallpaperProviderView.dart';
import 'package:wallywiz/components/home/CategoryCard.dart';
import 'package:wallywiz/components/shared/waypoint.dart';
import 'package:wallywiz/hooks/useBannerAd.dart';
import 'package:wallywiz/hooks/useInterStitialAd.dart';
import 'package:wallywiz/services/queries.dart';

class Home extends HookConsumerWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final brightness = Theme.of(context).brightness;

    final categoryQuery = useApi.listInfiniteCategories();
    final controller = useScrollController();

    final categories = useMemoized(() {
      return categoryQuery.pages.expand((element) => element.data).toList();
    }, [categoryQuery.pages]);

    useEffect(() {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: brightness == Brightness.dark
              ? Colors.grey[900]
              : Colors.white, // status bar color
          statusBarIconBrightness: brightness == Brightness.dark
              ? Brightness.light
              : Brightness.dark,
        ),
      );
      return null;
    }, [brightness]);

    final (:bannerAd, :isAdLoaded) = useBannerAd(adUnitId: AdIds.bottomBanner);

    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add_photo_alternate_rounded),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) {
                return CreateWallpaperProviderView();
              },
            ));
          },
        ),
        body: GridView.builder(
          controller: controller,
          itemCount: categories.length,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            childAspectRatio: 0.7,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            final category = categories[index];
            if (index == categories.length - 1) {
              return Waypoint(
                controller: controller,
                isGrid: true,
                onTouchEdge: () {
                  if (!categoryQuery.hasNextPage) return;
                  categoryQuery.fetchNext();
                },
                child: CategoryCard(
                  category: category,
                ),
              );
            }

            return CategoryCard(
              category: category,
            );
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
      ),
    );
  }
}
