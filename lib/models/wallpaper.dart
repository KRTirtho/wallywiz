import 'package:json_annotation/json_annotation.dart';

part 'wallpaper.g.dart';

@JsonSerializable()
class Wallpaper {
  late final String id;

  @JsonKey(name: 'remote_id')
  late final String remoteId;
  @JsonKey(name: 'remote_api')
  late final String remoteApi;

  static DateTime _fromJson(String date) => DateTime.parse(date);
  static String _toJson(DateTime date) => date.toIso8601String();

  @JsonKey(
    name: 'created_at',
    toJson: Wallpaper._toJson,
    fromJson: Wallpaper._fromJson,
  )
  late final DateTime createdAt;

  @JsonKey(
    name: 'updated_at',
    toJson: Wallpaper._toJson,
    fromJson: Wallpaper._fromJson,
  )
  late final DateTime updatedAt;

  late final String orientation;
  late final String url;

  @JsonKey(name: 'hd_url')
  late final String hdUrl;

  late final String thumbnail;

  @JsonKey(name: 'author_name')
  late final String authorName;
  @JsonKey(name: 'author_url')
  late final String authorUrl;
  @JsonKey(name: 'category_id')
  late final String categoryId;

  Wallpaper({
    required this.id,
    required this.remoteId,
    required this.remoteApi,
    required this.createdAt,
    required this.updatedAt,
    required this.orientation,
    required this.url,
    required this.hdUrl,
    required this.thumbnail,
    required this.authorName,
    required this.authorUrl,
    required this.categoryId,
  });

  factory Wallpaper.fromJson(Map<String, dynamic> json) =>
      _$WallpaperFromJson(json);

  Map<String, dynamic> toJson() => _$WallpaperToJson(this);
}
