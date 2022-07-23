import 'package:collection/collection.dart';

extension StringSelector<T, R> on Map<T, R> {
  R? getNestedProperty(String selector) {
    dynamic result;

    selector.split(".").forEachIndexed((index, key) {
      if (index == 0 && containsKey(key)) {
        result = this[key];
      } else if (result is List && result.isNotEmpty) {
        final keyAsInt = int.tryParse(key);
        if (keyAsInt != null && result[keyAsInt] != null) {
          result = result[keyAsInt];
        } else if (key == "\$") {
          result.shuffle();
          result = result.first;
        }
      } else if (result is Map && result.containsKey(key)) {
        result = result[key];
      }
    });

    if (result is! R) return null;
    return result as R;
  }
}
