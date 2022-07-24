import 'package:wallywiz/extensions/map.dart';

extension StringSelector<T> on List<T> {
  T? getNestedProperty(String selector) {
    final Map map = {"data": this};
    return map.getNestedProperty("data.$selector");
  }
}
