import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wallywiz/collections/ad_ids.dart';
import 'package:wallywiz/components/shared/UnitDurationPickerDialog.dart';
import 'package:wallywiz/components/shared/WallpaperCarouselItem.dart';
import 'package:wallywiz/extensions/constrains.dart';
import 'package:wallywiz/hooks/useInterstitialAd.dart';
import 'package:wallywiz/hooks/useMultiBannerAds.dart';
import 'package:wallywiz/models/wallpaper.dart';
import 'package:wallywiz/providers/shuffler.dart';

final adClickCounter = StateProvider((ref) => 0);

class WallpaperCarousel extends HookConsumerWidget {
  final List<Wallpaper> wallpapers;
  final VoidCallback? onEndReached;
  const WallpaperCarousel({
    Key? key,
    required this.wallpapers,
    this.onEndReached,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final controller = useMemoized(() => CarouselController(), []);
    final duration = useState<Duration>(Duration.zero);
    final durationController = useTextEditingController();
    final shuffler = ref.watch(shufflerProvider);

    final selectedWallpapers = useState<Set<Wallpaper>>({});

    final interstitialAd = useInterstitialAd(AdIds.openCategoryInterstitial);

    final adFilledWallpapers =
        useMultiBannerAds(items: wallpapers, adSize: AdSize.mediumRectangle);

    final carouselSlider = CarouselSlider(
      carouselController: controller,
      options: CarouselOptions(
        height: double.infinity,
        enableInfiniteScroll: false,
        onPageChanged: (index, reason) {
          if (index == wallpapers.length - 1) {
            onEndReached?.call();
          }
        },
      ),
      items: [
        for (final wallpaper in adFilledWallpapers)
          if (wallpaper is Wallpaper)
            WallpaperCarouselItem(
              wallpaper: wallpaper,
              onLongPress: () {
                selectedWallpapers.value = {
                  ...selectedWallpapers.value,
                  wallpaper,
                };
              },
            )
          else if (wallpaper is BannerAdItem && wallpaper.isAdLoaded)
            SizedBox(
              height: AdSize.mediumRectangle.height.toDouble(),
              width: AdSize.mediumRectangle.width.toDouble(),
              child: StatefulBuilder(builder: (context, setState) {
                return AdWidget(
                  ad: wallpaper.bannerAd,
                );
              }),
            )
      ],
    );

    final selectionGridView = Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Selected Wallpapers (${selectedWallpapers.value.length})',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              FilledButton.tonalIcon(
                icon: const Icon(Icons.delete_outline),
                label: const Text('Clear All'),
                onPressed: () {
                  selectedWallpapers.value = {};
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 120,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: wallpapers.length,
              itemBuilder: (context, index) {
                final wallpaper = wallpapers[index];
                final isSelected = selectedWallpapers.value.contains(wallpaper);
                return InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    if (isSelected) {
                      selectedWallpapers.value = {
                        ...selectedWallpapers.value,
                      }..remove(wallpaper);
                    } else {
                      selectedWallpapers.value = {
                        ...selectedWallpapers.value,
                        wallpaper,
                      };
                    }
                  },
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color:
                                isSelected ? Colors.blue : Colors.transparent,
                            width: 3,
                          ),
                          image: DecorationImage(
                            image: CachedNetworkImageProvider(wallpaper.hdUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.black.withOpacity(0.5),
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );

    onDurationPicker() async {
      final durationVal = await showDialog<Duration>(
        context: context,
        builder: (context) =>
            UnitDurationPickerDialog(initialDuration: duration.value),
      );
      if (durationVal == null) return;
      duration.value = durationVal;
      durationController.text =
          '${durationVal.inHours}h:${durationVal.inMinutes.remainder(60)}m';
    }

    return WillPopScope(
      onWillPop: () {
        if (selectedWallpapers.value.isNotEmpty) {
          selectedWallpapers.value = {};
          return Future.value(false);
        }
        return Future.value(true);
      },
      child: CallbackShortcuts(
        bindings: {
          LogicalKeySet(LogicalKeyboardKey.arrowLeft): () {
            controller.previousPage();
          },
          LogicalKeySet(LogicalKeyboardKey.arrowRight): () {
            controller.nextPage();
          },
        },
        child: Focus(
          autofocus: true,
          child: SafeArea(
            child: LayoutBuilder(builder: (context, constrains) {
              return SingleChildScrollView(
                physics: constrains.mdAndUp
                    ? const NeverScrollableScrollPhysics()
                    : null,
                child: Flex(
                  direction:
                      constrains.mdAndUp ? Axis.horizontal : Axis.vertical,
                  children: [
                    SizedBox(
                      height:
                          constrains.maxHeight - (constrains.mdAndUp ? 0 : 120),
                      width: constrains.mdAndUp
                          ? constrains.maxWidth * 0.7
                          : constrains.maxWidth,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: selectedWallpapers.value.isEmpty
                            ? carouselSlider
                            : selectionGridView,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: durationController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            readOnly: true,
                            onTap: onDurationPicker,
                            decoration: InputDecoration(
                                constraints: BoxConstraints(
                                  maxWidth: constrains.mdAndUp
                                      ? constrains.maxWidth * 0.3 - 50
                                      : constrains.maxWidth,
                                ),
                                labelText: 'Shuffle Duration',
                                suffixIcon: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: IconButton.filledTonal(
                                    icon: const Icon(Icons.timer_outlined),
                                    style: IconButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: onDurationPicker,
                                  ),
                                )),
                          ),
                          const SizedBox(height: 10),
                          FilledButton.tonalIcon(
                            icon: const Icon(Icons.play_arrow_outlined),
                            label: Text(
                              selectedWallpapers.value.isEmpty
                                  ? 'Shuffle Wallpapers'
                                  : 'Shuffle Selected Wallpapers',
                            ),
                            style: FilledButton.styleFrom(
                              minimumSize: Size(
                                ((constrains.mdAndUp
                                        ? constrains.maxWidth -
                                            (constrains.maxWidth * 0.7)
                                        : constrains.maxWidth)) -
                                    20,
                                40,
                              ),
                            ),
                            onPressed: () async {
                              final clicked = ref.read(adClickCounter);
                              final sourceWallpapers =
                                  selectedWallpapers.value.isNotEmpty
                                      ? selectedWallpapers.value
                                      : wallpapers.toSet();
                              // don't show the ad if the user has clicked 3 times
                              if (clicked == 2) {
                                await interstitialAd?.show().then((_) {
                                  ref
                                      .read(shufflerProvider.notifier)
                                      .setShuffleSource(
                                        ShufflerSource(
                                          interval: duration.value,
                                          sources: sourceWallpapers,
                                        ),
                                      );
                                });
                                ref
                                    .read(adClickCounter.notifier)
                                    .update((s) => 1);
                              } else {
                                ref
                                    .read(shufflerProvider.notifier)
                                    .setShuffleSource(
                                      ShufflerSource(
                                        interval: duration.value,
                                        sources: sourceWallpapers,
                                      ),
                                    );
                                ref
                                    .read(adClickCounter.notifier)
                                    .update((s) => s + 1);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
