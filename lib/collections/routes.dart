import 'package:go_router/go_router.dart';
import 'package:wallywiz/models/category.dart';
import 'package:wallywiz/pages/categories/category/wallpaper.dart';
import 'package:wallywiz/pages/home.dart';
import 'package:wallywiz/pages/settings.dart';

final router = GoRouter(initialLocation: "/", routes: [
  GoRoute(
    path: "/",
    builder: (context, state) {
      return const Home();
    },
    routes: [
      GoRoute(
        path: "categories/:categoryId/wallpapers",
        builder: (context, state) {
          return WallpaperPage(
            category: state.extra as Category,
          );
        },
      )
    ],
  ),
  GoRoute(
    path: "/settings",
    builder: (context, state) {
      return const Settings();
    },
  )
]);
