import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wallywiz/models/category.dart';
import 'package:wallywiz/pages/categories/category/wallpaper.dart';
import 'package:wallywiz/pages/home.dart';
import 'package:wallywiz/pages/latest.dart';
import 'package:wallywiz/pages/settings.dart';
import 'package:wallywiz/pages/shell.dart';
import 'package:wallywiz/pages/trending.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final shellNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  initialLocation: "/",
  navigatorKey: rootNavigatorKey,
  routes: [
    ShellRoute(
      navigatorKey: shellNavigatorKey,
      routes: [
        GoRoute(
          path: "/",
          builder: (context, state) => const Home(),
        ),
        GoRoute(
          path: "/trending",
          builder: (context, state) => const TrendingPage(),
        ),
        GoRoute(
          path: "/latest",
          builder: (context, state) => const LatestPage(),
        ),
      ],
      builder: (context, state, child) => ShellRoutePage(child: child),
    ),
    GoRoute(
      path: "/categories/:categoryId/wallpapers",
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        return WallpaperPage(
          category: state.extra as Category,
        );
      },
    ),
    GoRoute(
      path: "/settings",
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        return const Settings();
      },
    )
  ],
);
