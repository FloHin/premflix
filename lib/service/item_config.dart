import 'package:json_annotation/json_annotation.dart';

part 'item_config.g.dart';


@JsonSerializable()
class ItemConfig {
  String id;
  bool starred;
  bool hidden;
  DateTime? clickedAt;
  DateTime? openedAt;

  ItemConfig(
    this.id, {
    this.starred = false,
    this.hidden = false,
    this.clickedAt,
    this.openedAt,
  });

  ItemConfig copyWith({
    bool? starred,
    bool? hidden,
    DateTime? clickedAt,
    DateTime? openedAt,
  }) {
    return ItemConfig(
      id,
      starred: starred ?? this.starred,
      hidden: hidden ?? this.hidden,
      clickedAt: clickedAt ?? this.clickedAt,
      openedAt: openedAt ?? this.openedAt,
    );
  }
  factory ItemConfig.fromJson(Map<String, dynamic> json) => _$ItemConfigFromJson(json);

  Map<String, dynamic> toJson() => _$ItemConfigToJson(this);
}
