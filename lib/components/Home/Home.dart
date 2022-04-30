import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wallywiz/components/shared/WallpaperProviderView.dart';
import 'package:wallywiz/helpers/toCapitalCase.dart';
import 'package:wallywiz/providers/wallpaper-provider.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text("WallyWiz"), centerTitle: false),
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
                      height: 250,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
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
                              TextButton(
                                child: const Text("View"),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          WallpaperProviderView(
                                        provider: provider,
                                      ),
                                    ),
                                  );
                                },
                              )
                            ],
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
