import 'package:json_annotation/json_annotation.dart';

import 'breadcrumb.dart';
import 'content.dart';

part 'folder_response.g.dart';

@JsonSerializable(explicitToJson: true)
class FolderResponse {
  final String? status;
  final List<Content>? content;
  final List<Breadcrumb>? breadcrumbs;
  final String? name;
  final String? parentId;
  final String? folderId;

  FolderResponse({
    required this.status,
    required this.content,
    required this.breadcrumbs,
    this.name,
    this.parentId,
    this.folderId,
  });

  factory FolderResponse.fromJson(Map<String, dynamic> json) => _$FolderResponseFromJson(json);
  Map<String, dynamic> toJson() => _$FolderResponseToJson(this);
}
