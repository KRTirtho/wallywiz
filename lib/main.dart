import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// list of wallpaper sources
// - unsplash
// - pexels
// - dicebear
// - unsplash
// - pixabay
// - NASA picture of the day
// - Bing picture of the day (https://bing.biturl.top)
// - Anime wallpaper grabber

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
