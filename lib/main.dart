import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wallywiz/components/Home/Home.dart';
import 'package:wallywiz/providers/preferences.dart';
import 'package:wallywiz/services/background_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid || Platform.isIOS) await initBackgroundService();
  runApp(const ProviderScope(child: MyApp()));
}
// list of wallpaper sources
// - unsplash
// - pexels
// - dicebear
// - pixabay
// - flickr
// - NASA picture of the day
// - Bing picture of the day (https://bing.biturl.top)
// - Anime wallpaper grabber

class MyApp extends HookConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final preferences = ref.watch(userPreferencesProvider);
    return MaterialApp(
      title: 'Flutter Demo',
      themeMode: preferences.themeMode,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        inputDecorationTheme: const InputDecorationTheme(
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: .5),
            ),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue, width: 2)),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red, width: 2),
            )),
      ),
      darkTheme: ThemeData.dark().copyWith(
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[900],
        ),
        scaffoldBackgroundColor: Colors.grey[900],
        inputDecorationTheme: const InputDecorationTheme(
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white, width: .5),
          ),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue, width: 2)),
          errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red, width: 2)),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 2),
          ),
        ),
      ),
      home: const Home(),
    );
  }
}
