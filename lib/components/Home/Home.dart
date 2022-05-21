import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wallywiz/components/Settings/Settings.dart';
import 'package:wallywiz/components/shared/WallpaperProviderView.dart';
import 'package:wallywiz/helpers/toCapitalCase.dart';
import 'package:wallywiz/providers/wallpaper-provider.dart';

const POD = [RandomWallpaperAPI.bing, RandomWallpaperAPI.nasa];

const brandImages = {
  RandomWallpaperAPI.bing: "assets/bing-logo.png",
  RandomWallpaperAPI.nasa: "assets/nasa-logo.png",
  RandomWallpaperAPI.pexels: "assets/pexels-logo.png",
  RandomWallpaperAPI.pixabay: "assets/pixabay-logo.png",
  RandomWallpaperAPI.reddit: "assets/reddit-logo.png",
  RandomWallpaperAPI.unsplash: "assets/unsplash-logo.png",
};

class Home extends HookConsumerWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final brightness = Theme.of(context).brightness;
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("WallyWiz"),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const Settings(),
              ));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: LayoutBuilder(builder: (context, constrains) {
          return SizedBox(
            width: constrains.maxWidth,
            child: Wrap(
                runSpacing: 8,
                spacing: 8,
                alignment: WrapAlignment.spaceEvenly,
                children: RandomWallpaperAPI.values.map(
                  (provider) {
                    return SizedBox(
                      width: 170,
                      height: 200,
                      child: Card(
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WallpaperProviderView(
                                  provider: provider,
                                  isPictureOfTheDay: POD.contains(provider),
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                AspectRatio(
                                  aspectRatio: 1,
                                  child: Image.asset(
                                    brandImages[provider]!,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                Text(
                                  toCapitalCase(provider.name),
                                  style: Theme.of(context).textTheme.headline6,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ).toList()),
          );
        }),
      ),
    );
  }
}
