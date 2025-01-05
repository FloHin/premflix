import 'package:json_annotation/json_annotation.dart';

import '../service/item_config.dart';
import 'breadcrumb.dart';
import 'item.dart';

part 'folder_response.g.dart';

@JsonSerializable(explicitToJson: true)
class FolderResponse {
  final String? status;
  final List<Item>? content;
  final List<Breadcrumb>? breadcrumbs;
  final String? name;
  final String? parentId;
  String? folderId;
  ItemConfig? config;

  FolderResponse({
    required this.status,
    required this.content,
    required this.breadcrumbs,
    this.name,
    this.parentId,
    this.folderId,
  });

  FolderResponse copyWith({ItemConfig? config}) {
    return this..config = config;
  }

  factory FolderResponse.fromJson(Map<String, dynamic> json) => _$FolderResponseFromJson(json);
  Map<String, dynamic> toJson() => _$FolderResponseToJson(this);
}
