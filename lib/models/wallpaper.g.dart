// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallpaper.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Wallpaper _$WallpaperFromJson(Map<String, dynamic> json) => Wallpaper(
      id: json['id'] as String,
      remoteId: json['remote_id'] as String,
      remoteApi: json['remote_api'] as String,
      createdAt: Wallpaper._fromJson(json['created_at'] as String),
      updatedAt: Wallpaper._fromJson(json['updated_at'] as String),
      orientation: json['orientation'] as String,
      url: json['url'] as String,
      hdUrl: json['hd_url'] as String,
      thumbnail: json['thumbnail'] as String,
      authorName: json['author_name'] as String,
      authorUrl: json['author_url'] as String,
      categoryId: json['category_id'] as String,
    );

Map<String, dynamic> _$WallpaperToJson(Wallpaper instance) => <String, dynamic>{
      'id': instance.id,
      'remote_id': instance.remoteId,
      'remote_api': instance.remoteApi,
      'created_at': Wallpaper._toJson(instance.createdAt),
      'updated_at': Wallpaper._toJson(instance.updatedAt),
      'orientation': instance.orientation,
      'url': instance.url,
      'hd_url': instance.hdUrl,
      'thumbnail': instance.thumbnail,
      'author_name': instance.authorName,
      'author_url': instance.authorUrl,
      'category_id': instance.categoryId,
    };
