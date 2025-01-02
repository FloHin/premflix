import 'package:json_annotation/json_annotation.dart';

part 'content.g.dart';

@JsonSerializable()
class Content {
  final String id;
  final String name;
  final String type;
  final int size;
  final int createdAt;
  final String mimeType;
  final String transcodeStatus;
  final String link;
  final String streamLink;
  final String virusScan;

  Content({
    required this.id,
    required this.name,
    required this.type,
    required this.size,
    required this.createdAt,
    required this.mimeType,
    required this.transcodeStatus,
    required this.link,
    required this.streamLink,
    required this.virusScan,
  });

  factory Content.fromJson(Map<String, dynamic> json) => _$ContentFromJson(json);
  Map<String, dynamic> toJson() => _$ContentToJson(this);
}
