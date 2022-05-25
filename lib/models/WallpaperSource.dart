class WallpaperSource {
  final String id;
  final String name;
  final String url;
  final String jsonAccessor;
  WallpaperSource({
    required this.id,
    required this.jsonAccessor,
    required this.name,
    required this.url,
  });

  List<String> get propertyAccessors => jsonAccessor.split(".");

  WallpaperSource.fromJson(Map<String, dynamic> map)
      : id = map["id"],
        jsonAccessor = map["jsonAccessor"],
        name = map["name"],
        url = map["url"];

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "jsonAccessor": jsonAccessor,
      "name": name,
      "url": url,
    };
  }
}
