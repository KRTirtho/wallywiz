import 'package:json_annotation/json_annotation.dart';

part 'category.g.dart';

@JsonSerializable()
class Category {
  late final String id;

  @JsonKey(name: 'remote_id')
  late final String remoteId;
  @JsonKey(name: 'remote_api')
  late final String remoteApi;

  static DateTime _fromJson(String date) => DateTime.parse(date);
  static String _toJson(DateTime date) => date.toIso8601String();

  @JsonKey(
    name: 'created_at',
    toJson: Category._toJson,
    fromJson: Category._fromJson,
  )
  late final DateTime createdAt;

  @JsonKey(
    name: 'updated_at',
    toJson: Category._toJson,
    fromJson: Category._fromJson,
  )
  late final DateTime updatedAt;

  late final String title;

  Category({
    required this.id,
    required this.remoteId,
    required this.remoteApi,
    required this.createdAt,
    required this.updatedAt,
    required this.title,
  });

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}
