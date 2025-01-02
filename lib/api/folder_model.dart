import 'package:json_annotation/json_annotation.dart';

import 'breadcrumb.dart';
import 'content.dart';

part 'folder_model.g.dart';

@JsonSerializable(explicitToJson: true)
class FolderModel {
  final String status;
  final List<Content> content;
  final List<Breadcrumb> breadcrumbs;
  final String name;
  final String parentId;
  final String folderId;

  FolderModel({
    required this.status,
    required this.content,
    required this.breadcrumbs,
    required this.name,
    required this.parentId,
    required this.folderId,
  });

  factory FolderModel.fromJson(Map<String, dynamic> json) => _$FolderModelFromJson(json);
  Map<String, dynamic> toJson() => _$FolderModelToJson(this);
}
