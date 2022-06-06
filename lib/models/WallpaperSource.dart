enum WallpaperImageType { jpg, png }

class WallpaperSource {
  final String id;
  final String name;
  final String url;
  final String jsonAccessor;
  final Map<String, dynamic> headers;
  final WallpaperImageType imageType;
  WallpaperSource({
    required this.id,
    required this.jsonAccessor,
    required this.name,
    required this.url,
    this.imageType = WallpaperImageType.jpg,
    this.headers = const {},
  });

  List<String> get propertyAccessors => jsonAccessor.split(".");

  WallpaperSource.fromJson(Map<String, dynamic> map)
      : id = map["id"],
        jsonAccessor = map["jsonAccessor"],
        name = map["name"],
        url = map["url"],
        imageType = WallpaperImageType
            .values[map["imageType"] ?? WallpaperImageType.jpg.index],
        headers = map["headers"] ?? {};

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "jsonAccessor": jsonAccessor,
      "name": name,
      "url": url,
      "imageType": imageType.index,
      "headers": headers
    };
  }
}
