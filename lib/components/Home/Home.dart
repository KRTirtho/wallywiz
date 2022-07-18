import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wallywiz/components/Settings/Settings.dart';
import 'package:wallywiz/components/CreateWallpaperProvider/CreateWallpaperProviderView.dart';
import 'package:wallywiz/components/shared/MarqueeText.dart';
import 'package:wallywiz/components/WallpaperSupplierView/WallpaperSupplierView.dart';
import 'package:wallywiz/helpers/toCapitalCase.dart';
import 'package:wallywiz/providers/wallpaper-provider.dart';

class Home extends HookConsumerWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final wallpaperSources =
        ref.watch(wallpaperProvider.select((s) => s.wallpaperSources));
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SingleChildScrollView(
        child: LayoutBuilder(builder: (context, constrains) {
          return SizedBox(
            width: constrains.maxWidth,
            child: Wrap(
                runSpacing: 8,
                spacing: 8,
                alignment: WrapAlignment.spaceEvenly,
                children: wallpaperSources.map(
                  (wallpaperSource) {
                    return SizedBox(
                      width: 170,
                      height: 200,
                      child: Card(
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WallpaperSupplierView(
                                  wallpaperSource: wallpaperSource,
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
                                  child: wallpaperSource.logoSource
                                          .startsWith("http")
                                      ? Image.network(
                                          wallpaperSource.logoSource,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.file(
                                          File(wallpaperSource.logoSource),
                                          fit: BoxFit.cover,
                                        ),
                                ),
                                Flexible(
                                  child: MarqueeText(
                                    text: toCapitalCase(wallpaperSource.name),
                                    style:
                                        Theme.of(context).textTheme.headline6,
                                    staticLimit: 10,
                                  ),
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
