import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallywiz/components/CreateWallpaperProvider/CreateWallpaperProviderView.dart';

const kKeyBoxName = "wallywiz_box_name";
String getBoxKey(String boxName) => "wallywiz_box_$boxName";

abstract class PersistedStateNotifier<T> extends StateNotifier<T> {
  final String cacheKey;
  final bool encrypted;

  FutureOr<void> onInit() {}

  PersistedStateNotifier(
    super.state,
    this.cacheKey, {
    this.encrypted = false,
  }) {
    _load().then((_) => onInit());
  }

  static late LazyBox _box;
  static late LazyBox _encryptedBox;

  static Future<String?> read(String key) async {
    final localStorage = await SharedPreferences.getInstance();
    return localStorage.getString(key);
  }

  static Future<void> write(String key, String value) async {
    final localStorage = await SharedPreferences.getInstance();
    await localStorage.setString(key, value);
  }

  static Future<void> initializeBoxes({required String path}) async {
    String? boxName = await read(kKeyBoxName);

    if (boxName == null) {
      boxName = "wallywiz-${uuid.v4()}";
      await write(kKeyBoxName, boxName);
    }

    String? encryptionKey = await read(getBoxKey(boxName));

    if (encryptionKey == null) {
      encryptionKey = base64Url.encode(Hive.generateSecureKey());
      await write(getBoxKey(boxName), encryptionKey);
    }

    _encryptedBox = await Hive.openLazyBox(
      boxName,
      encryptionCipher: HiveAesCipher(base64Url.decode(encryptionKey)),
    );

    _box = await Hive.openLazyBox(
      "wallywiz_cache",
      path: path,
    );
  }

  LazyBox get box => encrypted ? _encryptedBox : _box;

  Future<void> _load() async {
    final json = await box.get(cacheKey);

    if (json != null) {
      state = await fromJson(castNestedJson(json));
    }
  }

  Map<String, dynamic> castNestedJson(Map map) {
    return Map.castFrom<dynamic, dynamic, String, dynamic>(
      map.map((key, value) {
        if (value is Map) {
          return MapEntry(
            key,
            castNestedJson(value),
          );
        } else if (value is Iterable) {
          return MapEntry(
            key,
            value.map((e) {
              if (e is Map) return castNestedJson(e);
              return e;
            }).toList(),
          );
        }
        return MapEntry(key, value);
      }),
    );
  }

  void save() async {
    await box.put(cacheKey, toJson());
  }

  FutureOr<T> fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();

  @override
  set state(T value) {
    if (state == value) return;
    super.state = value;
    save();
  }
}
