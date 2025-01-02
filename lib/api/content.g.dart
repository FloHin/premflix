// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Content _$ContentFromJson(Map<String, dynamic> json) => Content(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      size: (json['size'] as num).toInt(),
      createdAt: (json['createdAt'] as num).toInt(),
      mimeType: json['mimeType'] as String,
      transcodeStatus: json['transcodeStatus'] as String,
      link: json['link'] as String,
      streamLink: json['streamLink'] as String,
      virusScan: json['virusScan'] as String,
    );

Map<String, dynamic> _$ContentToJson(Content instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'size': instance.size,
      'createdAt': instance.createdAt,
      'mimeType': instance.mimeType,
      'transcodeStatus': instance.transcodeStatus,
      'link': instance.link,
      'streamLink': instance.streamLink,
      'virusScan': instance.virusScan,
    };
