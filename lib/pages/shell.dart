import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:wallywiz/components/shared/page_window_title_bar.dart';
import 'package:wallywiz/components/shell/custom_adaptive_scaffold.dart';

class ShellRoutePage extends HookWidget {
  final Widget child;
  const ShellRoutePage({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final index = useState(0);

    return CustomAdaptiveScaffold(
      destinations: const [
        // Categories
        NavigationDestination(
          icon: Icon(Icons.category_outlined),
          label: "Categories",
          selectedIcon: Icon(Icons.category_rounded),
        ),
        // trending
        NavigationDestination(
          icon: Icon(Icons.trending_up_rounded),
          label: "Trending",
        ),
        // latest
        NavigationDestination(
          icon: Icon(Icons.new_releases_outlined),
          label: "Latest",
          selectedIcon: Icon(Icons.new_releases_rounded),
        ),
      ],
      appBar: PageWindowTitleBar(
        scrolledUnderElevation: 0,
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
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              GoRouter.of(context).push("/settings");
            },
          ),
        ],
      ),
      body: child,
      selectedIndex: index.value,
      onDestinationSelected: (newIndex) {
        index.value = newIndex;
        switch (newIndex) {
          case 0:
            GoRouter.of(context).go("/");
            break;
          case 1:
            GoRouter.of(context).go("/trending");
            break;
          case 2:
            GoRouter.of(context).go("/latest");
            break;
        }
      },
    );
  }
}
