import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:wallywiz/collections/ad_ids.dart';
import 'package:wallywiz/utils/platform.dart';

typedef BannerAdItem = ({
  BannerAd bannerAd,
  bool isAdLoaded,
});

List useMultiBannerAds<T>({
  required List<T> items,
  AdSize adSize = AdSize.mediumRectangle,
}) {
  final isAdLoaded = useState<Map<int, bool>>({});

  var adCount = 0;

  // for every 3 items, show an ad
  final adFilledItems = useMemoized<List>(
    () => items.mapIndexed(
      (index, item) {
        final random = Random();
        if (index == 2 ||
            (adCount < 3 &&
                random.nextBool() &&
                index != 0 &&
                index != items.length - 1)) {
          adCount++;
          return [
            BannerAd(
              adUnitId:
                  kDebugMode ? AdIds.demoBanner : AdIds.horizontalScrollBanner,
              size: adSize,
              request: const AdRequest(),
              listener: BannerAdListener(
                onAdLoaded: (ad) async {
                  isAdLoaded.value = {
                    ...isAdLoaded.value,
                    index: true,
                  };
                },
                onAdFailedToLoad: (ad, error) {
                  ad.dispose();
                },
              ),
            ),
            item
          ];
        } else {
          return item;
        }
      },
    ).expand((element) {
      if (element is List) {
        return element;
      } else {
        return [element];
      }
    }).toList(),
    [items, adSize],
  );

  useEffect(() {
    if (!kAdPlatform) return null;
    final ads = adFilledItems.whereType<BannerAd>();
    Future.wait(ads.map((ad) => ad.load()));
    return () {
      for (var ad in ads) {
        ad.dispose();
      }
    };
  }, [adFilledItems]);

  final result = useMemoized(
    () => adFilledItems.mapIndexed(
      (index, ad) {
        if (ad is T) {
          return ad;
        }
        final BannerAdItem adItem = (
          bannerAd: ad,
          isAdLoaded: isAdLoaded.value[index] ?? false,
        );

        return adItem;
      },
    ).toList(),
    [
      adFilledItems,
      isAdLoaded.value,
    ],
  );

  return result;
}
