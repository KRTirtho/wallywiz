import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:wallywiz/providers/futures.dart';

List<String> filter(rawData) {
  List<String> properties = [];

  final List<MapEntry> data =
      (rawData is Map ? rawData.entries : (rawData as List).asMap().entries)
          .toList();

  for (final entry in data) {
    if (entry.value is String &&
        Uri.tryParse(entry.value)?.hasAbsolutePath == true) {
      properties.add(entry.key);
    } else if (entry.value is Map || entry.value is List) {
      final d2properties = filter(entry.value);
      if (d2properties.isEmpty) continue;

      // final noIndexProperties = Set.from(d2properties.map((e) {
      //   final s = e.split(".");
      //   if (int.tryParse(s.first) != null) {
      //     s.removeAt(0);
      //     return s.join(".");
      //   }
      //   return e;
      // })).toList();

      // when value is List and if every property is equal or list has
      // single element use the '$' randomize selector
      // if (entry.value is List) {
      //   properties.add("${entry.key}.\$.${noIndexProperties.first}");
      // }
      properties.addAll(d2properties.map((e) => "${entry.key}.$e"));
    }
  }

  return properties
      .map(
        (p) => p
            .replaceAll(RegExp(r'\.\d+\.'), ".\$.")
            .replaceAll(RegExp(r'\d+\.'), "\$.")
            .replaceAll(RegExp(r'\.\d+'), ".\$"),
      )
      .toSet()
      .toList();
}

AsyncSnapshot<List> useJsonUrlFilter(String url, Map headers) {
  return useFuture(
    useMemoized(
      () => dio
          .get(url,
              options: Options(
                headers: Map.castFrom(headers),
                responseType: ResponseType.json,
              ))
          .then((data) {
        if (data.data is List) {
          return [
            filter(data.data).map((s) => "data.$s").toList(),
            {"data": data.data}
          ];
        }
        return [filter(data.data), data.data];
      }),
      [url],
    ),
  );
}
