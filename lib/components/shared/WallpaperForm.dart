import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wallywiz/collections/ad_ids.dart';
import 'package:wallywiz/components/shared/UnitDurationPickerDialog.dart';
import 'package:wallywiz/hooks/useInterstitialAd.dart';
import 'package:wallywiz/models/wallpaper.dart';
import 'package:wallywiz/providers/shuffler.dart';

final adClickCounter = StateProvider((ref) => 0);

class WallpaperForm extends HookConsumerWidget {
  final bool isCollectionActive;
  final Set<Wallpaper> selectedWallpapers;
  final List<Wallpaper> wallpapers;

  const WallpaperForm({
    Key? key,
    required this.isCollectionActive,
    required this.selectedWallpapers,
    required this.wallpapers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final shuffler = ref.watch(shufflerProvider);
    final duration = useState<Duration>(
      isCollectionActive ? shuffler.interval : Duration.zero,
    );
    final durationController = useTextEditingController(
      text: isCollectionActive
          ? '${duration.value.inHours}h:${duration.value.inMinutes.remainder(60)}m'
          : null,
    );
    final interstitialAd = useInterstitialAd(AdIds.openCategoryInterstitial);

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

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: TextField(
              controller: durationController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              readOnly: true,
              onTap: onDurationPicker,
              decoration: InputDecoration(
                  labelText: 'Shuffle Duration',
                  suffixIcon: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
          ),
          const SizedBox(height: 10),
          FilledButton.tonalIcon(
            icon: const Icon(Icons.play_arrow_outlined),
            label: Text(
              selectedWallpapers.isEmpty
                  ? 'Shuffle Wallpapers'
                  : 'Shuffle Selected Wallpapers',
            ),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
            onPressed: () async {
              final clicked = ref.read(adClickCounter);
              final sourceWallpapers = selectedWallpapers.isNotEmpty
                  ? selectedWallpapers
                  : wallpapers.toSet();
              // don't show the ad if the user has clicked 3 times
              if (clicked == 2) {
                await interstitialAd?.show().then((_) {
                  ref.read(shufflerProvider.notifier).setShuffleSource(
                        ShufflerSource(
                          interval: duration.value,
                          sources: sourceWallpapers,
                        ),
                      );
                });
                ref.read(adClickCounter.notifier).update((s) => 1);
              } else {
                ref.read(shufflerProvider.notifier).setShuffleSource(
                      ShufflerSource(
                        interval: duration.value,
                        sources: sourceWallpapers,
                      ),
                    );
                ref.read(adClickCounter.notifier).update((s) => s + 1);
              }
            },
          ),
        ],
      ),
    );
  }
}
