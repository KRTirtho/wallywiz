import 'package:go_router/go_router.dart';
import 'package:wallywiz/pages/home.dart';
import 'package:wallywiz/pages/settings.dart';

final router = GoRouter(initialLocation: "/", routes: [
  GoRoute(
    path: "/",
    builder: (context, state) {
      return const Home();
    },
  ),
  GoRoute(
    path: "/settings",
    builder: (context, state) {
      return const Settings();
    },
  )
]);
