import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:wallywiz/hooks/useJsonUrlFilter.dart';
import 'package:wallywiz/extensions/map.dart';
import 'package:collection/collection.dart';

class JsonPropertyPicker extends HookWidget {
  final String url;
  final Map headers;
  const JsonPropertyPicker({
    required this.url,
    required this.headers,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final snapshot = useJsonUrlFilter(url, headers);

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 30),
      contentPadding: const EdgeInsets.all(10),
      title: const Text("Pick the relevant property"),
      content: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: ListView(
          children: [
            const Text("This is all available URL properties"),
            if (!snapshot.hasData)
              const Center(child: CircularProgressIndicator())
            else
              ...snapshot.data!.first.map((path) {
                final value =
                    (snapshot.data!.last as Map).getNestedProperty(path);
                if (value is String &&
                    Uri.tryParse(value)?.hasAbsolutePath == true &&
                    value.startsWith("http")) {
                  final List segments = path.split('.');
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.brown[700]
                          : Colors.amber[50],
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.deepOrange[900]!
                            : Colors.orange,
                        width: 2,
                      ),
                    ),
                    child: Material(
                      type: MaterialType.transparency,
                      child: ListTile(
                        title: Wrap(
                          children: segments.mapIndexed((i, segment) {
                            if (i == segments.length - 1) return Text(segment);
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(segment),
                                const Icon(Icons.keyboard_arrow_right_rounded)
                              ],
                            );
                          }).toList(),
                        ),
                        subtitle: Text(value),
                        onTap: () {
                          Navigator.pop(context, path);
                        },
                      ),
                    ),
                  );
                }
                return Container();
              }).toList()
          ],
        ),
      ),
    );
  }
}
