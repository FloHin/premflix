// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ItemConfig _$ItemConfigFromJson(Map<String, dynamic> json) => ItemConfig(
      json['id'] as String,
      starred: json['starred'] as bool? ?? false,
      hidden: json['hidden'] as bool? ?? false,
      clickedAt: json['clickedAt'] == null
          ? null
          : DateTime.parse(json['clickedAt'] as String),
      openedAt: json['openedAt'] == null
          ? null
          : DateTime.parse(json['openedAt'] as String),
    );

Map<String, dynamic> _$ItemConfigToJson(ItemConfig instance) =>
    <String, dynamic>{
      'id': instance.id,
      'starred': instance.starred,
      'hidden': instance.hidden,
      'clickedAt': instance.clickedAt?.toIso8601String(),
      'openedAt': instance.openedAt?.toIso8601String(),
    };
