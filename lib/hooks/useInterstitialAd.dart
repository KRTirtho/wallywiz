import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:wallywiz/collections/ad_ids.dart';
import 'package:wallywiz/utils/platform.dart';

InterstitialAd? useInterstitialAd(String adUnitId) {
  final adRef = useRef<InterstitialAd?>(null);

  useEffect(() {
    if (!kAdPlatform) return null;
    () async {
      await InterstitialAd.load(
          adUnitId: kDebugMode ? AdIds.demoInterstitial : adUnitId,
          request: const AdRequest(nonPersonalizedAds: true),
          adLoadCallback: InterstitialAdLoadCallback(
            // Called when an ad is successfully received.
            onAdLoaded: (ad) {
              ad.fullScreenContentCallback = FullScreenContentCallback(
                onAdShowedFullScreenContent: (ad) {},
                onAdImpression: (ad) {},
                onAdFailedToShowFullScreenContent: (ad, err) {
                  ad.dispose();
                },

                onAdDismissedFullScreenContent: (ad) {
                  ad.dispose();
                },
                // Called when a click is recorded for an ad.
                onAdClicked: (ad) {},
              );

              adRef.value = ad;
            },
            // Called when an ad request failed.
            onAdFailedToLoad: (LoadAdError error) {
              debugPrint('InterstitialAd failed to load: $error');
            },
          ));
    }();

    return () {
      adRef.value?.dispose();
    };
  }, [adUnitId]);

  return adRef.value;
}
