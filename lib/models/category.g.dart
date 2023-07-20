// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Category _$CategoryFromJson(Map<String, dynamic> json) => Category(
      id: json['id'] as String,
      remoteId: json['remote_id'] as String,
      remoteApi: json['remote_api'] as String,
      createdAt: Category._fromJson(json['created_at'] as String),
      updatedAt: Category._fromJson(json['updated_at'] as String),
      title: json['title'] as String,
    );

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
      'id': instance.id,
      'remote_id': instance.remoteId,
      'remote_api': instance.remoteApi,
      'created_at': Category._toJson(instance.createdAt),
      'updated_at': Category._toJson(instance.updatedAt),
      'title': instance.title,
    };
