// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'folder_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FolderModel _$FolderModelFromJson(Map<String, dynamic> json) => FolderModel(
      status: json['status'] as String,
      content: (json['content'] as List<dynamic>)
          .map((e) => Content.fromJson(e as Map<String, dynamic>))
          .toList(),
      breadcrumbs: (json['breadcrumbs'] as List<dynamic>)
          .map((e) => Breadcrumb.fromJson(e as Map<String, dynamic>))
          .toList(),
      name: json['name'] as String,
      parentId: json['parentId'] as String,
      folderId: json['folderId'] as String,
    );

Map<String, dynamic> _$FolderModelToJson(FolderModel instance) =>
    <String, dynamic>{
      'status': instance.status,
      'content': instance.content.map((e) => e.toJson()).toList(),
      'breadcrumbs': instance.breadcrumbs.map((e) => e.toJson()).toList(),
      'name': instance.name,
      'parentId': instance.parentId,
      'folderId': instance.folderId,
    };
