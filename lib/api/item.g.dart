// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Item _$ItemFromJson(Map<String, dynamic> json) => Item(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      size: (json['size'] as num?)?.toInt(),
      createdAt: (json['createdAt'] as num?)?.toInt(),
      mimeType: json['mimeType'] as String?,
      transcodeStatus: json['transcodeStatus'] as String?,
      link: json['link'] as String?,
      streamLink: json['streamLink'] as String?,
      directlink: json['directlink'] as String?,
      virusScan: json['virusScan'] as String?,
      config: json['config'] == null
          ? null
          : ItemConfig.fromJson(json['config'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ItemToJson(Item instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'size': instance.size,
      'createdAt': instance.createdAt,
      'mimeType': instance.mimeType,
      'transcodeStatus': instance.transcodeStatus,
      'link': instance.link,
      'streamLink': instance.streamLink,
      'directlink': instance.directlink,
      'virusScan': instance.virusScan,
      'config': instance.config,
    };
