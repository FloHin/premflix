import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import '../service/item_config.dart';

part 'item.g.dart';

@JsonSerializable()
class Item {
  final String id;
  final String name;
  final String type;
  final int? size;
  final int? createdAt;
  final String? mimeType;
  final String? transcodeStatus;
  final String? link;
  final String? streamLink;
  final String? directlink;
  final String? virusScan;
  String? folderId;
  ItemConfig? config;

  Item({
    required this.id,
    required this.name,
    required this.type,
    this.size,
    this.createdAt,
    this.mimeType,
    this.transcodeStatus,
    this.link,
    this.streamLink,
    this.directlink,
    this.virusScan,
    this.config,
    this.folderId,
  });

  Item copyWith({ItemConfig? config}) {
    return this..config = config;
  }

  IconData getIcon() {
    if (type == "folder") {
      return Icons.folder;
    }
    if (mimeType?.contains("video") ?? false) {
      return Icons.ondemand_video;
    }
    if (link != null) {
      if (link!.endsWith(".mp4") || link!.endsWith(".m4v")) {
        return Icons.ondemand_video;
        // return Icons.video_collection;
      }
    }
    return Icons.question_mark_outlined;
  }

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);

  Map<String, dynamic> toJson() => _$ItemToJson(this);
}
