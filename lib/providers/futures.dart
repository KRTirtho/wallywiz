import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:riverpod/riverpod.dart';
import 'package:wallywiz/models/WallpaperSource.dart';
import 'package:wallywiz/extensions/map.dart';

final dio = Dio(BaseOptions(responseType: ResponseType.json));
final wallpaperQuery = FutureProvider.family<Map, String>(
  (ref, arg) async {
    final source = WallpaperSource.fromJson(jsonDecode(arg));
    final res = (await dio.get(
      source.url,
      options: Options(
        headers: source.headers,
      ),
    ))
        .data as Map;

    final imageURL = res.getNestedProperty(source.jsonAccessor);

    return {"response": res, "image": imageURL};
  },
);
