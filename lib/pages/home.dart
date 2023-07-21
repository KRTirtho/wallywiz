import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wallywiz/components/CreateWallpaperProvider/CreateWallpaperProviderView.dart';
import 'package:wallywiz/components/home/CategoryCard.dart';
import 'package:wallywiz/components/shared/page_window_title_bar.dart';
import 'package:wallywiz/components/shared/waypoint.dart';
import 'package:wallywiz/providers/wallpaper-provider.dart';
import 'package:wallywiz/services/queries.dart';

class Home extends HookConsumerWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final wallpapers = ref.watch(wallpaperProvider);
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

    return SafeArea(
      child: Scaffold(
        appBar: PageWindowTitleBar(
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SvgPicture.asset(
              "assets/logo.svg",
              width: 100,
              height: 100,
            ),
          ),
          titleSpacing: 0,
          title: const Text("WallyWiz"),
          centerTitle: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.restart_alt_rounded),
              tooltip: "Refresh Wallpaper now!",
              onPressed: () {
                wallpapers.refreshWallpaper();
              },
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () {
                GoRouter.of(context).go("/settings");
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
      ),
    );
  }
}
