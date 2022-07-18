enum WallpaperImageType { jpg, png }

class WallpaperSource {
  final String id;
  final String name;
  final String url;
  final String jsonAccessor;
  final Map<String, dynamic> headers;
  final WallpaperImageType imageType;
  final bool isOfficial;

  /// This can be a base64 encoded image String or a path to image
  late final String logoSource;
  WallpaperSource({
    required this.id,
    required this.jsonAccessor,
    required this.name,
    required this.url,
    required this.isOfficial,

    /// This can be a base64 encoded image String or a path to image
    String? logoSource,
    this.imageType = WallpaperImageType.jpg,
    this.headers = const {},
  }) {
    this.logoSource =
        logoSource ?? "https://avatars.dicebear.com/api/identicon/$name.png";
  }

  List<String> get propertyAccessors => jsonAccessor.split(".");

  WallpaperSource.fromJson(Map<String, dynamic> map)
      : id = map["id"],
        jsonAccessor = map["jsonAccessor"],
        name = map["name"],
        url = map["url"],
        imageType = WallpaperImageType
            .values[map["imageType"] ?? WallpaperImageType.jpg.index],
        isOfficial = map["isOfficial"] ?? false,
        headers = map["headers"] ?? {} {
    logoSource = map["logoSource"] ??
        "https://avatars.dicebear.com/api/identicon/$name.png";
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "jsonAccessor": jsonAccessor,
      "name": name,
      "url": url,
      "imageType": imageType.index,
      "headers": headers,
      "logoSource": logoSource,
      "isOfficial": isOfficial,
    };
  }
}
