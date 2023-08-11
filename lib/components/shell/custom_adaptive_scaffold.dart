import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_side_menu/flutter_side_menu.dart';

class CustomAdaptiveScaffold extends HookWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavigationDestination> destinations;
  final Widget body;
  final PreferredSizeWidget? appBar;

  const CustomAdaptiveScaffold({
    Key? key,
    required this.onDestinationSelected,
    required this.selectedIndex,
    required this.destinations,
    required this.body,
    this.appBar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final navRailTheme = theme.navigationRailTheme;

    // AdaptiveLayout has a number of slots that take SlotLayouts and these
    // SlotLayouts' configs take maps of Breakpoints to SlotLayoutConfigs.
    return Scaffold(
      appBar: appBar,
      body: AdaptiveLayout(
        // Primary navigation config has nothing from 0 to 600 dp screen width,
        // then an unextended NavigationRail with no labels and just icons then an
        // extended NavigationRail with both icons and labels.
        internalAnimations: false,
        primaryNavigation: SlotLayout(
          config: <Breakpoint, SlotLayoutConfig>{
            Breakpoints.medium: SlotLayout.from(
              inAnimation: AdaptiveScaffold.leftOutIn,
              key: const Key('Primary Navigation Medium'),
              builder: (_) => AdaptiveScaffold.standardNavigationRail(
                selectedIndex: selectedIndex,
                onDestinationSelected: onDestinationSelected,
                destinations: destinations
                    .map((_) => AdaptiveScaffold.toRailDestination(_))
                    .toList(),
                backgroundColor: navRailTheme.backgroundColor,
                selectedIconTheme: navRailTheme.selectedIconTheme,
                unselectedIconTheme: navRailTheme.unselectedIconTheme,
                selectedLabelTextStyle: navRailTheme.selectedLabelTextStyle,
                unSelectedLabelTextStyle: navRailTheme.unselectedLabelTextStyle,
              ),
            ),
            Breakpoints.large: SlotLayout.from(
              key: const Key('Primary Navigation Large'),
              builder: (context) {
                return SideMenu(
                  mode: SideMenuMode.open,
                  hasResizer: false,
                  hasResizerToggle: false,
                  maxWidth: 200,
                  builder: (data) {
                    return SideMenuData(
                      items: [
                        for (var destination in destinations)
                          SideMenuItemDataTile(
                            title: destination.label,
                            icon: destination.icon,
                            isSelected: selectedIndex ==
                                destinations.indexOf(destination),
                            selectedIcon: destination.selectedIcon,
                            borderRadius: BorderRadius.circular(7),
                            highlightSelectedColor: Colors.transparent,
                            selectedTitleStyle: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                            onTap: () {
                              onDestinationSelected(
                                destinations.indexOf(destination),
                              );
                            },
                          )
                      ],
                    );
                  },
                );
              },
            ),
          },
        ),
        // Body switches between a ListView and a GridView from small to medium
        // breakpoints and onwards.
        body: SlotLayout(
          config: <Breakpoint, SlotLayoutConfig>{
            Breakpoints.small: SlotLayout.from(
              key: const Key('Body Small'),
              builder: (_) => body,
            ),
            Breakpoints.mediumAndUp: SlotLayout.from(
              key: const Key('Body Medium'),
              builder: (_) => body,
            )
          },
        ),
        // BottomNavigation is only active in small views defined as under 600 dp
        // width.
        bottomNavigation: SlotLayout(
          config: <Breakpoint, SlotLayoutConfig>{
            Breakpoints.small: SlotLayout.from(
              key: const Key('Bottom Navigation Small'),
              inAnimation: AdaptiveScaffold.bottomToTop,
              outAnimation: AdaptiveScaffold.topToBottom,
              builder: (_) => FlashyTabBar(
                selectedIndex: selectedIndex,
                onItemSelected: onDestinationSelected,
                items: [
                  for (var destination in destinations)
                    FlashyTabBarItem(
                      icon: destination.icon,
                      title: Text(destination.label),
                      activeColor: theme.colorScheme.primary,
                      inactiveColor: theme.colorScheme.secondary,
                    )
                ],
                height: 55,
              ),
            )
          },
        ),
      ),
    );
  }
}
