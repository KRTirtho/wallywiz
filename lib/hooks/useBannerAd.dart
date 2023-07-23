import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:wallywiz/collections/ad_ids.dart';
import 'package:wallywiz/utils/platform.dart';

({BannerAd? bannerAd, bool isAdLoaded}) useBannerAd({
  required String adUnitId,
}) {
  final isLoaded = useState(false);
  final context = useContext();
  final mediaQuery = MediaQuery.of(context);

  final bannerAd = useRef<BannerAd?>(null);

  useEffect(() {
    if (!kAdPlatform) return null;
    () async {
      AdSize? size =
          await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
        mediaQuery.size.width.truncate(),
      );
      size ??= AdSize.banner;

      bannerAd.value = BannerAd(
        adUnitId: kDebugMode ? AdIds.demoBanner : adUnitId,
        request: const AdRequest(nonPersonalizedAds: true),
        size: size,
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            isLoaded.value = true;
          },
          onAdFailedToLoad: (ad, err) {
            debugPrint('Failed to load a banner ad: ${err.message}');
            ad.dispose();
          },
        ),
      );
      await bannerAd.value?.load();
    }();

    return () {
      bannerAd.value?.dispose();
    };
  }, [adUnitId]);

  return (
    bannerAd: bannerAd.value,
    isAdLoaded: kAdPlatform && isLoaded.value,
  );
}
